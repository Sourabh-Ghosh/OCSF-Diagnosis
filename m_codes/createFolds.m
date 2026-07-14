function folds = createFolds(imds,classNames,numFolds)
%==================================================================
% CREATEFOLDS
%
% Creates manual stratified K-fold partitions.
%
% INPUTS
%   imds        : imageDatastore
%   classNames  : categories(imds.Labels)
%   numFolds    : Number of folds (5)
%
% OUTPUT
%   folds{f}.Indices
%   folds{f}.ClassIndices
%   folds{f}.NumImages
%
%==================================================================

%% Reproducibility

rng(40);


numClasses = numel(classNames);

%% Initialize folds

folds = cell(numFolds,1);

for f = 1:numFolds

    folds{f}.Indices = [];

    folds{f}.ClassIndices = cell(numClasses,1);

    folds{f}.NumImages = 0;

end

%% Create folds class-by-class

for c = 1:numClasses

    %--------------------------------------------------------------
    % Images belonging to current class
    %--------------------------------------------------------------

    idx = find(imds.Labels == classNames(c));

    % Shuffle images of current class
    idx = idx(randperm(numel(idx)));

    n = numel(idx);

    %--------------------------------------------------------------
    % Number of samples in each fold
    %--------------------------------------------------------------

    baseCount = floor(n/numFolds);

    remainder = mod(n,numFolds);

    foldSizes = baseCount*ones(1,numFolds);

    % Balanced Round-Robin distribution of remaining samples

    for r = 1:remainder

        foldNumber = mod(c+r-2,numFolds)+1;

        foldSizes(foldNumber) = foldSizes(foldNumber)+1;

    end

    %--------------------------------------------------------------
    % Assign indices to folds
    %--------------------------------------------------------------

    startIdx = 1;

    for f = 1:numFolds

        stopIdx = startIdx + foldSizes(f) - 1;

        currentIdx = idx(startIdx:stopIdx);

        folds{f}.ClassIndices{c} = currentIdx;

        folds{f}.Indices = [folds{f}.Indices; currentIdx];

        folds{f}.NumImages = folds{f}.NumImages + numel(currentIdx);

        startIdx = stopIdx + 1;

    end

end

%% Shuffle image order inside every fold

for f = 1:numFolds

    p = randperm(numel(folds{f}.Indices));

    folds{f}.Indices = folds{f}.Indices(p);

end

%% Display summary

fprintf('\n');
disp('=========================================================')
disp(' Manual Stratified Cross Validation Created')
disp('=========================================================')

totalImages = 0;

for f = 1:numFolds

    fprintf('Fold %d : %3d images\n', ...
        f,folds{f}.NumImages);

    totalImages = totalImages + folds{f}.NumImages;

end

disp('---------------------------------------------------------')
fprintf('Total Images : %d\n',totalImages);
disp('=========================================================')

end