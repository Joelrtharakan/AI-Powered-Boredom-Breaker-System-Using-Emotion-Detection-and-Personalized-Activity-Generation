
import os
import pandas as pd
import numpy as np
import torch
import torch.nn as nn

from datasets import Dataset
from transformers import (
    AutoTokenizer,
    AutoModelForSequenceClassification,
    TrainingArguments,
    Trainer,
    EarlyStoppingCallback
)

from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, precision_recall_fscore_support
from sklearn.utils.class_weight import compute_class_weight

# ==============================
# CONFIG
# ==============================

BASE_MODEL = "cardiffnlp/twitter-roberta-base-emotion"
SYNTHETIC_DATA_FILE = "data/emotional_wellness_dataset.csv"
LARGE_DATA_FILE = "/Users/joeltharakan/Documents/AI Boredom System/emotions.csv"
OUTPUT_DIR = "models/fine_tuned_roberta_v3"

BATCH_SIZE = 16
NUM_EPOCHS = 6
SYNTHETIC_MULTIPLIER = 4   # ← FIXED (was 10)

# ==============================
# LOAD SYNTHETIC DATA
# ==============================

print("Loading synthetic dataset...")
df_synthetic = pd.read_csv(SYNTHETIC_DATA_FILE)

# Upsample domain dataset moderately
df_synthetic_upsampled = pd.concat(
    [df_synthetic] * SYNTHETIC_MULTIPLIER,
    ignore_index=True
)

print("Synthetic size:", len(df_synthetic_upsampled))

# ==============================
# LOAD LARGE DATASET
# ==============================

print("Loading large dataset...")
df_large = pd.read_csv(LARGE_DATA_FILE)

label_map = {
    0: "sadness",
    1: "joy",
    2: "love",
    3: "anger",
    4: "fear",
    5: "surprise"
}

df_large["label"] = df_large["label"].map(label_map)

# Balanced sampling
SAMPLES_PER_CATEGORY = 2000

df_large_sampled = (
    df_large
    .groupby("label")
    .apply(lambda x: x.sample(n=min(len(x), SAMPLES_PER_CATEGORY), random_state=42))
    .reset_index(drop=True)
)

print("Large balanced size:", len(df_large_sampled))

# ==============================
# COMBINE DATASETS
# ==============================

df_combined = pd.concat(
    [df_large_sampled, df_synthetic_upsampled],
    ignore_index=True
)

df_combined = df_combined.sample(frac=1, random_state=42).reset_index(drop=True)

print("Combined size:", len(df_combined))
print("Label distribution:")
print(df_combined["label"].value_counts())

# ==============================
# STABLE LABEL MAPPING (CRITICAL)
# ==============================

labels = sorted(df_combined["label"].unique())

label2id = {label: i for i, label in enumerate(labels)}
id2label = {i: label for label, i in label2id.items()}

df_combined["labels"] = df_combined["label"].map(label2id)

# ==============================
# STRATIFIED SPLIT (CRITICAL)
# ==============================

train_df, val_df = train_test_split(
    df_combined,
    test_size=0.1,
    random_state=42,
    stratify=df_combined["labels"]
)

train_dataset = Dataset.from_pandas(train_df)
val_dataset = Dataset.from_pandas(val_df)

# ==============================
# TOKENIZATION
# ==============================

print("Tokenizing...")
tokenizer = AutoTokenizer.from_pretrained(BASE_MODEL)

def tokenize_function(examples):
    return tokenizer(
        examples["text"],
        padding="max_length",
        truncation=True,
        max_length=128
    )

tokenized_train = train_dataset.map(tokenize_function, batched=True)
tokenized_val = val_dataset.map(tokenize_function, batched=True)

cols_to_remove = [
    col for col in tokenized_train.column_names
    if col not in ["input_ids", "attention_mask", "labels"]
]

tokenized_train = tokenized_train.remove_columns(cols_to_remove)
tokenized_val = tokenized_val.remove_columns(cols_to_remove)

tokenized_train.set_format("torch")
tokenized_val.set_format("torch")

# ==============================
# MODEL
# ==============================

print("Loading model...")

model = AutoModelForSequenceClassification.from_pretrained(
    BASE_MODEL,
    num_labels=len(labels),
    id2label=id2label,
    label2id=label2id,
    ignore_mismatched_sizes=True
)

# ==============================
# CLASS WEIGHTS (MAJOR IMPROVEMENT)
# ==============================

class_weights = compute_class_weight(
    class_weight="balanced",
    classes=np.unique(df_combined["labels"]),
    y=df_combined["labels"]
)

class_weights = torch.tensor(class_weights, dtype=torch.float)

# Custom Trainer with weighted loss
class WeightedTrainer(Trainer):
    def compute_loss(self, model, inputs, return_outputs=False, **kwargs):
        labels = inputs.get("labels")
        outputs = model(**inputs)
        logits = outputs.get("logits")
        loss_fn = nn.CrossEntropyLoss(weight=class_weights.to(model.device))
        loss = loss_fn(logits, labels)
        return (loss, outputs) if return_outputs else loss

# ==============================
# METRICS
# ==============================

def compute_metrics(eval_pred):
    logits, labels = eval_pred
    predictions = np.argmax(logits, axis=-1)

    precision, recall, f1, _ = precision_recall_fscore_support(
        labels,
        predictions,
        average="weighted",
        zero_division=0
    )

    acc = accuracy_score(labels, predictions)

    return {
        "accuracy": acc,
        "f1": f1,
        "precision": precision,
        "recall": recall
    }

# ==============================
# TRAINING ARGUMENTS
# ==============================

training_args = TrainingArguments(
    output_dir=OUTPUT_DIR,
    eval_strategy="epoch",
    save_strategy="epoch",
    learning_rate=2e-5,
    per_device_train_batch_size=BATCH_SIZE,
    per_device_eval_batch_size=BATCH_SIZE,
    num_train_epochs=NUM_EPOCHS,
    weight_decay=0.01,
    logging_dir=f"{OUTPUT_DIR}/logs",
    logging_steps=50,
    load_best_model_at_end=True,
    metric_for_best_model="f1",
    save_total_limit=1,
    use_cpu=True   # change to False if GPU available
)

# ==============================
# TRAINER
# ==============================

trainer = WeightedTrainer(
    model=model,
    args=training_args,
    train_dataset=tokenized_train,
    eval_dataset=tokenized_val,
    compute_metrics=compute_metrics,
    callbacks=[EarlyStoppingCallback(early_stopping_patience=2)]
)

# ==============================
# TRAIN
# ==============================

print("Starting training...")
trainer.train()

# ==============================
# SAVE MODEL
# ==============================

print("Saving model...")
trainer.save_model(OUTPUT_DIR)
tokenizer.save_pretrained(OUTPUT_DIR)

print("Model saved to:", OUTPUT_DIR)

print("\nFinal Labels:")
for i, lbl in id2label.items():
    print(i, "→", lbl)

print("\nTraining complete ✅")
