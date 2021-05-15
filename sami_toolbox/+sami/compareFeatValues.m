function stats = compareFeatValues(dataInput, category, fSetInfo, userOptions, figI)
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
if ~exist('fSetInfo','var') || isempty(fSetInfo), fSetInfo = 'NOT_SPECIFIED'; end
userOptions = sami.util.setIfUnset(userOptions, 'feat_threshold', 0.05);
userOptions = sami.util.setIfUnset(userOptions, 'feat_multipleTesting', 'bonferroni');
userOptions = sami.util.setIfUnset(userOptions, 'stats_minNforSubjectRFXtests', 12);
userOptions = sami.util.setIfUnset(userOptions, 'stats_minNforNonParamTests', 5);

% check
if ismember(category, userOptions.stimuli_settings(1,2:end)) == 0, error('*** sami:ERROR *** input for ''category'' is not specified in ''userOptions.stimuli_settings''. Please check input. returning.'); end

% print progress
disp(['*** compare features [fig. ' num2str(figI) '] ***']);

%% init vars
fileNameSufix = ['_' sami.util.deblank(fSetInfo) '_by_' sami.util.deblank(category)];
nFeat = numel(dataInput);

%% get category for 'data'-input according to 'category'-input
fileOrder = sami.util.getStimOrder(userOptions);
[~, catIdx] = ismember(category, userOptions.stimuli_settings(1,2:end));
catOfStim = cell2mat(userOptions.stimuli_settings(fileOrder+1,catIdx + 1));
catNums = unique(catOfStim);

nCat = numel(catNums);

% works ONLY if there is an equal amount of stimuli per category !!!!!!!
catCounts = accumarray(catOfStim,1);
if all(catCounts == catCounts(1))
    nStimPerCat = catCounts(1);
else
    error('*** sami:ERROR *** toolbox is (currently) unable to deal with unequally distributed stimuli across categories. please provide equal n for each category. returning.');
end

%% data preprocessing
% loop each feature-set
data = nan(nStimPerCat,nCat,nFeat);
units = cell(nFeat,1);
fisherZ = false(nFeat,1);
for f = 1:nFeat
    % average multivariate data to obtain one data_point per stimulus
    if dataInput(f).fisherZ4paramTesting
        tmpData = tanh(mean(atanh(dataInput(f).fSet),1))';
    else
        tmpData = mean(dataInput(f).fSet,1)';
    end
    % sort according to categories
    for c = 1:nCat
        data(:,c,f) = tmpData(catOfStim == catNums(c));
    end
    % get meta info
    units{f} = dataInput(f).unit;
    fisherZ(f) = dataInput(f).fisherZ4paramTesting;
end

%% loop feature-sets -> plot data -> do ANOVA if applicable
% prepare figure
nHorPan = ceil(sqrt(2/3 * nFeat));
nVerPan = ceil(nFeat/nHorPan);
sami.util.selectPlot(figI,userOptions.fig_display);
set(gcf,'Position',[200 10 1500 1000]);

