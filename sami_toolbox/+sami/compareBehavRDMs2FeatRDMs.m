function stats = compareBehavRDMs2FeatRDMs(refRDMs_input, featRDMs_input, refName_input, featName_input, userOptions, figI)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 09/2020

%% define default behavior
if ~exist('figI','var') || isempty(figI), figI = sami.util.getFigI(); end
userOptions = sami.util.setIfUnset(userOptions, 'rdms_pairWiseCorr', 'Spearman');
userOptions = sami.util.setIfUnset(userOptions, 'rdms_relatednessTest', 'signedRank');
userOptions = sami.util.setIfUnset(userOptions, 'rdms_relatednessThreshold', 0.05);
userOptions = sami.util.setIfUnset(userOptions, 'rdms_relatednessMultipleTesting', 'FDR');
userOptions = sami.util.setIfUnset(userOptions, 'rdms_differencesTest','signedRank');
userOptions = sami.util.setIfUnset(userOptions, 'rdms_differencesThreshold',0.05);
userOptions = sami.util.setIfUnset(userOptions, 'rdms_differencesMultipleTesting','FDR');
userOptions = sami.util.setIfUnset(userOptions, 'stats_minNforSubjectRFXtests', 12);
userOptions = sami.util.setIfUnset(userOptions, 'rdms_nRandomisations',50000);
userOptions = sami.util.setIfUnset(userOptions, 'rdms_orderByCorr',true);

%% check input
if ~any(ismember({'signedRank','randomisation','none'}, userOptions.rdms_relatednessTest))
    error('*** sami:ERROR *** wrong specification in ''rdms_relatednessTest''. Please check. returning.')
end
if ~any(ismember({'signedRank','conditionBootstrap','none'}, userOptions.rdms_relatednessTest))
    error('*** sami:ERROR *** wrong specification in ''rdms_relatednessTest''. Please check. returning.')
end

disp(['*** compare behavioralRDMs with featuresRDMs [fig. ' num2str(figI) '] ***']);

%% init vars
fileNameSufix = ['_' refName_input '_with_' featName_input];

if ~exist('refName_input','var') || isempty(refName_input)
    refName = 'reference'; 
else
    refName = [refName_input ' -'];
end
if ~exist('featName_input','var') || isempty(featName_input)
    featName = 'feature'; 
else
    featName = featName_input;
end

% figure style
style.barFace = [.4 .4 .4];
style.barEdge = 'none';

style.ceilingFace = [.7 .7 .7];
style.ceilingEdge = 'none';
style.ceilingAlpha = 0.5;

style.errorBarColor = [0 0 0];
style.errorBarWidth = 4;
style.errorBarCapSize = 0;
style.errorBarLineStyle = 'none';

style.starsColor = [0 0 0];
style.starsSize = 20;

style.featRDMsColor = [0 0 0];
style.featRDMsRotation = 45;

style.vertAxisWidth = 1;
style.vertAxisColor = [0 0 0];

style.pwCompColors = [0 0 0;...     % black
                      1 .4667 0;... % orange
                      .7725 0 0];   % red

%% prepare ref/feat RDMs
[refRDMs,nRefRDMs] = sami.rdm.unwrapRDMs(refRDMs_input);
meanRefRDM = mean(refRDMs,3);
[featRDMs,nFeatRDMs,featNames] = sami.rdm.unwrapRDMs(featRDMs_input);
[nStim,~,nSubj] = size(refRDMs);

%% check if all entries in any RDM are valid
if any(isnan(refRDMs(:))) || any(isnan(featRDMs(:)))
    error('*** sami:ERROR *** NANs found in one of the reference or feature RDMs. Cant''t deal with that. Please check and remove NANs from RDMs. returning.')
end

%% estimate the ceiling for the refRDM
[ceilingUpperBound, ceilingLowerBound] = sami.stat.noiseCeilingOfAvgRDMcorr(refRDMs,userOptions.rdms_pairWiseCorr);
stats.ceiling = [ceilingLowerBound,ceilingUpperBound];

