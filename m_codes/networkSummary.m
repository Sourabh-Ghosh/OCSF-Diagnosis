function networkSummary(layers,numClasses,RunFolder)
%==========================================================================
% NETWORKSUMMARY
%
% Displays and exports the CNN architecture.
%
% INPUTS
%   layers      : Network layers
%   numClasses  : Number of output classes
%
% OUTPUT
%   Results/
%       NetworkSummary.xlsx
%       NetworkSummary.csv
%       NetworkArchitecture.png
%
%==========================================================================

%% Create Results folder

% if ~exist('Results','dir')
%     mkdir('Results');
% end

%% Create Layer Graph

lgraph = layerGraph(layers);

%% Display Layer Graph

figure('Color','w');
plot(lgraph);
title('Proposed Lightweight CNN Architecture');

exportgraphics(gcf,...
    fullfile(RunFolder,'NetworkArchitecture.png'),...
    'Resolution',300);

%% =====================================================================
% Create Layer Summary
%% =====================================================================

numLayers = numel(layers);

LayerNumber = (1:numLayers)';
LayerName   = strings(numLayers,1);
LayerType   = strings(numLayers,1);
OutputSize  = strings(numLayers,1);
Description = strings(numLayers,1);

for i = 1:numLayers

    LayerName(i) = string(layers(i).Name);

    LayerType(i) = erase(class(layers(i)),"nnet.cnn.layer.");

    switch class(layers(i))

        case 'nnet.cnn.layer.ImageInputLayer'

            OutputSize(i) = "19×251×1";
            Description(i) = "Input Image";

        case 'nnet.cnn.layer.Convolution2DLayer'

            OutputSize(i) = sprintf("%d Filters",layers(i).NumFilters);

            Description(i) = sprintf( ...
                "%dx%d Conv (Padding=%s)",...
                layers(i).FilterSize(1),...
                layers(i).FilterSize(2),...
                string(layers(i).PaddingMode));

        case 'nnet.cnn.layer.BatchNormalizationLayer'

            OutputSize(i) = "-";
            Description(i) = "Batch Normalization";

        case 'nnet.cnn.layer.ReLULayer'

            OutputSize(i) = "-";
            Description(i) = "ReLU Activation";

        case 'nnet.cnn.layer.MaxPooling2DLayer'

            OutputSize(i) = sprintf("%dx%d",...
                layers(i).PoolSize(1),...
                layers(i).PoolSize(2));

            Description(i) = sprintf(...
                "Stride = %d",...
                layers(i).Stride(1));

        case 'nnet.cnn.layer.FullyConnectedLayer'

            OutputSize(i) = sprintf("%d",...
                layers(i).OutputSize);

            Description(i) = "Fully Connected";

        case 'nnet.cnn.layer.SoftmaxLayer'

            OutputSize(i) = "-";
            Description(i) = "Softmax";

        otherwise

            OutputSize(i) = "-";
            Description(i) = "-";

    end

end

%% Create Table

NetworkTable = table(...
    LayerNumber,...
    LayerName,...
    LayerType,...
    OutputSize,...
    Description,...
    'VariableNames',...
    {'Layer','Name','Type','Output','Description'});

%% Display

disp(' ')
disp('===============================================================')
disp(' Network Architecture Summary')
disp('===============================================================')

disp(NetworkTable)

fprintf('Number of Layers : %d\n',numLayers);
fprintf('Output Classes   : %d\n',numClasses);

disp('===============================================================')

%% =====================================================================
% Export Excel
%% =====================================================================

excelFile = fullfile(RunFolder,'NetworkSummary.xlsx');

if exist(excelFile,'file')
    delete(excelFile);
end

writetable(NetworkTable,...
    excelFile,...
    'Sheet','Layers');

SummaryTable = table(...
    numLayers,...
    numClasses,...
    "19 × 251 × 1",...
    'VariableNames',...
    {'TotalLayers',...
     'OutputClasses',...
     'InputSize'});

writetable(SummaryTable,...
    excelFile,...
    'Sheet','Summary');

%% =====================================================================
% Export CSV
%% =====================================================================

csvFile = fullfile(RunFolder,'NetworkSummary.csv');

writetable(NetworkTable,csvFile);

%% =====================================================================
% Completion Message
%% =====================================================================

disp(' ')
disp('===============================================================')
disp(' Network Summary Successfully Generated')
disp('===============================================================')
disp(['Excel File : ',excelFile])
disp(['CSV File   : ',csvFile])
disp(['Figure     : Results/NetworkArchitecture.png'])
disp('===============================================================')
disp(' ')

end