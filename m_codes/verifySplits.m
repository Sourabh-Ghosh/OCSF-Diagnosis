function verifySplits(imds,folds,RunFolder)
%======================================================================
% VERIFYSPLITS
%
% Verifies the integrity of Train / Validation / Test partitions.
%
% Checks:
%   ✓ No overlap between Train / Validation / Test
%   ✓ Every image appears exactly once in the Test set
%   ✓ No duplicate images within a split
%   ✓ Total images are preserved
%
%======================================================================

fprintf('\n');
disp('===============================================================')
disp(' Verifying Dataset Splits')
disp('===============================================================')

numFolds = numel(folds);

allTestIndices = [];

for fold = 1:numFolds

    fprintf('\nFold %d\n',fold);
    disp('---------------------------------------------------------------')

    trainIdx = folds{fold}.TrainIndices;
    valIdx   = folds{fold}.ValidationIndices;
    testIdx  = folds{fold}.TestIndices;

    %% ============================================================
    % Check 1
    % No overlap
    %% ============================================================

    if ~isempty(intersect(trainIdx,valIdx))

        error('Overlap detected between TRAIN and VALIDATION in Fold %d.',fold);

    end

    if ~isempty(intersect(trainIdx,testIdx))

        error('Overlap detected between TRAIN and TEST in Fold %d.',fold);

    end

    if ~isempty(intersect(valIdx,testIdx))

        error('Overlap detected between VALIDATION and TEST in Fold %d.',fold);

    end

    fprintf('✓ No overlap between Train / Validation / Test\n');

    %% ============================================================
    % Check 2
    % Duplicate samples
    %% ============================================================

    if numel(unique(trainIdx))~=numel(trainIdx)

        error('Duplicate TRAIN samples detected in Fold %d.',fold);

    end

    if numel(unique(valIdx))~=numel(valIdx)

        error('Duplicate VALIDATION samples detected in Fold %d.',fold);

    end

    if numel(unique(testIdx))~=numel(testIdx)

        error('Duplicate TEST samples detected in Fold %d.',fold);

    end

    fprintf('✓ No duplicate samples inside each split\n');

    %% ============================================================
    % Check 3
    % Total images
    %% ============================================================

    total = numel(trainIdx)+numel(valIdx)+numel(testIdx);

    if total~=numel(imds.Files)

        error('Incorrect number of images in Fold %d.',fold);

    end

    fprintf('✓ Total images = %d\n',total);

    %% ============================================================
    % Collect Test indices
    %% ============================================================

    allTestIndices = [allTestIndices; testIdx];

end

%% ================================================================
% Check 4
% Every image used exactly once as Test
%% ================================================================

disp(' ')
disp('---------------------------------------------------------------')

if numel(unique(allTestIndices))~=numel(imds.Files)

    error('Some images are repeated or missing in Test sets.');

end

fprintf('✓ Every image appears exactly once in the Test set.\n');

%% ================================================================
% Check 5
% Test coverage
%% ================================================================

missing = setdiff((1:numel(imds.Files))',unique(allTestIndices));

if ~isempty(missing)

    error('Some images never appeared in the Test set.');

end

fprintf('✓ Test set covers the complete dataset.\n');

%% ================================================================
% Finished
%% ================================================================

disp('---------------------------------------------------------------')
disp(' All verification checks PASSED.')
disp('===============================================================')
fprintf('\n');

%% ================================================================
% Overall Fold Summary
%% ================================================================

disp(' ')
disp('===============================================================')
disp(' Overall Dataset Split Summary')
disp('===============================================================')

TrainImages = zeros(numFolds,1);
ValidationImages = zeros(numFolds,1);
TestImages = zeros(numFolds,1);

for fold = 1:numFolds

    TrainImages(fold)      = numel(folds{fold}.TrainIndices);
    ValidationImages(fold) = numel(folds{fold}.ValidationIndices);
    TestImages(fold)       = numel(folds{fold}.TestIndices);

end

OverallSummary = table( ...
    (1:numFolds)', ...
    TrainImages, ...
    ValidationImages, ...
    TestImages, ...
    'VariableNames', ...
    {'Fold','Training','Validation','Testing'});

disp(OverallSummary)

disp('===============================================================')
disp(' ')

%% ================================================================
% Export Split Summary to Excel
%% ================================================================

% if ~exist('Results','dir')
%     mkdir('Results');
% end

excelFile = fullfile(RunFolder,'FoldSummary.xlsx');

% Delete previous file if it exists
if exist(excelFile,'file')
    delete(excelFile);
end

%---------------------------------------------------------------
% Overall Summary
%---------------------------------------------------------------

writetable(OverallSummary,excelFile,...
    'Sheet','OverallSummary');

%---------------------------------------------------------------
% Individual Fold Summary
%---------------------------------------------------------------

for fold = 1:numFolds

    sheetName = sprintf('Fold_%d',fold);

    writetable(folds{fold}.SplitTable,...
        excelFile,...
        'Sheet',sheetName);

end

disp('✓ Fold summary exported to FoldSummary.xlsx')

