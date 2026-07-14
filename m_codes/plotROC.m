function ROCResults = plotROC( ...
    TrueLabels,...
    Scores,...
    classNames,...
    fold,...
    RunFolder)
%==========================================================================
% PLOTROC
%
% Computes and plots One-vs-Rest ROC curves for multi-class classification.
%
% Outputs:
%   - Class-wise AUC
%   - Macro-average AUC
%   - Micro-average AUC
%
%==========================================================================

%% Create Folder

foldFolder = fullfile( ...
    RunFolder,...
    sprintf('Fold_%d',fold));

if ~exist(foldFolder,'dir')
    mkdir(foldFolder);
end

numClasses = numel(classNames);

%% Initialization

ClassAUC = zeros(numClasses,1);

FPR = cell(numClasses,1);
TPR = cell(numClasses,1);

%% One-vs-Rest ROC

figure(...
    'Color','w',...
    'Units','normalized',...
    'Position',[0.15 0.15 0.55 0.60]);
hold on
grid on
box on

colors = lines(numClasses);

for c = 1:numClasses

    positiveClass = classNames(c);

    labels = (TrueLabels == positiveClass);

    [X,Y,~,AUC] = perfcurve(labels,...
                            Scores(:,c),...
                            true);

    FPR{c} = X;
    TPR{c} = Y;

    ClassAUC(c) = AUC;

    plot(X,Y,...
    'Color',0.75*colors(c,:) + 0.25*[1 1 1],...
    'LineWidth',0.8,...
    'HandleVisibility','off');

end

%% Chance Line

plot([0 1],[0 1],'k--','LineWidth',1.5);

%% -----------------------------------------------------------------------
% Macro ROC
%% -----------------------------------------------------------------------

% macroFPR = linspace(0,1,500);
% 
% macroTPR = zeros(size(macroFPR));
% 
% for c = 1:numClasses
% 
%     macroTPR = macroTPR + interp1(...
%         FPR{c},...
%         TPR{c},...
%         macroFPR,...
%         'linear',...
%         'extrap');
% 
% end
% 
% macroTPR = macroTPR/numClasses;
% 
% MacroAUC = trapz(macroFPR,macroTPR);
% 
% plot(macroFPR,...
%      macroTPR,...
%      'b-',...
%      'LineWidth',3);
% 
% %% -----------------------------------------------------------------------
% % Micro ROC
% %% -----------------------------------------------------------------------
% 
% TrueBinary = [];
% 
% ScoreBinary = [];
% 
% for c = 1:numClasses
% 
%     TrueBinary = [TrueBinary;
%                   TrueLabels==classNames(c)];
% 
%     ScoreBinary = [ScoreBinary;
%                    Scores(:,c)];
% 
% end
% 
% [microFPR,microTPR,~,MicroAUC] = ...
%     perfcurve(TrueBinary,...
%               ScoreBinary,...
%               true);
% 
% plot(microFPR,...
%      microTPR,...
%      'r-',...
%      'LineWidth',3);

%% Figure Formatting

xlabel('False Positive Rate',...
    'FontName','Times New Roman',...
    'FontSize',12);

ylabel('True Positive Rate',...
    'FontName','Times New Roman',...
    'FontSize',12);

title(sprintf('ROC Curves (Fold %d)',fold),...
    'FontWeight','bold');

% legend(...
%     {'Chance',...
%      'Macro-average',...
%      'Micro-average'},...
%     'Location','southeast',...
%     'FontName','Times New Roman',...
%     'FontSize',11);

xlim([0 1]);
ylim([0 1]);

% text(0.60,...
%      0.18,...
%      sprintf(['Macro AUC = %.4f\n' ...
%               'Micro AUC = %.4f'],...
%               MacroAUC,...
%               MicroAUC),...
%      'BackgroundColor','white',...
%      'EdgeColor','black',...
%      'Margin',6,...
%      'FontName','Times New Roman',...
%      'FontSize',11);

%% Save

exportgraphics(gcf,...
    fullfile(foldFolder,'ROC.png'),...
    'Resolution',600);

savefig(fullfile(foldFolder,'ROC.fig'));

close(gcf);

%% Store Results

ROCResults.ClassAUC = ClassAUC;

% ROCResults.MacroAUC = MacroAUC;
% 
% ROCResults.MicroAUC = MicroAUC;

%% Export AUC Table

ClassIndex = (1:numClasses)';

AUCTable = table(...
    ClassIndex,...
    ClassAUC,...
    'VariableNames',...
    {'Class','AUC'});

writetable(AUCTable,...
    fullfile(foldFolder,'AUC.xlsx'));

fprintf('ROC Curves saved : Fold %d\n',fold);
% fprintf('Macro AUC        : %.4f\n',MacroAUC);
% fprintf('Micro AUC        : %.4f\n',MicroAUC);

end