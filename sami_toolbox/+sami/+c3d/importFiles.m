function c3dData = importFiles(userOptions)
% c3dData = importFiles(userOptions)
% 
% Imports c3d-files from a specific folder, set in userOptions, and returns struct
% containing all relevant 3D-MoCap-data for further analysis. If set, stimuli will be
% sorted according to 'userOptions.stimuli_sorting', otherwise alphabetically.
% 
%   input:
%       - userOptions.c3dPath: 
%           string. Path to folder which contains all c3d files to be loaded.
% 
%       - userOptions.c3d_ViconPluginGait: 
%           boolean. In case c3d-MoCap-Data was recorded using Vicon "Plug-in Gait Full Body" 
%           markerset, the data will be transformed automaticaly into sami-format. 
%           Defaults to false.
%     
%           (https://docs.vicon.com/display/Nexus25/Plug-in+Gait+models+and+templates)
%               
%       - userOptions.c3d_OwnMarker:
%           boolean. If all sami-markers are available, but named differently, this function 
%           can rename parts of given labels, if userOptions.c3d_OwnMarker is true.
%           Defaults to false.
% 
%       - userOptions.c3d_MarkerMatching:
%           cell array. Definies rules for renaming labels. In each row, the substring
%           from the 'ownMarker# column will be replaced the string in the 'samiMarker' column.
%           Example: 
%               userOptions.c3d_MarkerMatching = {'ownMarker','samiMarker';...
%                                                 'Head','HEAD';...
%                                                 'LASI','LHIP';...
%                                                 'RASI','RHIP';...
%                                                 };% 
% 
%   output:      
%       - c3dData:
%           struct. Containing for each loaded c3dd-stimulis-file relevant data:
%                   c3dData.file: filename
%                   c3dData.marker: 3d data in [time*marker*dimension] format
%                   c3dData.labels: labels of [marker]
%                   c3dData.framerate: framerate in Hz
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 10/2020

%% define default behavior
if ~isfield(userOptions, 'c3dPath'), error('*** sami:error *** path to folder containing c3d data mus be set in userOptions.c3dPath.'); end%if
userOptions = sami.util.setIfUnset(userOptions, 'c3d_ViconPluginGait', false);
userOptions = sami.util.setIfUnset(userOptions, 'c3d_OwnMarker', false);
if userOptions.c3d_OwnMarker==true && (~isfield(userOptions, 'c3d_MarkerMatching') || isempty(userOptions.c3d_MarkerMatching) || size(userOptions.c3d_MarkerMatching,1)<2), error('*** sami:error *** please specifiy ''userOptions.c3d_MarkerMatching''.'); end%if

disp('*** importing c3d files and checking them ***');

%% load samiOptions
samiOptions = sami.loadSamiOptions();
labelOrderWanted = [strcat('p1',samiOptions.labels), strcat('p2',samiOptions.labels)];
nLabels = numel(labelOrderWanted);

%% read in data folder
files = dir(fullfile(userOptions.c3dPath,'*.c3d'));

%% get order for Stimuli
[~,fileOrderNames] = sami.util.getStimOrder(userOptions);

%% loop files + load c3d + checking
c3dData = struct();
nFiles = numel(files);
fprintf('   ... import file (of %d): 1',nFiles);
for f = 1:nFiles
    % display progress
    fprintf([repmat('\b',1,numel(num2str(f-1))) '%d'],f);
    
    %% load c3d -> according to sort_order defined by userOptions.stimuli_sorting
    thisFileIdx = find(contains({files(:).name},fileOrderNames{f}));
    thisFileName = fullfile(files(thisFileIdx).folder,files(thisFileIdx).name);
    [c3d.MarkersUnsorted, c3d.VideoFrameRate,~,~,~, c3d.ParameterGroup,~,~,c3d.MissingMarker] = sami.c3d.loadc3d(thisFileName);
    
    % find labels
    idxPoint = find(contains([c3d.ParameterGroup.name],'POINT'));
    idxLabels = contains([c3d.ParameterGroup(idxPoint).Parameter.name],'LABELS');
    c3d.LabelsUnsorted = c3d.ParameterGroup(idxPoint).Parameter(idxLabels).data;
    
    % check for missing data (residuals==-1 in c3d-file)
    if any(c3d.MissingMarker(:))
        fprintf('\n'); error('*** sami:ERROR *** missing data. please label all markers without any gaps.');
    end
        
    %% if Vicon Plug-in Gait Modell is used, call convert_function
    if userOptions.c3d_ViconPluginGait == true
        c3d = sami.c3d.plugingait(c3d, samiOptions);
    else
        %% else, rename/sort into target sami_labels/sami_order
        nLabelsUnsorted = numel(c3d.LabelsUnsorted);
        
        % if ownMarker names were used, rename them to sami-standard +++++++++++++++++++++
        if userOptions.c3d_OwnMarker == true
            for i = 1:nLabelsUnsorted
                oldLabel = c3d.LabelsUnsorted{i};
                if any( cellfun(@(s) contains(oldLabel, s), userOptions.c3d_MarkerMatching(:,1)) )
                    idx = cellfun(@(s) contains(oldLabel, s), userOptions.c3d_MarkerMatching(:,1));
                    c3d.LabelsUnsorted{i} = strrep(oldLabel, userOptions.c3d_MarkerMatching{idx,1} , userOptions.c3d_MarkerMatching{idx,2});
                end
            end
        end
        
        % rename labels by adding person# to sami-standard
        c3d = sami.c3d.renameLabels2samiStandard(c3d,samiOptions);

        % sort labels into order defined by sami-standard ++++++++++++++++++++++++++++++++
        c3d.Labels = cell(1,nLabels);
        c3d.Markers = nan(size(c3d.MarkersUnsorted,1),nLabels,size(c3d.MarkersUnsorted,3));
        for i = 1:nLabels
            tmp_idx = find(strcmp(c3d.LabelsUnsorted , labelOrderWanted{i}));
            if ~isempty(tmp_idx)
                c3d.Labels{i} = c3d.LabelsUnsorted{tmp_idx};
                c3d.Markers(:,i,:) = c3d.MarkersUnsorted(:,tmp_idx,:);
            end
        end
        
        % check for any missing lables from config_labels ++++++++++++++++++++++++++++++++
        if any(cellfun(@isempty,c3d.Labels))
            fprintf('\n'); error('*** ERROR *** not all needed labels are found in c3d-file.');
        end 
    end
    
    %% Quality-Checks
    % NANs?
    if any(isnan(c3d.Markers(:)))
        fprintf('\n'); error('*** ERROR *** NANs still remain in 3d-MoCap-Data. Please check input data! abort.');
    end
    
    %% saving structure
    c3dData(f).file = files(thisFileIdx).name;
    c3dData(f).marker = c3d.Markers;
    c3dData(f).labels = c3d.Labels;
    c3dData(f).frameRate = c3d.VideoFrameRate;
    c3dData(f).nPersons = c3d.nPersons;
    c3dData(f).ignore_labels = c3d.LabelsUnsorted;
    c3dData(f).ignore_marker = c3d.MarkersUnsorted;
end
fprintf(' ... ok\n');

%% saving c3dData struct
save(fullfile(userOptions.rootPath,'c3dData.mat'),'c3dData');

%% finishing
fprintf(' ... c3d_data saved in rootPath as "c3dData.mat" \n');
fprintf(' ... DONE loading c3d_data\n\n');

end

