"""
V6 Emotion Model Training Script — Target: 92%+ Accuracy
==========================================================
KEY IMPROVEMENTS OVER V5:
1. 3x more synthetic data (750+ unique templates)
2. Higher synthetic multiplier (15x) for better representation
3. Gradient accumulation for effective batch size of 64
4. 10 epochs with patience 4 (trains longer, finds better minimum)
5. Lower learning rate (1e-5) for more precise fine-tuning
6. Warmup ratio 0.15 (longer warmup helps roberta)
7. Weight decay 0.02 (stronger regularization)
8. Label smoothing 0.05 (less aggressive than V5's 0.1)

Same 8 labels: sadness, joy, love, anger, fear, surprise, bored, neutral
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
OUTPUT_DIR = "models/fine_tuned_roberta_v6"
BATCH_SIZE = 16
GRAD_ACCUM = 4             # Effective batch size = 16 * 4 = 64
NUM_EPOCHS = 10
LEARNING_RATE = 1e-5        # Lower LR for more precise fine-tuning
WARMUP_RATIO = 0.15
WEIGHT_DECAY = 0.02
LABEL_SMOOTHING = 0.05      # Less aggressive smoothing
SYNTHETIC_MULTIPLIER = 15   # Higher multiplier for custom categories
MAX_LENGTH = 128

# ============================
# Label Consolidation Map (same as V5)
# ============================
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

# 1. HuggingFace gold-standard dataset (20K)
print("\n   [1/4] Loading dair-ai/emotion...")
hf_dataset = load_dataset("dair-ai/emotion")
hf_label_names = hf_dataset["train"].features["label"].names
df_hf = pd.concat([
    hf_dataset["train"].to_pandas(),
    hf_dataset["validation"].to_pandas(),
    hf_dataset["test"].to_pandas()
], ignore_index=True)
df_hf["label"] = df_hf["label"].map(lambda x: hf_label_names[x])
print(f"         {len(df_hf)} samples")

# 2. V6 synthetic dataset (new, 750+)
print("   [2/4] Loading V6 synthetic data...")
V6_SYNTH_PATH = "data/v6_synthetic_dataset.csv"
if not os.path.exists(V6_SYNTH_PATH):
    print("         Generating V6 synthetic data...")
    os.system("python scripts/generate_v6_synthetic_data.py")
df_v6 = pd.read_csv(V6_SYNTH_PATH)
print(f"         {len(df_v6)} samples")

# 3. V5 synthetic dataset (extra data)
print("   [3/4] Loading V5 synthetic data...")
V5_SYNTH_PATH = "data/v5_synthetic_dataset.csv"
df_v5 = pd.read_csv(V5_SYNTH_PATH) if os.path.exists(V5_SYNTH_PATH) else pd.DataFrame()
if len(df_v5) > 0:
    print(f"         {len(df_v5)} samples")

# 4. Old synthetic datasets (remapped)
print("   [4/4] Loading old synthetic data (remapped)...")
old_dfs = []
for path in ["data/rich_synthetic_dataset.csv", "data/emotional_wellness_dataset.csv"]:
    if os.path.exists(path):
        df_old = pd.read_csv(path)
        df_old["label"] = df_old["label"].map(LABEL_REMAP)
        df_old = df_old.dropna(subset=["label"])
        old_dfs.append(df_old)
        print(f"         {path}: {len(df_old)} samples")

# ============================
# Combine synthetic data
# ============================
all_synthetic = [df_v6]
if len(df_v5) > 0:
    all_synthetic.append(df_v5)
all_synthetic.extend(old_dfs)

df_synthetic = pd.concat(all_synthetic, ignore_index=True)
df_synthetic = df_synthetic.drop_duplicates(subset=["text"])
print(f"\n   Total unique synthetic: {len(df_synthetic)}")

# ============================
# Prepare HuggingFace data
# ============================
df_hf["label"] = df_hf["label"].map(LABEL_REMAP)
df_hf = df_hf.dropna(subset=["label"])

# ============================
# Upsample synthetic data
# ============================
print(f"\n{'='*60}")
print("⚖️  BALANCING DATASETS")
print(f"{'='*60}")

df_synth_up = pd.concat([df_synthetic] * SYNTHETIC_MULTIPLIER, ignore_index=True)
print(f"   HuggingFace:  {len(df_hf)} samples")
print(f"   Synthetic (x{SYNTHETIC_MULTIPLIER}): {len(df_synth_up)} samples")

# Combine
df_combined = pd.concat([df_hf, df_synth_up], ignore_index=True)
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

print(f"\n   Combined total: {len(df_combined)} samples")
print(f"   Labels ({len(labels)}): {labels}")
print(f"\n   Distribution:")
for label, count in df_combined["label"].value_counts().items():
    pct = count / len(df_combined) * 100
    bar = "█" * int(pct / 2)
    print(f"     {label:12s} {count:6d} ({pct:4.1f}%) {bar}")

# ============================
# Stratified Split
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
print(f"🔤 TOKENIZATION ({BASE_MODEL})")
print(f"{'='*60}")
tokenizer = AutoTokenizer.from_pretrained(BASE_MODEL)

def tokenize_fn(examples):
    return tokenizer(examples["text"], padding="max_length",
                     truncation=True, max_length=MAX_LENGTH)

train_dataset = train_dataset.map(tokenize_fn, batched=True)
val_dataset = val_dataset.map(tokenize_fn, batched=True)
print("   ✅ Tokenization complete")

# ============================
# Class Weights
# ============================
cw = compute_class_weight("balanced", classes=np.unique(df_combined["labels"]),
                          y=df_combined["labels"])
class_weights = torch.tensor(cw, dtype=torch.float)
print(f"\n⚖️  Class weights:")
for i, l in enumerate(labels):
    print(f"     {l:12s} → {class_weights[i]:.3f}")

# ============================
# Model
# ============================
print(f"\n{'='*60}")
print(f"🧠 LOADING MODEL ({BASE_MODEL})")
print(f"{'='*60}")
model = AutoModelForSequenceClassification.from_pretrained(
    BASE_MODEL, num_labels=len(labels),
    id2label=id2label, label2id=label2id,
    ignore_mismatched_sizes=True
)
print(f"   Ready: {len(labels)} output labels")

# ============================
# Metrics
# ============================
def compute_metrics(eval_pred):
    logits, labels_true = eval_pred
    predictions = np.argmax(logits, axis=-1)
    precision, recall, f1, _ = precision_recall_fscore_support(
        labels_true, predictions, average="weighted", zero_division=0)
    acc = accuracy_score(labels_true, predictions)
    return {"accuracy": acc, "f1": f1, "precision": precision, "recall": recall}

# ============================
# Weighted Trainer
# ============================
class WeightedTrainer(Trainer):
    def compute_loss(self, model, inputs, return_outputs=False, **kwargs):
        labels_input = inputs.get("labels")
        outputs = model(**inputs)
        logits = outputs.get("logits")
        loss_fn = nn.CrossEntropyLoss(
            weight=class_weights.to(model.device),
            label_smoothing=LABEL_SMOOTHING
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
    gradient_accumulation_steps=GRAD_ACCUM,
    num_train_epochs=NUM_EPOCHS,
    weight_decay=WEIGHT_DECAY,
    warmup_ratio=WARMUP_RATIO,
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
    callbacks=[EarlyStoppingCallback(early_stopping_patience=4)]
)

# ============================
# TRAIN
# ============================
print(f"\n{'='*60}")
print("🚀 V6 TRAINING — Target: 92%+ Accuracy")
print(f"{'='*60}")
print(f"   Base model:     {BASE_MODEL}")
print(f"   Labels:         {labels}")
print(f"   Train samples:  {len(train_dataset)}")
print(f"   Val samples:    {len(val_dataset)}")
print(f"   Epochs:         {NUM_EPOCHS}")
print(f"   Batch (eff):    {BATCH_SIZE} × {GRAD_ACCUM} = {BATCH_SIZE * GRAD_ACCUM}")
print(f"   Learning rate:  {LEARNING_RATE}")
print(f"   Warmup ratio:   {WARMUP_RATIO}")
print(f"   Weight decay:   {WEIGHT_DECAY}")
print(f"   Label smooth:   {LABEL_SMOOTHING}")
print(f"   Synth mult:     {SYNTHETIC_MULTIPLIER}x")
print(f"   Early stop:     patience=4 (metric=f1)")
print(f"{'='*60}\n")

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
print(f"\n{'='*60}")
print("📊 FINAL EVALUATION")
print(f"{'='*60}")
eval_results = trainer.evaluate()
for k, v in eval_results.items():
    print(f"   {k}: {v:.4f}" if isinstance(v, float) else f"   {k}: {v}")

print("\n📋 Per-Class Classification Report:")
predictions = trainer.predict(val_dataset)
preds = np.argmax(predictions.predictions, axis=-1)
print(classification_report(
    val_dataset["labels"], preds,
    target_names=labels, zero_division=0
))

print(f"\n🏷️ Label Map:")
for idx, label in id2label.items():
    print(f"   {idx} → {label}")

print(f"\n✅ Model saved to: {OUTPUT_DIR}")
print("🎉 V6 Training Complete!")
