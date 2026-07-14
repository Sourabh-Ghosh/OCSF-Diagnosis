function options = createTrainingOptions( ...
    imdsValidation,...
    InitialLearnRate,...
    MaxEpochs,...
    MiniBatchSize,...
    ValidationFrequency)
%==========================================================================
% CREATETRAININGOPTIONS
%
% Creates the training options for the proposed lightweight CNN.
%
% INPUTS
%   imdsValidation      : Validation image datastore
%   InitialLearnRate    : Initial learning rate
%   MaxEpochs           : Maximum number of epochs
%   MiniBatchSize       : Mini-batch size
%   ValidationFrequency : Validation frequency (iterations)
%
% OUTPUT
%   options             : Training options object
%
%==========================================================================

options = trainingOptions("sgdm", ...
    'InitialLearnRate', InitialLearnRate, ...
    'MaxEpochs', MaxEpochs, ...
    'MiniBatchSize', MiniBatchSize, ...
    'Shuffle', 'every-epoch', ...
    'ValidationData', imdsValidation, ...
    'ValidationFrequency', ValidationFrequency, ...
    'Metrics', ["accuracy","fscore"], ...
    'Verbose', false, ...
    'Plots', 'none');

%% Display Training Configuration

disp(' ')
disp('===============================================================')
disp(' Training Configuration')
disp('===============================================================')

fprintf('Optimizer              : SGDM\n');
fprintf('Initial Learning Rate  : %.5f\n', InitialLearnRate);
fprintf('Maximum Epochs         : %d\n', MaxEpochs);
fprintf('Mini Batch Size        : %d\n', MiniBatchSize);
fprintf('Validation Frequency   : %d iterations\n', ValidationFrequency);
fprintf('Shuffle                : Every Epoch\n');
fprintf('Loss Function          : Cross-Entropy\n');

disp('===============================================================')
disp(' ')

end