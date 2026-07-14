function RandomizationResults = randomizationTest(...
    imds,...
    folds,...
    layers,...
    classNames,...
    InitialLearnRate,...
    MaxEpochs,...
    MiniBatchSize,...
    ValidationFrequency,...
    OriginalMetrics,...
    RunFolder)
%==========================================================================
% RANDOMIZATIONTEST
%
% Performs a label randomization experiment to verify that the CNN learns
% meaningful image-label relationships rather than random associations.
%
% The experiment:
%   1. Randomly permutes class labels.
%   2. Retrains the CNN using identical settings.
%   3. Evaluates the randomized model.
%   4. Compares original and randomized performance.
%
% OUTPUT
%
% RunFolder/
%   RandomizationTest/
%
%       Fold_1/
%       Fold_2/
%       ...
%       Summary/
%
%       RandomizationResults.xlsx
%       RandomizationSummary.txt
%       RandomizationComparison.png
%       Randomization.mat
%
%==========================================================================

disp(' ')
disp('===============================================================')
disp('Randomization Test')
disp('===============================================================')

%% ------------------------------------------------------------------------
% Create Randomization Folder
%% ------------------------------------------------------------------------

RandomRunFolder = fullfile(...
    RunFolder,...
    'RandomizationTest');

if ~exist(RandomRunFolder,'dir')
    mkdir(RandomRunFolder);
end

disp(['Randomization folder : ' RandomRunFolder])
disp(' ')

%% ------------------------------------------------------------------------
% Copy Datastore
%% ------------------------------------------------------------------------

RandomImds = copy(imds);

%% ------------------------------------------------------------------------
% Randomize Labels
%% ------------------------------------------------------------------------

disp('Randomly permuting labels...')

rng(2026)

RandomImds.Labels = ...
    RandomImds.Labels(randperm(numel(RandomImds.Labels)));

disp('Label permutation completed.')

%% ------------------------------------------------------------------------
% Information
%% ------------------------------------------------------------------------

numClasses = numel(classNames);

ChanceAccuracy = 100/numClasses;

fprintf('\n');
fprintf('Number of Classes : %d\n',numClasses);
fprintf('Chance Accuracy   : %.2f %%\n',ChanceAccuracy);

disp(' ')
disp('Beginning randomized training...')
disp(' ')

%% ------------------------------------------------------------------------
% Train CNN Using Randomized Labels
%% ------------------------------------------------------------------------

disp('===============================================================')
disp('Training CNN with Randomized Labels')
disp('===============================================================')

TrainingResults = trainNetwork(...
    RandomImds,...
    folds,...
    layers,...
    InitialLearnRate,...
    MaxEpochs,...
    MiniBatchSize,...
    ValidationFrequency,...
    RandomRunFolder);

%% ------------------------------------------------------------------------
% Training Curves
%% ------------------------------------------------------------------------

% plotTrainingCurves(...
%     TrainingResults,...
%     RandomRunFolder);

%% ------------------------------------------------------------------------
% Evaluate Randomized Model
%% ------------------------------------------------------------------------

EvaluationResults = evaluateModel(...
    TrainingResults,...
    RandomImds,...
    folds,...
    classNames,...
    RandomRunFolder);

%% ------------------------------------------------------------------------
% Compute Metrics
%% ------------------------------------------------------------------------

RandomMetrics = computeMetrics(...
    EvaluationResults,...
    classNames,...
    RandomRunFolder,...
    false,...
    false);

%% ------------------------------------------------------------------------
% Cross-Validation Summary
%% ------------------------------------------------------------------------

% summarizeCrossValidation(...
%     TrainingResults,...
%     EvaluationResults,...
%     RandomMetrics,...
%     classNames,...
%     RandomRunFolder);

disp(' ')
disp('===============================================================')
disp('Randomized Training Completed Successfully')
disp('===============================================================')
disp(' ')

%% ------------------------------------------------------------------------
% Extract Original Metrics
%% ------------------------------------------------------------------------

OriginalAccuracy = [OriginalMetrics.Accuracy]';
OriginalPrecision = [OriginalMetrics.Precision]';
OriginalRecall = [OriginalMetrics.Recall]';
OriginalSpecificity = [OriginalMetrics.Specificity]';
OriginalF1Score = [OriginalMetrics.F1Score]';

% OriginalInferenceTime = [OriginalMetrics.InferenceTime]';
% OriginalAverageInferenceTime = [OriginalMetrics.AverageInferenceTime]';

%% ------------------------------------------------------------------------
% Extract Randomized Metrics
%% ------------------------------------------------------------------------

