"""
V9 Emotion Model — Surgical Fine-Tune From V7
================================================
V7 has 98.3% standard accuracy. V8 tried training from scratch with
massive targeted data — it hurt standard accuracy (93.3%).

NEW STRATEGY: Start from the ALREADY TRAINED V7 model and do a
SHORT, GENTLE fine-tune with ONLY the targeted data.
This preserves V7's strong general knowledge while teaching it
the specific edge cases.

Key differences:
- BASE = V7 model (not roberta-base)
- Training data = ONLY targeted examples (no HuggingFace re-training)
- Very low LR (2e-6 vs 1e-5)
- Only 5 epochs (not 10)
- No class weights (targeted data is already balanced)
"""

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
from sklearn.metrics import (
    accuracy_score,
    precision_recall_fscore_support,
    classification_report
)

# ============================
# Configuration
# ============================
BASE_MODEL = "models/fine_tuned_roberta_v7"  # START FROM V7!
OUTPUT_DIR = "models/fine_tuned_roberta_v9"
BATCH_SIZE = 16
GRAD_ACCUM = 2        # Smaller effective batch (32) for fine-tuning
NUM_EPOCHS = 8
LEARNING_RATE = 2e-6   # Very low — we're fine-tuning, not training
WARMUP_RATIO = 0.1
WEIGHT_DECAY = 0.01
LABEL_SMOOTHING = 0.02  # Very light smoothing
MAX_LENGTH = 128
TARGETED_REPEAT = 10    # Repeat targeted data

# ============================
# Load targeted data (V8 + V7)
# ============================
print("=" * 60)
print("📂 LOADING TARGETED DATA ONLY")
print("=" * 60)

dfs = []
for path in ["data/v8_targeted_dataset.csv", "data/v7_targeted_dataset.csv"]:
    if os.path.exists(path):
        df = pd.read_csv(path)
        print(f"   {path}: {len(df)} samples")
        dfs.append(df)

df_targeted = pd.concat(dfs, ignore_index=True).drop_duplicates(subset=["text"])
print(f"\n   Unique targeted samples: {len(df_targeted)}")

# Repeat for training volume
df_train = pd.concat([df_targeted] * TARGETED_REPEAT, ignore_index=True)
df_train = df_train.sample(frac=1, random_state=42).reset_index(drop=True)

# ============================
# Label encoding (must match V7)
# ============================
labels = sorted(df_targeted["label"].unique())
label2id = {l: i for i, l in enumerate(labels)}
id2label = {i: l for i, l in enumerate(labels)}
df_train["labels"] = df_train["label"].map(label2id).astype(int)

print(f"   Labels ({len(labels)}): {labels}")
print(f"   Training samples: {len(df_train)} (x{TARGETED_REPEAT} repeat)")
print(f"\n   Distribution:")
for label, count in df_train["label"].value_counts().sort_index().items():
    pct = count / len(df_train) * 100
    print(f"     {label:12s} {count:5d} ({pct:4.1f}%)")

# ============================
# Split
# ============================
train_df, val_df = train_test_split(
    df_train, test_size=0.15, random_state=42,
    stratify=df_train["labels"]
)
print(f"\n   Train: {len(train_df)} | Val: {len(val_df)}")

train_dataset = Dataset.from_pandas(train_df[["text", "labels"]])
val_dataset = Dataset.from_pandas(val_df[["text", "labels"]])

# ============================
# Tokenizer & Model (from V7)
# ============================
print(f"\n{'='*60}")
print(f"🧠 LOADING V7 MODEL AS BASE")
print(f"{'='*60}")
tokenizer = AutoTokenizer.from_pretrained(BASE_MODEL)
model = AutoModelForSequenceClassification.from_pretrained(
    BASE_MODEL,
    num_labels=len(labels),
    id2label=id2label,
    label2id=label2id,
)
print(f"   ✅ V7 model loaded — fine-tuning on targeted data only")

# Tokenize
def tokenize_fn(ex):
    return tokenizer(ex["text"], padding="max_length", truncation=True, max_length=MAX_LENGTH)

train_dataset = train_dataset.map(tokenize_fn, batched=True)
val_dataset = val_dataset.map(tokenize_fn, batched=True)

# ============================
# Metrics
# ============================
def compute_metrics(eval_pred):
    logits, labels_true = eval_pred
    preds = np.argmax(logits, axis=-1)
    p, r, f1, _ = precision_recall_fscore_support(labels_true, preds, average="weighted", zero_division=0)
    return {"accuracy": accuracy_score(labels_true, preds), "f1": f1, "precision": p, "recall": r}

# ============================
# Training Args
# ============================
training_args = TrainingArguments(
    output_dir=OUTPUT_DIR,
    eval_strategy="epoch", save_strategy="epoch",
    learning_rate=LEARNING_RATE,
    per_device_train_batch_size=BATCH_SIZE,
    per_device_eval_batch_size=BATCH_SIZE,
    gradient_accumulation_steps=GRAD_ACCUM,
    num_train_epochs=NUM_EPOCHS,
    weight_decay=WEIGHT_DECAY, warmup_ratio=WARMUP_RATIO,
    lr_scheduler_type="cosine",
    logging_dir=f"{OUTPUT_DIR}/logs", logging_steps=20,
    load_best_model_at_end=True, metric_for_best_model="f1",
    greater_is_better=True, save_total_limit=2,
    label_smoothing_factor=LABEL_SMOOTHING,
)

trainer = Trainer(
    model=model, args=training_args,
    train_dataset=train_dataset, eval_dataset=val_dataset,
    compute_metrics=compute_metrics,
    callbacks=[EarlyStoppingCallback(early_stopping_patience=3)]
)

print(f"\n{'='*60}")
print("🔧 V9 SURGICAL FINE-TUNE FROM V7")
print(f"{'='*60}")
print(f"   Base: V7 ({BASE_MODEL})")
print(f"   Data: {len(train_dataset)} targeted samples only")
print(f"   LR: {LEARNING_RATE} (very gentle)")
print(f"   Epochs: {NUM_EPOCHS} | Batch(eff): {BATCH_SIZE*GRAD_ACCUM}")
print(f"{'='*60}\n")

trainer.train()

# ============================
# Save & Evaluate
# ============================
print("\n💾 Saving model...")
model.save_pretrained(OUTPUT_DIR)
tokenizer.save_pretrained(OUTPUT_DIR)

print(f"\n{'='*60}")
print("📊 FINAL EVALUATION (on targeted validation)")
print(f"{'='*60}")
results = trainer.evaluate()
for k, v in results.items():
    print(f"   {k}: {v:.4f}" if isinstance(v, float) else f"   {k}: {v}")

print("\n📋 Per-Class Report:")
preds_out = trainer.predict(val_dataset)
preds = np.argmax(preds_out.predictions, axis=-1)
print(classification_report(val_dataset["labels"], preds, target_names=labels, zero_division=0))

print(f"\n✅ Model saved to: {OUTPUT_DIR}")
print("🎉 V9 Training Complete!")
