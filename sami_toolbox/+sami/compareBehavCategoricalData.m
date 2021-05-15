function stats = compareBehavCategoricalData(data, category, depVar, userOptions, figI)
% stats = compareBehavCategoricalData(data, category, depVar, userOptions, figI)
%   Detailed explanation goes here
% 
%  IMPORTANT NOTE: this function assumes an "within-factorial" design, i.e. participants 
%                  are rating each category, leading to a data s*p-data_matrix, where
%                  s=stimulus and p=participant
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 09/2020

%% define default behavior
if ~exist('figI','var') || isempty(figI), figI = sami.util.getFigI(); end
if ~exist('category','var') || isempty(category), category = userOptions.stimuli_sorting; end
if ~exist('depVar','var') || isempty(depVar), depVar = 'NOT_SPECIFIED'; end
userOptions = sami.util.setIfUnset(userOptions, 'behav_threshold', 0.05);
userOptions = sami.util.setIfUnset(userOptions, 'behav_multipleTesting', 'bonferroni');
userOptions = sami.util.setIfUnset(userOptions, 'stats_minNforSubjectRFXtests', 12);
userOptions = sami.util.setIfUnset(userOptions, 'stats_minNforNonParamTests', 5);

% check
if ismember(category, userOptions.stimuli_settings(1,2:end)) == 0, error('*** sami:ERROR *** input for ''category'' is not specified in ''userOptions.stimuli_settings''. Please check input. returning.'); end

% print progress
disp(['*** compare ''categorical'' behavioral data [fig. ' num2str(figI) '] ***']);

%% init vars
fileNameSufix = ['_' sami.util.deblank(depVar) '_by_' sami.util.deblank(category)];
cmp = sami.fig.createColormap('confMatrix');

%% get category for 'data'-input according to 'category'-input
fileOrder = sami.util.getStimOrder(userOptions);
[~, catIdx] = ismember(category, userOptions.stimuli_settings(1,2:end));
catOfStim = cell2mat(userOptions.stimuli_settings(fileOrder+1,catIdx + 1));
catNums = unique(catOfStim);
nCat = numel(catNums);
nStim = numel(catOfStim);
nSubj = size(data,2);
nRatings = (nStim/nCat) * nSubj;

%% data preprocessing
% create confusionMatrix by counting every single ratings and comparing to 'category'-input
% in 'absolute' as well as 'percentage' values
confMat_abs = zeros(nCat);
for i = 1:nStim
    thisRef = catOfStim(i);
    for j = 1:nSubj
        thisRat = data(i,j);
        confMat_abs(thisRef,thisRat) = confMat_abs(thisRef,thisRat) + 1;
    end
end
confMat_perc = confMat_abs ./ nRatings .* 100;
% calc total values
confMat_abs_totalTarget = sum(confMat_abs,2);
confMat_abs_totalResponse = sum(confMat_abs,1);
confMat_perc_totalTarget = confMat_abs_totalTarget ./ sum(confMat_abs_totalTarget) .* 100;
confMat_perc_totalResponse = confMat_abs_totalResponse ./ sum(confMat_abs_totalResponse) .* 100;
% complete matrices
confMat_abs_total = [confMat_abs,confMat_abs_totalTarget;confMat_abs_totalResponse,nan];
confMat_perc_total = [confMat_perc,confMat_perc_totalTarget;confMat_perc_totalResponse,nan];
% save stats
stats.confMat_abs = confMat_abs;
stats.confMat_perc = confMat_perc;
stats.confMat_abs_total = confMat_abs_total;
stats.confMat_perc_total = confMat_perc_total;

% for subject RFX tests: get accuracy and d-prime for each subject
data_acc = nan(nSubj,nCat);
data_dp = nan(nSubj,nCat);
for s = 1:nSubj
    for c = catNums'
        thisCatIdx = catOfStim == catNums(c);
        
        % accuracy per category
        data_acc(s,c) = mean(data(thisCatIdx,s) == c) * 100;
        
        % hit + false alarm rate to calculate d'
        catRated = data(:,s) == c;
        catPresent = thisCatIdx;
        catNotPresent = ~thisCatIdx;
        
        hit = sum(catRated & catPresent) / sum(catPresent);
        fa = sum(catRated & catNotPresent) / sum(catNotPresent);
        
        % note: proportions of 0 are replaced with 0.5/N, proportions of 1 are replaced with (N-0.5)/N
        %       where N is the number of 'category'-trials, or 'non-category#-trials respectively
        if hit == 1, hit = (sum(catPresent)-0.5)./sum(catPresent); end
        if hit == 0, hit = 0.5/sum(catPresent); end
        if fa == 1, fa = (sum(catNotPresent)-0.5)./sum(catNotPresent); end
        if fa == 0, fa = 0.5/sum(catNotPresent); end
        
        data_dp(s,c) = norminv(hit)-norminv(fa);
    end
