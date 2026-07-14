function analyzeDatasetComplexity( ...
    imds,...
    classNames,...
    RunFolder)
%==========================================================================
% ANALYZEDATASETCOMPLEXITY
%
% Computes dataset complexity directly from the input grayscale images.
%
% Metrics:
%   1. Average Intra-class Distance
%   2. Nearest Inter-class Distance
%   3. Separation Ratio
%
% INPUTS
%
% imds        : Image datastore
% classNames  : Class labels
% RunFolder   : Current experiment folder
%
% OUTPUT
%
% Results/
%   Run_xxxxx/
%       DatasetAnalysis/
%
%           DatasetComplexity.xlsx
%           DatasetComplexity.mat
%           DatasetComplexitySummary.txt
%
%==========================================================================

disp(' ')
disp('===============================================================')
disp('Analyzing Dataset Complexity')
disp('===============================================================')

%% ------------------------------------------------------------------------
% Create Folder
%% ------------------------------------------------------------------------

analysisFolder = fullfile(...
    RunFolder,...
    'DatasetAnalysis');

if ~exist(analysisFolder,'dir')
    mkdir(analysisFolder);
end

%% ------------------------------------------------------------------------
% Dataset Information
%% ------------------------------------------------------------------------

numSamples = numel(imds.Files);

numClasses = numel(classNames);

fprintf('Total Samples : %d\n',numSamples);
fprintf('Total Classes : %d\n',numClasses);

%% ------------------------------------------------------------------------
% Read Images
%% ------------------------------------------------------------------------

disp(' ')
disp('Reading images ...')

FeatureMatrix = zeros(numSamples,19*251);

Labels = imds.Labels;

for i = 1:numSamples

    % Read image

    I = readimage(imds,i);

    % Convert to double

    I = im2double(I);

    % Flatten image

    x = I(:)';

    x = x / max(norm(x),eps);

    FeatureMatrix(i,:) = x;

    % Progress

    if mod(i,100)==0 || i==numSamples

        fprintf('Processed %d / %d images\n',...
            i,...
            numSamples);

    end

end

disp('Feature matrix successfully created.')

%% ------------------------------------------------------------------------
% Initialize
%% ------------------------------------------------------------------------

ClassCentroids = zeros(numClasses,size(FeatureMatrix,2));

IntraDistance = zeros(numClasses,1);

NearestInterDistance = zeros(numClasses,1);

SeparationRatio = zeros(numClasses,1);

SamplesPerClass = zeros(numClasses,1);

%% ------------------------------------------------------------------------
% Compute Class Centroids and Intra-class Distance
%% ------------------------------------------------------------------------

disp(' ')
disp('Computing class centroids and intra-class distances ...')

for c = 1:numClasses

    %% Current Class

    currentClass = classNames(c);

    %% Samples belonging to current class

    idx = Labels == currentClass;

    Xclass = FeatureMatrix(idx,:);

    SamplesPerClass(c) = size(Xclass,1);

    %% Compute Class Centroid

    centroid = mean(Xclass,1);

    centroid = centroid / max(norm(centroid),eps);

    ClassCentroids(c,:) = centroid;

    %% Compute Euclidean Distance of Every Sample to Centroid

    distance = vecnorm(...
        Xclass - centroid,...
        2,...
        2);

    %% Average Intra-class Distance

    IntraDistance(c) = mean(distance);

    %% Display Progress

    fprintf(['Class %2d/%2d : %-20s ',...
             'Samples = %3d   ',...
             'Intra Distance = %.6f\n'],...
             c,...
             numClasses,...
             string(currentClass),...
             SamplesPerClass(c),...
             IntraDistance(c));

end

disp(' ')
disp('Intra-class distance computation completed.')

%% ------------------------------------------------------------------------
% Compute Inter-class Distance
%% ------------------------------------------------------------------------

disp(' ')
disp('Computing inter-class distances ...')

%% Distance Matrix Between Class Centroids

