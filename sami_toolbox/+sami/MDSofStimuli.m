function MDSofStimuli(RDMs, colorCategory, userOptions, figI)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020


%% Set defaults and check options struct
if ~exist('figI','var') || isempty(figI), figI = sami.util.getFigI(numel(RDMs)); end
if numel(figI) ~= numel(RDMs), error('*** sami:ERROR *** amount of Figure-Numbers and RDMs are not equal.'); end
userOptions = sami.util.setIfUnset(userOptions, 'MDS_criterion', 'metricstress');
userOptions = sami.util.setIfUnset(userOptions, 'feat_distance', 'Euclidean');
userOptions = sami.util.setIfUnset(userOptions, 'fig_display', true);
userOptions = sami.util.setIfUnset(userOptions, 'fig_savePDF', false);
userOptions = sami.util.setIfUnset(userOptions, 'fig_saveFig', false);
userOptions = sami.util.setIfUnset(userOptions, 'fig_savePS', false);

if userOptions.MDS_plotLabels == 1
    if (~isfield(userOptions, 'stimuli_MDS_labels') || isempty(userOptions.stimuli_MDS_labels))
        disp('*** sami:INFO *** MDS_plotLabels is ON, but there are no stimuli_MDS_Labels provided. Turning it OFF.'); 
        userOptions.MDS_plotLabels = 0;
    elseif size(RDMs(1).RDM,1) ~= numel(userOptions.stimuli_MDS_labels)
        error('*** sami:ERROR *** amount of "Stimuli Labels" and "size of RDMs" are not equal.'); 
    end
end

%% Set MDSOptions
MDSOptions.fig_display = userOptions.fig_display;
MDSOptions.MDSCriterion = userOptions.MDS_criterion;
if strcmpi(userOptions.feat_distance,'euclidean')
    MDSOptions.MDSDistance = ['\it' sami.util.deunderscore(userOptions.feat_distance) '\rm'];
else
    MDSOptions.MDSDistance = ['1 - \it' sami.util.deunderscore(userOptions.feat_distance) '\rm correaltion'];
end
MDSOptions.dotColors = sami.util.getStimColors(colorCategory,userOptions);

if userOptions.MDS_plotLabels == 1
    stimOrder = sami.util.getStimOrder(userOptions);
    MDSOptions.dotLabels = userOptions.stimuli_MDS_labels(stimOrder);
end

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
        [~, leg_idx_Key] = ismember(colorCategory, {userOptions.stimuli_naming_key.name});
        leg.title = userOptions.stimuli_naming_key(leg_idx_Key).name;
        leg.Labels = userOptions.stimuli_naming_key(leg_idx_Key).condition;
        leg.Colors = userOptions.stimuli_naming_key(leg_idx_Key).color;
        for i = 1:numel(leg.Colors)
            j = 1;
            while any(MDSOptions.dotColors(j,:) ~= leg.Colors{i})
                j = j+1;
            end
            leg.DotIdx(i) = j;
        end
        MDSOptions.legend = leg;
    end
end

%% loop RDMs
for iRDM = 1:numel(RDMs)
	RDMName = RDMs(iRDM).name;
    thisFigI = figI(iRDM);
	    
	localOptions = MDSOptions;
	localOptions.figI = thisFigI;
	localOptions.fileName = ['Stimuli_MDS_' sami.util.deblank(RDMName) '_by_' colorCategory];
	localOptions.titleString = ['Stimuli MDS for RDM: "' sami.util.deunderscore(RDMName) '"'];
	
    disp(['*** Drawing MDS: "' localOptions.titleString '" [fig. ' num2str(thisFigI) ']']);
    sami.fig.MDSArrangement(RDMs(iRDM), localOptions);
    
    %% saving
    returnHere = pwd;
    thisFileName = localOptions.fileName;

    % figure
    sami.util.gotoDir(fullfile(userOptions.rootPath, 'MDSplots'));
    disp(['   -> saving MDS_plot FIGURE to ' fullfile(pwd, thisFileName)]);
    sami.fig.handleFigure(figI, thisFileName, userOptions);
        
    cd(returnHere);
end

