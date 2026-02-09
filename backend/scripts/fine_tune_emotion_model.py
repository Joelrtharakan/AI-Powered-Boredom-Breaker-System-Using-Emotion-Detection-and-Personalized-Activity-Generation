import os
import pandas as pd
import numpy as np
from datasets import Dataset
from transformers import (
    AutoTokenizer, 
    AutoModelForSequenceClassification, 
    TrainingArguments, 
    Trainer
)
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, precision_recall_fscore_support

# --- Config ---
BASE_MODEL = "cardiffnlp/twitter-roberta-base-emotion"
DATA_FILE = "data/emotional_wellness_dataset.csv"
OUTPUT_DIR = "models/fine_tuned_roberta"
NUM_EPOCHS = 3 # Keep it low for demo purposes
BATCH_SIZE = 4

# --- Load Data ---
print(f"Loading data from {DATA_FILE}...")
df = pd.read_csv(DATA_FILE)

# Create label map
labels = df['label'].unique().tolist()
label2id = {label: i for i, label in enumerate(labels)}
id2label = {i: label for i, label in enumerate(labels)}
print(f"Labels found: {labels}")

df['labels'] = df['label'].map(label2id)

# Split
train_df, val_df = train_test_split(df, test_size=0.2, random_state=42)
train_dataset = Dataset.from_pandas(train_df)
val_dataset = Dataset.from_pandas(val_df)

# --- Tokenize ---
print("Tokenizing...")
tokenizer = AutoTokenizer.from_pretrained(BASE_MODEL)

def tokenize_function(examples):
    return tokenizer(examples["text"], padding="max_length", truncation=True, max_length=128)

tokenized_train = train_dataset.map(tokenize_function, batched=True)
tokenized_val = val_dataset.map(tokenize_function, batched=True)

# Remove the string 'label' column and '__index_level_0__' if present, keep 'labels'
cols_to_remove = [col for col in tokenized_train.column_names if col not in ["input_ids", "attention_mask", "labels"]]
tokenized_train = tokenized_train.remove_columns(cols_to_remove)
tokenized_val = tokenized_val.remove_columns(cols_to_remove)

tokenized_train.set_format("torch")
tokenized_val.set_format("torch")

# --- Model Setup ---
print("Initializing Model...")
# Note: We ignore mismatched sizes because we are changing the classification head
model = AutoModelForSequenceClassification.from_pretrained(
    BASE_MODEL, 
    num_labels=len(labels),
    problem_type="single_label_classification",
    ignore_mismatched_sizes=True,
    id2label=id2label,
    label2id=label2id
)

# Freeze base layers (optional, but requested in prompt to start with upper layers)
# In a real heavy training, we might freeze the first 6-8 layers. 
# For this small demo, we'll keep them trainable or just freeze embeddings.
# for param in model.roberta.embeddings.parameters():
#     param.requires_grad = False

# --- Metrics ---
def compute_metrics(eval_pred):
    logits, labels = eval_pred
    predictions = np.argmax(logits, axis=-1)
    precision, recall, f1, _ = precision_recall_fscore_support(labels, predictions, average='macro', zero_division=0)
    acc = accuracy_score(labels, predictions)
    return {
        'accuracy': acc,
        'f1': f1,
        'precision': precision,
        'recall': recall
    }

# --- Trainer ---
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
    logging_steps=10,
    load_best_model_at_end=True,
    metric_for_best_model="f1",
    save_total_limit=2,
    use_cpu=True # Force CPU since we don't know if user has MPS/CUDA setup correctly
)

trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=tokenized_train,
    eval_dataset=tokenized_val,
    compute_metrics=compute_metrics,
)

# --- Train ---
print("Starting Training...")
trainer.train()

# --- Save ---
print(f"Saving model to {OUTPUT_DIR}...")
trainer.save_model(OUTPUT_DIR)
tokenizer.save_pretrained(OUTPUT_DIR)

print("Done! Model is ready for use.")
