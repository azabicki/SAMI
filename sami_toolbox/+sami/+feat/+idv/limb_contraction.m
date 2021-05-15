function results = limb_contraction(data)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

%% use this markers
limbs = {'RWRI', 'LWRI','RANK', 'LANK'};

%% init vars
head = {'HEAD'};
timesteps = size(data.marker,1);
nP = 2; % soften?
nLimbs = numel(limbs);
dist_ts = nan(timesteps,nLimbs,nP);

%% calculate distances for each person
for p = 1:nP
    % get head index
    idxH = strcmp(data.labels, ['p' num2str(p) head{1}]);
    
    % loop limbs
    for limb = 1:nLimbs
        idxL = strcmp(data.labels, ['p' num2str(p) limbs{limb}]);
        
        xyz.head = squeeze(data.marker(:,idxH,:));
        xyz.limb = squeeze(data.marker(:,idxL,:));
        
        tmpData = [reshape(xyz.head,1,3*timesteps);reshape(xyz.limb,1,3*timesteps)];
        tmpData = reshape(tmpData,2*timesteps,3);
        tmpData = squareform(pdist(tmpData,'euclidean'));
        
        dist_ts(:,limb,p) = diag(tmpData(1:2:2*timesteps,2:2:2*timesteps));
    end
end

% calculating means
limbContraction_avg = mean(mean(dist_ts),3);

%% Results
results.feat = limbContraction_avg;
results.name = 'limb_contraction';
results.color = [.2 .5 0];
results.unit = 'mm';

end

