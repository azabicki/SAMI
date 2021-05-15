function stimColors = getStimColors(category,userOptions)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

stimOrder = sami.util.getStimOrder(userOptions);

if ismember(category , userOptions.stimuli_settings(1,2:end))
    [~, idx_Set] = ismember(category, userOptions.stimuli_settings(1,2:end));
    [~, idx_Key] = ismember(category, {userOptions.stimuli_naming_key.name});
else
    idx_Set = 1;
    [~, idx_Key] = ismember(userOptions.stimuli_settings(1,2), {userOptions.stimuli_naming_key.name});
end

stimCategories = cell2mat(userOptions.stimuli_settings(2:end,idx_Set + 1));
categoryColors = userOptions.stimuli_naming_key(idx_Key).color;

stimColors = nan(size(stimOrder,1),3);
for i = 1:size(stimColors,1)
    thisCat = stimCategories(stimOrder(i));
    stimColors(i,:) = categoryColors{thisCat};    
end

end

