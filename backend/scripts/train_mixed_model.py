
import os
import pandas as pd
import numpy as np
from datasets import Dataset, concatenate_datasets
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
SYNTHETIC_DATA_FILE = "data/emotional_wellness_dataset.csv"
LARGE_DATA_FILE = "/Users/joeltharakan/Documents/AI Boredom System/emotions.csv"
OUTPUT_DIR = "models/fine_tuned_roberta_v2"
BATCH_SIZE = 16
NUM_EPOCHS = 5

# --- Load Synthetic Data ---
# This data is highly relevant, so we keep all of it (500 samples)
# and we even repeat it to give it more weight vs the large general dataset.
print(f"Loading synthetic data from {SYNTHETIC_DATA_FILE}...")
df_synthetic = pd.read_csv(SYNTHETIC_DATA_FILE)
# Multiply synthetic dataset to increase its presence
# Multiply synthetic dataset to increase its presence significantly (10x)
df_synthetic_upsampled = pd.concat([df_synthetic] * 10, ignore_index=True)
print(f"Upsampled synthetic dataset size: {len(df_synthetic_upsampled)}")

# --- Load Large Data ---
print(f"Loading large data from {LARGE_DATA_FILE}...")
df_large = pd.read_csv(LARGE_DATA_FILE)

# Map numeric labels to string labels
label_map = {
    0: "sadness",
    1: "joy",
    2: "love",
    3: "anger",
    4: "fear",
    5: "surprise"
}
df_large['label'] = df_large['label'].map(label_map)

# Stratified Sampling for Large Dataset
# We want a balanced representation of general emotions, not overwhelmed by 'joy' or 'sadness'.
# We take 200 samples per category (6 categories * 200 = 1200 samples).
# This creates a ratio of roughly 1:1 between general emotions and specific wellness ones.
# We take 2000 samples per category (6 categories * 2000 = 12000 samples).
# This creates a ratio of roughly 2:1 between general emotions and specific wellness ones.
SAMPLES_PER_CATEGORY_LARGE = 2000

df_large_sampled = df_large.groupby('label').apply(lambda x: x.sample(n=min(len(x), SAMPLES_PER_CATEGORY_LARGE), random_state=42)).reset_index(drop=True)
print(f"Sampled large dataset size (balanced): {len(df_large_sampled)}")
print(df_large_sampled['label'].value_counts())

# Combine
df_combined = pd.concat([df_large_sampled, df_synthetic_upsampled], ignore_index=True)
# Shuffle
df_combined = df_combined.sample(frac=1, random_state=42).reset_index(drop=True)

print(f"Combined dataset size: {len(df_combined)}")
print("Final Label distribution:")
print(df_combined['label'].value_counts())

# Create label maps for model
labels = df_combined['label'].unique().tolist()
label2id = {label: i for i, label in enumerate(labels)}
id2label = {i: label for i, label in enumerate(labels)}

df_combined['labels'] = df_combined['label'].map(label2id)

# Split
train_df, val_df = train_test_split(df_combined, test_size=0.1, random_state=42)
train_dataset = Dataset.from_pandas(train_df)
val_dataset = Dataset.from_pandas(val_df)

# --- Tokenize ---
print("Tokenizing...")
tokenizer = AutoTokenizer.from_pretrained(BASE_MODEL)

def tokenize_function(examples):
    return tokenizer(examples["text"], padding="max_length", truncation=True, max_length=128)

tokenized_train = train_dataset.map(tokenize_function, batched=True)
tokenized_val = val_dataset.map(tokenize_function, batched=True)

# Cleanup columns
cols_to_remove = [col for col in tokenized_train.column_names if col not in ["input_ids", "attention_mask", "labels"]]
tokenized_train = tokenized_train.remove_columns(cols_to_remove)
tokenized_val = tokenized_val.remove_columns(cols_to_remove)

tokenized_train.set_format("torch")
tokenized_val.set_format("torch")

# --- Model Setup ---
print("Initializing Model...")
model = AutoModelForSequenceClassification.from_pretrained(
    BASE_MODEL, 
    num_labels=len(labels),
    problem_type="single_label_classification",
    ignore_mismatched_sizes=True,
    id2label=id2label,
    label2id=label2id
)

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
    logging_steps=50,
    load_best_model_at_end=True,
    metric_for_best_model="f1",
    save_total_limit=1,
    use_cpu=True
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

# Output mappings for app
print("UPDATED LABEL MAPPING for deployment:")
print(label_map)
print("-" * 20)
print("ALL LABELS:")
for i, lbl in id2label.items():
    print(f"{lbl}")
    
print("Done! Model is ready for use.")
