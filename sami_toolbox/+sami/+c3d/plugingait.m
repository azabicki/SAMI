function c3d = plugingait(c3d, samiOptions)
% c3d = plugingait(c3d, samiOptions)
% 
% This function receives 3d-MoCap as defined by the VICON NEXUS "full body plugin-gait"
% model. It expects two posterior superior iliac spine (PSIS) markers for the pelvis (not 
% the single sacral % marker), and does not use KAD. It then transforms the current 
% 3d-MoCap data into the SAMI-13-Markerset.
% 
%   input:
%       - c3d:
%           struct. Containing c3d data of a stimulus, given by importFiles function.
% 
%       - samiOptions.labels:
%           cell array. Defines sami_standard names and order for labels. Needed to
%           identify individuals by searching for substring unequal to sami_labels.
%           string. Path to folder which contains all c3d files to be loaded.
% 
%   output:
%       - c3d:
%           struct. same as input, but automatically preprocessed from Plug-in-Gait into 
%           sami-data-format (e.g. averaging 4-head-markers from plug-in-gait model,...)
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 10/2020

%% init varis
labelOrderWanted = [strcat('p1',samiOptions.labels), strcat('p2',samiOptions.labels)];
nLabels = numel(labelOrderWanted);

%% rename labels by adding person# to sami-standard
c3d = sami.c3d.renameLabels2samiStandard(c3d,samiOptions);

%% sort labels into order defined by sami-standard
c3d.Labels = cell(1,nLabels);
c3d.Markers = nan(size(c3d.MarkersUnsorted,1),nLabels,size(c3d.MarkersUnsorted,3));
for i = 1:nLabels
    actualLabel = labelOrderWanted{i};
    actualPerson = actualLabel(1:2);
    
    % depending on sami_label, do different things
    switch actualLabel(3:end)
        case 'HEAD'
            c3d.Labels{i} = actualLabel;
            searchThis = {[actualPerson 'LFHD'],[actualPerson 'LBHD'],[actualPerson 'RFHD'],[actualPerson 'RBHD']};
            idx = contains(c3d.LabelsUnsorted,searchThis);
            c3d.Markers(:,i,:) = mean(c3d.MarkersUnsorted(:,idx,:),2);
            
        case 'LWRI'
            c3d.Labels{i} = actualLabel;
            searchThis = {[actualPerson 'LWRA'],[actualPerson 'LWRB']};
            idx = contains(c3d.LabelsUnsorted,searchThis);
            c3d.Markers(:,i,:) = mean(c3d.MarkersUnsorted(:,idx,:),2);
            
        case 'RWRI'
            c3d.Labels{i} = actualLabel;
            searchThis = {[actualPerson 'RWRA'],[actualPerson 'RWRB']};
            idx = contains(c3d.LabelsUnsorted,searchThis);
            c3d.Markers(:,i,:) = mean(c3d.MarkersUnsorted(:,idx,:),2);
            
        case 'LHIP'
            c3d.Labels{i} = actualLabel;
            searchThis = {[actualPerson 'LASI'],[actualPerson 'LPSI']};
            idx = contains(c3d.LabelsUnsorted,searchThis);
            c3d.Markers(:,i,1:2) = mean(c3d.MarkersUnsorted(:,idx,1:2),2);
            
            searchThis = [actualPerson 'LASI'];
            idx = contains(c3d.LabelsUnsorted,searchThis);
            c3d.Markers(:,i,3) = c3d.MarkersUnsorted(:,idx,3);
            
        case 'RHIP'
            c3d.Labels{i} = actualLabel;
            searchThis = {[actualPerson 'RASI'],[actualPerson 'RPSI']};
            idx = contains(c3d.LabelsUnsorted,searchThis);
            c3d.Markers(:,i,1:2) = mean(c3d.MarkersUnsorted(:,idx,1:2),2);
            
            searchThis = [actualPerson 'RASI'];
            idx = contains(c3d.LabelsUnsorted,searchThis);
            c3d.Markers(:,i,3) = c3d.MarkersUnsorted(:,idx,3);
            
        otherwise
            tmp_idx = find(strcmp(c3d.LabelsUnsorted , actualLabel));
            if ~isempty(tmp_idx)
                c3d.Labels{i} = c3d.LabelsUnsorted{tmp_idx};
                c3d.Markers(:,i,:) = c3d.MarkersUnsorted(:,tmp_idx,:);
            end
    end
end

end

