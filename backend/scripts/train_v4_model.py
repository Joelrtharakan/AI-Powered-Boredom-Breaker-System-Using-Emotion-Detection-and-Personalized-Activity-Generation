"""
V4 Emotion Model Training Script
=================================
KEY CHANGES FROM V3:
1. Uses `roberta-base` instead of Twitter emotion model (no inherited JOY bias)
2. Uses `dair-ai/emotion` from HuggingFace (16K properly labeled samples) 
   instead of the noisy local emotions.csv
3. Rich synthetic dataset with 50+ templates per custom category
4. Higher synthetic multiplier (8x) so custom categories compete
5. Label smoothing (0.1) prevents overconfident predictions
6. Cosine LR scheduler for stable convergence
7. Per-class evaluation report at the end

Expected training time: ~3-4 hours on CPU.
"""

import os
import pandas as pd
import numpy as np
import torch
import torch.nn as nn
from datasets import Dataset, load_dataset
from transformers import (
    AutoTokenizer,
    AutoModelForSequenceClassification,
    TrainingArguments,
    Trainer,
    EarlyStoppingCallback
)
from sklearn.model_selection import train_test_split
from sklearn.utils.class_weight import compute_class_weight
from sklearn.metrics import (
    accuracy_score,
    precision_recall_fscore_support,
    classification_report
)

# ============================
# Configuration
# ============================
BASE_MODEL = "roberta-base"  # CLEAN SLATE - no emotion biases
OUTPUT_DIR = "models/fine_tuned_roberta_v4"
BATCH_SIZE = 16
NUM_EPOCHS = 8
LEARNING_RATE = 2e-5
SYNTHETIC_MULTIPLIER = 8     # Higher to give custom categories real weight
MAX_LENGTH = 128

# ============================
# Data Loading
# ============================
print("📂 Loading datasets...")

# 1. Gold-standard emotion dataset from HuggingFace (properly labeled!)
print("   Downloading dair-ai/emotion dataset...")
hf_dataset = load_dataset("dair-ai/emotion")
hf_label_names = hf_dataset["train"].features["label"].names
# ['sadness', 'joy', 'love', 'anger', 'fear', 'surprise']

# Convert to pandas with string labels
df_hf_train = hf_dataset["train"].to_pandas()
df_hf_val = hf_dataset["validation"].to_pandas()
df_hf_test = hf_dataset["test"].to_pandas()
df_large = pd.concat([df_hf_train, df_hf_val, df_hf_test], ignore_index=True)
df_large["label"] = df_large["label"].map(lambda x: hf_label_names[x])

print(f"   HuggingFace dataset: {len(df_large)} samples")
print(f"   Labels: {df_large['label'].value_counts().to_dict()}")

# 2. Rich synthetic dataset (custom categories)
RICH_SYNTH_PATH = "data/rich_synthetic_dataset.csv"
if not os.path.exists(RICH_SYNTH_PATH):
    print("⚠️ Rich synthetic dataset not found. Generating it now...")
    os.system("python scripts/generate_rich_synthetic_data.py")

df_synthetic = pd.read_csv(RICH_SYNTH_PATH)

# 3. Also load older synthetic data if available  
OLD_SYNTH_PATH = "data/emotional_wellness_dataset.csv"
if os.path.exists(OLD_SYNTH_PATH):
    df_old_synth = pd.read_csv(OLD_SYNTH_PATH)
    df_synthetic = pd.concat([df_synthetic, df_old_synth], ignore_index=True)
    df_synthetic = df_synthetic.drop_duplicates(subset=["text", "label"])
    print(f"   Combined synthetic dataset: {len(df_synthetic)} samples")
else:
    print(f"   Rich synthetic dataset: {len(df_synthetic)} samples")

# ============================
# Balanced Sampling
# ============================
print("\n⚖️ Balancing datasets...")

# Use ALL of the HuggingFace data (it's already well-balanced at 20K)
# Upsample synthetic data significantly so custom categories have real presence
df_synthetic_upsampled = pd.concat(
    [df_synthetic] * SYNTHETIC_MULTIPLIER,
    ignore_index=True
)

print(f"   HuggingFace data: {len(df_large)} samples")
print(f"   Synthetic data (x{SYNTHETIC_MULTIPLIER}): {len(df_synthetic_upsampled)} samples")

# Combine
df_combined = pd.concat(
    [df_large, df_synthetic_upsampled],
    ignore_index=True
)

# Shuffle
df_combined = df_combined.sample(frac=1, random_state=42).reset_index(drop=True)

# ============================
# Label Encoding
# ============================
labels = sorted(df_combined["label"].unique())
label2id = {l: i for i, l in enumerate(labels)}
id2label = {i: l for i, l in enumerate(labels)}

df_combined["labels"] = df_combined["label"].map(label2id)
df_combined = df_combined.dropna(subset=["labels"])
df_combined["labels"] = df_combined["labels"].astype(int)

print(f"\n📊 Combined dataset: {len(df_combined)} samples")
print(f"   {len(labels)} labels: {labels}")
print(f"\nLabel distribution:")
print(df_combined["label"].value_counts())

# ============================
# Stratified Train/Val Split
# ============================
train_df, val_df = train_test_split(
    df_combined,
    test_size=0.1,
    random_state=42,
    stratify=df_combined["labels"]
)

print(f"\n   Train: {len(train_df)} | Val: {len(val_df)}")

