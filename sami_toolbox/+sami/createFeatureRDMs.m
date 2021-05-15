function RDMs = createFeatureRDMs(feat, userOptions)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020


%% define default behavior
userOptions = sami.util.setIfUnset(userOptions, 'feat_distance', 'Euclidean');

%% looping feature-sets
nFeat = numel(feat);
for f = 1:nFeat
    % Get features for this stimulus
    thisFeatures = feat(f).fSet';
    
    % Calculate the RDM
    localRDM = squareform( pdist( thisFeatures, userOptions.feat_distance ) );
    
    % Store the RDM in a struct with the right names and things!
    RDMs(f).RDM = localRDM;
    RDMs(f).name = feat(f).name;
    RDMs(f).color = feat(f).color;
    
    clear localRDM;
end

end