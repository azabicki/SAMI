function RDMs = plotRDMs(RDMs, userOptions, fileNameSufix, figI, aspect)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020


%% define default behavior
if ~exist('figI','var') || isempty(figI), figI = sami.util.getFigI(); end
if ~exist('aspect', 'var') || isempty(aspect), aspect = 2/3; end

if ~exist('fileNameSufix','var') || isempty(fileNameSufix)
    fNr = 1;
    while ~isempty(dir(fullfile(userOptions.rootPath, 'RDMplots',[sprintf('RDMplot_%04d',fNr) '.*'])))
        fNr = fNr + 1;
    end
    fileNameSufix = sprintf('%04d',fNr);
end

%% init vars
nRDMs = numel(RDMs);
cmp = sami.fig.createColormap('RDMs');

disp(['*** Drawing RDMs [fig. ' num2str(figI) ']']);

% figure
% sami.util.selectPlot(figI,userOptions.fig_display);
nHorPan = ceil(sqrt(aspect * nRDMs));
nVerPan = ceil(nRDMs/nHorPan);

%% display dissimilarity matrices
for iRDM = 1:nRDMs
    sami.util.selectPlot([figI nVerPan nHorPan iRDM],userOptions.fig_display); cla;
    set(gcf,'Position',[230 70 800 800*aspect]);
    
    thisRDM = RDMs(iRDM).RDM;
    
    % display data
    image(thisRDM,'CDataMapping','scaled','AlphaData',~isnan(thisRDM));
    colormap(gca, cmp);
    set(gca,'XTick',[],'YTick',[]);
    title(['\bf' sami.util.deunderscore(RDMs(iRDM).name)]);
    axis square off;
    colorbar;
end

%% handle figure: export and/or close it appropriately
returnHere = pwd;
thisFileName = ['RDMplot_' fileNameSufix];

% figure
sami.util.gotoDir(fullfile(userOptions.rootPath, 'RDMplots'));
disp(['   -> saving RDMs FIGURE to ' fullfile(pwd, thisFileName) '.*']);
sami.fig.handleFigure(figI, thisFileName, userOptions);

cd(returnHere);

end