train_dataset = Dataset.from_pandas(train_df[["text", "labels"]])
val_dataset = Dataset.from_pandas(val_df[["text", "labels"]])

# ============================
# Tokenizer
# ============================
print(f"\n🔤 Loading tokenizer: {BASE_MODEL}")
tokenizer = AutoTokenizer.from_pretrained(BASE_MODEL)


def tokenize_function(examples):
    return tokenizer(
        examples["text"],
        padding="max_length",
        truncation=True,
        max_length=MAX_LENGTH
    )


print("   Tokenizing...")
train_dataset = train_dataset.map(tokenize_function, batched=True)
val_dataset = val_dataset.map(tokenize_function, batched=True)

# ============================
# Class Weights
# ============================
class_weights = compute_class_weight(
    class_weight="balanced",
    classes=np.unique(df_combined["labels"]),
    y=df_combined["labels"]
)
class_weights = torch.tensor(class_weights, dtype=torch.float)
print(f"\n⚖️ Class weights computed ({len(class_weights)} classes)")

# ============================
# Model (from clean roberta-base)
# ============================
print(f"\n🧠 Loading base model: {BASE_MODEL}")
model = AutoModelForSequenceClassification.from_pretrained(
    BASE_MODEL,
    num_labels=len(labels),
    id2label=id2label,
    label2id=label2id,
    ignore_mismatched_sizes=True
)
print(f"   Model loaded with {len(labels)} output labels")

# ============================
# Metrics
# ============================
def compute_metrics(eval_pred):
    logits, labels_true = eval_pred
    predictions = np.argmax(logits, axis=-1)

    precision, recall, f1, _ = precision_recall_fscore_support(
        labels_true, predictions, average="weighted", zero_division=0
    )
    acc = accuracy_score(labels_true, predictions)

    return {
        "accuracy": acc,
        "f1": f1,
        "precision": precision,
        "recall": recall
    }


# ============================
# Custom Trainer with Weighted + Label Smoothing Loss
# ============================
class WeightedTrainer(Trainer):
    def compute_loss(self, model, inputs, return_outputs=False, **kwargs):
        labels_input = inputs.get("labels")
        outputs = model(**inputs)
        logits = outputs.get("logits")

        # Weighted cross entropy with label smoothing
        loss_fn = nn.CrossEntropyLoss(
            weight=class_weights.to(model.device),
            label_smoothing=0.1  # Prevents overconfident predictions
        )
        loss = loss_fn(logits, labels_input)
        return (loss, outputs) if return_outputs else loss


# ============================
# Training Arguments
# ============================
training_args = TrainingArguments(
    output_dir=OUTPUT_DIR,
    eval_strategy="epoch",
    save_strategy="epoch",
    learning_rate=LEARNING_RATE,
    per_device_train_batch_size=BATCH_SIZE,
    per_device_eval_batch_size=BATCH_SIZE,
    num_train_epochs=NUM_EPOCHS,
    weight_decay=0.01,
    warmup_ratio=0.1,
    lr_scheduler_type="cosine",   # Better than linear for fine-tuning
    logging_dir=f"{OUTPUT_DIR}/logs",
    logging_steps=50,
    load_best_model_at_end=True,
    metric_for_best_model="f1",
    greater_is_better=True,
    save_total_limit=2,
    use_cpu=True  # Change to False if GPU available
)

# ============================
# Trainer
# ============================
trainer = WeightedTrainer(
    model=model,
    args=training_args,
    train_dataset=train_dataset,
    eval_dataset=val_dataset,
    compute_metrics=compute_metrics,
    callbacks=[EarlyStoppingCallback(early_stopping_patience=3)]
)

# ============================
# Train!
# ============================
print("\n🚀 Starting V4 Training...")
print(f"   Base model: {BASE_MODEL}")
print(f"   Labels: {len(labels)}")
print(f"   Train samples: {len(train_dataset)}")
print(f"   Val samples: {len(val_dataset)}")
print(f"   Epochs: {NUM_EPOCHS}")
print(f"   Batch size: {BATCH_SIZE}")
print(f"   Learning rate: {LEARNING_RATE}")
print(f"   Synthetic multiplier: {SYNTHETIC_MULTIPLIER}")
print(f"   Label smoothing: 0.1")
print(f"   LR scheduler: cosine")
print("=" * 60)

trainer.train()

# ============================
# Save
# ============================
print("\n💾 Saving model...")
model.save_pretrained(OUTPUT_DIR)
tokenizer.save_pretrained(OUTPUT_DIR)

# ============================
# Final Evaluation
# ============================
print("\n📊 Final Evaluation:")
eval_results = trainer.evaluate()
for k, v in eval_results.items():
    print(f"   {k}: {v:.4f}" if isinstance(v, float) else f"   {k}: {v}")

# Detailed per-class report
print("\n📋 Per-Class Report:")
predictions = trainer.predict(val_dataset)
preds = np.argmax(predictions.predictions, axis=-1)
print(classification_report(
    val_dataset["labels"],
    preds,
    target_names=labels,
    zero_division=0
))

# ============================
# Print label mapping
# ============================
print("\n🏷️ Final Labels:")
for idx, label in id2label.items():
    print(f"   {idx} → {label}")

print(f"\nModel saved to: {OUTPUT_DIR}")
print("\n✅ Training complete 🎉")
