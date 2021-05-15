function stats = compareBehavData(data, category, depVar, userOptions, figI)
% 
% 
% 
% 
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
disp(['*** compare behavioral data [fig. ' num2str(figI) '] ***']);

%% init vars
fileNameSufix = ['_' sami.util.deblank(depVar) '_by_' sami.util.deblank(category)];

%% get category for 'data'-input according to 'category'-input
fileOrder = sami.util.getStimOrder(userOptions);
[~, catIdx] = ismember(category, userOptions.stimuli_settings(1,2:end));
catOfStim = cell2mat(userOptions.stimuli_settings(fileOrder+1,catIdx + 1));
catNums = unique(catOfStim);
nCat = numel(catNums);

%% data preprocessing
% average across stimuli in category for each subject
dataSubj = nan(size(data,2),numel(catNums));
for i = 1:nCat
    dataSubj(:,i) = mean(data(catOfStim == catNums(i),:));
end

% average across subjects in category for each stimulus
dataStim = nan(size(data,1)/numel(catNums),numel(catNums));
for i = 1:nCat
    dataStim(:,i) = mean(data(catOfStim == catNums(i),:),2);
end

%% loop both data_set and plot them, and do parametric/non_parametric group comparisons, if applicable
for i = 1:2
    % fetch data
    switch i
        case 1
            % fetch data
            thisData = dataSubj;
            title_info = {'subjects' 'stimuli'};
            statName = 'compSubjects';
        case 2
            % fetch data
            thisData = dataStim;
            title_info = {'stimuli' 'subjects'};
            statName = 'compStimuli';
    end
    nThisData = size(thisData,1);
    
    % selectPlot
    sami.util.selectPlot([figI 1 2 i],userOptions.fig_display); cla;
    set(gcf,'Position',[200 50 800 400]);
    
    % decide what kind of plot to plot with current data
    if nThisData >=  userOptions.stats_minNforSubjectRFXtests
        % ---------- show barplot --------------------------------------------------
        sami.fig.drawBars(thisData,category,userOptions);
                
        % calculate one-way-ANOVA <OR> t-test
        if nCat > 2
            % test for group difference + add pairwise significance lines
            stats.(statName).groupDiffs = sami.stat.ANOVA(thisData,userOptions.behav_multipleTesting,userOptions.behav_threshold);
            
            % prepare string for title, depending on statistical test
            pStr = sami.util.getPString(stats.(statName).groupDiffs.p);
            statStr = sprintf(['%s(%d,%d) = %.2f , ' pStr ', eta^2 = %.2f'], stats.(statName).groupDiffs.S, stats.(statName).groupDiffs.df1, stats.(statName).groupDiffs.df2, stats.(statName).groupDiffs.V,stats.(statName).groupDiffs.etaSq);
        else
            % test for group difference + add pairwise significance lines
            stats.(statName).groupDiffs = sami.stat.tTest(thisData,'paired');
            
            % prepare string for title, depending on statistical test
            pStr = sami.util.getPString(stats.(statName).groupDiffs.p);
            statStr = sprintf(['%s(%d) = %.2f , ' pStr ', d = %.2f'], stats.(statName).groupDiffs.S, stats.(statName).groupDiffs.df, stats.(statName).groupDiffs.V,stats.(statName).groupDiffs.d);
        end
        
        % show title/ylabel
        title({['behavioral rating (' depVar ')'],...
               ['averaged across ' title_info{1} ' (n=' num2str(nThisData) ')'],...
               statStr},...
                'fontsize',10)
        ylabel('average rating (\pm SEM)');
    else
        % ---------- boxplot --------------------------------------------------
        sami.fig.drawBoxPlot(thisData,category,userOptions);
        
        % calculate Kruskal-Wallis <OR> Mann-Whitney-U-Test *IF* StimPerCat > minNforKW
        if nThisData >= userOptions.stats_minNforNonParamTests
            if nCat > 2
                % test for group difference + add pairwise significance lines
                stats.(statName).groupDiffs = sami.stat.KruskalWallis(thisData,userOptions.behav_multipleTesting,userOptions.behav_threshold);
                
                % prepare string for title, depending on statistical test
                pStr = sami.util.getPString(stats.(statName).groupDiffs.p);
                statStr = sprintf(['%s(%d) = %.2f , ' pStr ', eta^2 = %.2f'], stats.(statName).groupDiffs.S, stats.(statName).groupDiffs.df, stats.(statName).groupDiffs.V,stats.(statName).groupDiffs.etaSq);
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
        
        % show title/ylabel
        title({['behavioral rating (' depVar ') of ' title_info{1} ' (n=' num2str(nThisData) ')'],...
               ['(' title_info{1} ', averaged across ' title_info{2} ')'],...
                statStr},...
                'fontsize',10)
        ylabel('behavioral rating values');        
    end
    
    % edit title: add statistics and add multCompare info in case of significant differences
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
thisFileName = ['compBehavioralData' fileNameSufix];

% ANOVA results
sami.util.gotoDir(fullfile(userOptions.rootPath, 'compBehavData'));
disp(['   -> saving ANOVA results to ' fullfile(pwd, thisFileName)]);
save([thisFileName '.mat'], 'stats');

% figure
sami.util.gotoDir(fullfile(userOptions.rootPath, 'compBehavData','figs'));
disp(['   -> saving behavioral data FIGURE to ' fullfile(pwd, thisFileName)]);
sami.fig.handleFigure(figI, thisFileName, userOptions);

cd(returnHere);

end