end

%% plotting : confusion matrix
sami.util.selectPlot([figI 2 2 1],userOptions.fig_display); cla;
% set(gcf,'Position',[2600 50 850 650]);
set(gcf,'Position',[200 10 830 830]);


image(confMat_perc,'CDataMapping','scaled')
hold on; box on; axis equal; 
xlim([.5 nCat+.5]); ylim([.5 nCat+.5]);

title(['\fontsize{11}confusion matrix: ''' depVar ''' responses']);

xlabel('\fontsize{10}\bfbehavioral response');
ylabel('\fontsize{10}\bftarget');
set(gca,...
    'XTick',1:nCat,...
    'XTickLabel',userOptions.stimuli_naming_key(catIdx).condition,...
    'XTickLabelRotation',90,...
    'YTick',1:nCat,...
    'YTickLabel',userOptions.stimuli_naming_key(catIdx).condition,...
    'XAxisLocation','top',...
    'FontSize',9);

caxis([0 100]);
colormap(cmp)
c = colorbar;
c.Label.String = '[%]';
c.Label.FontSize = 10;

%% plotting : confusion matrix - TABLE
sami.util.selectPlot([figI 2 2 3],userOptions.fig_display); cla; 
box on; axis equal

xlabel('\fontsize{10}\bfbehavioral response');
ylabel('\fontsize{10}\bftarget');
xlim([0.5 nCat+1.5]); ylim([0.5 nCat+1.5]);
set(gca,...
    'XTick',1:nCat+1,...
    'XTickLabel',[userOptions.stimuli_naming_key(catIdx).condition,{'\Sigma'}],...
    'XTickLabelRotation',90,...
    'YTick',1:nCat+1,...
    'YTickLabel',[userOptions.stimuli_naming_key(catIdx).condition,{'\Sigma'}],...
    'XAxisLocation','top',...
    'FontSize',9,...
    'TickLength',[0 0],...
    'Ydir','reverse');

line([0.5 nCat+1.5],[nCat+.5 nCat+.5],'Color',[.7 .7 .7],'LineWidth',0.5);
line([nCat+.5 nCat+.5],[0.5 nCat+1.5],'Color',[.7 .7 .7],'LineWidth',0.5);

for t = 1:nCat+1
    for r = 1:nCat+1
        if ~isnan(confMat_abs_total(t,r))
            if r == t
                txtB = 'bold';
            else
                txtB = 'normal';
            end
            str = {sprintf('%.2f%%',confMat_perc_total(t,r)),' '};
            text(r,t,str,'HorizontalAlignment','center','Fontsize',9,'fontweight',txtB);
            str = {' ',['(' num2str(confMat_abs_total(t,r)) ')']};
            text(r,t,str,'HorizontalAlignment','center','Fontsize',7,'fontweight',txtB);
        end
    end
end

%% plotting : accuracy + d' barplots in a loop
for plt = 1:2
    switch plt
        case 1
            thisData = data_acc;
            thisM = 100/nCat;
            
            thisFig = 2;
            statName = 'accuracy';
            
            thisTitleP = {['accuracy of behavioral responses (' depVar ')'],...
                          ['averaged across subjects (n=' num2str(nSubj) ')']};
            thisYlabelP = 'accuracy (\pm SEM) [%]';
            
            thisTitleNP = {['behavioral response (' depVar ') of subjects (n=' num2str(nSubj) ')'],...
                           ['(subjects: averaged across ' num2str(nStim) ' stimuli)']};
            thisYlabelNP = 'accuracy [%]';
        case 2
            thisData = data_dp;
            thisM = 0;
            
            thisFig = 4;
            statName = 'dprime';
            
            thisTitleP = {['sensitivity of stimulus categories (' depVar ') '],...
                          ['averaged across subjects (n=' num2str(nSubj) ')']};
            thisYlabelP = 'd'' (\pm SEM)';
            
            thisTitleNP = {['sensitivity for stimulus categories (' depVar ') of subjects (n=' num2str(nSubj) ')'],...
                           ['(subjects: averaged across ' num2str(nStim) ' stimuli)']};
            thisYlabelNP = 'd''';
    end
    
    sami.util.selectPlot([figI 2 2 thisFig],userOptions.fig_display); cla;

    % decide what kind of statistical analysis and figures to plot with current data
    if nSubj >=  userOptions.stats_minNforSubjectRFXtests
        % ---------- parametric --- show barplot -----------------------------------------
        sami.fig.drawBars(thisData,category,userOptions);
        
        % calculate one-way-ANOVA <OR> t-test
        if nCat > 2
            % test for group difference + add pairwise significance lines
            stats.(statName).groupDiffs = sami.stat.rmANOVA(thisData,userOptions.behav_multipleTesting,userOptions.behav_threshold);
            
            % prepare string for title, depending on statistical test
            pStr = sami.util.getPString(stats.(statName).groupDiffs.p);
            if isinteger([stats.(statName).groupDiffs.df1 stats.(statName).groupDiffs.df2])
                statStr = sprintf(['%s(%d,%d) = %.2f , ' pStr ', pEta^2 = %.2f'], stats.(statName).groupDiffs.S, stats.(statName).groupDiffs.df1, stats.(statName).groupDiffs.df2, stats.(statName).groupDiffs.V,stats.(statName).groupDiffs.pEtaSq);
            else
                statStr = sprintf(['%s(%.2f,%.2f) = %.2f , ' pStr ', pEta^2 = %.2f'], stats.(statName).groupDiffs.S, stats.(statName).groupDiffs.df1, stats.(statName).groupDiffs.df2, stats.(statName).groupDiffs.V,stats.(statName).groupDiffs.pEtaSq);
            end
        else
            % test for group difference + add pairwise significance lines
            stats.(statName).groupDiffs = sami.stat.tTest(thisData,'paired');
            
            % prepare string for title, depending on statistical test
            pStr = sami.util.getPString(stats.(statName).groupDiffs.p);
            statStr = sprintf(['%s(%d) = %.2f , ' pStr ', d = %.2f'], stats.(statName).groupDiffs.S, stats.(statName).groupDiffs.df, stats.(statName).groupDiffs.V,stats.(statName).groupDiffs.d);
        end
        
        % calculate one-sample t-test comparing against chance/zero
        stats.(statName).testVsValue = sami.stat.tTest(thisData,'one_sample',thisM);
        
        % show title/ylabel
        title([thisTitleP,statStr], 'fontsize',10)
        ylabel(thisYlabelP);
    else
        % ---------- non-parameteric --- boxplot -----------------------------------------
        sami.fig.drawBoxPlot(thisData,category,userOptions);
        
        % calculate Kruskal-Wallis <OR> Mann-Whitney-U-Test *IF* StimPerCat > minNforNPtests
        if nSubj >= userOptions.stats_minNforNonParamTests
            if nCat > 2
                % test for group difference + add pairwise significance lines
                stats.(statName).groupDiffs = sami.stat.Friedman(thisData,userOptions.behav_multipleTesting,userOptions.behav_threshold);
                
                % prepare string for title, depending on statistical test
                pStr = sami.util.getPString(stats.(statName).groupDiffs.p);
                statStr = sprintf(['%s(%d) = %.2f , ' pStr ', W = %.2f'], stats.(statName).groupDiffs.S, stats.(statName).groupDiffs.df, stats.(statName).groupDiffs.V,stats.(statName).groupDiffs.KendallW);
            else
                % test for group difference + add pairwise significance lines
                stats.(statName).groupDiffs = sami.stat.Wilcoxon(thisData,'paired');
                
                % prepare string for title, depending on statistical test
                pStr = sami.util.getPString(stats.(statName).groupDiffs.p);
                statStr = sprintf(['%s = %.2f , ' pStr ', r = %.2f'], stats.(statName).groupDiffs.S, stats.(statName).groupDiffs.V, stats.(statName).groupDiffs.r);
            end
        else
            statStr = '';
        end
        
        % calculate one-sided Wilcoxon signed rank test comparing against chance/zero
        stats.(statName).testVsValue = sami.stat.Wilcoxon(thisData,'one_sample',thisM);
        
        % show title/ylabel
        title([thisTitleNP,statStr], 'fontsize',10)
        ylabel(thisYlabelNP);
    end
    
    % edit title and add statistics
    curAx = gca;
    curTitle = curAx.Title.String;
    if stats.(statName).groupDiffs.p < 0.05 && nCat > 2
        multTestStr = ['\rm(threshold: ' num2str(userOptions.behav_threshold) ', multiple testing: ' userOptions.behav_multipleTesting ')'];
        title([curTitle; multTestStr]);
    end
    
    % save stats
    stats.(statName).dataPoints = thisData;
    stats.(statName).dataMEAN = mean(thisData);
    stats.(statName).dataSEM = std(thisData) ./ sqrt(size(thisData,1));
end

%% save
returnHere = pwd;
thisFileName = ['compBehavCategoricalData' fileNameSufix];

% ANOVA results
sami.util.gotoDir(fullfile(userOptions.rootPath, 'compBehavCategoricalData'));
disp(['   -> saving STATISTIC results to ' fullfile(pwd, thisFileName)]);
save([thisFileName '.mat'], 'stats');

% figure
sami.util.gotoDir(fullfile(userOptions.rootPath, 'compBehavCategoricalData','figs'));
disp(['   -> saving behavioral data FIGURE to ' fullfile(pwd, thisFileName)]);
sami.fig.handleFigure(figI, thisFileName, userOptions);

cd(returnHere);

end