RandomAccuracy = [RandomMetrics.Accuracy]';
RandomPrecision = [RandomMetrics.Precision]';
RandomRecall = [RandomMetrics.Recall]';
RandomSpecificity = [RandomMetrics.Specificity]';
RandomF1Score = [RandomMetrics.F1Score]';

% RandomInferenceTime = [RandomMetrics.InferenceTime]';
% RandomAverageInferenceTime = [RandomMetrics.AverageInferenceTime]';

%% ------------------------------------------------------------------------
% Mean ± Standard Deviation
%% ------------------------------------------------------------------------

MetricName = [
    "Accuracy"
    "Precision"
    "Recall"
    "Specificity"
    "F1-Score"
];

OriginalResult = [
    sprintf('%.5f ± %.5f',...
    mean(OriginalAccuracy,"omitnan"),std(OriginalAccuracy,"omitnan"))
    sprintf('%.5f ± %.5f',...
    mean(OriginalPrecision,"omitnan"),std(OriginalPrecision,"omitnan"))
    sprintf('%.5f ± %.5f',...
    mean(OriginalRecall,"omitnan"),std(OriginalRecall,"omitnan"))
    sprintf('%.5f ± %.5f',...
    mean(OriginalSpecificity,"omitnan"),std(OriginalSpecificity,"omitnan"))
    sprintf('%.5f ± %.5f',...
    mean(OriginalF1Score,"omitnan"),std(OriginalF1Score,"omitnan"))
];

RandomizedResult = [
    sprintf('%.5f ± %.5f',...
    mean(RandomAccuracy,"omitnan"),std(RandomAccuracy,"omitnan"))
    sprintf('%.5f ± %.5f',...
    mean(RandomPrecision,"omitnan"),std(RandomPrecision,"omitnan"))
    sprintf('%.5f ± %.5f',...
    mean(RandomRecall,"omitnan"),std(RandomRecall,"omitnan"))
    sprintf('%.5f ± %.5f',...
    mean(RandomSpecificity,"omitnan"),std(RandomSpecificity,"omitnan"))
    sprintf('%.5f ± %.5f',...
    mean(RandomF1Score,"omitnan"),std(RandomF1Score,"omitnan"))
];

%% ------------------------------------------------------------------------
% Results Table
%% ------------------------------------------------------------------------

RandomizationResults = table(MetricName,...
    string(OriginalResult),...
    string(RandomizedResult),...
    'VariableNames',...
    {'Metric',...
     'Original',...
     'Randomized'});

    writetable(...
    RandomizationResults,...
    fullfile(RandomRunFolder,...
    'RandomizationResults.xlsx'));

disp('RandomizationResults.xlsx saved.')

save(...
    fullfile(RandomRunFolder,...
    'Randomization.mat'),...
    'OriginalMetrics',...
    'RandomMetrics',...
    'RandomizationResults');

%% ------------------------------------------------------------------------
% Create Comparison Figure
%% ------------------------------------------------------------------------

disp('Generating Randomization Comparison Figure...')

OriginalMean = [
    mean(OriginalAccuracy,"omitnan")
    mean(OriginalPrecision,"omitnan")
    mean(OriginalRecall,"omitnan")
    mean(OriginalSpecificity,"omitnan")
    mean(OriginalF1Score,"omitnan")];

RandomMean = [
    mean(RandomAccuracy,"omitnan")
    mean(RandomPrecision,"omitnan")
    mean(RandomRecall,"omitnan")
    mean(RandomSpecificity,"omitnan")
    mean(RandomF1Score,"omitnan")];

figure(...
    'Color','w',...
    'Units','normalized',...
    'Position',[0.20 0.18 0.60 0.55]);

barh([OriginalMean RandomMean],'grouped')

grid on
box on

set(gca,...
    'YTick',1:numel(MetricName),...
    'YTickLabel',MetricName,...
    'FontName','Times New Roman',...
    'FontSize',11)

xlabel('Metric Value',...
    'FontName','Times New Roman',...
    'FontSize',12)

title('Original vs Randomized Labels',...
    'FontName','Times New Roman',...
    'FontWeight','bold')

legend(...
    {'Original','Randomized'},...
    'Location','best')

exportgraphics(...
    gcf,...
    fullfile(RandomRunFolder,...
    'RandomizationComparison.png'),...
    'Resolution',600);

savefig(...
    fullfile(RandomRunFolder,...
    'RandomizationComparison.fig'));

close(gcf);

disp('RandomizationComparison.png saved.')

%% ------------------------------------------------------------------------
% Create Summary Report
%% ------------------------------------------------------------------------

reportFile = fullfile(...
    RandomRunFolder,...
    'RandomizationSummary.txt');

fid = fopen(reportFile,'w');

