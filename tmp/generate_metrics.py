import matplotlib.pyplot as plt
import json
import os

# Data extracted from trainer_state.json
log_history = [
    {"epoch": 0.54, "loss": 0.1131, "step": 50},
    {"epoch": 1.0, "eval_accuracy": 0.9816, "eval_f1": 0.9816, "eval_loss": 0.1207, "step": 92},
    {"epoch": 1.09, "loss": 0.095, "step": 100},
    {"epoch": 1.63, "loss": 0.057, "step": 150},
    {"epoch": 2.0, "eval_accuracy": 0.9754, "eval_f1": 0.9754, "eval_loss": 0.0907, "step": 184},
    {"epoch": 2.17, "loss": 0.0477, "step": 200},
    {"epoch": 2.72, "loss": 0.036, "step": 250},
    {"epoch": 3.0, "eval_accuracy": 0.9754, "eval_f1": 0.9754, "eval_loss": 0.0497, "step": 276}
]

epochs_train = [log["epoch"] for log in log_history if "loss" in log]
loss_train = [log["loss"] for log in log_history if "loss" in log]

epochs_eval = [log["epoch"] for log in log_history if "eval_loss" in log]
loss_eval = [log["eval_loss"] for log in log_history if "eval_loss" in log]
acc_eval = [log["eval_accuracy"] for log in log_history if "eval_accuracy" in log]
f1_eval = [log["eval_f1"] for log in log_history if "eval_f1" in log]

# Create Artifacts directory if it doesn't exist (though it should)
output_dir = "/Users/joeltharakan/Documents/AI Boredom System/artifacts"
os.makedirs(output_dir, exist_ok=True)

# Plot 1: Loss Curve
plt.figure(figsize=(10, 6))
plt.plot(epochs_train, loss_train, label='Training Loss', marker='o', color='#3b82f6', linewidth=2)
plt.plot(epochs_eval, loss_eval, label='Evaluation Loss', marker='s', color='#ef4444', linewidth=2)
plt.title('Training and Evaluation Loss (RoBERTa V14 Fine-Tuning)', fontsize=14, pad=20)
plt.xlabel('Epoch', fontsize=12)
plt.ylabel('Loss', fontsize=12)
plt.grid(True, linestyle='--', alpha=0.7)
plt.legend()
plt.savefig(os.path.join(output_dir, 'loss_curve.png'), dpi=300, bbox_inches='tight')
plt.close()

# Plot 2: Accuracy and F1 Score
plt.figure(figsize=(10, 6))
plt.plot(epochs_eval, [a*100 for a in acc_eval], label='Accuracy (%)', marker='o', color='#10b981', linewidth=2)
plt.plot(epochs_eval, [f*100 for f in f1_eval], label='F1-Score (%)', marker='s', color='#8b5cf6', linewidth=2)
plt.title('Model Performance Metrics (V14 Final)', fontsize=14, pad=20)
plt.xlabel('Epoch', fontsize=12)
plt.ylabel('Percentage (%)', fontsize=12)
plt.ylim(90, 100)
plt.grid(True, linestyle='--', alpha=0.7)
plt.legend()
plt.savefig(os.path.join(output_dir, 'performance_metrics.png'), dpi=300, bbox_inches='tight')
plt.close()

print(f"Graphs generated successfully in {output_dir}")
