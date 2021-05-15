function [personIdentifier,personIndex,nPersons] = getPersonIdentifier(c3d, samiOptions)
% [personIdentifier,personIndex,nPersons] = getPersonIdentifier(c3d, samiOptions)
% 
% Identifies individuals from given marker labels. and returns their indi
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
%       - personIdentifier:
%           cell array. contains individual substrings within labels for each identified person.
% 
%       - personIndex:
%           array. for each label, personIndex states the corresponding person.
% 
%       - nPersons:
%           double. how many persons are identified in given labels.
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 10/2020

% init  vars
nLabelsUnsorted = numel(c3d.LabelsUnsorted);
personIndex = nan(1,nLabelsUnsorted);

% various versions for identifying individuals from labels implemented, #3 seems to catch
% all possible naming_conventions 
use_version = 3;

switch use_version
    case 1
        % detect which marker belongs to an individuum, by erase 'marker-name' +++++++++++
        % from labels, and then finding unique values
        personIdentifierTMP = cell(nLabelsUnsorted,1);
        for i = 1:nLabelsUnsorted
            fullLabel = c3d.LabelsUnsorted{i};
            if any(cellfun(@(s) contains(fullLabel, s), samiOptions.labels))
                markerLabel = samiOptions.labels{cellfun(@(s) contains(fullLabel, s), samiOptions.labels)};
                personIdentifierTMP{i} = erase(fullLabel,markerLabel);
            end
        end
        personIdentifierTMP = personIdentifierTMP(~cellfun('isempty',personIdentifierTMP));
        personIdentifier = unique(personIdentifierTMP);
        
    case 2
        % v2: ausgehend von samiLabels
        personIdentifierTMP = cell(0);
        for i = 1:numel(samiOptions.labels)
            samiLabel = samiOptions.labels{i};
            labelIdx = find(contains(c3d.LabelsUnsorted, samiLabel));
            
            for L = 1:numel(labelIdx)
                fullLabel = c3d.LabelsUnsorted{labelIdx(L)};
                personIdentifierTMP = [personIdentifierTMP; {erase(fullLabel,samiLabel)}]; %#ok<AGROW>
            end
        end
        personIdentifier = unique(personIdentifierTMP);
        
    case 3
        % first: find individuel 'personIdentifiers' in labelsUnsorted by looking into
        % marker which contain "samiLabels"
        personIdentifierTMP = cell(nLabelsUnsorted,1);
        for i = 1:nLabelsUnsorted
            fullLabel = c3d.LabelsUnsorted{i};            
            tmp = cellfun(@(s) contains(fullLabel, s), samiOptions.labels);
            if any(tmp)
                markerLabel = samiOptions.labels{tmp};
                personIdentifierTMP{i} = erase(fullLabel,markerLabel);
            end
        end
        personIdentifierTMP = personIdentifierTMP(cellfun(@(s) ischar(s),personIdentifierTMP));
        personIdentifier = unique(personIdentifierTMP);
                
        % second: assign to each unsortedLabel person# (i.e. index in 'personIdentifier')
        emptyIdentity = cellfun('isempty',personIdentifier);
        if ~any(emptyIdentity)
            for i = 1:numel(emptyIdentity)
                % loop this, bc there might be more than 2 persons in the future
                personIndex(contains(c3d.LabelsUnsorted,personIdentifier(i))) = i;
            end
        else
            % case that one person is identified by 'pure labels', i.e. no suffix to the
            % marker was added, e.g. subject 1 -> 'Head' / subject 2 -> 'Head2'
            
            % do this: loop all non-empty-identifiers, set 'personIndex' and remember which index 
            % was changed, use this knowledge to identify emptyIdentity-labels
            nonEmptyIdx = zeros(1,nLabelsUnsorted);
            for i = find(~emptyIdentity)
                thisNonEmptyIdx = contains(c3d.LabelsUnsorted,personIdentifier(i));
                nonEmptyIdx = nonEmptyIdx + double(thisNonEmptyIdx);
                personIndex(thisNonEmptyIdx) = i;
            end
            
            % set emptyIdentifier there, where no previous non-empty-identifier was found 
            emptyIdx = nonEmptyIdx==0;
            personIndex(emptyIdx) = find(emptyIdentity);
        end
end

% find numer of persons ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
nPersons = numel(personIdentifier);
if nPersons < 1 || nPersons > 2
	fprintf('\n'); error('*** ERROR *** there are less then 1 or more then 2 persons identified in c3d-file.');
end

end