%% calculate the average correlation
% correlate the average of the featRDMs with each instance of the refRDM
feat2refCorrs = nan(nSubj,nFeatRDMs);
for iFeat = 1:nFeatRDMs
    for iSubj = 1:nSubj
        if isequal(userOptions.rdms_pairWiseCorr,'Kendall_taua')
            feat2refCorrs(iSubj,iFeat) = sami.stat.rankCorr_Kendall_taua(sami.rdm.vectorizeRDMs(featRDMs(:,:,iFeat))',sami.rdm.vectorizeRDMs(refRDMs(:,:,iSubj))');
        else
            feat2refCorrs(iSubj,iFeat) = corr(sami.rdm.vectorizeRDMs(featRDMs(:,:,iFeat))',sami.rdm.vectorizeRDMs(refRDMs(:,:,iSubj))','type',userOptions.rdms_pairWiseCorr,'rows','pairwise');
        end
    end
end
y = mean(feat2refCorrs,1);

% check if bars will be sorted
if userOptions.rdms_orderByCorr
    [~,sortedIs] = sort(y,'descend');
else
    sortedIs = 1:nFeatRDMs;
end
featNames = featNames(sortedIs);
y_sorted = y(sortedIs);

% save stats
stats.featNames = featNames;
stats.featRelatedness_r = y_sorted;
stats.featRelatedness_subjects_r = feat2refCorrs(:,sortedIs);

%% decide inference procedures and test for RDM relatedness
% check if there are enough subjects for subject RFX tests
if nRefRDMs >= userOptions.stats_minNforSubjectRFXtests
    subjectRFX = true;
    fprintf('   -> (info) Found %d instances of the reference RDMs.\n',nRefRDMs);
else
    subjectRFX = false;
    fprintf('   -> (info) Found less than 12 of reference RDMs instances. Cannot do subject random-effects inference.\n');
end

% decide RDM-relatedness test
if isequal(userOptions.rdms_relatednessTest,'signedRank') && ~subjectRFX
    userOptions.rdms_relatednessTest = 'randomisation';
end

% perform choosen test
switch userOptions.rdms_relatednessTest
    case 'signedRank'
        fprintf('   -> Performing signed-rank test of RDM relatedness (subject as random effect).\n');
        pVals = nan(nFeatRDMs,1);
        for iFeat = 1:nFeatRDMs
            [pVals(iFeat)] = sami.stat.signrank_onesided(feat2refCorrs(:,iFeat));
        end
        pVals = pVals(sortedIs);
        
        % correct pVals for MC
        stats.featRelatedness_p = sami.stat.multipleTesting(pVals,userOptions.rdms_relatednessMultipleTesting,userOptions.rdms_relatednessThreshold);
        
    case 'randomisation'
        fprintf('   -> Performing condition-label randomisation test of RDM relatedness (fixed effects).\n');
        fprintf('     -> of %d randomisations: 0%%', userOptions.rdms_nRandomisations);
        tic;
        nRand = userOptions.rdms_nRandomisations;
        rdms = nan(nFeatRDMs,nStim*(nStim-1)/2);
        for iRDM = 1:nFeatRDMs
            rdms(iRDM,:) = sami.rdm.vectorizeRDM(featRDMs(:,:,iRDM));
        end
        
        % do exhaustive permutations if number of stimuli < 8
        exPerm = false;
        if nStim < 8
            allPerm = perms(1:nStim);
            nRand = size(allPerm, 1);
            exPerm = true;
        end
        
        % loop randomisations
        nullCorr = nan(nRand,nFeatRDMs);
        for iRand = 1:nRand
            if exPerm
                rndIdx = allPerm(iRand, :);
            else
                rndIdx = randperm(nStim);
            end
            
            rdmA_rand_vec = sami.rdm.vectorizeRDM(meanRefRDM(rndIdx,rndIdx));
            
            if isequal(userOptions.rdms_pairWiseCorr,'Kendall_taua')
                for iFeat = 1:nFeatRDMs
                    nullCorr(iRand,iFeat) = sami.stat.rankCorr_Kendall_taua(rdmA_rand_vec',rdms(iFeat,:)');
                end
            else
                nullCorr(iRand,:) = corr(rdmA_rand_vec',rdms','type',userOptions.rdms_pairWiseCorr,'rows','pairwise');
            end
            
            if mod(iRand,nRand/100) == 0
                fprintf([repmat('\b',1,numel(num2str(round(100*iRand/nRand)-1))+1) '%d%%'],round(100*iRand/nRand))
            end
        end
        t = toc;
        fprintf([' ... DONE [in ' num2str(ceil(t)) 's]\n']);

        % calculate p-values from the randomisation test
        pVals = nan(nFeatRDMs,1);
        for iFeat = 1:nFeatRDMs
            pVals(iFeat) = 1 - sami.stat.relRank(nullCorr(:,iFeat), y(iFeat));
        end
        pVals = pVals(sortedIs);
        
        % correct pVals for MC
        stats.featRelatedness_p = sami.stat.multipleTesting(pVals,userOptions.rdms_relatednessMultipleTesting,userOptions.rdms_relatednessThreshold);        
        
        % display warning text
        if exPerm
            fprintf('      >>> WARNING <<< Comparing RDMs with fewer than 8 conditions (per conditions set) will produce unrealiable results!\n');
            fprintf('                      I''ll partially compensate by using exhaustive instead of random permutations...\n');
        end
        
    otherwise
        fprintf('   -> Not performing any test of RDM relatedness.\n');
