
import os
import torch
import pandas as pd
import numpy as np
from datasets import Dataset
from transformers import (
    AutoTokenizer,
    AutoModelForSequenceClassification,
    TrainingArguments,
    Trainer,
    DataCollatorWithPadding
)
from sklearn.metrics import accuracy_score, f1_score

# --- Configuration ---
MODEL_PATH_V2 = "models/fine_tuned_roberta_v2" # Start from V2
MODEL_PATH_FINAL = "models/fine_tuned_roberta_final" # Output
CORRECTION_DATA_PATH = "data/correction_dataset.csv"
EPOCHS = 3
BATCH_SIZE = 16
LEARNING_RATE = 2e-5

def compute_metrics(eval_pred):
    predictions, labels = eval_pred
    predictions = np.argmax(predictions, axis=1)
    acc = accuracy_score(labels, predictions)
    f1 = f1_score(labels, predictions, average="weighted")
    return {"accuracy": acc, "f1": f1}

def fine_tune_correction():
    print(f"🚀 Starting Correction Fine-Tuning from {MODEL_PATH_V2}...")

    # 1. Load Correction Data
    if not os.path.exists(CORRECTION_DATA_PATH):
        print(f"❌ Correction dataset not found at {CORRECTION_DATA_PATH}")
        return

    df_correction = pd.read_csv(CORRECTION_DATA_PATH)
    print(f"📊 Loaded {len(df_correction)} correction samples.")
    
    # 2. Add some original synthetic data to prevent catastrophic forgetting
    # Just a small sample to remind it of the other classes
    synthetic_path = "data/emotional_wellness_dataset.csv"
    if os.path.exists(synthetic_path):
        df_synthetic = pd.read_csv(synthetic_path)
        # Sample 200 random rows from synthetic
        df_synthetic = df_synthetic.sample(n=min(len(df_synthetic), 500), random_state=42)
        df_correction = pd.concat([df_correction, df_synthetic], ignore_index=True)
        print(f"➕ Added {len(df_synthetic)} synthetic samples for stability.")

    # Shuffle
    df_correction = df_correction.sample(frac=1).reset_index(drop=True)

    # 3. Load Tokenizer & Map Labels
    tokenizer = AutoTokenizer.from_pretrained(MODEL_PATH_V2)
    
    # Get ID mapping from the model config
    model = AutoModelForSequenceClassification.from_pretrained(MODEL_PATH_V2)
    label2id = model.config.label2id
    id2label = model.config.id2label
    
    # Filter data to only include valid labels
    valid_labels = set(label2id.keys())
    original_count = len(df_correction)
    df_correction = df_correction[df_correction['label'].isin(valid_labels)]
    
    if len(df_correction) < original_count:
        print(f"⚠️ Filtered out {original_count - len(df_correction)} samples with invalid labels.")

    dataset = Dataset.from_pandas(df_correction)

    def tokenize_function(examples):
        return tokenizer(examples["text"], padding="max_length", truncation=True, max_length=128)

    tokenized_datasets = dataset.map(tokenize_function, batched=True)

    # Map labels to IDs
    def map_labels(example):
        example["label"] = label2id[example["label"]]
        return example

    tokenized_datasets = tokenized_datasets.map(map_labels)
    
    # Split
    split_dataset = tokenized_datasets.train_test_split(test_size=0.1)
    train_dataset = split_dataset["train"]
    eval_dataset = split_dataset["test"]

    data_collator = DataCollatorWithPadding(tokenizer=tokenizer)

    # 4. Training Arguments
    training_args = TrainingArguments(
        output_dir=MODEL_PATH_FINAL,
        eval_strategy="epoch",  # Changed from evaluation_strategy
        save_strategy="epoch",
        learning_rate=LEARNING_RATE,
        per_device_train_batch_size=BATCH_SIZE,
        per_device_eval_batch_size=BATCH_SIZE,
        num_train_epochs=EPOCHS,
        weight_decay=0.01,
        load_best_model_at_end=True,
        metric_for_best_model="accuracy",
        save_total_limit=2,
        logging_dir="./logs_correction",
        logging_steps=50,
    )

    # 5. Initialize Trainer
    trainer = Trainer(
        model=model,
        args=training_args,
        train_dataset=train_dataset,
        eval_dataset=eval_dataset,
        tokenizer=tokenizer,
        data_collator=data_collator,
        compute_metrics=compute_metrics,
    )

    # 6. Train
    print("🔥 Starting Training...")
    trainer.train()

    # 7. Save Final Model
    print(f"💾 Saving Corrected Model to {MODEL_PATH_FINAL}...")
    trainer.save_model(MODEL_PATH_FINAL)
    tokenizer.save_pretrained(MODEL_PATH_FINAL)
    
    # Save metrics
    metrics = trainer.evaluate()
    print(f"✅ Final Metrics: {metrics}")

if __name__ == "__main__":
    # Check for MPS
    if torch.backends.mps.is_available():
        print("🚀 Using MPS (Metal Performance Shaders) for Hardware Acceleration!")
    else:
        print("⚠️ MPS not available. Using CPU (slower).")
        
    fine_tune_correction()
