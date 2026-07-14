function TrainingResults = trainNetwork( ...
    imds,...
    folds,...
    layers,...
    InitialLearnRate,...
    MaxEpochs,...
    MiniBatchSize,...
    ValidationFrequency,...
    RunFolder)
%==========================================================================
% TRAINNETWORK
%
% Trains the proposed CNN using manual stratified 5-fold cross-validation.
%
%==========================================================================

numFolds = numel(folds);

%% Results Folder

if ~exist('Results','dir')
    mkdir('Results');
end

TrainingTime = zeros(numFolds,1);

ModelFile = strings(numFolds,1);

TrainingResults = struct();

%% =====================================================================
% Training Loop
%======================================================================

for fold = 1:numFolds

    fprintf('\n');
    disp('===============================================================')
    fprintf(' Training Fold %d / %d\n',fold,numFolds);
    disp('===============================================================')

    %% -------------------------------------------------------------
    % Create Datastores
    %% -------------------------------------------------------------

    imdsTrain = subset(imds,folds{fold}.TrainIndices);

    imdsValidation = subset(imds,folds{fold}.ValidationIndices);

    imdsTest = subset(imds,folds{fold}.TestIndices);

    %% -------------------------------------------------------------
    % Training Options
    %% -------------------------------------------------------------

    options = createTrainingOptions( ...
        imdsValidation,...
        InitialLearnRate,...
        MaxEpochs,...
        MiniBatchSize,...
        ValidationFrequency);

    %% -------------------------------------------------------------
    % Train
    %% -------------------------------------------------------------

    tic

    [net,info] = trainnet(...
        imdsTrain,...
        layers,...
        "crossentropy",...
        options);

    TrainingTime(fold)=toc;

    %% -------------------------------------------------------------
    % Save Network
    %% -------------------------------------------------------------

    foldFolder = fullfile(RunFolder,...
        sprintf('Fold_%d',fold));

    if ~exist(foldFolder,'dir')
        mkdir(foldFolder);
    end

    modelFile = fullfile(foldFolder,'Network.mat');

    save(modelFile,'net');

    save(fullfile(foldFolder,...
        'TrainingHistory.mat'),'info');

    %% -------------------------------------------------------------
    % Store Results
    %% -------------------------------------------------------------

    TrainingResults(fold).Network = net;

    TrainingResults(fold).TrainingInfo = info;

    TrainingResults(fold).TrainDatastore = imdsTrain;

    TrainingResults(fold).ValidationDatastore = imdsValidation;

    TrainingResults(fold).TestDatastore = imdsTest;

    TrainingResults(fold).TrainingTime = TrainingTime(fold);

    TrainingResults(fold).ModelFile = modelFile;

    TrainingResults(fold).TrainingOptions = options;

    ModelFile(fold)=string(modelFile);

    %% -------------------------------------------------------------
    % Display
    %% -------------------------------------------------------------

    fprintf('Training Time : %.2f seconds\n',...
        TrainingTime(fold));

end

%% =====================================================================
% Training Summary
%======================================================================

Summary = table(...
    (1:numFolds)',...
    TrainingTime,...
    ModelFile,...
    'VariableNames',...
    {'Fold',...
     'TrainingTime',...
     'ModelFile'});

writetable(Summary,...
    fullfile(RunFolder,'TrainingSummary.xlsx'));

disp(' ')
disp('===============================================================')
disp(' Training Completed Successfully')
disp('===============================================================')

disp(Summary)

disp('===============================================================')

end