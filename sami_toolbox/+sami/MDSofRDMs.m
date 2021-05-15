function MDSofRDMs(RDMs, userOptions, title_suffix, figI)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

%% Set defaults and check options struct
if ~exist('figI','var') || isempty(figI), figI = sami.util.getFigI(); end
if ~exist('title_suffix','var') || isempty(title_suffix), title_suffix = ''; end
userOptions = sami.util.setIfUnset(userOptions, 'rdms_pairWiseCorr', 'Spearman');
userOptions = sami.util.setIfUnset(userOptions, 'MDS_criterion', 'metricstress');
userOptions = sami.util.setIfUnset(userOptions, 'fig_display', true);
userOptions = sami.util.setIfUnset(userOptions, 'fig_savePDF', false);
userOptions = sami.util.setIfUnset(userOptions, 'fig_saveFig', false);
userOptions = sami.util.setIfUnset(userOptions, 'fig_savePS', false);

if numel(RDMs) < 3, warning('RDMsPLotMDS:NotEnoughRDMs', ['Only ' num2str(numel(RDMs)) ' RDMs is not enough. 3 is a minimum for MDS to work; skipping.']); return; end

%% init
if isempty(title_suffix)
    txt1 = ''; txt2 = ''; txt3 = '';
else
    txt1 = '_'; txt2 = '['; txt3 = ']';
end

nRDMs = numel(RDMs);

%% Set MDSOptions
MDSOptions.fig_display = userOptions.fig_display;
MDSOptions.figI = figI;
MDSOptions.fileName = ['2ndOrderMDSofRDMs' txt1 sami.util.deblank(title_suffix)];
MDSOptions.titleString = ['2nd order MDS of RDMs ' txt2 sami.util.deunderscore(title_suffix) txt3];

MDSOptions.MDSCriterion = userOptions.MDS_criterion;
MDSOptions.MDSDistance = ['1 - \it' sami.util.deunderscore(userOptions.rdms_pairWiseCorr) '\rm correaltion'];
MDSOptions.dotLabels = {RDMs(:).name};
MDSOptions.dotColors = reshape([RDMs(:).color],[3 nRDMs])';


if isfield(userOptions, 'MDS_plotLabels')
    MDSOptions.plotLabels = userOptions.MDS_plotLabels;
end
if isfield(userOptions, 'MDS_dotSize')
    MDSOptions.dotSize = userOptions.MDS_dotSize;
end
if isfield(userOptions, 'MDS_fontSize')
    MDSOptions.fontSize = userOptions.MDS_fontSize;
end

% prepare legend
if isfield(userOptions, 'MDS_plotLegend')
    MDSOptions.plotLegend = userOptions.MDS_plotLegend;
    if MDSOptions.plotLegend == 1
        leg.title = [];
        leg.Labels = sami.util.deunderscore(MDSOptions.dotLabels);
        leg.Colors = MDSOptions.dotColors;
        leg.DotIdx = 1:numel(leg.Labels);
        MDSOptions.legend = leg;
    end
end

%% calculate RDM of RDMs
distanceMatrix.RDM = 1 - sami.stat.RDMCorrMat(RDMs,userOptions.rdms_pairWiseCorr);
distanceMatrix.name = ['Pairwise RDM correlations: ' title_suffix];

%% plotting
disp(['*** Drawing MDS: "' MDSOptions.titleString '" [fig. ' num2str(figI) ']']);
sami.fig.MDSArrangement(distanceMatrix, MDSOptions);

%% saving
returnHere = pwd;
thisFileName = MDSOptions.fileName;

% figure
sami.util.gotoDir(fullfile(userOptions.rootPath, 'MDSplots'));
disp(['   -> saving MDS_plot FIGURE to ' fullfile(pwd, thisFileName)]);
sami.fig.handleFigure(figI, thisFileName, userOptions);

cd(returnHere);