end

%% decide inference type and perform feature-RDM-comparison test
% pairwise difference in average feat2refCorrs
for i = 1:nFeatRDMs
    for j = 1:nFeatRDMs
        stats.featDifferences_r(i,j) = y_sorted(i)-y_sorted(j);
    end
end

% decide feature-RDM-comparison test
if isequal(userOptions.rdms_differencesTest,'signedRank')
    if subjectRFX
        fprintf('   -> (info) using %d instances of the reference RDM for random-effects tests comparing pairs of feature RDMs.\n', nRefRDMs);
    else
        fprintf('   -> (info) attempting to revert to condition-bootstrap tests comparing pairs of feature RDMs.\n');
        if nStim >= 20
            fprintf('   -> (info) reverting to condition bootstrap tests for comparing pairs of feature RDMs.\n');
            userOptions.rdms_differencesTest = 'conditionBootstrap';
        else
            fprintf('   -> (info) there are less than 20 conditions. can not do tests for comparing pairs of feature RDMs.\n');
            userOptions.rdms_differencesTest = 'none';
        end
    end
end

% perform choosen test
switch userOptions.rdms_differencesTest
    case 'signedRank'
        fprintf('   -> Performing signed-rank test for feature RDM comparisons (subject as random effect).\n');
        % do a one sided signrank test on the similarity of the each feature RDM,averaged 
        % over all instances with the different instances of the reference RDM
        pairWisePs = nan(nFeatRDMs);
        for iFeat = 1:nFeatRDMs
            for jFeat = 1:nFeatRDMs
                [pairWisePs(iFeat,jFeat)] = signrank(feat2refCorrs(:,iFeat),feat2refCorrs(:,jFeat),'alpha',0.05,'method','exact');
            end
        end
        stats.featDifferences_pUncorr = pairWisePs(sortedIs,sortedIs);
        pairWisePs = pairWisePs(sortedIs,sortedIs);
        
        % correct pVals for MC
        pUncorr = sami.rdm.vectorizeRDM(pairWisePs)';
        pCorr = sami.stat.multipleTesting(pUncorr,userOptions.rdms_differencesMultipleTesting,userOptions.rdms_differencesThreshold);
        pCorr = squareform(pCorr);
        pCorr(logical(eye(size(pCorr,1)))) = 1;
        stats.featDifferences_p = pCorr;
        stats.featDifferences_pUncorr = pairWisePs;

        % standard error
        stats.featRelatedness_SEs = std(feat2refCorrs(:,sortedIs))/sqrt(nSubj);
        
    case 'conditionBootstrap'
        fprintf('   -> Performing condition bootstrap test comparing feature RDMs (subject as random effect).\n');
        % bootstrap correlation values
        bootstrapRs = sami.stat.bootstrapRDMs(refRDMs, featRDMs, userOptions);
        
        % find p-values based on bootstraped distributions of correlation values
        pairWisePs = nan(nFeatRDMs);
        for iFeat = 1:(nFeatRDMs-1)
            bsI = bootstrapRs(iFeat,:);
            feat2refSimsI = feat2refCorrs(:,iFeat);
            
            for jFeat = (iFeat+1):nFeatRDMs
                bsJ = bootstrapRs(jFeat,:);
                feat2refSimsJ = feat2refCorrs(:,jFeat);
                
                [~, ~, pairWisePs(iFeat, jFeat)] = sami.stat.bootConfint(feat2refSimsI - feat2refSimsJ, bsI - bsJ, 'two-tailed', userOptions);
                pairWisePs(jFeat, iFeat) = pairWisePs(iFeat, jFeat);
            end
        end
        stats.featDifferences_pUncorr = pairWisePs(sortedIs,sortedIs);
        pairWisePs = pairWisePs(sortedIs,sortedIs);
        
        % correct pVals for MC
        pUncorr = sami.rdm.vectorizeRDM(pairWisePs)';
        pCorr = sami.stat.multipleTesting(pUncorr,userOptions.rdms_differencesMultipleTesting,userOptions.rdms_differencesThreshold);
        pCorr = squareform(pCorr);
        pCorr(logical(eye(size(pCorr,1)))) = 1;
        stats.featDifferences_p = pCorr;
        stats.featDifferences_pUncorr = pairWisePs;
        
        % standard error
        bootstrapEs = std(bootstrapRs, 0, 2);
        stats.featRelatedness_SEs = bootstrapEs(sortedIs);
        
    otherwise
        fprintf('   -> Not performing any test for comparing pairs of feature RDMs.\n');
