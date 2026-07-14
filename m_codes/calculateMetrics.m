function Metrics = calculateMetrics(TrueLabels,PredictedLabels)
%==========================================================================
% CALCULATEMETRICS
%
% Computes classification metrics for multi-class classification.
%
% INPUTS
%   TrueLabels
%   PredictedLabels
%
% OUTPUT
%   Metrics
%
%==========================================================================

%% Confusion Matrix

CM = confusionmat(TrueLabels,PredictedLabels);

numClasses = size(CM,1);

TotalSamples = sum(CM(:));

%% -----------------------------------------------------------------------
% Overall Accuracy
%% -----------------------------------------------------------------------

Accuracy = sum(diag(CM))/TotalSamples;

%% -----------------------------------------------------------------------
% Initialize
%% -----------------------------------------------------------------------

Precision = zeros(numClasses,1);

Recall = zeros(numClasses,1);

Specificity = zeros(numClasses,1);

F1 = zeros(numClasses,1);

%% -----------------------------------------------------------------------
% Class-wise Metrics
%% -----------------------------------------------------------------------

for c = 1:numClasses

    TP = CM(c,c);

    FP = sum(CM(:,c)) - TP;

    FN = sum(CM(c,:)) - TP;

    TN = TotalSamples - TP - FP - FN;

    %% Precision

    if TP+FP==0
        Precision(c)=0;
    else
        Precision(c)=TP/(TP+FP);
    end

    %% Recall

    if TP+FN==0
        Recall(c)=0;
    else
        Recall(c)=TP/(TP+FN);
    end

    %% Specificity

    if TN+FP==0
        Specificity(c)=0;
    else
        Specificity(c)=TN/(TN+FP);
    end

    %% F1-score

    if Precision(c)+Recall(c)==0
        F1(c)=0;
    else
        F1(c)=2*Precision(c)*Recall(c)/...
              (Precision(c)+Recall(c));
    end

end

%% -----------------------------------------------------------------------
% Macro Average
%% -----------------------------------------------------------------------

Metrics.Accuracy = Accuracy;

Metrics.Precision = mean(Precision,"omitnan");

Metrics.Recall = mean(Recall,"omitnan");

Metrics.Specificity = mean(Specificity,"omitnan");

Metrics.F1Score = mean(F1,"omitnan");

%% -----------------------------------------------------------------------
% Class-wise Metrics
%% -----------------------------------------------------------------------

Metrics.ClassPrecision = Precision;

Metrics.ClassRecall = Recall;

Metrics.ClassSpecificity = Specificity;

Metrics.ClassF1 = F1;

%% -----------------------------------------------------------------------
% Confusion Matrix
%% -----------------------------------------------------------------------

Metrics.ConfusionMatrix = CM;

Metrics.TotalSamples = TotalSamples;

%% -----------------------------------------------------------------------
% Display
%% -----------------------------------------------------------------------

fprintf('\n');

disp('===============================================================')

disp(' Classification Metrics')

disp('===============================================================')

fprintf('Accuracy      : %.4f\n',Metrics.Accuracy);

fprintf('Precision     : %.4f\n',Metrics.Precision);

fprintf('Recall        : %.4f\n',Metrics.Recall);

fprintf('Specificity   : %.4f\n',Metrics.Specificity);

fprintf('F1-Score      : %.4f\n',Metrics.F1Score);

disp('===============================================================')

fprintf('\n');

end