CentroidDistance = zeros(numClasses,numClasses);

for i = 1:numClasses

    for j = i:numClasses

        if i == j

            CentroidDistance(i,j) = NaN;

        else

            d = norm(...
                ClassCentroids(i,:) - ...
                ClassCentroids(j,:));

            CentroidDistance(i,j) = d;

            CentroidDistance(j,i) = d;

        end

    end

end

%% Nearest Inter-class Distance

for c = 1:numClasses

    NearestInterDistance(c) = ...
        min(CentroidDistance(c,:),[],'omitnan');

end

disp('Nearest inter-class distances computed.')

%% ------------------------------------------------------------------------
% Separation Ratio
%% ------------------------------------------------------------------------

disp('Computing separation ratios ...')

SeparationRatio = ...
    NearestInterDistance ./ ...
    max(IntraDistance,eps);

disp('Separation ratios computed.')

%% ------------------------------------------------------------------------
% Display
%% ------------------------------------------------------------------------

disp(' ')
disp('===============================================================')
disp('Dataset Complexity')
disp('===============================================================')

for c = 1:numClasses

    fprintf(['Class %2d : %-20s  ',...
        'Intra = %.4f   ',...
        'Nearest Inter = %.4f   ',...
        'Ratio = %.4f\n'],...
        c,...
        string(classNames(c)),...
        IntraDistance(c),...
        NearestInterDistance(c),...
        SeparationRatio(c));

end

disp('===============================================================')

%% ------------------------------------------------------------------------
% Create Dataset Complexity Table
%% ------------------------------------------------------------------------

disp(' ')
disp('Saving Dataset Complexity Results ...')

% ------------------------------------------------------------------------

