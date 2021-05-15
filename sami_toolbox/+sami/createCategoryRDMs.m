function RDMs = createCategoryRDMs(categories, type, userOptions, categoryShift, makeFig)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

%% preparations
if ~exist('makeFig','var') || isempty(makeFig), makeFig = false; end
if ~exist('categoryShift','var') || isempty(categoryShift), categoryShift = []; end
userOptions = sami.util.setIfUnset(userOptions, 'default_modelRDMcolor', [.5 .5 .5]);

%% loop defined category_combinations
nRDMs = numel(categories);
StimOrder = sami.util.getStimOrder(userOptions);

for n = 1:nRDMs
    % find indizes of categories in userOptions.stimuli_settings
    this_cat_cut = regexp(categories{n},'*','split');
    
    % check if categories are existing
    if any(~ismember(this_cat_cut, userOptions.stimuli_settings(1,2:end)))
        fprintf('\n'); error('*** sami:ERROR *** definition of categories failed. check names and if there are equal to first row in "userOptions.stimuli_settings".');
    end
    
    % create category vectors as input for sami.rdm.categoricalRDM
    cat_data = nan(numel(StimOrder),numel(this_cat_cut));
    for c = 1:numel(this_cat_cut)
        [~, sort_cat] = ismember(this_cat_cut{c}, userOptions.stimuli_settings(1,2:end));
        cat_data_raw = cell2mat(userOptions.stimuli_settings(2:end,sort_cat + 1));
        cat_data(:,c) = cat_data_raw(StimOrder);
    end
    
    % shift categories, if wanted
    shifted_title = '';
    if ~isempty(categoryShift)
        for cs = 1:size(categoryShift,1)
            cat_data(cat_data==categoryShift(cs,1)) = categoryShift(cs,2);
        end
        shifted_title = '_shifted';
    end
    
    % analyse categorical vectors and obtain RDMs
    [tmp_binRDM,tmp_crossRDM] = sami.rdm.categoricalRDM(cat_data);
    tmp_distRDM = squareform(pdist(cat_data,'euclidean'));
    
	% Store the RDM in a struct with the right names and things!
    switch type
        case 'binary'
                RDMs(n).RDM = tmp_binRDM;
        case 'catDiffs'
                RDMs(n).RDM = tmp_crossRDM;
        case 'distance'
                RDMs(n).RDM = tmp_distRDM;
        otherwise
            fprintf('\n'); error('*** sami:ERROR *** please specify type of calculation wanted.');
    end
    
    RDMs(n).name = [categories{n} shifted_title];
    RDMs(n).color = userOptions.default_modelRDMcolor;
end

%% visualise
if makeFig
	sami.plotRDMs(RDMs,userOptions);
end


end