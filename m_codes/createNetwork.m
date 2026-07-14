function layers = createNetwork(numClasses)
%==========================================================================
% CREATENETWORK
%
% Defines the proposed lightweight CNN architecture for
% Open-Circuit Switch Fault (OCSF) diagnosis.
%
% INPUT
%   numClasses  : Number of output classes
%
% OUTPUT
%   layers      : CNN layer architecture
%
% The architecture follows the proposed model presented in the manuscript.
%
%==========================================================================

%% Input Layer

disp(' ')
disp('===============================================================')
disp(' Network Building Starts')
disp('===============================================================')

layers = [

    imageInputLayer([19 251 1], ...
        'Name','input', ...
        'Normalization','none')

    %% ---------------------------------------------------------------
    % Convolution Block 1
    %% ---------------------------------------------------------------

    convolution2dLayer(3,8, ...
        'Padding','same', ...
        'Name','conv1')

    batchNormalizationLayer( ...
        'Name','bn1')

    reluLayer( ...
        'Name','relu1')

    maxPooling2dLayer(2, ...
        'Stride',2, ...
        'Name','pool1')

    %% ---------------------------------------------------------------
    % Convolution Block 2
    %% ---------------------------------------------------------------

    convolution2dLayer(3,16, ...
        'Padding','same', ...
        'Name','conv2')

    batchNormalizationLayer( ...
        'Name','bn2')

    reluLayer( ...
        'Name','relu2')

    maxPooling2dLayer(2, ...
        'Stride',2, ...
        'Name','pool2')

    %% ---------------------------------------------------------------
    % Convolution Block 3
    %% ---------------------------------------------------------------

    convolution2dLayer(3,32, ...
        'Padding','same', ...
        'Name','conv3')

    batchNormalizationLayer( ...
        'Name','bn3')

    reluLayer( ...
        'Name','relu3')

    %% ---------------------------------------------------------------
    % Classification Head
    %% ---------------------------------------------------------------

   
    fullyConnectedLayer(numClasses, ...
        'Name','fc')

    softmaxLayer( ...
        'Name','softmax')
];

%% ---------------------------------------------------------------------
% Display Network Information
%% ---------------------------------------------------------------------

disp(' ')
disp('===============================================================')
disp(' Proposed Lightweight CNN Architecture')
disp('===============================================================')

disp(layers)

fprintf('Input Size            : %d × %d × %d\n',19,251,1);
fprintf('Output Classes        : %d\n',numClasses);
fprintf('Total Layers          : %d\n',numel(layers));

disp('===============================================================')
disp(' ')

end