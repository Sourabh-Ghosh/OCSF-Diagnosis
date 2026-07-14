function plotTrainingCurves( ...
    TrainingResults,...
    RunFolder)
%==========================================================================
% PLOTTRAININGCURVES
%
% Plots training and validation learning curves for each fold.
%
% Compatible with MATLAB R2025a trainnet().
%
% INPUTS
%   TrainingResults
%   RunFolder
%
% Generated Files
%
% Results/
%   Run_xxxxx/
%       Fold_1/
%           TrainingCurves.png
%           TrainingCurves.fig
%           TrainingHistory.xlsx
%
%==========================================================================

numFolds = numel(TrainingResults);

disp(' ')
disp('===============================================================')
disp('Generating Training Curves')
disp('===============================================================')

for fold = 1:numFolds

    fprintf('\nProcessing Fold %d...\n',fold);

    %% -------------------------------------------------------------
    % Fold Folder
    %% -------------------------------------------------------------

    foldFolder = fullfile( ...
        RunFolder,...
        sprintf('Fold_%d',fold));

    if ~exist(foldFolder,'dir')
        mkdir(foldFolder);
    end

    %% -------------------------------------------------------------
    % Read Training History
    %% -------------------------------------------------------------

    info = TrainingResults(fold).TrainingInfo;

    TrainHistory = info.TrainingHistory;

    ValidationHistory = info.ValidationHistory;

    %% -------------------------------------------------------------
    % Epoch Information
    %% -------------------------------------------------------------

    Epochs = unique(TrainHistory.Epoch);

    numEpochs = numel(Epochs);

    %% -------------------------------------------------------------
    % Initialize
    %% -------------------------------------------------------------

    TrainAccuracy = zeros(numEpochs,1);

    TrainLoss = zeros(numEpochs,1);

    ValidationAccuracy = zeros(numEpochs,1);

    ValidationLoss = zeros(numEpochs,1);

    ValidationEpoch = zeros(height(ValidationHistory),1);

        %% -------------------------------------------------------------
    % Compute Epoch-wise Training Metrics
    %% -------------------------------------------------------------

    for e = 1:numEpochs

        currentEpoch = Epochs(e);

        idxTrain = TrainHistory.Epoch == currentEpoch;

        TrainAccuracy(e) = mean( ...
            TrainHistory.Accuracy(idxTrain), ...
            "omitnan");

        TrainLoss(e) = mean( ...
            TrainHistory.Loss(idxTrain), ...
            "omitnan");

    end

    %% -------------------------------------------------------------
    % Determine Validation Epoch Number
    %% -------------------------------------------------------------

    for k = 1:height(ValidationHistory)

        idx = find( ...
            TrainHistory.Iteration == ...
            ValidationHistory.Iteration(k), ...
            1);

        if ~isempty(idx)

            ValidationEpoch(k) = ...
                TrainHistory.Epoch(idx);

        end

    end

    %% -------------------------------------------------------------
    % Compute Epoch-wise Validation Metrics
    %% -------------------------------------------------------------

    for e = 1:numEpochs

        currentEpoch = Epochs(e);

        idxValidation = ...
            ValidationEpoch == currentEpoch;

        if any(idxValidation)

            ValidationAccuracy(e) = mean( ...
                ValidationHistory.Accuracy(idxValidation), ...
                "omitnan");

            ValidationLoss(e) = mean( ...
                ValidationHistory.Loss(idxValidation), ...
                "omitnan");

        else

            ValidationAccuracy(e) = NaN;

            ValidationLoss(e) = NaN;

        end

    end

    %% -------------------------------------------------------------
    % Export Training History
    %% -------------------------------------------------------------

    TrainingHistoryTable = table( ...
        Epochs,...
        TrainAccuracy,...
        TrainLoss,...
        ValidationAccuracy,...
        ValidationLoss,...
        'VariableNames',...
        {'Epoch',...
         'TrainingAccuracy',...
         'TrainingLoss',...
         'ValidationAccuracy',...
         'ValidationLoss'});

    writetable( ...
        TrainingHistoryTable,...
        fullfile( ...
        foldFolder,...
        'TrainingHistory.xlsx'));

    %% =============================================================
    % Create Figure
    %% =============================================================
    
    figure(...
        'Color','w',...
        'Units','normalized',...
        'Position',[0.08 0.20 0.82 0.42]);
    
    %% =============================================================
    % Accuracy Curves
    %% =============================================================
    
    subplot(1,2,1)
    
    plot(Epochs,...
         TrainAccuracy,...
         '-',...
         'LineWidth',2);
    
    hold on
    
    plot(Epochs,...
         ValidationAccuracy,...
         '--',...
         'LineWidth',2);
    
    grid on
    box on
    
    xlabel('Epoch',...
        'FontName','Times New Roman',...
        'FontSize',12);
    
    ylabel('Accuracy (%)',...
        'FontName','Times New Roman',...
        'FontSize',12);
    
    title(sprintf('Accuracy (Fold %d)',fold),...
        'FontWeight','bold',...
        'FontName','Times New Roman',...
        'FontSize',13);
    
    legend(...
        {'Training','Validation'},...
        'Location','southeast');
    
    ylim([0 100])
    
    set(gca,...
        'FontName','Times New Roman',...
        'FontSize',11,...
        'LineWidth',1);
    
    %% =============================================================
    % Loss Curves
    %% =============================================================
    
    subplot(1,2,2)
    
    plot(Epochs,...
         TrainLoss,...
         '-',...
         'LineWidth',2);
    
    hold on
    
    plot(Epochs,...
         ValidationLoss,...
         '--',...
         'LineWidth',2);
    
    grid on
    box on
    
    set(gca,'YScale','log')
    
    xlabel('Epoch',...
        'FontName','Times New Roman',...
        'FontSize',12);
    
    ylabel('Cross-Entropy Loss',...
        'FontName','Times New Roman',...
        'FontSize',12);
    
    title(sprintf('Loss (Fold %d)',fold),...
        'FontWeight','bold',...
        'FontName','Times New Roman',...
        'FontSize',13);
    
    legend(...
        {'Training','Validation'},...
        'Location','northeast');
    
    set(gca,...
        'FontName','Times New Roman',...
        'FontSize',11,...
        'LineWidth',1);
    
    %% =============================================================
    % Overall Title
    %% =============================================================
    
    sgtitle(...
        sprintf('Training History - Fold %d',fold),...
        'FontName','Times New Roman',...
        'FontWeight','bold',...
        'FontSize',15);
    
    %% =============================================================
    % Save Figure
    %% =============================================================
    
    exportgraphics(...
        gcf,...
        fullfile(foldFolder,...
        'TrainingCurves.png'),...
        'Resolution',600);
    
    savefig(...
        fullfile(foldFolder,...
        'TrainingCurves.fig'));
    
    close(gcf);

    fprintf('✓ Training curves saved for Fold %d\n',fold);

end

%% =============================================================
% Display
%% =============================================================

disp(' ')
disp('===============================================================')
disp('Training Curves Generated Successfully')
disp('===============================================================')
disp(['Results Folder : ' RunFolder])
disp('===============================================================')
disp(' ')

end