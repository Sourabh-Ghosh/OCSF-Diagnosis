function summarizeCrossValidation( ...
    TrainingResults,...
    EvaluationResults,...
    Metrics,...
    classNames,...
    RunFolder)
%==========================================================================
% SUMMARIZECROSSVALIDATION
%
% Creates cross-validation summary plots and reports.
%
% INPUTS
%   TrainingResults
%   EvaluationResults
%   Metrics
%   classNames
%   RunFolder
%
% OUTPUT
%   Results/
%       Run_xxxxx/
%           Summary/
%
%               AverageTrainingCurves.png
%               AverageTrainingCurves.fig
%
%               AverageClassROC.png
%               AverageClassROC.fig
%               AverageClassAUC.xlsx
%
%               AverageConfusionMatrix.png
%               AverageConfusionMatrix.fig
%               AverageConfusionMatrix.xlsx
%
%               SummaryReport.txt
%
%==========================================================================

fprintf('\n');
disp('===============================================================')
disp('Cross-Validation Summary')
disp('===============================================================')

%% -----------------------------------------------------------------------
% Create Summary Folder
%% -----------------------------------------------------------------------

summaryFolder = fullfile(RunFolder,'Summary');

if ~exist(summaryFolder,'dir')
    mkdir(summaryFolder);
end

%% -----------------------------------------------------------------------
% Basic Information
%% -----------------------------------------------------------------------

numFolds = numel(TrainingResults);

numClasses = numel(classNames);

fprintf('Number of folds      : %d\n',numFolds);
fprintf('Number of classes    : %d\n',numClasses);

disp(' ')
disp(['Summary folder : ' summaryFolder])
disp(' ')

%% =======================================================================
% PART 1
%
% Average Training Curves
%
% (To be added next)
%==========================================================================

%% =======================================================================
% PART 1
%
% Average Training Curves
%==========================================================================

disp('Generating Average Training Curves...')

%% Initialization

%% -----------------------------------------------------------------------
% Read First Fold Training History
%% -----------------------------------------------------------------------

historyFile = fullfile(...
    RunFolder,...
    'Fold_1',...
    'TrainingHistory.xlsx');

EpochHistory = readtable(historyFile);

numEpochs = height(EpochHistory);

Epoch = EpochHistory.Epoch;

%% -----------------------------------------------------------------------
% Initialize
%% -----------------------------------------------------------------------

TrainAccuracy = zeros(numEpochs,numFolds);

ValidationAccuracy = zeros(numEpochs,numFolds);

TrainLoss = zeros(numEpochs,numFolds);

ValidationLoss = zeros(numEpochs,numFolds);

%% Collect Data

for fold = 1:numFolds

    historyFile = fullfile(...
    RunFolder,...
    sprintf('Fold_%d',fold),...
    'TrainingHistory.xlsx');

EpochHistory = readtable(historyFile);

    TrainAccuracy(:,fold) = EpochHistory.TrainingAccuracy;

    ValidationAccuracy(:,fold) = EpochHistory.ValidationAccuracy;

    TrainLoss(:,fold) = EpochHistory.TrainingLoss;

    ValidationLoss(:,fold) = EpochHistory.ValidationLoss;

end

%% Mean

MeanTrainAccuracy = mean(TrainAccuracy,2);

MeanValidationAccuracy = mean(ValidationAccuracy,2);

MeanTrainLoss = mean(TrainLoss,2);

MeanValidationLoss = mean(ValidationLoss,2);

%% Standard Deviation

StdTrainAccuracy = std(TrainAccuracy,0,2);

StdValidationAccuracy = std(ValidationAccuracy,0,2);

StdTrainLoss = std(TrainLoss,0,2);

StdValidationLoss = std(ValidationLoss,0,2);

%% Create Figure

figure(...
    'Color','w',...
    'Units','normalized',...
    'Position',[0.15 0.15 0.70 0.45]);
subplot(1,2,1)

hold on
grid on
box on

fill([Epoch; flipud(Epoch)],...
     [MeanTrainAccuracy-StdTrainAccuracy;
      flipud(MeanTrainAccuracy+StdTrainAccuracy)],...
     [0.85 0.85 1],...
     'EdgeColor','none',...
     'FaceAlpha',0.4);

fill([Epoch; flipud(Epoch)],...
     [MeanValidationAccuracy-StdValidationAccuracy;
      flipud(MeanValidationAccuracy+StdValidationAccuracy)],...
     [1 0.85 0.85],...
     'EdgeColor','none',...
     'FaceAlpha',0.4);

plot(Epoch,...
     MeanTrainAccuracy,...
     'b-',...
     'LineWidth',1.5);

plot(Epoch,...
     MeanValidationAccuracy,...
     'r-',...
     'LineWidth',1.5);

xlabel('Epoch',...
    'FontName','Times New Roman',...
    'FontSize',12);

