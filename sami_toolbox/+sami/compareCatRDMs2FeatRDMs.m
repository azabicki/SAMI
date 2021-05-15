function stats = compareCatRDMs2FeatRDMs(refRDMs, featRDMs, infoTXT, userOptions, figI)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

%% define default behavior
if ~exist('figI','var') || isempty(figI), figI = sami.util.getFigI(); end
userOptions = sami.util.setIfUnset(userOptions, 'rdms_pairWiseCorr', 'Spearman');
userOptions = sami.util.setIfUnset(userOptions, 'rdms_pairWiseCorrMultipleTesting', 'holm');
userOptions = sami.util.setIfUnset(userOptions, 'rdms_pairWiseCorrThreshold', 0.05);

% print progress
disp(['*** compare categoryRDMs with featuresRDMs [fig. ' num2str(figI) '] ***']);

%% init vars
if ~exist('infoTXT','var') || isempty(infoTXT)
    titleTxt = ['compare Category and Feature RDMs (multiple testing: ' userOptions.rdms_pairWiseCorrMultipleTesting ')'];
    
	fNr = 1;
    while exist(fullfile(userOptions.rootPath, 'compCat2Feat', 'figs', [fprintf('compCat2FeatRDMs_%04d',fNr) '.*']),'file')
        fNr = fNr + 1;
    end
    fileNameSufix = sprintf('%04d',fNr);
else
    titleTxt = [sami.util.deunderscore(infoTXT) ' (multiple testing: ' userOptions.rdms_pairWiseCorrMultipleTesting ')'];
    fileNameSufix = sami.util.deblank(infoTXT);
end

cmp = sami.fig.createColormap('RDMofRDMs');
nRefRDMs = size(refRDMs,2);
nFeatRDMs = size(featRDMs,2);

%% calculate correlation
[corrMat, pValMat] = sami.stat.RDMCorrMat([refRDMs featRDMs], userOptions.rdms_pairWiseCorr);

% get values interested in
rVals = corrMat(1:nRefRDMs,nRefRDMs+1:end);
pVals = pValMat(1:nRefRDMs,nRefRDMs+1:end);

% correct pVals for multiple testing
pValsCorr = sami.stat.multipleTesting(pVals',userOptions.rdms_pairWiseCorrMultipleTesting,userOptions.rdms_pairWiseCorrThreshold)';

%% ploting
% +++++++++++++++++ corr. Matrix +++++++++++++++++
sami.util.selectPlot([figI 2 1 1],userOptions.fig_display);
set(gcf,'Position',[120 20 800 800]);

imagesc(rVals,[-1 1]);
axis equal; box on;

set(gca,'xTick',1:nFeatRDMs,'xTickLabel',sami.util.deunderscore({featRDMs(:).name}),'XTickLabelRotation', 45,'TickLength',[0 0],'fontsize',10);
set(gca,'yTick',1:nRefRDMs,'yTickLabel',sami.util.deunderscore({refRDMs(:).name}));

xlim([0.5 nFeatRDMs + 0.5]);
ylim([0.5 nRefRDMs + 0.5]);

for i = 1:nRefRDMs-1
    line([0.5 0.5+nFeatRDMs],[i i]+0.5,'Color','w','LineWidth',2)
end

% plot sig. stars
for i = 1:nRefRDMs
    for j = 1:nFeatRDMs
        %         text(j,i,['i' num2str(i) 'j' num2str(j)],'HorizontalAlignment','center','VerticalAlignment','middle','FontSize',12);
        if pValsCorr(i,j) < 0.05
            text(j,i,sami.util.getStars(pValsCorr(i,j)),'HorizontalAlignment','center','VerticalAlignment','middle','FontSize',22,'FontWeight','normal');
        end
    end
end

% plot colorbar
colormap(gca, cmp);
cb = colorbar;
cb.Label.String = {' correlation coefficient',['(' sami.util.deunderscore(userOptions.rdms_pairWiseCorr) ')']};

% plot optional title
title(titleTxt);

% +++++++++++++++++ stats table +++++++++++++++++
sami.util.selectPlot([figI 2 1 2],userOptions.fig_display);
hold on; axis equal; box off;

title(['r/p - Values (multiple testing: ' userOptions.rdms_pairWiseCorrMultipleTesting ')']);
set(gca,'TickLength',[0 0],'XTickLabelRotation',45,'Ydir','reverse',...
        'XTick',1:nFeatRDMs,'XTicklabel',sami.util.deunderscore({featRDMs(:).name}),...
        'YTick',1:nRefRDMs,'YTicklabel',sami.util.deunderscore({refRDMs(:).name}));
xlim([0.5 nFeatRDMs + 0.5]);
ylim([0.5 nRefRDMs + 0.5]);

% plot lines
for i = 1:nRefRDMs+1
    line([0.5 0.5+nFeatRDMs],[0.5 0.5]+-1+i,'Color','k');
end
for i = 1:nFeatRDMs+1
    line([0.5 0.5]+-1+i,[0.5 0.5+nRefRDMs],'Color','k');
end

% text
for i = 1:nRefRDMs
    for j = 1:nFeatRDMs
        if pValsCorr(i,j) > 0.05
            thisFW = 'normal';
        else
            thisFW = 'bold';
        end
        thisTXT = {sprintf('r = %.2f',rVals(i,j)),sami.util.getPString(pValsCorr(i,j))};
        text(j,i,thisTXT,'HorizontalAlignment','center','FontSize',7,'Fontweight',thisFW);
    end
end

%% return stats
stats.r = rVals;
stats.p = pValsCorr;
stats.p_uncorr = pVals;

%% save 
returnHere = pwd;
thisFileName = ['compCat2FeatRDMs_' fileNameSufix];

% correlation matrix
sami.util.gotoDir(fullfile(userOptions.rootPath, 'compCat2Feat'));
disp(['   -> saving 2nd-order STATISTICS to ' fullfile(pwd, thisFileName)]);
save([thisFileName '.mat'], 'stats');

% figure
sami.util.gotoDir(fullfile(userOptions.rootPath, 'compCat2Feat', 'figs'));
disp(['   -> saving 2nd-order FIGURE to ' fullfile(pwd, thisFileName) '.*']);
sami.fig.handleFigure(figI, thisFileName, userOptions);

cd(returnHere);

end



