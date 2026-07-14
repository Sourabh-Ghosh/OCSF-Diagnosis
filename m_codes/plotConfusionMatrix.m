function plotConfusionMatrix( ...
    TrueLabels,...
    PredictedLabels,...
    fold,...
    RunFolder)
%==========================================================================
% PLOTCONFUSIONMATRIX
%
% Plots and saves the normalized confusion matrix for one fold.
%
% INPUTS
%   TrueLabels
%   PredictedLabels
%   fold
%
% OUTPUT
%   Results/Fold_x/ConfusionMatrix.png
%
%==========================================================================

%% Create Fold Folder

foldFolder = fullfile( ...
    RunFolder,...
    sprintf('Fold_%d',fold));

if ~exist(foldFolder,'dir')
    mkdir(foldFolder);
end

%% Create Figure

figure('Color','w',...
       'Units','normalized',...
       'Position',[0.20 0.12 0.55 0.65]);

cm = confusionchart(TrueLabels,...
                    PredictedLabels,...
                    'Normalization','row-normalized');

%% Formatting

cm.Title = sprintf('Normalized Confusion Matrix (Fold %d)',fold);

cm.RowSummary = 'row-normalized';

cm.ColumnSummary = 'column-normalized';

cm.FontName = 'Times New Roman';

cm.FontSize = 12;

%% Save Figure

exportgraphics(gcf,...
    fullfile(foldFolder,'ConfusionMatrix.png'),...
    'Resolution',600);

%% Save MATLAB Figure

savefig(fullfile(foldFolder,'ConfusionMatrix.fig'));

%% Display

fprintf('Confusion Matrix saved : Fold %d\n',fold);

close(gcf);

end