end

%% creating figure >>> bar-plot 
sami.util.selectPlot([figI 1 2 1],userOptions.fig_display);
set(gcf,'Position',[130 150 950 650]); 
hold on;

% average RDM-relatedness bars +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
for barI = 1:nFeatRDMs
    patch([barI-0.4 barI-0.4 barI+0.4 barI+0.4],[0 y_sorted(barI) y_sorted(barI) 0],[-0.01 -0.01 -0.01 -0.01],...
        style.barFace,...
        'edgecolor',style.barEdge);
end

% ceiling ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
h = patch([0.1 0.1 nFeatRDMs+0.9 nFeatRDMs+0.9],...
          [ceilingLowerBound ceilingUpperBound ceilingUpperBound ceilingLowerBound],...
          [0.1 0.1 0.1 0.1],...
          style.ceilingFace,...
          'edgecolor',style.ceilingEdge);
alpha(h,style.ceilingAlpha);

% errorbars ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
errorbar(1:nFeatRDMs,y_sorted,stats.featRelatedness_SEs,...
    'Color',style.errorBarColor,...
    'CapSize',style.errorBarCapSize,...
    'LineWidth',style.errorBarWidth,...
    'LineStyle',style.errorBarLineStyle);

% p-values from RDM relatedness tests ++++++++++++++++++++++++++++++++++++++++++++++++++++
if ~isequal(userOptions.rdms_relatednessTest,'none')
    pVals = stats.featRelatedness_p;
    for test = 1:nFeatRDMs
        if pVals(test) <= userOptions.rdms_relatednessThreshold
            H = stats.featRelatedness_r(test) + stats.featRelatedness_SEs(test) + max(stats.featRelatedness_SEs);
            text(test, H, ['\bf',sami.util.getStars(pVals(test))],...
                'Rotation', 0,...
                'Color', style.starsColor,...
                'FontSize',style.starsSize,...
                'HorizontalAlignment','center');
        end
    end
end

% label the bars with the names of the feature RDMs ++++++++++++++++++++++++++++++++++++++
Ymin = min(min(y)-max(stats.featRelatedness_SEs),0);
for test = 1:nFeatRDMs
    text(test, Ymin, ['\bf',sami.util.deunderscore(featNames{test})],...
        'Rotation', style.featRDMsRotation,...
        'Color', style.featRDMsColor,...
        'HorizontalAlignment','right');
end

% plot pretty vertical axis ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
axis off;
maxYTickI = ceil(max( [y ceilingUpperBound] ) * 10);
for YTickI = 0:maxYTickI
    plot([0 0.2],[YTickI YTickI]./10,'Color',style.vertAxisColor,'LineWidth',style.vertAxisWidth);
    text(0,double(YTickI/10),num2str(YTickI/10,1),'HorizontalAlignment','right');
