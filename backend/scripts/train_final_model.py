
import os
import torch
from transformers import RobertaForSequenceClassification, RobertaTokenizer, Trainer, TrainingArguments, EarlyStoppingCallback
from datasets import Dataset
import pandas as pd
import numpy as np
from sklearn.metrics import accuracy_score, f1_score
from shutil import rmtree
import warnings

warnings.filterwarnings("ignore")

# ============================================================
# 👑 V14 FINAL MODEL TRAINER (Restored)
# ============================================================
# The Ultimate Model: Trains on the ENTIRE consolidated corpus.
# Dataset: data/v14_final_dataset.csv

MODEL_SAVE_PATH = "models/v14_final_model"
DATASET_PATH = "data/v14_final_dataset.csv"
BASE_MODEL = "cardiffnlp/twitter-roberta-base-emotion"

# Hyperparams
NUM_EPOCHS = 5
BATCH_SIZE = 16
LEARNING_RATE = 1e-5 
MAX_LENGTH = 128

def compute_metrics(eval_pred):
    logits, labels = eval_pred
    predictions = np.argmax(logits, axis=-1)
    acc = accuracy_score(labels, predictions)
    f1 = f1_score(labels, predictions, average="weighted")
    return {"accuracy": acc, "f1": f1}

def train():
    print("🚀 Starting V14 *FINAL* Consolidated Training...")
    
    # 1. LOAD DATASET
    if not os.path.exists(DATASET_PATH):
        print(f"❌ Dataset not found: {DATASET_PATH}")
        return
    
    df = pd.read_csv(DATASET_PATH)
    
    # 2. LABEL MAPPING
    label2id = {"joy": 0, "sadness": 1, "anger": 2, "fear": 3, "neutral": 4, "bored": 5}
    id2label = {0: "joy", 1: "sadness", 2: "anger", 3: "fear", 4: "neutral", 5: "bored"}

    def normalize_label(l):
        l = str(l).lower().strip()
        if l in label2id: return l
        mapping = {
            "happiness": "joy", "happy": "joy", "positive_engaged": "joy",
            "sad": "sadness", "depressed": "sadness", "lonely": "sadness",
            "anxious": "fear", "worry": "fear", "overthinking": "fear", "anxiety": "fear",
            "annoyed": "anger", "stress": "anger", "frustrated": "anger",
            "low_energy": "bored", "tired": "bored", "exhausted": "bored", "low_energy_bored": "bored",
            "calm": "neutral", "ok": "neutral", "fine": "neutral"
        }
        return mapping.get(l, l)

    df["label_clean"] = df["label"].apply(normalize_label)
    df = df[df["label_clean"].isin(label2id.keys())] # Filter unknowns
    df["labels"] = df["label_clean"].map(label2id)
    print(f"   ✅ Final Training Set: {len(df)} examples.")
    
    # Split
    dataset = Dataset.from_pandas(df[["text", "labels"]])
    dataset = dataset.train_test_split(test_size=0.1, seed=42)
    
    # 3. LOAD MODEL
    # Since earlier intermediate models (v12, v11) were cleaned up, we start from Base or existing V14 if available
    if os.path.exists(MODEL_SAVE_PATH):
        print(f"   Loading existing V14 model for further refinement: {MODEL_SAVE_PATH}")
        model_path = MODEL_SAVE_PATH
    else:
        print(f"   Loading fresh base model: {BASE_MODEL}")
        model_path = BASE_MODEL

    tokenizer = RobertaTokenizer.from_pretrained(model_path)
    model = RobertaForSequenceClassification.from_pretrained(
        model_path, 
        num_labels=6, 
        ignore_mismatched_sizes=True,
        id2label=id2label,
        label2id=label2id
    )
    
    # Tokenize
    def tokenize_function(examples):
        return tokenizer(examples["text"], padding="max_length", truncation=True, max_length=MAX_LENGTH)
        
    tokenized_datasets = dataset.map(tokenize_function, batched=True)

    # 4. TRAINER SETUP
    training_args = TrainingArguments(
        output_dir="./results_v14",
        eval_strategy="epoch",
        save_strategy="epoch",
        learning_rate=LEARNING_RATE,
        per_device_train_batch_size=BATCH_SIZE,
        per_device_eval_batch_size=BATCH_SIZE,
        num_train_epochs=NUM_EPOCHS,
        weight_decay=0.01,
        load_best_model_at_end=True,
        metric_for_best_model="f1",
        save_total_limit=2,
        logging_dir='./logs',
        logging_steps=50,
        report_to="none"
    )

    trainer = Trainer(
        model=model,
        args=training_args,
        train_dataset=tokenized_datasets["train"],
        eval_dataset=tokenized_datasets["test"],
        compute_metrics=compute_metrics,
        callbacks=[EarlyStoppingCallback(early_stopping_patience=2)]
    )

    # 5. TRAIN
    print("   Training...")
    trainer.train()
    
    # 6. SAVE
    print(f"💾 Saving V14 Final Model to {MODEL_SAVE_PATH}...")
    if os.path.exists(MODEL_SAVE_PATH): rmtree(MODEL_SAVE_PATH)
    trainer.save_model(MODEL_SAVE_PATH)
    tokenizer.save_pretrained(MODEL_SAVE_PATH)
    
    print("✅ V14 Model Training Complete!")

if __name__ == "__main__":
    train()
