function results = distance_correlation(data)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

%% options
mw_size = .1;           % size of moving window [in seconds]

%% init vars
nP = 2;
nMarker = size(data.labels,2);
timesteps = size(data.marker,1);
IPD = nan(timesteps,1);
dt = 1/data.frameRate;              % set time interval
m_w = mw_size * data.frameRate;                   % moving average window 

%% use this markers to calculate virtual marker at assumed "center" of each person
marker = {'LHIP', 'RHIP'};
marker_idx_p1 = [find(strcmp(data.labels, ['p1' marker{1}])), find(strcmp(data.labels, ['p1' marker{2}]))];
marker_idx_p2 = [find(strcmp(data.labels, ['p2' marker{1}])), find(strcmp(data.labels, ['p2' marker{2}]))];

% for limb contraction
head = {'HEAD'};
limbs = {'RWRI', 'LWRI','RANK', 'LANK'};
nLimbs = numel(limbs);

%% calculate timeseries of interpersonal distance
for t = 1:timesteps
    % calc virtual center for each person
    r_p1_m1 = data.marker(t,marker_idx_p1(1),:);
    r_p1_m2 = data.marker(t,marker_idx_p1(2),:);
    mdp_p1 = squeeze((r_p1_m1 + r_p1_m2) / 2);

    r_p2_m1 = data.marker(t,marker_idx_p2(1),:);
    r_p2_m2 = data.marker(t,marker_idx_p2(2),:);
    mdp_p2 = squeeze((r_p2_m1 + r_p2_m2) / 2);
    
    % calc interpersonal distance between virtual centers
    IPD(t) = pdist([mdp_p1, mdp_p2]','euclidean');
end % end TIME loop

%% correlation: IPD vs. vel/acc
IPD_vel = IPD(2:end);
IPD_acc = IPD(3:end);
corr_vel = nan(1,numel(data.labels));
corr_acc = nan(1,numel(data.labels));

% calculate velocity and acceleration of each marker
path_diff = diff(data.marker);
path = sqrt(sum(path_diff.*path_diff,3));

vel_raw = path ./ dt;
vel = movmean(vel_raw, m_w);
acc_raw =  diff(vel)./ dt;
acc = movmean(acc_raw, m_w);

% correlations
for m = 1:nMarker
    corr_vel(m) = corr(IPD_vel, vel(:,m));
    corr_acc(m) = corr(IPD_acc, acc(:,m));
end

% post-processing
corr_vel = abs(reshape(corr_vel, [nMarker/2, 2]));     % abs
mean_corr_vel = tanh(mean(atanh(corr_vel),2));  % fisher z

corr_acc = abs(reshape(corr_acc, [nMarker/2, 2]));     % abs
mean_corr_acc = tanh(mean(atanh(corr_acc),2));  % fisher z

%% correlation: IPD vs. limb contraction
corr_lc = nan(4,nP);

for p = 1:nP
    % get head index
    idxH = strcmp(data.labels, ['p' num2str(p) head{1}]);
    
    % loop limbs
    for limb = 1:nLimbs
        % get index of limb and 3d_data
        idxL = strcmp(data.labels, ['p' num2str(p) limbs{limb}]);
        
        xyz.head = squeeze(data.marker(:,idxH,:));
        xyz.limb = squeeze(data.marker(:,idxL,:));
        
        % timeseries of distance between head and limb
        tmpData = [reshape(xyz.head,1,3*timesteps);reshape(xyz.limb,1,3*timesteps)];
        tmpData = reshape(tmpData,2*timesteps,3);
        tmpData = squareform(pdist(tmpData,'euclidean'));
        
        lc_ts = diag(tmpData(1:2:2*timesteps,2:2:2*timesteps));
        
        % correlation betwenn IPD vs LC
        corr_lc(limb,p) = corr(IPD, lc_ts);
    end
end

% post-processing
corr_lc = abs(corr_lc);                         % abs
mean_corr_lc = tanh(mean(atanh(corr_lc),2));    % fisher z
    
%% correlation: IPD vs. volume
marker_range = nan(timesteps,nP,3);

% calculate vol
for p = 1:nP
    for a = 1:3
        marker_range(:,p,a) = range( data.marker(:,contains(data.labels, ['p' num2str(p)]),a)' );
    end
end
vol_ts = prod(marker_range,3);

% correlation
corr_vol = corr(vol_ts, IPD);

% post-processing
corr_vol = abs(corr_vol);                       % abs
mean_corr_vol = tanh(mean(atanh(corr_vol)));    % fisher z

%% Results
results(1).feat = mean_corr_vel;
results(1).name = 'corr_dist_velocity';
results(1).color = [0 .8 .6];
results(1).unit = '|Pearson r|';
results(1).fisherZ4paramTesting = true;

results(2).feat = mean_corr_acc;
results(2).name = 'corr_dist_acceleration';
results(2).color = [0 .8 .6];
results(2).unit = '|Pearson r|';
results(2).fisherZ4paramTesting = true;

results(3).feat = mean_corr_lc;
results(3).name = 'corr_dist_limb_contraction';
results(3).color = [0 .8 .6];
results(3).unit = '|Pearson r|';
results(3).fisherZ4paramTesting = true;

results(4).feat = mean_corr_vol;
results(4).name = 'corr_dist_volume';
results(4).color = [0 .8 .6];
results(4).unit = '|Pearson r|';
results(4).fisherZ4paramTesting = true;

end