end
plot([0.1 0.1],[0 YTickI]./10,'k','LineWidth',style.vertAxisWidth);
% text(-1.2,double(maxYTickI/10/2),...
text(-.15*range(xlim),double(maxYTickI/10/2),...
    {'\bf RDM correlation ',['\rm[',sami.util.deunderscore(userOptions.rdms_pairWiseCorr),', averaged across ',num2str(nRefRDMs),' subjects]']},...
    'HorizontalAlignment','center',...
    'Rotation',90);

% add title/description text above +++++++++++++++++++++++++++++++++++++++++++++++++++++++
ylim(ylim + [0 .01]);
title({['\bf\fontsize{10} Relatedness between ' refName '-RDM and each of the ' featName '-RDMs'],...
    ['\fontsize{8}RDM relatedness tests: \rm',userOptions.rdms_relatednessTest,...
    '\rm (threshold: ',num2str(userOptions.rdms_relatednessThreshold),', multiple testing: ',userOptions.rdms_relatednessMultipleTesting,')'],...
    ['\bfsignificance:\rm *: p < ' num2str(userOptions.rdms_relatednessThreshold, '%0.2f') ', **: p < ',num2str(userOptions.rdms_relatednessThreshold/5, '%0.2f') ', ***: p < ',num2str(userOptions.rdms_relatednessThreshold/50, '%0.3f')]});

%%  creating figure >>> matrices for pairwise feature RDM comparisons
sami.util.selectPlot([figI 1 2 2],userOptions.fig_display);

% prepare matrix: get data and color_code according to p-values ++++++++++++++++++++++++++
plt_thresh = userOptions.rdms_differencesThreshold;
plt_invisible = true(nFeatRDMs);
plt_invisible(stats.featDifferences_r > 0) = false;

plt_pMat = stats.featDifferences_p;
plt_sigLevel = plt_pMat;
plt_sigLevel(plt_pMat > plt_thresh) = 1;                            % black
plt_sigLevel(plt_pMat <= plt_thresh & plt_pMat > plt_thresh/5) = 2; % intermediate color
plt_sigLevel(plt_pMat <= plt_thresh/5) = 3;                         % red

plt_image = nan(size(plt_sigLevel,1),size(plt_sigLevel,2),3);
for k1 = 1:nFeatRDMs
    for k2 = 1:nFeatRDMs
        if plt_invisible(k1,k2)
            plt_image(k1,k2,:) = [1 1 1]; % set every "invisible cell = white"
        else
            plt_image(k1,k2,:) = style.pwCompColors(plt_sigLevel(k1,k2),:);            
        end
    end
end

% display matrix and add tick_labels +++++++++++++++++++++++++++++++++++++++++++++++++++++
imagesc(plt_image(1:nFeatRDMs-1,2:nFeatRDMs,:));
axis square;
set(gca,'xTick',1:nFeatRDMs-1,...
    'xTickLabel',sami.util.deunderscore(stats.featNames(2:nFeatRDMs)),...
    'XTickLabelRotation', 90,...
    'yTick',1:nFeatRDMs-1,...
    'yTickLabel',sami.util.deunderscore(stats.featNames(1:nFeatRDMs-1)),...
    'TickLength',[0 0],...
    'fontsize',10);

% add title/description text above +++++++++++++++++++++++++++++++++++++++++++++++++++++++
title({['\bf\fontsize{10}Pairwise comparison of ''relatedness'' between ' featName ' RMDs'],...
       ['\fontsize{8}pairwise comparison tests: \rm',userOptions.rdms_differencesTest,...
        '\rm (threshold: ',num2str(userOptions.rdms_differencesThreshold),', multiple testing: ',userOptions.rdms_differencesMultipleTesting,')'],...
       ['\bfsignificance:\rm black: n.s., orange: p < ' num2str(userOptions.rdms_differencesThreshold, '%0.2f') ', red: p < ',num2str(userOptions.rdms_differencesThreshold/5, '%0.2f')]});

% edit size of axes ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
set(gca,'Position',get(gca,'Position') .* [1.1 2 .5 1]);

%% save 
returnHere = pwd;
thisFileName = ['compare' fileNameSufix '_RDMs'];

% correlation matrix
sami.util.gotoDir(fullfile(userOptions.rootPath, 'compBehav2Feat'));
disp(['   -> saving comparing STATISTICS to ' fullfile(pwd, thisFileName)]);
save([thisFileName '.mat'], 'stats');

% figure
sami.util.gotoDir(fullfile(userOptions.rootPath, 'compBehav2Feat','figs'));
disp(['   -> saving 2nd-order FIGURE to ' fullfile(pwd, thisFileName)]);
sami.fig.handleFigure(figI, thisFileName, userOptions);

cd(returnHere);
end



