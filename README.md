# Open-Circuit Fault Diagnosis in Active Front-End Converter using Lightweight LeNet-based Network

A MATLAB-based deep learning framework for the diagnosis of multi-switch open-circuit faults (OCSFs) in three-phase Active Front-End (AFE) rectifiers using a lightweight convolutional neural network (CNN).

The framework provides a complete and reproducible pipeline for:

- Dataset preparation
- Stratified K-fold cross-validation
- CNN training and evaluation
- Performance metric computation
- Training and validation curve visualization
- ROC and confusion matrix generation
- Cross-validation performance summarization
- Dataset complexity analysis
- Randomization (label permutation) testing
- Automatic generation of publication-quality figures and tables

---

<img width="945" height="362" alt="image" src="https://github.com/user-attachments/assets/a7c2ca3c-6cb6-4ef5-aaf2-1841ace10c3e" />



# Repository Structure

```
OCSF-Diagnosis/
│
├── src/
│   ├── main.m
│   ├── createNetwork.m
│   ├── trainNetwork.m
│   ├── evaluateModel.m
│   ├── computeMetrics.m
│   ├── calculateMetrics.m
│   ├── plotTrainingCurves.m
│   ├── plotROC.m
│   ├── plotConfusionMatrix.m
│   ├── summarizeCrossValidation.m
│   ├── analyzeDatasetComplexity.m
│   ├── randomizationTest.m
│   └── ...
│
├── data/
│   └── README.md
│
├── results/
│
├── pretrained_models/
│
├── docs/
│
├── figures/
│
├── LICENSE
├── CITATION.cff
└── README.md
```

---

# Framework Workflow

```
Dataset
    │
    ▼
Image Datastore
    │
    ▼
Stratified K-Fold Cross Validation
    │
    ▼
CNN Training
    │
    ▼
Model Evaluation
    │
    ▼
Performance Metrics
    │
    ├── Accuracy
    ├── Precision
    ├── Recall
    ├── Specificity
    ├── F1-score
    ├── Inference Time
    │
    ▼
Visualization
    ├── Training Curves
    ├── ROC Curves
    └── Confusion Matrices
    │
    ▼
Cross-Validation Summary
    │
    ▼
Dataset Complexity Analysis
    │
    ▼
Randomization Test
```

---

# Network Architecture

The proposed lightweight CNN consists of:

1. Input Layer
2. Convolution Block 1
3. Batch Normalization
4. ReLU
5. Max Pooling
6. Convolution Block 2
7. Batch Normalization
8. ReLU
9. Max Pooling
10. Convolution Block 3
11. Batch Normalization
12. ReLU
13. Global Average Pooling
14. Fully Connected Layer
15. ReLU
16. Dropout
17. Fully Connected Output Layer
18. Softmax Layer

---

# Requirements

The framework was developed using

- MATLAB R2024b (or later recommended)

Required MATLAB Toolboxes

- Deep Learning Toolbox
- Statistics and Machine Learning Toolbox
- Image Processing Toolbox

---

# Dataset

The experimental dataset is publicly available at

https://dx.doi.org/10.21227/df03-g309

After downloading the dataset, place the image folders inside

```
data/
```

Update the dataset path in

```
main.m
```

before running the code.



# Running the Framework

Open MATLAB and navigate to

```
src/
```

Then simply execute

```matlab
main
```

The complete workflow is executed automatically.

---

# Generated Outputs

Each execution creates a timestamped results directory.

Example

```
Results/

Run_2026_07_14_183015/

    Fold_1/
    Fold_2/
    Fold_3/
    Fold_4/
    Fold_5/

    Summary/

    DatasetAnalysis/

    RandomizationTest/

    OverallMetrics.xlsx
    PerformanceSummary.xlsx
    Metrics.mat
```

---

# Evaluation Metrics

The framework automatically computes

- Accuracy
- Precision
- Recall
- Specificity
- F1-score
- Inference Time
- Average Inference Time

---

# Visualization

The framework automatically generates

- Training Accuracy
- Validation Accuracy
- Training Loss
- Validation Loss
- Fold-wise ROC Curves
- Fold-wise Confusion Matrices
- Average Confusion Matrix
- Average Training Curves
- Randomization Comparison Plot

---

# Dataset Complexity Analysis

The framework computes

- Average Intra-class Distance
- Nearest Inter-class Distance
- Separation Ratio

Results are exported to

```
DatasetAnalysis/
```

---

# Randomization Test

A label permutation experiment is implemented to verify that the CNN learns meaningful image-label relationships rather than random associations.

The framework reports

- Original Performance
- Randomized Performance
- Comparison Figures
- Statistical Summary

---

# Citation

If you use this framework in your research, please cite:

> S. Ghosh, A. K. Singh, E. Hassan, S. N. Singh, "Open-Circuit Fault Diagnosis in Active Front-End Converter using Lightweight LeNet-based Network," *(update with publication details after acceptance).*

---

# License

This project is released under the MIT License.

See the LICENSE file for details.

---

# Acknowledgement

If this framework contributes to your research, please consider citing the associated publication.
