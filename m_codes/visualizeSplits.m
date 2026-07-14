function visualizeSplits(folds,classNames,RunFolder)
%======================================================================
% VISUALIZESPLITS
%
% Visualizes Train / Validation / Test distribution
% for every class in every fold.
%
%======================================================================

numFolds = numel(folds);
numClasses = numel(classNames);

%% Create Results Folder

% if ~exist('Results','dir')
%     mkdir('Results');
% end

%% Figure

figure('Color','w',...
       'Units','normalized',...
       'Position',[0.05 0.05 0.9 0.85]);

t = tiledlayout(numFolds,1,...
    'TileSpacing','compact',...
    'Padding','compact');

title(t,'Train / Validation / Test Distribution Across 5 Folds',...
      'FontWeight','bold',...
      'FontSize',14);

for fold = 1:numFolds

    nexttile

    T = folds{fold}.SplitTable;

    Y = [T.Train T.Validation T.Test];

    bar(Y,'stacked','BarWidth',0.8);

    grid on

    ylim([0 16]);

    ylabel(sprintf('Fold %d',fold),...
        'FontWeight','bold');

    xticks(1:numClasses);

    if fold~=numFolds
        xticklabels([]);
    else
        xticklabels(string(1:numClasses));
        xlabel('Class Index');
    end

end

lgd = legend({'Training','Validation','Testing'},...
    'Orientation','horizontal');

lgd.Layout.Tile = 'south';

exportgraphics(gcf,...
    fullfile(RunFolder,'CrossValidationSplit.png'),...
    'Resolution',600);

disp(' ')
disp('========================================================')
disp(' Split visualization created successfully.')
disp(' Figure saved to:')
disp(fullfile('Results','CrossValidationSplit.png'))
disp('========================================================')