function folds = createSplits(imds,classNames,folds)
%======================================================================
% CREATESPLITS
%
% Creates Train / Validation / Test split for each outer fold.
%
% Outer Fold  -> Test Set
% Remaining   -> Train + Validation
%
% Validation = First 2 samples per class
% Training   = Remaining samples per class
%
%======================================================================

numClasses = numel(classNames);
numFolds   = numel(folds);

for fold = 1:numFolds

    fprintf('\n');
    fprintf('============================================================\n');
    fprintf('Creating Split for Fold %d\n',fold);
    fprintf('============================================================\n');

    TrainIndices = [];
    ValidationIndices = [];
    TestIndices = [];

    TrainCount = zeros(numClasses,1);
    ValidationCount = zeros(numClasses,1);
    TestCount = zeros(numClasses,1);

    %% -------------------------------------------------------------
    % Process each class independently
    %% -------------------------------------------------------------

    for c = 1:numClasses

        %% -------------------------------
        % Test indices
        %% -------------------------------

        testIdx = folds{fold}.ClassIndices{c};

        TestIndices = [TestIndices; testIdx];

        TestCount(c) = numel(testIdx);

        %% -------------------------------
        % Remaining samples
        %% -------------------------------

        remainingIdx = [];

        for k = 1:numFolds

            if k ~= fold

                remainingIdx = [remainingIdx;
                                folds{k}.ClassIndices{c}];

            end

        end

        % NOTE:
        % remainingIdx is already randomized because the images
        % were shuffled once in createFolds().

        %% -------------------------------
        % Validation
        %% -------------------------------

        validationIdx = remainingIdx(1:2);

        %% -------------------------------
        % Training
        %% -------------------------------

        trainIdx = remainingIdx(3:end);

        %% -------------------------------
        % Store
        %% -------------------------------

        ValidationIndices = [ValidationIndices;
                             validationIdx];

        TrainIndices = [TrainIndices;
                        trainIdx];

        ValidationCount(c) = numel(validationIdx);

        TrainCount(c) = numel(trainIdx);

    end

    %% -------------------------------------------------------------
    % Store indices
    %% -------------------------------------------------------------

    folds{fold}.TrainIndices = TrainIndices;

    folds{fold}.ValidationIndices = ValidationIndices;

    folds{fold}.TestIndices = TestIndices;

    %% Labels

    folds{fold}.TrainLabels = imds.Labels(TrainIndices);

    folds{fold}.ValidationLabels = imds.Labels(ValidationIndices);

    folds{fold}.TestLabels = imds.Labels(TestIndices);

    %% -------------------------------------------------------------
    % Summary Table
    %% -------------------------------------------------------------

    SplitTable = table( ...
        classNames,...
        TrainCount,...
        ValidationCount,...
        TestCount,...
        'VariableNames',...
        {'Class','Train','Validation','Test'});

    folds{fold}.SplitTable = SplitTable;

    %% -------------------------------------------------------------
    % Display Summary
    %% -------------------------------------------------------------

    disp(SplitTable)

    fprintf('------------------------------------------------------------\n');
    fprintf('Training Images   : %3d\n',numel(TrainIndices));
    fprintf('Validation Images : %3d\n',numel(ValidationIndices));
    fprintf('Testing Images    : %3d\n',numel(TestIndices));
    fprintf('------------------------------------------------------------\n');

end

end