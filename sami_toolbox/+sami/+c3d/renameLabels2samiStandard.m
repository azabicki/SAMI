function c3d = renameLabels2samiStandard(c3d,samiOptions)
% c3d = renameLabels2samiStandard(c3d,samiOptions)
% 
% Detects which marker belongs to which person, and labels the given marker according to
% sami_format for each person (i.e. p1HEAD).
% 
%   input: 
%       - c3d:
%           struct. Containing c3d data of a stimulus, given by importFiles function.
%           
%       - samiOptions.labels:
%           cell array. Defines sami_standard names and order for labels. Needed to
%           identify individuals by searching for substring unequal to sami_labels.
% 
%   output:      
%       - c3d:
%           struct. same as input, but now with renamed labels in sami_format.
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 10/2020

%% init vars
nLabelsUnsorted = numel(c3d.LabelsUnsorted);

%% find individual persons and their 'identifiers' in each given labels ++++++++++++++++++
[personIdentifier,personIndex,c3d.nPersons] = sami.c3d.getPersonIdentifier(c3d, samiOptions);

%% rename labels by adding person# to sami-standard ++++++++++++++++++++++++++++++++++++++
for i = 1:nLabelsUnsorted
    oldLabel = c3d.LabelsUnsorted{i};
    % if oldLabel is asigned to a person: erasing old personIdentifier and adding p#
    if ~isnan(personIndex(i))
        personString = personIdentifier{personIndex(i)};
        c3d.LabelsUnsorted{i} = ['p' num2str(personIndex(i)) erase(oldLabel,personString)];
    end
end

end

