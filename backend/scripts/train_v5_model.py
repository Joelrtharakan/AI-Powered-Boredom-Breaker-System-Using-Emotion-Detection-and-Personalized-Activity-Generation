"""
V5 Emotion Model Training Script
=================================
MAJOR IMPROVEMENT: 8 consolidated labels instead of 16.

Labels: sadness, joy, love, anger, fear, surprise, bored, neutral

Key changes from V4:
1. 8 labels instead of 16 — cleaner, more distinct categories
2. Maps dair-ai/emotion (6 labels) directly  
3. Rich V5 synthetic data adds "bored" + "neutral" categories
4. Remaps old synthetic data (low_energy_bored→bored, anxious→fear, etc.)
5. Higher synthetic multiplier (12x) for bored/neutral to balance against 20K HuggingFace
6. Label smoothing + cosine LR + class weights (same as V4)

Expected: significantly higher accuracy due to fewer, more distinct labels.
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
BASE_MODEL = "roberta-base"
OUTPUT_DIR = "models/fine_tuned_roberta_v5"
BATCH_SIZE = 16
NUM_EPOCHS = 8
LEARNING_RATE = 2e-5
SYNTHETIC_MULTIPLIER = 12    # Higher for custom categories
MAX_LENGTH = 128

# ============================
# Label Consolidation Map
# ============================
LABEL_REMAP = {
    # Direct mappings (from dair-ai/emotion)
    "sadness": "sadness",
    "joy": "joy",
    "love": "love",
    "anger": "anger",
    "fear": "fear",
    "surprise": "surprise",
    # Custom → consolidated
    "positive_engaged": "joy",
    "stressed": "anger",
    "anxious": "fear",
    "overthinking": "fear",
    "low_energy_bored": "bored",
    "restless_bored": "bored",
    "emotionally_flat": "bored",
    "neutral": "neutral",
    "calm": "neutral",
    "focused": "neutral",
    # Direct new labels
    "bored": "bored",
}

# ============================
# Data Loading
# ============================
print("📂 Loading datasets...")

# 1. Gold-standard HuggingFace dataset (20K properly labeled)
print("   Loading dair-ai/emotion dataset...")
hf_dataset = load_dataset("dair-ai/emotion")
hf_label_names = hf_dataset["train"].features["label"].names

df_hf_train = hf_dataset["train"].to_pandas()
df_hf_val = hf_dataset["validation"].to_pandas()
df_hf_test = hf_dataset["test"].to_pandas()
df_large = pd.concat([df_hf_train, df_hf_val, df_hf_test], ignore_index=True)
df_large["label"] = df_large["label"].map(lambda x: hf_label_names[x])

print(f"   HuggingFace: {len(df_large)} samples")

# 2. V5 synthetic dataset
V5_SYNTH_PATH = "data/v5_synthetic_dataset.csv"
if not os.path.exists(V5_SYNTH_PATH):
    print("   ⚠️ V5 synthetic data not found. Generating...")
    os.system("python scripts/generate_v5_synthetic_data.py")

df_v5_synth = pd.read_csv(V5_SYNTH_PATH)
print(f"   V5 synthetic: {len(df_v5_synth)} samples")

# 3. Old synthetic datasets (remap to consolidated labels)
old_datasets = []
for old_path in ["data/rich_synthetic_dataset.csv", "data/emotional_wellness_dataset.csv"]:
    if os.path.exists(old_path):
        df_old = pd.read_csv(old_path)
        df_old["label"] = df_old["label"].map(LABEL_REMAP)
        df_old = df_old.dropna(subset=["label"])
        old_datasets.append(df_old)
        print(f"   Old data ({old_path}): {len(df_old)} samples (remapped)")

# ============================
# Combine all synthetic data
# ============================
all_synthetic = [df_v5_synth] + old_datasets
df_synthetic = pd.concat(all_synthetic, ignore_index=True)
df_synthetic = df_synthetic.drop_duplicates(subset=["text", "label"])
print(f"\n   Total unique synthetic: {len(df_synthetic)} samples")

# ============================
# Remap HuggingFace labels (should be 1:1 for the 6 base)
# ============================
df_large["label"] = df_large["label"].map(LABEL_REMAP)
df_large = df_large.dropna(subset=["label"])

# ============================
# Upsample synthetic data
# ============================
print(f"\n⚖️ Balancing datasets...")
df_synthetic_upsampled = pd.concat(
    [df_synthetic] * SYNTHETIC_MULTIPLIER,
    ignore_index=True
)
print(f"   HuggingFace: {len(df_large)} samples")
print(f"   Synthetic (x{SYNTHETIC_MULTIPLIER}): {len(df_synthetic_upsampled)} samples")

# Combine everything
df_combined = pd.concat(
    [df_large, df_synthetic_upsampled],
    ignore_index=True
)
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
print(f"\n⚖️ Class weights: {dict(zip(labels, [round(w, 3) for w in class_weights.tolist()]))}")

# ============================
# Model
# ============================
print(f"\n🧠 Loading base model: {BASE_MODEL}")
model = AutoModelForSequenceClassification.from_pretrained(
    BASE_MODEL,
    num_labels=len(labels),
    id2label=id2label,
    label2id=label2id,
    ignore_mismatched_sizes=True
)
print(f"   Model ready: {len(labels)} labels")

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
    return {"accuracy": acc, "f1": f1, "precision": precision, "recall": recall}


# ============================
# Custom Trainer
# ============================
class WeightedTrainer(Trainer):
    def compute_loss(self, model, inputs, return_outputs=False, **kwargs):
        labels_input = inputs.get("labels")
        outputs = model(**inputs)
        logits = outputs.get("logits")
        loss_fn = nn.CrossEntropyLoss(
            weight=class_weights.to(model.device),
            label_smoothing=0.1
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
    lr_scheduler_type="cosine",
    logging_dir=f"{OUTPUT_DIR}/logs",
    logging_steps=50,
    load_best_model_at_end=True,
    metric_for_best_model="f1",
    greater_is_better=True,
    save_total_limit=2,
    use_cpu=True
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
# Train
# ============================
print("\n🚀 V5 Training Starting...")
print(f"   Base: {BASE_MODEL}")
print(f"   Labels: {labels}")
print(f"   Train: {len(train_dataset)} | Val: {len(val_dataset)}")
print(f"   Epochs: {NUM_EPOCHS} | Batch: {BATCH_SIZE} | LR: {LEARNING_RATE}")
print(f"   Synthetic multiplier: {SYNTHETIC_MULTIPLIER}")
print(f"   Label smoothing: 0.1 | LR schedule: cosine")
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

print("\n📋 Per-Class Report:")
predictions = trainer.predict(val_dataset)
preds = np.argmax(predictions.predictions, axis=-1)
print(classification_report(
    val_dataset["labels"],
    preds,
    target_names=labels,
    zero_division=0
))

print("\n🏷️ Final Labels:")
for idx, label in id2label.items():
    print(f"   {idx} → {label}")

print(f"\nModel saved to: {OUTPUT_DIR}")
print("\n✅ V5 Training Complete 🎉")