ClassIDText = string((1:numClasses)');

ClassNameText = string(classNames(:));

SamplesText = string(SamplesPerClass);

IntraDistanceText = string(compose("%.4f", IntraDistance));

NearestInterDistanceText = string(compose("%.4f", NearestInterDistance));

SeparationRatioText = string(compose("%.4f", SeparationRatio));

ComplexityTable = table(...
    ClassIDText,...
    ClassNameText,...
    SamplesText,...
    IntraDistanceText,...
    NearestInterDistanceText,...
    SeparationRatioText,...
    'VariableNames',...
    {'ClassID',...
     'ClassName',...
     'Samples',...
     'AverageIntraDistance',...
     'NearestInterDistance',...
     'SeparationRatio'});

%% ------------------------------------------------------------------------
% Add Overall Mean ± SD
%% ------------------------------------------------------------------------

SummaryRow = table(...
    "-",...
    "Overall Mean ± SD",...
    string(sum(SamplesPerClass)),...
    string(sprintf("%.4f ± %.4f",...
        mean(IntraDistance),...
        std(IntraDistance))),...
    string(sprintf("%.4f ± %.4f",...
        mean(NearestInterDistance),...
        std(NearestInterDistance))),...
    string(sprintf("%.4f ± %.4f",...
        mean(SeparationRatio),...
        std(SeparationRatio))),...
    'VariableNames',...
    ComplexityTable.Properties.VariableNames);

ComplexityTable = [ComplexityTable; SummaryRow];

%% ------------------------------------------------------------------------
% Export Excel
%% ------------------------------------------------------------------------

writetable(...
    ComplexityTable,...
    fullfile(analysisFolder,...
    'DatasetComplexity.xlsx'));

disp('DatasetComplexity.xlsx saved.')

%% ------------------------------------------------------------------------
% Save MAT File
%% ------------------------------------------------------------------------

save(...
    fullfile(analysisFolder,...
    'DatasetComplexity.mat'),...
    'FeatureMatrix',...
    'ClassCentroids',...
    'CentroidDistance',...
    'SamplesPerClass',...
    'IntraDistance',...
    'NearestInterDistance',...
    'SeparationRatio');

disp('DatasetComplexity.mat saved.')

%% ------------------------------------------------------------------------
% Create Summary Report
%% ------------------------------------------------------------------------

fid = fopen(...
    fullfile(analysisFolder,...
    'DatasetComplexitySummary.txt'),'w');

fprintf(fid,'===============================================================\n');
fprintf(fid,'DATASET COMPLEXITY SUMMARY\n');
fprintf(fid,'===============================================================\n\n');

fprintf(fid,'Generated On : %s\n',char(datetime('now')));

fprintf(fid,'Number of Samples : %d\n',numSamples);

fprintf(fid,'Number of Classes : %d\n\n',numClasses);

fprintf(fid,'---------------------------------------------------------------\n');
fprintf(fid,'Overall Statistics\n');
fprintf(fid,'---------------------------------------------------------------\n');

fprintf(fid,'Average Intra-class Distance\n');
fprintf(fid,'%.4f ± %.4f\n\n',...
    mean(IntraDistance),...
    std(IntraDistance));

fprintf(fid,'Average Nearest Inter-class Distance\n');
fprintf(fid,'%.4f ± %.4f\n\n',...
    mean(NearestInterDistance),...
    std(NearestInterDistance));

fprintf(fid,'Average Separation Ratio\n');
fprintf(fid,'%.4f ± %.4f\n\n',...
    mean(SeparationRatio),...
    std(SeparationRatio));

fprintf(fid,'Interpretation\n');
fprintf(fid,'--------------\n');
fprintf(fid,'Larger separation ratios indicate better dataset separability.\n');
fprintf(fid,'Smaller ratios indicate classes that are intrinsically more difficult to distinguish.\n');

fclose(fid);

disp('DatasetComplexitySummary.txt saved.')

%% ------------------------------------------------------------------------
% Check for Potentially Difficult Classes
%% ------------------------------------------------------------------------

disp(' ')
disp('===============================================================')
disp('Dataset Complexity Summary')
disp('===============================================================')

fprintf('Average Intra-class Distance      : %.4f ± %.4f\n',...
    mean(IntraDistance),...
    std(IntraDistance));

fprintf('Average Nearest Inter-class Dist. : %.4f ± %.4f\n',...
    mean(NearestInterDistance),...
    std(NearestInterDistance));

fprintf('Average Separation Ratio          : %.4f ± %.4f\n',...
    mean(SeparationRatio),...
    std(SeparationRatio));

disp(' ')

%% ------------------------------------------------------------------------
% Identify Most Challenging Classes
%% ------------------------------------------------------------------------

[WorstRatio,idxWorst] = min(SeparationRatio);

[BestRatio,idxBest] = max(SeparationRatio);

fprintf('Most Difficult Class\n');
fprintf('--------------------\n');
fprintf('Class : %s\n',string(classNames(idxWorst)));
fprintf('Separation Ratio : %.4f\n\n',WorstRatio);

fprintf('Best Separated Class\n');
fprintf('--------------------\n');
fprintf('Class : %s\n',string(classNames(idxBest)));
fprintf('Separation Ratio : %.4f\n\n',BestRatio);

%% ------------------------------------------------------------------------
% Optional Warning
%% ------------------------------------------------------------------------

LowRatioThreshold = 2.0;

LowRatioClasses = find(SeparationRatio < LowRatioThreshold);

if ~isempty(LowRatioClasses)

    disp('Warning:')
    disp('The following classes exhibit relatively low separation ratios:')

    for k = 1:numel(LowRatioClasses)

        fprintf('   %s (%.4f)\n',...
            string(classNames(LowRatioClasses(k))),...
            SeparationRatio(LowRatioClasses(k)));

    end

else

    disp('All classes exhibit satisfactory separation.')

end

%% ------------------------------------------------------------------------
% Finish
%% ------------------------------------------------------------------------

disp(' ')
disp('===============================================================')
disp('Dataset Complexity Analysis Completed Successfully')
disp('===============================================================')
disp(' ')

disp('Results saved to:')
disp(analysisFolder)
disp(' ')

end