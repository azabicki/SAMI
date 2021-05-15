function [StimOrder,sortedFileNames] = getStimOrder(userOptions)
% [StimOrder,sortedFileNames] = getStimOrder(userOptions)
% 
% Sorts stimuli with respect to a specified stimulus-category and returns order, as well  
% as a sorted cell array containing filenames.
% 
%   input: 
%       - userOptions.stimuli_sorting:
%           string. 'name_of_category' which is used to sort the stimuli according to. Must
%           be present in the first row of 'userOptions.stimuli_settings'.
%           Defaults to 1
%           
%       - userOptions.stimuli_settings:
%           cell array. Each stimulus (column 1) is described by various categories
%           (column 2-...). Each category-column starts with 'name_of_category', followed
%           by numbers coding for category-groups.
% 
%   output:      
%       - StimOrder:
%           array. Order of stimuli in first column in 'userOptions.stimuli_settings',
%           grouped according to category set in 'userOptions.stimuli_sorting'
%           
%       - sortedFileNames:
%           cell array. Filenames of stimuli sorted as 'StimOrder'.
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 10/2020

if isfield(userOptions,'stimuli_sorting') && isfield(userOptions,'stimuli_settings')
    % sort according to specified condition in userOptions.stimuli_sorting
    if ismember(userOptions.stimuli_sorting , userOptions.stimuli_settings(1,2:end))
        [~, sort_cat] = ismember(userOptions.stimuli_sorting, userOptions.stimuli_settings(1,2:end));
    else
        sort_cat = 1;
    end
    
    [~, StimOrder] = sort(cell2mat(userOptions.stimuli_settings(2:end,sort_cat + 1)));
    sortedFileNames = userOptions.stimuli_settings(StimOrder+1,1);
else
    % in case user does not specified stimuli_settings OR stimuli_sorting, stimuli will 
    % be sorted according to 'dir' function (this is usefull when someone wants to 
    % analyse behavioral data only... 
    files = dir(fullfile(userOptions.c3dPath,'*.c3d'));
    StimOrder = 1:numel(files);
    sortedFileNames = {files(StimOrder).name}';
end