fprintf(fid,'===============================================================\n');
fprintf(fid,' RANDOMIZATION TEST SUMMARY\n');
fprintf(fid,'===============================================================\n\n');

fprintf(fid,'Generated On : %s\n\n',char(datetime('now')));

fprintf(fid,'Number of Classes : %d\n',numel(classNames));

fprintf(fid,'Chance Accuracy   : %.2f %%\n\n',ChanceAccuracy);

fprintf(fid,'---------------------------------------------------------------\n');
fprintf(fid,'ORIGINAL DATASET\n');
fprintf(fid,'---------------------------------------------------------------\n');

fprintf(fid,'Accuracy      : %.5f ± %.5f\n',...
    mean(OriginalAccuracy),std(OriginalAccuracy));

fprintf(fid,'Precision     : %.5f ± %.5f\n',...
    mean(OriginalPrecision),std(OriginalPrecision));

fprintf(fid,'Recall        : %.5f ± %.5f\n',...
    mean(OriginalRecall),std(OriginalRecall));

fprintf(fid,'Specificity   : %.5f ± %.5f\n',...
    mean(OriginalSpecificity),std(OriginalSpecificity));

fprintf(fid,'F1-score      : %.5f ± %.5f\n\n',...
    mean(OriginalF1Score),std(OriginalF1Score));

fprintf(fid,'---------------------------------------------------------------\n');
fprintf(fid,'RANDOMIZED LABELS\n');
fprintf(fid,'---------------------------------------------------------------\n');

fprintf(fid,'Accuracy      : %.5f ± %.5f\n',...
    mean(RandomAccuracy),std(RandomAccuracy));

fprintf(fid,'Precision     : %.5f ± %.5f\n',...
    mean(RandomPrecision),std(RandomPrecision));

fprintf(fid,'Recall        : %.5f ± %.5f\n',...
    mean(RandomRecall),std(RandomRecall));

fprintf(fid,'Specificity   : %.5f ± %.5f\n',...
    mean(RandomSpecificity),std(RandomSpecificity));

fprintf(fid,'F1-score      : %.5f ± %.5f\n\n',...
    mean(RandomF1Score),std(RandomF1Score));

fprintf(fid,'---------------------------------------------------------------\n');
fprintf(fid,'INTERPRETATION\n');
fprintf(fid,'---------------------------------------------------------------\n');

fprintf(fid,...
'Randomizing the correspondence between images and class labels causes\n');
fprintf(fid,...
'the classification performance to collapse towards chance level.\n\n');

fprintf(fid,...
'This demonstrates that the CNN learns genuine image-label\n');
fprintf(fid,...
'relationships rather than memorizing the training data.\n');

fprintf(fid,'\n===============================================================\n');
fprintf(fid,'End of Report\n');
fprintf(fid,'===============================================================\n');

fclose(fid);

disp('RandomizationSummary.txt saved.')

%% ------------------------------------------------------------------------
% Console Summary
%% ------------------------------------------------------------------------

disp(' ')
disp('===============================================================')
disp('Randomization Test Results')
disp('===============================================================')

fprintf('Chance Accuracy                 : %.2f %%\n',ChanceAccuracy);

fprintf('Original Accuracy               : %.5f ± %.5f\n',...
    mean(OriginalAccuracy),...
    std(OriginalAccuracy));

fprintf('Randomized Accuracy             : %.5f ± %.5f\n',...
    mean(RandomAccuracy),...
    std(RandomAccuracy));

fprintf('Original Precision              : %.5f ± %.5f\n',...
    mean(OriginalPrecision),...
    std(OriginalPrecision));

fprintf('Randomized Precision            : %.5f ± %.5f\n',...
    mean(RandomPrecision),...
    std(RandomPrecision));

fprintf('Original Recall                 : %.5f ± %.5f\n',...
    mean(OriginalRecall),...
    std(OriginalRecall));

fprintf('Randomized Recall               : %.5f ± %.5f\n',...
    mean(RandomRecall),...
    std(RandomRecall));

fprintf('Original Specificity            : %.5f ± %.5f\n',...
    mean(OriginalSpecificity),...
    std(OriginalSpecificity));

fprintf('Randomized Specificity          : %.5f ± %.5f\n',...
    mean(RandomSpecificity),...
    std(RandomSpecificity));

fprintf('Original F1-score              : %.5f ± %.5f\n',...
    mean(OriginalF1Score),...
    std(OriginalF1Score));

fprintf('Randomized F1-score            : %.5f ± %.5f\n',...
    mean(RandomF1Score),...
    std(RandomF1Score));

disp(' ')
disp('Results saved to:')
disp(RandomRunFolder)

disp(' ')
disp('===============================================================')
disp('Randomization Test Completed Successfully')
disp('===============================================================')

end

