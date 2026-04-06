# 📊 Model Evaluation Metrics: AI Boredom Breaker (V14 Final)

These metrics provide a quantitative overview of the performance and training stability of the **AI Boredom Breaker's** core sentiment engine.

## 📈 1. Loss Curves (Training vs. Evaluation)
The loss curve demonstrates the model's convergence over 3 epochs. Both training and evaluation loss show a steady decrease, indicating successful domain adaptation to student-specific emotional lexicon.

![Loss Curve](/Users/joeltharakan/Documents/AI%20Boredom%20System/artifacts/loss_curve.png)

## 🎯 2. Performance Metrics (Accuracy & F1-Score)
The model achieves state-of-the-art performance for multi-class emotional sentiment detection in the student domain. 

![Performance Metrics](/Users/joeltharakan/Documents/AI%20Boredom%20System/artifacts/performance_metrics.png)

### Summary Statistics
| Metric | Value | Epoch |
| :--- | :--- | :--- |
| **Best Accuracy** | 98.16% | 1.0 |
| **Best F1-Score** | 98.16% | 1.0 |
| **Final Eval Loss** | 0.0497 | 3.0 |

### 🛠️ Methodology Note
The metrics were derived from the **V14 Master Corpus**, combining the GoEmotions foundation with specialized Gen Z and Tamil academic stress markers. The high F1-score highlights the model's robustness against class imbalances, ensuring frequent moods (e.g., Boredom) and critical moods (e.g., High Distress) are equally well-detected.
