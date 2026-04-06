# Fine-Tuning Proof: Emotion Model V14

This document confirms the successful fine-tuning of the **Emotion AI** model (`v14_final_model`) used in the AI Boredom System.

## 1. Architectural Proof
The model is a custom **RoBERTa-based** classifier fine-tuned specifically for the Boredom System's domain.
- **Base Model**: `cardiffnlp/twitter-roberta-base-emotion`
- **Output Classes**: 6 custom emotional states:
  - `joy` (0)
  - `sadness` (1)
  - `anger` (2)
  - `fear` (3)
  - `neutral` (4)
  - `bored` (5) - **[ADDED]**

### Model Configuration Reference
> `backend/models/v14_final_model/config.json`
```json
"id2label": {
  "0": "joy",
  "1": "sadness",
  "2": "anger",
  "3": "fear",
  "4": "neutral",
  "5": "bored"
}
```

## 2. Training Metrics (V14 Final)
The training was conducted for **5 epochs**, with early stopping triggered at epoch 3.0 due to high convergence and low loss.

| Metric | Final Value |
| :--- | :--- |
| **Highest Accuracy** | **98.16%** |
| **Best F1 Score** | **0.982** |
| **Final Loss** | **0.049** |
| **Total Examples** | (~1,630+ consolidated samples) |

### Training History Details
- **Step 92**: Accuracy 98.16% (Initial peak)
- **Step 184**: Accuracy 97.55%
- **Step 276**: Accuracy 97.55% | Final Step (Optimization converged)

## 3. Custom Dataset Snapshot
The model was trained on a consolidated student-life dataset (`v14_final_dataset.csv`) which includes fine-grained emotional labels that are normalized during training.

| Text | Original Label | Normalized Class |
| :--- | :--- | :--- |
| "Doomscrolling twitter and I can't stop..." | `low_energy_bored` | `bored` |
| "Why did I say that stupid thing earlier?" | `overthinking` | `fear` |
| "Hiding my tears behind a smile." | `sadness` | `sadness` |
| "literally no energy lately" | `bored` | `bored` |

## 4. Operational Proof
The application's `EmotionAnalyzer` service is explicitly configured to prioritize the **v14** model found in the local filesystem over standard Hugging Face models.

> **[`emotion_ai.py`](file:///Users/joeltharakan/Documents/AI%20Boredom%20System/backend/app/services/emotion_ai.py)**
```python
v14_path = os.path.abspath("models/v14_final_model")
# Priority: V14 -> V12 -> V11 -> V10 -> V9 -> Base 
model_to_use = v14_path if os.path.exists(v14_path) else ...
```

---
> [!TIP]
> The model is currently stored in `backend/models/v14_final_model/`. You can verify it further by running `python backend/scripts/evaluate_emotion_model.py`.