ylabel('Accuracy (%)',...
    'FontName','Times New Roman',...
    'FontSize',12);

title('Average Accuracy',...
    'FontName','Times New Roman',...
    'FontWeight','bold');

legend(...
    {'Training \pm SD',...
     'Validation \pm SD',...
     'Training',...
     'Validation'},...
    'Location','southeast');

subplot(1,2,2)

hold on
grid on
box on

fill([Epoch; flipud(Epoch)],...
     [MeanTrainLoss-StdTrainLoss;
      flipud(MeanTrainLoss+StdTrainLoss)],...
     [0.85 0.85 1],...
     'EdgeColor','none',...
     'FaceAlpha',0.4);

fill([Epoch; flipud(Epoch)],...
     [MeanValidationLoss-StdValidationLoss;
      flipud(MeanValidationLoss+StdValidationLoss)],...
     [1 0.85 0.85],...
     'EdgeColor','none',...
     'FaceAlpha',0.4);

plot(Epoch,...
     MeanTrainLoss,...
     'b-',...
     'LineWidth',1.5);

plot(Epoch,...
     MeanValidationLoss,...
     'r-',...
     'LineWidth',1.5);

xlabel('Epoch',...
    'FontName','Times New Roman',...
    'FontSize',12);

ylabel('Loss',...
    'FontName','Times New Roman',...
    'FontSize',12);

title('Average Loss',...
    'FontName','Times New Roman',...
    'FontWeight','bold');

legend(...
    {'Training \pm SD',...
     'Validation \pm SD',...
     'Training',...
     'Validation'},...
    'Location','northeast');

%% Save

exportgraphics(gcf,...
    fullfile(summaryFolder,...
    'AverageTrainingCurves.png'),...
    'Resolution',600);

savefig(fullfile(summaryFolder,...
    'AverageTrainingCurves.fig'));

close(gcf);

disp('Average Training Curves saved.')


%% =======================================================================
% PART 2
%
% Average Confusion Matrix
%
% (To be added later)
%==========================================================================

disp('Generating Average Confusion Matrix...')

AverageCM = zeros(numClasses,numClasses);

for fold = 1:numFolds

    CM = Metrics(fold).ConfusionMatrix;

    RowSum = sum(CM,2);

    RowSum(RowSum==0) = 1;

    CM = CM ./ RowSum;

    AverageCM = AverageCM + CM;

end

AverageCM = AverageCM / numFolds;

AverageCMTable = array2table(...
    AverageCM,...
    'VariableNames',cellstr(string(classNames)),...
    'RowNames',cellstr(string(classNames)));

writetable(...
    AverageCMTable,...
    fullfile(summaryFolder,...
    'AverageConfusionMatrix.xlsx'),...
    'WriteRowNames',true);

figure(...
    'Color','w',...
    'Units','normalized',...
    'Position',[0.15 0.12 0.60 0.65]);

h = heatmap(...
    string(classNames),...
    string(classNames),...
    AverageCM);

h.Title = sprintf(...
    'Average Confusion Matrix (%d-Fold Cross-Validation)',...
    numFolds);

h.XLabel = 'Predicted Class';
h.YLabel = 'True Class';

h.FontName = 'Times New Roman';
h.FontSize = 12;

h.CellLabelFormat = '%.3f';

exportgraphics(...
    gcf,...
    fullfile(summaryFolder,...
    'AverageConfusionMatrix.png'),...
    'Resolution',600);

savefig(...
    fullfile(summaryFolder,...
    'AverageConfusionMatrix.fig'));

close(gcf);

disp('Average Confusion Matrix saved.')

%% =======================================================================
% Classification Summary
%==========================================================================

disp('Generating Classification Summary...')

Precision = zeros(numClasses,numFolds);
Recall = zeros(numClasses,numFolds);
Specificity = zeros(numClasses,numFolds);
F1 = zeros(numClasses,numFolds);
AUC = zeros(numClasses,numFolds);

for fold = 1:numFolds

    Precision(:,fold) = Metrics(fold).ClassPrecision;

    Recall(:,fold) = Metrics(fold).ClassRecall;

    Specificity(:,fold) = Metrics(fold).ClassSpecificity;

    F1(:,fold) = Metrics(fold).ClassF1;

    AUC(:,fold) = Metrics(fold).ClassAUC;

end

MeanPrecision = mean(Precision,2);
StdPrecision = std(Precision,0,2);

MeanRecall = mean(Recall,2);
StdRecall = std(Recall,0,2);

MeanSpecificity = mean(Specificity,2);
StdSpecificity = std(Specificity,0,2);

MeanF1 = mean(F1,2);
StdF1 = std(F1,0,2);

MeanAUC = mean(AUC,2);
StdAUC = std(AUC,0,2);

PrecisionText = strings(numClasses,1);
RecallText = strings(numClasses,1);
SpecificityText = strings(numClasses,1);
F1Text = strings(numClasses,1);
AUCText = strings(numClasses,1);

