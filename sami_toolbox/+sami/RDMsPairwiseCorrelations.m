function RDMsPairwiseCorrelations(RDMs, userOptions, infoTXT, figI)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020


%% Set defaults and check options struct
if ~exist('figI','var') || isempty(figI), figI = sami.util.getFigI(); end
userOptions = sami.util.setIfUnset(userOptions, 'rdms_pairWiseCorr', 'Spearman');
userOptions = sami.util.setIfUnset(userOptions, 'fig_display', true);
userOptions = sami.util.setIfUnset(userOptions, 'fig_savePDF', false);
userOptions = sami.util.setIfUnset(userOptions, 'fig_saveFig', false);
userOptions = sami.util.setIfUnset(userOptions, 'fig_savePS', false);

%% init
if ~exist('infoTXT','var') || isempty(infoTXT)
    titleTxt = '';
    fileNameSufix = '';
else
    titleTxt = [' - ' sami.util.deunderscore(infoTXT)];
    fileNameSufix = ['_' sami.util.deblank(infoTXT)]; 
end

cmp = sami.fig.createColormap('RDMofRDMs');
nRDMs = size(RDMs,2);

disp(['*** Drawing RDMs [fig. ' num2str(figI) ']']);

%% calc correlation matrix
corrMat = sami.stat.RDMCorrMat(RDMs, userOptions.rdms_pairWiseCorr);

%% figure
sami.util.selectPlot(figI,userOptions.fig_display);
set(gcf,'Position',[200 50 500 500]);
imagesc(corrMat,[-1 1]);
axis square on;
box on;

RDMnames = cellfun(@sami.util.deunderscore,{RDMs(:).name},'UniformOutput',false);

set(gca,'xTick',1:nRDMs,'xTickLabel',RDMnames,'XTickLabelRotation', 90,'TickLength',[0 0],'fontsize',10);
set(gca,'yTick',1:nRDMs,'yTickLabel',RDMnames);
title(['RDM correlation matrix' titleTxt],'FontSize',12);

colormap(cmp); 
cb = colorbar;
cb.Label.String = [sami.util.deunderscore(userOptions.rdms_pairWiseCorr) ' correlation coefficient'];


%% saving
returnHere = pwd;
thisFileName = ['RDMsCorrMat' fileNameSufix];

% correlation matrix
sami.util.gotoDir(fullfile(userOptions.rootPath, 'RDMsCorrMat'));
disp(['   -> saving 2nd-order correlation MATRIX to ' fullfile(pwd, [thisFileName '.mat'])]);
save([thisFileName '.mat'], 'corrMat');

% figure
sami.util.gotoDir(fullfile(userOptions.rootPath, 'RDMsCorrMat', 'figs'));
disp(['   -> saving 2nd-order correlation FIGURE to ' fullfile(pwd, thisFileName)]);
sami.fig.handleFigure(figI, thisFileName, userOptions);

cd(returnHere);

end