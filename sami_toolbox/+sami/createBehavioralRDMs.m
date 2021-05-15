function [RDMs, behavData] = createBehavioralRDMs(input, nameSuffix, type, userOptions, makeFig)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 09/2020

%% preparations
if ~exist('makeFig','var') || isempty(makeFig), makeFig = false; end
userOptions = sami.util.setIfUnset(userOptions, 'default_behavRDMcolor', [.9 .2 .1]);
userOptions = sami.util.setIfUnset(userOptions, 'behav_distanceMeasure', 'euclidean');


%% load data from file
try
    inputData = table2cell(readtable(input));
catch
	fprintf('\n'); error('*** sami:ERROR *** check input for creatBehavioralRDMs function. Could not read in data. returning.');
end

%% sort behavioral input according to userOptions
% get fileOrder for 'input' as well as 'global template'
fileOrderInput = inputData(:,1);
[~,fileOrderTemplate] = sami.util.getStimOrder(userOptions);

% find sorting indices from input -> template order
[isMem, fileSortIdx] = ismember(fileOrderTemplate,fileOrderInput);

% return if input-stimuli are not equal to c3d-files
if any(~isMem)
	fprintf('\n'); error('*** sami:ERROR *** behavioral stimuli-names does not correspond to available c3d files. please check. returning.');
end

% sort input data
behavData = cell2mat(inputData(fileSortIdx,2:end));

%% create RDM for each subject
for s = 1:size(behavData,2)
    % obtain differently calculated RDMs
    [tmp_binRDM,tmp_crossRDM] = sami.rdm.categoricalRDM( behavData(:,s),[],false );
    tmp_distRDM = squareform( pdist( behavData(:,s), userOptions.behav_distanceMeasure ) );
    
    % Store the RDM in a struct with the right names and things!
    switch type
        case 'binary'
                RDMs(s).RDM = tmp_binRDM;
        case 'catDiffs'
                RDMs(s).RDM = tmp_crossRDM;
        case 'distance'
                RDMs(s).RDM = tmp_distRDM;
        otherwise
            fprintf('\n'); error('*** sami:ERROR *** please specify type of calculation wanted.');
    end

    RDMs(s).name = ['subj' num2str(s) '_' nameSuffix];
    RDMs(s).color = userOptions.default_behavRDMcolor;
end

%% visualise
if makeFig
	sami.plotRDMs(RDMs);
end


end