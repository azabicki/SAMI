%% example script
clear all; close all;

% add toolbox to path
returnHere = pwd;
cd ../sami_toolbox;
addpath(genpath(pwd));
cd(returnHere)

% +++ obligatory: loading userOptions / initializing SAMItoolbox +++++++++++++++++++++++++
userOptions = DemoOne_defineUserOptions();
userOptions = sami.initSAMI(userOptions,'c');

redo = 0;
if redo == 1
    % +++ loading c3d-files and checking them ++++++++++++++++++++++++++++++++++++++++++++
    c3dData = sami.c3d.importFiles(userOptions);

    % +++ calculate features +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    feat_idv = sami.calcFeatures(c3dData, 'idv', userOptions);
    feat_itx = sami.calcFeatures(c3dData, 'itx', userOptions);
else
    load(fullfile(userOptions.rootPath,'c3dData.mat'));
    
    load(fullfile(userOptions.rootPath,'features_idv.mat'));
    load(fullfile(userOptions.rootPath,'features_itx.mat'));
end

% +++ create feature_RDMs ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
RDMs_idv = sami.createFeatureRDMs(feat_idv, userOptions);
RDMs_itx = sami.createFeatureRDMs(feat_itx, userOptions);

% +++ create model RDMs ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
modelThis = {'emotion','valence'};
RDMs_stim_models_categorical = sami.createCategoryRDMs(modelThis, 'binary', userOptions);

% +++ create behavioral RDMs +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
[RDMs_behav_val_subj, behav_val_data] = sami.createBehavioralRDMs('DemoOne_BehavValenceRating.txt', 'Valence', 'distance',  userOptions);
[RDMs_behav_emo_subj, behav_emo_data] = sami.createBehavioralRDMs('DemoOne_BehavEmotionRating.txt', 'Emotion', 'binary', userOptions);

% average across subjects
RDMs_behav_val = sami.rdm.averageRDMs(RDMs_behav_val_subj,'mean_val_RDM',[1 0 0]);
RDMs_behav_emo = sami.rdm.averageRDMs(RDMs_behav_emo_subj,'mean_emo_RDM',[1 0 0]);

%% display RDMs/MDS plots
% +++ show RDMs ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sami.plotRDMs([RDMs_stim_models_categorical RDMs_idv],userOptions);
sami.plotRDMs([RDMs_stim_models_categorical RDMs_itx],userOptions);
sami.plotRDMs([RDMs_behav_val_subj RDMs_behav_val],userOptions);
sami.plotRDMs([RDMs_behav_emo_subj RDMs_behav_emo],userOptions);

% +++ MDS of Stimuli +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sami.MDSofStimuli(RDMs_idv(1), 'emotion', userOptions);
sami.MDSofStimuli(RDMs_idv(1), 'valence', userOptions);

% +++ 2nd order - RDM correlation matrix and MDS +++++++++++++++++++++++++++++++++++++++++
sami.RDMsPairwiseCorrelations([RDMs_stim_models_categorical RDMs_idv], userOptions, 'CAT and IDV');
sami.RDMsPairwiseCorrelations([RDMs_stim_models_categorical RDMs_itx], userOptions, 'CAT and ITX');
sami.RDMsPairwiseCorrelations([RDMs_behav_val RDMs_behav_emo RDMs_idv], userOptions, 'BEHAV and IDV');
sami.RDMsPairwiseCorrelations([RDMs_behav_val RDMs_behav_emo RDMs_itx], userOptions, 'BEHAV and ITX');

sami.MDSofRDMs([RDMs_stim_models_categorical RDMs_idv], userOptions,'CategoricalModels and IDV');
sami.MDSofRDMs([RDMs_stim_models_categorical RDMs_itx], userOptions,'CategoricalModels and ITX');
sami.MDSofRDMs([RDMs_behav_val RDMs_behav_emo RDMs_stim_models_categorical RDMs_idv], userOptions,'Behavior and CategoricalModels and IDV');
sami.MDSofRDMs([RDMs_behav_val RDMs_behav_emo RDMs_stim_models_categorical RDMs_itx], userOptions,'Behavior and CategoricalModels and ITX');

%% do some statistical analyses, like RSA or ANOVA...
% +++ compare METRIC behavioral data +++++++++++++++++++++++++++++++++++++++++++++++++++++
sami.compareBehavData(behav_val_data, 'emotion', 'Valence', userOptions);

% +++ compare CATEGORICAL behavioral data ++++++++++++++++++++++++++++++++++++++++++++++++
sami.compareBehavCategoricalData(behav_emo_data, 'emotion', 'Emotion', userOptions);

% +++ compare average feature-values between specific categories +++++++++++++++++++++++++
sami.compareFeatValues(feat_idv, 'emotion', 'IDV', userOptions);
sami.compareFeatValues(feat_idv, 'valence', 'IDV', userOptions);
sami.compareFeatValues(feat_itx, 'emotion', 'ITX', userOptions);
sami.compareFeatValues(feat_itx, 'valence', 'ITX', userOptions);

% +++ compare categoryRDMs with movement RDMs ++++++++++++++++++++++++++++++++++++++++++++
sami.compareCatRDMs2FeatRDMs(RDMs_stim_models_categorical,RDMs_idv,'Categorical vs IDV',userOptions);
sami.compareCatRDMs2FeatRDMs(RDMs_stim_models_categorical,RDMs_itx,'Categorical vs ITX',userOptions);

% +++ compare behavioralRDMs with movement RDMs ++++++++++++++++++++++++++++++++++++++++++
userOptions.rdms_pairWiseCorr = 'Pearson';
statsA = sami.compareBehavRDMs2FeatRDMs(RDMs_behav_val_subj, RDMs_idv, 'Valence', 'IDV', userOptions);
statsB = sami.compareBehavRDMs2FeatRDMs(RDMs_behav_val_subj, RDMs_itx, 'Valence', 'ITX', userOptions);

userOptions.rdms_pairWiseCorr = 'Kendall_taua';
statsC = sami.compareBehavRDMs2FeatRDMs(RDMs_behav_emo_subj, RDMs_idv, 'Emotion', 'IDV', userOptions);
statsD = sami.compareBehavRDMs2FeatRDMs(RDMs_behav_emo_subj, RDMs_itx, 'Emotion', 'ITX', userOptions);

