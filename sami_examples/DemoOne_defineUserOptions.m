function userOptions = DemoOne_defineUserOptions()
%  defineUserOptions is a nullary function which initialises a struct
%  containing the preferences and details for a particular project.
%  It should be edited to taste before a project is run, and a new
%  one created for each substantially different project.
%
%  For a guide to how to fill out the fields in this file, consult
%  the documentation folder (particularly the userOptions_guide.m)
%
%  A. Zabicki 09-2020
%__________________________________________________________________________

userOptions.debug = true; % will save and/or display some more information during execution of several functions

%% **********************************************************
% Project details
% **********************************************************
% *** edit how needed *********************

% This name identifies a collection of files which all belong to the same run of a project.
userOptions.analysisName = 'DemoOne_sami';

% The path leading to where the c3d files are stored.
userOptions.c3dPath = fullfile(pwd,'DemoOne_c3d');

% *** no need to change here anything *******************************
% This is the root directory of the project.
userOptions.rootPath = fullfile(pwd,userOptions.analysisName);
% *******************************************************************


%% **********************************************************
% c3d file and label settings
% **********************************************************

% if "Vicon Plug-in Gait" Modell is used and markers are named according to Plug-in Gait
% and _c3d_personIdentifier, sami_toolbox will transform data automatically
userOptions.c3d_ViconPluginGait = false;

% if markers are available, but named differently, use this to rename labels of "ownMarker" 
% into "samiMarker" [Head, LSHO, LELB, LWRI, LHIP, LKNE, LANK, RSHO, RELB, RWRI, RHIP, RKNE, RANK]
userOptions.c3d_OwnMarker = true;
userOptions.c3d_MarkerMatching = {...
    'ownMarker','samiMarker';...
    'HAND','WRI';...
    };
% if specified, user is able to keep own indiviuum identifications,
% otherwise markers will be renamed, e.g. 'p1HEAD' and 'p2HEAD", automatically
% userOptions.c3d_personIdentifier = '[[marker]][[person]]';


%% **********************************************************
% descriptions of stimuli: regarding their categories, and how to sort them
% **********************************************************
% set category which is used to sort the stimuli according to
userOptions.stimuli_sorting = 'emotion';

% if filename is specified: "stimulus_settings" will be loaded from this file
userOptions.stimuli_settings_filename = 'DemoOne_stimuli_settings.txt';
% else: stimulus_settings have to be defined here
userOptions.stimuli_settings = {};

% providing labels for each category describing the stimuli
userOptions.stimuli_naming_key(1).name = 'emotion';
userOptions.stimuli_naming_key(1).condition = {'happiness','affection','sadness','anger'};
userOptions.stimuli_naming_key(1).color = {[0 .5 1],[.1 .8 .1],[1 .5 0],[1 0 0]};
userOptions.stimuli_naming_key(2).name = 'valence';
userOptions.stimuli_naming_key(2).condition = {'positive','negative'};
userOptions.stimuli_naming_key(2).color = {[0 .5 1],[1 .5 0]};

% stimuli_labels for MDS plots 
%    ---> !!! same order as in first column in userOptions.stimuli_settings_filename !!!
% [userOptions.stimuli_MDS_labels{1:size(userOptions.stimuli_settings,1)-1}] = deal(' ');

%% **********************************************************
% calculating individual/interaction movement-features 
%    -> comparing movement-features between stimuli-categories 
%    -> creating movement/feature-RDMs for stimulus-set
% **********************************************************
% set alpha and correction method which will be applied in post-hoc multiple comparisons of feature values
userOptions.feat_threshold = 0.05;               % default: 0.05
userOptions.feat_multipleTesting = 'bonferroni'; % ['bonferroni'] | 'tukey-kramer' | 'hsd' | 'lsd' | 'dunn-sidak' | 'scheffe'

% which distance measure to use when calculating feature-RDMs.
userOptions.feat_distance = 'euclidean';        % input into pdist function, default: 'euclidean'

% should feature-RDM-entries be rank transformed into [0,1] before they're displayed?
userOptions.feat_rankTransform = false; % !!!!!!!! NOT YET IMPLEMENTED !!!!!!!!!!!!

