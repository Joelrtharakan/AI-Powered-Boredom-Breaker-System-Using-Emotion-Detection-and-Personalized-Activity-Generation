"""
V7 Emotion Model Training Script — Fixing Real-World Failures
===============================================================
Same architecture as V6 (which scored 96.7%) but with targeted data
that fills the gaps exposed by real-world testing.

Additions over V6:
- V7 targeted dataset (crisis language, single-word emotions, lethargy)
- V7 targeted data gets 20x multiplier (higher than general synthetic)
- All other settings identical to V6 (proven to work)
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
# Configuration (same as V6)
# ============================
BASE_MODEL = "roberta-base"
OUTPUT_DIR = "models/fine_tuned_roberta_v7"
BATCH_SIZE = 16
GRAD_ACCUM = 4
NUM_EPOCHS = 10
LEARNING_RATE = 1e-5
WARMUP_RATIO = 0.15
WEIGHT_DECAY = 0.02
LABEL_SMOOTHING = 0.05
GENERAL_SYNTH_MULT = 15
TARGETED_SYNTH_MULT = 20    # Higher multiplier for targeted gap-filling data
MAX_LENGTH = 128

# Label consolidation (same as V6)
LABEL_REMAP = {
    "sadness": "sadness", "joy": "joy", "love": "love",
    "anger": "anger", "fear": "fear", "surprise": "surprise",
    "positive_engaged": "joy", "stressed": "anger",
    "anxious": "fear", "overthinking": "fear",
    "low_energy_bored": "bored", "restless_bored": "bored",
    "emotionally_flat": "bored", "neutral": "neutral",
    "calm": "neutral", "focused": "neutral", "bored": "bored",
}

# ============================
# Data Loading
# ============================
print("=" * 60)
print("📂 LOADING DATASETS")
print("=" * 60)

# 1. HuggingFace (20K)
print("\n   [1/5] dair-ai/emotion...")
hf_dataset = load_dataset("dair-ai/emotion")
hf_labels = hf_dataset["train"].features["label"].names
df_hf = pd.concat([
    hf_dataset["train"].to_pandas(),
    hf_dataset["validation"].to_pandas(),
    hf_dataset["test"].to_pandas()
], ignore_index=True)
df_hf["label"] = df_hf["label"].map(lambda x: hf_labels[x])
df_hf["label"] = df_hf["label"].map(LABEL_REMAP)
df_hf = df_hf.dropna(subset=["label"])
print(f"         {len(df_hf)} samples")

# 2. V7 TARGETED data (NEW — gap-filling)
print("   [2/5] V7 targeted data...")
V7_PATH = "data/v7_targeted_dataset.csv"
if not os.path.exists(V7_PATH):
    print("         Generating...")
    os.system("python scripts/generate_v7_targeted_data.py")
df_v7 = pd.read_csv(V7_PATH)
print(f"         {len(df_v7)} samples (targeted gap-fill)")

# 3. V6 synthetic data
print("   [3/5] V6 synthetic data...")
df_v6 = pd.read_csv("data/v6_synthetic_dataset.csv") if os.path.exists("data/v6_synthetic_dataset.csv") else pd.DataFrame()
if len(df_v6): print(f"         {len(df_v6)} samples")

# 4. V5 synthetic data
print("   [4/5] V5 synthetic data...")
df_v5 = pd.read_csv("data/v5_synthetic_dataset.csv") if os.path.exists("data/v5_synthetic_dataset.csv") else pd.DataFrame()
if len(df_v5): print(f"         {len(df_v5)} samples")

# 5. Old data (remapped)
print("   [5/5] Old data (remapped)...")
old_dfs = []
for p in ["data/rich_synthetic_dataset.csv", "data/emotional_wellness_dataset.csv"]:
    if os.path.exists(p):
        df = pd.read_csv(p)
        df["label"] = df["label"].map(LABEL_REMAP)
        df = df.dropna(subset=["label"])
        old_dfs.append(df)
        print(f"         {p}: {len(df)}")

# ============================
# Combine & Upsample
# ============================
print(f"\n{'='*60}")
print("⚖️  BUILDING TRAINING SET")
print(f"{'='*60}")

# General synthetic (V6 + V5 + old)
general_parts = [df for df in [df_v6, df_v5] + old_dfs if len(df) > 0]
df_general = pd.concat(general_parts, ignore_index=True) if general_parts else pd.DataFrame()
df_general = df_general.drop_duplicates(subset=["text"])

# Upsample: targeted gets higher multiplier
df_v7_up = pd.concat([df_v7] * TARGETED_SYNTH_MULT, ignore_index=True)
df_general_up = pd.concat([df_general] * GENERAL_SYNTH_MULT, ignore_index=True) if len(df_general) > 0 else pd.DataFrame()

print(f"   HuggingFace:      {len(df_hf):>6} samples")
print(f"   General synth:    {len(df_general):>6} unique → x{GENERAL_SYNTH_MULT} = {len(df_general_up)}")
print(f"   Targeted (V7):    {len(df_v7):>6} unique → x{TARGETED_SYNTH_MULT} = {len(df_v7_up)}")

# Combine all
all_parts = [df_hf, df_general_up, df_v7_up]
df_combined = pd.concat([p for p in all_parts if len(p) > 0], ignore_index=True)
df_combined = df_combined.sample(frac=1, random_state=42).reset_index(drop=True)

# ============================
# Label Encoding
# ============================
labels = sorted(df_combined["label"].unique())
label2id = {l: i for i, l in enumerate(labels)}
id2label = {i: l for i, l in enumerate(labels)}
df_combined["labels"] = df_combined["label"].map(label2id).astype(int)

print(f"\n   Total training data: {len(df_combined)}")
print(f"   Labels ({len(labels)}): {labels}")
print(f"\n   Distribution:")
for label, count in df_combined["label"].value_counts().items():
    pct = count / len(df_combined) * 100
    bar = "█" * int(pct / 2)
    print(f"     {label:12s} {count:6d} ({pct:4.1f}%) {bar}")

# ============================
# Split
# ============================
train_df, val_df = train_test_split(
    df_combined, test_size=0.1, random_state=42,
    stratify=df_combined["labels"]
)
print(f"\n   Train: {len(train_df)} | Val: {len(val_df)}")

train_dataset = Dataset.from_pandas(train_df[["text", "labels"]])
val_dataset = Dataset.from_pandas(val_df[["text", "labels"]])

# ============================
# Tokenizer
# ============================
print(f"\n{'='*60}")
print(f"🔤 TOKENIZATION")
print(f"{'='*60}")
tokenizer = AutoTokenizer.from_pretrained(BASE_MODEL)

def tokenize_fn(ex):
    return tokenizer(ex["text"], padding="max_length", truncation=True, max_length=MAX_LENGTH)

train_dataset = train_dataset.map(tokenize_fn, batched=True)
val_dataset = val_dataset.map(tokenize_fn, batched=True)
print("   ✅ Done")

# ============================
# Class Weights
# ============================
cw = compute_class_weight("balanced", classes=np.unique(df_combined["labels"]), y=df_combined["labels"])
class_weights = torch.tensor(cw, dtype=torch.float)
print(f"\n⚖️  Class weights:")
for i, l in enumerate(labels):
    print(f"     {l:12s} → {class_weights[i]:.3f}")

# ============================
# Model
# ============================
print(f"\n{'='*60}")
print(f"🧠 LOADING MODEL")
print(f"{'='*60}")
model = AutoModelForSequenceClassification.from_pretrained(
    BASE_MODEL, num_labels=len(labels),
    id2label=id2label, label2id=label2id,
    ignore_mismatched_sizes=True
)
print(f"   Ready: {len(labels)} labels")

# ============================
# Metrics & Trainer
# ============================
def compute_metrics(eval_pred):
    logits, labels_true = eval_pred
    preds = np.argmax(logits, axis=-1)
    p, r, f1, _ = precision_recall_fscore_support(labels_true, preds, average="weighted", zero_division=0)
    return {"accuracy": accuracy_score(labels_true, preds), "f1": f1, "precision": p, "recall": r}

class WeightedTrainer(Trainer):
    def compute_loss(self, model, inputs, return_outputs=False, **kwargs):
        labels_in = inputs.get("labels")
        outputs = model(**inputs)
        loss_fn = nn.CrossEntropyLoss(weight=class_weights.to(model.device), label_smoothing=LABEL_SMOOTHING)
        loss = loss_fn(outputs.get("logits"), labels_in)
        return (loss, outputs) if return_outputs else loss

# ============================
# Training
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
    logging_dir=f"{OUTPUT_DIR}/logs", logging_steps=50,
    load_best_model_at_end=True, metric_for_best_model="f1",
    greater_is_better=True, save_total_limit=2,
    # use_cpu=True  # Removed — using MPS (Apple GPU) for ~5-10x speedup
)

trainer = WeightedTrainer(
    model=model, args=training_args,
    train_dataset=train_dataset, eval_dataset=val_dataset,
    compute_metrics=compute_metrics,
    callbacks=[EarlyStoppingCallback(early_stopping_patience=4)]
)

print(f"\n{'='*60}")
print("🚀 V7 TRAINING — Real-World Accuracy Fix")
print(f"{'='*60}")
print(f"   Train: {len(train_dataset)} | Val: {len(val_dataset)}")
print(f"   Epochs: {NUM_EPOCHS} | Batch(eff): {BATCH_SIZE*GRAD_ACCUM}")
print(f"   LR: {LEARNING_RATE} | Warmup: {WARMUP_RATIO}")
print(f"   Targeted mult: {TARGETED_SYNTH_MULT}x | General mult: {GENERAL_SYNTH_MULT}x")
print(f"{'='*60}\n")

# Resume from checkpoint if available
checkpoint = None
if os.path.isdir(OUTPUT_DIR):
    checkpoints = [os.path.join(OUTPUT_DIR, d) for d in os.listdir(OUTPUT_DIR) if d.startswith("checkpoint-")]
    if checkpoints:
        checkpoint = max(checkpoints, key=os.path.getmtime)
        print(f"   ⏩ Resuming from: {checkpoint}")

trainer.train(resume_from_checkpoint=checkpoint)

# ============================
# Save & Evaluate
# ============================
print("\n💾 Saving model...")
model.save_pretrained(OUTPUT_DIR)
tokenizer.save_pretrained(OUTPUT_DIR)

print(f"\n{'='*60}")
print("📊 FINAL EVALUATION")
print(f"{'='*60}")
results = trainer.evaluate()
for k, v in results.items():
    print(f"   {k}: {v:.4f}" if isinstance(v, float) else f"   {k}: {v}")

print("\n📋 Per-Class Report:")
preds_out = trainer.predict(val_dataset)
preds = np.argmax(preds_out.predictions, axis=-1)
print(classification_report(val_dataset["labels"], preds, target_names=labels, zero_division=0))

print(f"\n✅ Model saved to: {OUTPUT_DIR}")
print("🎉 V7 Training Complete!")