for c = 1:numClasses

    PrecisionText(c) = sprintf('%.4f ± %.4f',...
        MeanPrecision(c),StdPrecision(c));

    RecallText(c) = sprintf('%.4f ± %.4f',...
        MeanRecall(c),StdRecall(c));

    SpecificityText(c) = sprintf('%.4f ± %.4f',...
        MeanSpecificity(c),StdSpecificity(c));

    F1Text(c) = sprintf('%.4f ± %.4f',...
        MeanF1(c),StdF1(c));

    AUCText(c) = sprintf('%.4f ± %.4f',...
        MeanAUC(c),StdAUC(c));

end

ClassificationSummary = table(...
    (1:numClasses)',...
    string(classNames(:)),...
    PrecisionText,...
    RecallText,...
    SpecificityText,...
    F1Text,...
    AUCText,...
    'VariableNames',...
    {'ClassID',...
     'ClassName',...
     'Precision',...
     'Recall',...
     'Specificity',...
     'F1Score',...
     'AUC'});

writetable(...
    ClassificationSummary,...
    fullfile(summaryFolder,...
    'ClassificationSummary.xlsx'));

disp('Classification Summary saved.')


%% =======================================================================
% PART 3
%
% Summary Report
%
% (To be added later)
%==========================================================================

disp('Generating Summary Report...')

%% -----------------------------------------------------------------------
% Summary Statistics
%% -----------------------------------------------------------------------

Accuracy = [Metrics.Accuracy]';
Precision = [Metrics.Precision]';
Recall = [Metrics.Recall]';
Specificity = [Metrics.Specificity]';
F1Score = [Metrics.F1Score]';

InferenceTime = [Metrics.InferenceTime]';
AverageInferenceTime = [Metrics.AverageInferenceTime]';

TrainingTime = zeros(numFolds,1);

for fold = 1:numFolds
    TrainingTime(fold) = TrainingResults(fold).TrainingTime;
end

%% -----------------------------------------------------------------------
% Create Report
%% -----------------------------------------------------------------------

reportFile = fullfile(summaryFolder,'SummaryReport.txt');

fid = fopen(reportFile,'w');

fprintf(fid,'===============================================================\n');
fprintf(fid,' CNN CROSS-VALIDATION SUMMARY REPORT\n');
fprintf(fid,'===============================================================\n\n');

fprintf(fid,'Generated On : %s\n',char(datetime('now')));

fprintf(fid,'Number of Folds   : %d\n',numFolds);
fprintf(fid,'Number of Classes : %d\n\n',numClasses);

fprintf(fid,'---------------------------------------------------------------\n');
fprintf(fid,'CLASSIFICATION PERFORMANCE\n');
fprintf(fid,'---------------------------------------------------------------\n');

fprintf(fid,'Accuracy      : %.4f ± %.4f\n',...
    mean(Accuracy),std(Accuracy));

fprintf(fid,'Precision     : %.4f ± %.4f\n',...
    mean(Precision),std(Precision));

fprintf(fid,'Recall        : %.4f ± %.4f\n',...
    mean(Recall),std(Recall));

fprintf(fid,'Specificity   : %.4f ± %.4f\n',...
    mean(Specificity),std(Specificity));

fprintf(fid,'F1-Score      : %.4f ± %.4f\n\n',...
    mean(F1Score),std(F1Score));

fprintf(fid,'---------------------------------------------------------------\n');
fprintf(fid,'COMPUTATIONAL PERFORMANCE\n');
fprintf(fid,'---------------------------------------------------------------\n');

fprintf(fid,'Training Time (s)          : %.2f ± %.2f\n',...
    mean(TrainingTime),std(TrainingTime));

fprintf(fid,'Inference Time (s)         : %.4f ± %.4f\n',...
    mean(InferenceTime),std(InferenceTime));

fprintf(fid,'Average Inference Time (s) : %.6f ± %.6f\n\n',...
    mean(AverageInferenceTime),...
    std(AverageInferenceTime));

fprintf(fid,'---------------------------------------------------------------\n');
fprintf(fid,'GENERATED FILES\n');
fprintf(fid,'---------------------------------------------------------------\n');

fprintf(fid,'AverageTrainingCurves.png\n');
fprintf(fid,'AverageTrainingCurves.fig\n\n');

fprintf(fid,'AverageConfusionMatrix.png\n');
fprintf(fid,'AverageConfusionMatrix.fig\n');
fprintf(fid,'AverageConfusionMatrix.xlsx\n\n');

fprintf(fid,'ClassificationSummary.xlsx\n');

fprintf(fid,'===============================================================\n');
fprintf(fid,'End of Report\n');
fprintf(fid,'===============================================================\n');

fclose(fid);

disp('Summary Report saved.')

disp('===============================================================')
disp('Cross-Validation Summary Completed')
disp('===============================================================')
disp(' ')

end