%% **********************************************************
% behavioral data: 
%    -> comparing average behavioral ratings between stimuli-categories
%    -> creating behavioral-RDMs for each subject
% **********************************************************
% set alpha and correction method which will be applied in post-hoc multiple comparisons of behavioral ratings
userOptions.behav_threshold = 0.05;                 % default: 0.05
userOptions.behav_multipleTesting = 'bonferroni';   % ['bonferroni'] | 'tukey-kramer' | 'hsd' | 'lsd' | 'dunn-sidak' | 'scheffe'

% which distance measure to use between stimuli-rating-values when calculating subjects behavioral-RDMs
userOptions.behav_distanceMeasure = 'euclidean';    % input into pdist function, default: 'euclidean'

%% **********************************************************
% MDS plots
% **********************************************************
% what criterion to be minimised in MDS calculation?
userOptions.MDS_criterion = 'metricstress'; % default: 'metricstress'

% style
userOptions.MDS_plotLabels = true;  % show labels in MDS-Plot
userOptions.MDS_plotLegend = true;  % show color-legend in MDS-plot -> useful for "stimuliMDS()"
userOptions.MDS_dotSize = 20;       % default: 20
userOptions.MDS_fontSize = 9;       % default: 9

%% **********************************************************
% second-order-analysis of RDMs
% **********************************************************
% which similarity-measure is used for the pair-wise comparison of RDMs
userOptions.rdms_pairWiseCorr = 'Kendall_taua';

% for 'compareCatRDMs2FeatRDMs' function
% set alpha and correction method to be applied in pairwise-RDM-correlation analysis
userOptions.rdms_pairWiseCorrThreshold = 0.05;          % default: 0.05
userOptions.rdms_pairWiseCorrMultipleTesting = 'holm';  % ['holm'] | 'bonferroni' | 'FDR'

% for 'compareBehavRDMs2FeatRDMs' function
% set test, alpha and correction method for analysing relatedness of features and behavioral RDMs
userOptions.rdms_relatednessTest = 'signedRank';        % ['signedRank'] | 'randomisation'
userOptions.rdms_relatednessThreshold = 0.05;           % default: 0.05
userOptions.rdms_relatednessMultipleTesting = 'FDR';    % ['FDR'] | 'bonferroni' | 'holm'

% set test, alpha and correction method for analysing relatedness of features and behavioral RDMs
userOptions.rdms_differencesTest = 'signedRank';        % ['signedRank'] | 'conditionBootstrap'
userOptions.rdms_differencesThreshold = 0.05;           % default: 0.05
userOptions.rdms_differencesMultipleTesting = 'FDR';    % ['FDR'] | 'bonferroni' | 'holm'

% some set test, alpha and correction method for analysing relatedness of features and behavioral RDMs
userOptions.rdms_orderByCorr = true;                    % sort features by height of relatedness? default: true
userOptions.rdms_nRandomisations = 50000;               % default: 50000 (min. 10,000 highly recommended)
userOptions.rdms_nBootstrap = 1000;                     % default: 1000

%% **********************************************************
% everything else, my be set or not 
%       (here, defaults are used to show what can be edited)
% **********************************************************
userOptions.default_modelRDMcolor = [.5 .5 .5];
userOptions.default_behavRDMcolor = [.9 .2 .1];

% threshold: minimal number of datapoints for parametric group-comparisons (ANOVA, t-test)
userOptions.stats_minNforSubjectRFXtests = 12;
% threshold: minimal number of datapoints for NON-parametric group-comparisons (Wilcoxon, Kruskall-Walis)
userOptions.stats_minNforNonParamTests = 5;

%% **********************************************************
% handling figures
% **********************************************************
% generall displaying all figures?
userOptions.fig_display = true;     % default: true

% How should figures be outputted?
userOptions.fig_saveFIG = true;    % default: false
userOptions.fig_savePDF = true;    % default: false
userOptions.fig_saveSVG = true;    % default: false
userOptions.fig_saveTIF = true;    % default: false

% Which dots per inch resolution do we output?
userOptions.fig_dpi = 300;

end