for f = 1:nFeat
    % select panel
    sami.util.selectPlot([figI nVerPan nHorPan f],userOptions.fig_display); cla;
    
    % select data
    statName = dataInput(f).name;
    thisData = data(:,:,f);
    
    % decide what kind of plot to plot with current data
    if nStimPerCat >= userOptions.stats_minNforSubjectRFXtests
        % ---------- show barplot --------------------------------------------------
        sami.fig.drawBars(thisData,category,userOptions);
        
        % apply Fisher-z-transformation for 'correlational' data
        if fisherZ(f)
            thisData = atanh(thisData);
        end
        
        % calculate one-way-ANOVA OR t-test
        if nCat > 2
            % test for group difference + add pairwise significance lines
            stats.(statName).groupDiffs = sami.stat.ANOVA(thisData,userOptions.feat_multipleTesting,userOptions.feat_threshold);
            
            % prepare string for title, depending on statistical test
            pStr = sami.util.getPString(stats.(statName).groupDiffs.p);
            statStr = sprintf(['%s(%d,%d) = %.2f , ' pStr ', eta^2 = %.2f'], stats.(statName).groupDiffs.S, stats.(statName).groupDiffs.df1, stats.(statName).groupDiffs.df2, stats.(statName).groupDiffs.V,stats.(statName).groupDiffs.etaSq);
        else
            % test for group difference + add pairwise significance lines
            stats.(statName).groupDiffs = sami.stat.tTest(thisData,'two_sample');
            
            % prepare string for title, depending on statistical test
            pStr = sami.util.getPString(stats.(statName).groupDiffs.p);
            statStr = sprintf(['%s(%d) = %.2f , ' pStr ', d = %.2f'], stats.(statName).groupDiffs.S, stats.(statName).groupDiffs.df, stats.(statName).groupDiffs.V,stats.(statName).groupDiffs.d);
        end
        
        % show title/ylabel
        title({['"' sami.util.deunderscore(statName) '"'],...
               ['averaged across stimuli (n=' num2str(size(thisData,1)) ')'],...
               statStr},...
                'fontsize',10)
        ylabel({['feature values [' units{f} ']'],'(MEAN \pm SEM)'});
    else
        % ---------- boxplot --------------------------------------------------
        sami.fig.drawBoxPlot(thisData,category,userOptions);
        
        % calculate Kruskal-Wallis <OR> Mann-Whitney-U-Test *IF* StimPerCat > minNforKW
        if nStimPerCat >= userOptions.stats_minNforNonParamTests
            if nCat > 2
                % test for group difference + add pairwise significance lines
                stats.(statName).groupDiffs = sami.stat.KruskalWallis(thisData,userOptions.feat_multipleTesting,userOptions.feat_threshold);
                
                % prepare string for title, depending on statistical test
                pStr = sami.util.getPString(stats.(statName).groupDiffs.p);
                statStr = sprintf(['%s(%d) = %.2f , ' pStr ', eta^2 = %.2f'], stats.(statName).groupDiffs.S, stats.(statName).groupDiffs.df, stats.(statName).groupDiffs.V,stats.(statName).groupDiffs.etaSq);
            else
                % test for group difference + add pairwise significance lines
                stats.(statName).groupDiffs = sami.stat.Wilcoxon(thisData,'two_sample');
                
                % prepare string for title, depending on statistical test
                pStr = sami.util.getPString(stats.(statName).groupDiffs.p);
                statStr = sprintf(['%s = %.2f , ' pStr ', r = %.2f'], stats.(statName).groupDiffs.S, stats.(statName).groupDiffs.V, stats.(statName).groupDiffs.r);
            end
        else
            statStr = '';
        end
        
        % show title/ylabel
        title({['"' sami.util.deunderscore(statName) '"'],...
               ['distribution of stimuli (n=' num2str(size(thisData,1)) ')'],...
               statStr},...
                'fontsize',10)
        ylabel(['feature values [' units{f} ']']);
    end
    
    % edit title: add statistics and add multCompare info in case of significant differences
    curAx = gca;
    curTitle = curAx.Title.String;
    if stats.(statName).groupDiffs.p < 0.05 && nCat > 2
        multTestStr = ['\rm(threshold: ' num2str(userOptions.feat_threshold) ', multiple testing: ' userOptions.feat_multipleTesting ')'];
        title([curTitle; multTestStr]);
    end
    
    % save stats
    stats.(statName).dataPoints = thisData;
    stats.(statName).dataMEAN = mean(thisData);
    stats.(statName).dataSEM = std(thisData) ./ sqrt(size(thisData,1));
    stats.(statName).unit = units{f};    
end

%% save
returnHere = pwd;
thisFileName = ['compFeatureValues' fileNameSufix];

% ANOVA results
sami.util.gotoDir(fullfile(userOptions.rootPath, 'compFeatValues'));
disp(['   -> saving ANOVA results to ' fullfile(pwd, thisFileName)]);
save([thisFileName '.mat'], 'stats');

% figure
sami.util.gotoDir(fullfile(userOptions.rootPath, 'compFeatValues','figs'));
disp(['   -> saving feature data FIGURE to ' fullfile(pwd, thisFileName)]);
sami.fig.handleFigure(figI, thisFileName, userOptions);

cd(returnHere);

end
