function EvaluationResults = evaluateModel( ...
    TrainingResults,...
    imds,...
    folds,...
    classNames,...
    RunFolder)
%==========================================================================
% EVALUATEMODEL
% Evaluates the trained CNN on the independent test set for each fold.
%==========================================================================

numFolds = numel(folds);
EvaluationResults = struct();

if ~exist('Results','dir')
    mkdir('Results');
end

SummaryFold = zeros(numFolds,1);
SummaryNumImages = zeros(numFolds,1);
SummaryInferenceTime = zeros(numFolds,1);
SummaryAverageTime = zeros(numFolds,1);

for fold = 1:numFolds

    fprintf('\n===============================================================\n');
    fprintf('Evaluating Fold %d / %d\n',fold,numFolds);
    fprintf('===============================================================\n');

    imdsTest = subset(imds,folds{fold}.TestIndices);
    net = TrainingResults(fold).Network;

    tic
    Scores = minibatchpredict(net,imdsTest);
    InferenceTime = toc;

    PredictedLabels = scores2label(Scores,classNames);
    TrueLabels = imdsTest.Labels;
    AverageInferenceTime = InferenceTime/numel(TrueLabels);

    EvaluationResults(fold).Scores = Scores;
    EvaluationResults(fold).PredictedLabels = PredictedLabels;
    EvaluationResults(fold).TrueLabels = TrueLabels;
    EvaluationResults(fold).InferenceTime = InferenceTime;
    EvaluationResults(fold).AverageInferenceTime = AverageInferenceTime;

    foldFolder = fullfile(RunFolder,sprintf('Fold_%d',fold));

    if ~exist(foldFolder,'dir')
        mkdir(foldFolder);
    end

    save(fullfile(foldFolder,'EvaluationResults.mat'),...
        'Scores','PredictedLabels','TrueLabels',...
        'InferenceTime','AverageInferenceTime','classNames');

    PredictionTable = table(...
        (1:numel(TrueLabels))',...
        TrueLabels,...
        PredictedLabels,...
        'VariableNames',{'Sample','TrueLabel','PredictedLabel'});

    writetable(PredictionTable,...
        fullfile(foldFolder,'PredictionResults.xlsx'));

    SummaryFold(fold)=fold;
    SummaryNumImages(fold)=numel(TrueLabels);
    SummaryInferenceTime(fold)=InferenceTime;
    SummaryAverageTime(fold)=AverageInferenceTime;

    fprintf('Test Images                : %d\n',numel(TrueLabels));
    fprintf('Inference Time (s)         : %.4f\n',InferenceTime);
    fprintf('Average Time/Image (ms)    : %.4f\n',AverageInferenceTime*1000);

end

SummaryTable = table(...
    SummaryFold,...
    SummaryNumImages,...
    SummaryInferenceTime,...
    SummaryAverageTime,...
    'VariableNames',{'Fold','NumTestImages',...
    'InferenceTime','AverageInferenceTimePerImage'});

writetable(SummaryTable,...
    fullfile(RunFolder,'EvaluationSummary.xlsx'));

disp(' ');
disp('===============================================================');
disp('Evaluation Completed Successfully');
disp('===============================================================');
disp(SummaryTable);
disp('===============================================================');

end
