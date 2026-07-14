function [imds,classNames,numClasses] = loadDataset()
%% Reproducibility

rng(40);


%% Dataset location

dataFolder = ...
'C:\Users\soura\Downloads\SRU\SRU\My Research\Journals\IEEE TIMS - 1\Codes and Data\ImagesOCSF_1';

%% Image datastore

imds = imageDatastore( ...
    dataFolder,...
    'IncludeSubfolders',true,...
    'LabelSource','foldernames');

%% Dataset information

classNames = categories(imds.Labels);

numClasses = numel(classNames);

disp('--------------------------------------')
disp('Dataset Loaded Successfully')
disp('--------------------------------------')

disp(countEachLabel(imds))

img = readimage(imds,1);

fprintf('Image Size : %d × %d\n',size(img,1),size(img,2));

fprintf('Total Images : %d\n',numel(imds.Files));

fprintf('Number of Classes : %d\n',numClasses);

end