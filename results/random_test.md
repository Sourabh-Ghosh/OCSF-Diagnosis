---------------------------------------------------------------
ORIGINAL DATASET
---------------------------------------------------------------
Accuracy      : 0.98396 ± 0.00984\
Precision     : 0.98444 ± 0.01401\
Recall        : 0.98333 ± 0.01007\
Specificity   : 0.99958 ± 0.00026\
F1-score      : 0.98124 ± 0.01250

---------------------------------------------------------------
RANDOMIZED LABELS
---------------------------------------------------------------
Accuracy      : 0.02083 ± 0.00910\
Precision     : 0.01949 ± 0.01228\
Recall        : 0.02274 ± 0.01589\
Specificity   : 0.97435 ± 0.00028\
F1-score      : 0.01711 ± 0.01002

---------------------------------------------------------------
INTERPRETATION
---------------------------------------------------------------
Randomizing the correspondence between images and class labels causes the classification performance to collapse towards chance level.

This demonstrates that the CNN learns genuine image-label relationships rather than memorizing the training data.
