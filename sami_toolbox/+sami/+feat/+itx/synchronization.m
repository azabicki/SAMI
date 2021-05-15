function results = synchronization(data)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

%% options
step_length = .02;      % in seconds
max_lag = 1;            % in seconds
mw_size = .1;           % size of moving window [in seconds]

%% init vars
dt = 1/data.frameRate;  % set time interval

time_lag_int = step_length * data.frameRate;
time_lag_border = max_lag * data.frameRate;
time_lag = round(time_lag_int:time_lag_int:time_lag_border);

marker_idx(1,:) = find(contains(data.labels, 'p1'));
marker_idx(2,:)= find(contains(data.labels, 'p2'));

lbl_arms = {'SHO','ELB','WRI'};
lbl_trunc = {'HEAD','HIP','KNE','ANK'};
marker_idx_arms = contains(data.labels, lbl_arms);
marker_idx_arms = marker_idx_arms(contains(data.labels, 'p1'));
marker_idx_trunc = contains(data.labels, lbl_trunc);
marker_idx_trunc = marker_idx_trunc(contains(data.labels, 'p1'));

corrMat_vel = nan( numel(time_lag)*2+1 , size(marker_idx,2) );
corrMat_acc = nan( numel(time_lag)*2+1 , size(marker_idx,2) );

%% calculate velocity and acceleration of each marker
path_diff_3d = diff(data.marker);
path_diff = sqrt(sum(path_diff_3d.*path_diff_3d,3));

vel_raw = path_diff ./ dt;
vel = movmean(vel_raw,mw_size*data.frameRate);
acc_raw = diff(vel)./ dt;
acc = movmean(acc_raw,mw_size*data.frameRate);

%% calculate correlations
% without time_shift
for m = 1:size(marker_idx,2)
    corrMat_vel(numel(time_lag)+1,m) = corr(vel(:,marker_idx(1,m)), vel(:,marker_idx(2,m)));
    corrMat_acc(numel(time_lag)+1,m) = corr(acc(:,marker_idx(1,m)), acc(:,marker_idx(2,m)));
end

% correlations with time-shift
for m = 1:size(marker_idx,2)
    for lag = 1:size(time_lag,2)
        idx_plus  = numel(time_lag) +1 + lag;
        idx_minus = numel(time_lag) +1 - lag;
        
        % shift p1 -> left & p2 -> right
        % velocity
        tmp.time_shift_p1 = vel(time_lag(lag)+1:end,marker_idx(1,m));
        tmp.time_shift_p2 = vel(1:end-time_lag(lag),marker_idx(2,m));
        corrMat_vel(idx_plus,m) = corr(tmp.time_shift_p1, tmp.time_shift_p2);

        % acceleration
        tmp.time_shift_p1 = acc(time_lag(lag)+1:end,marker_idx(1,m));
        tmp.time_shift_p2 = acc(1:end-time_lag(lag),marker_idx(2,m));
        corrMat_acc(idx_plus,m) = corr(tmp.time_shift_p1, tmp.time_shift_p2);
        
        % shift p1 -> right & p2 -> left
        % velocity
        tmp.time_shift_p1 = vel(1:end-time_lag(lag),marker_idx(1,m));
        tmp.time_shift_p2 = vel(time_lag(lag)+1:end,marker_idx(2,m));
        corrMat_vel(idx_minus,m) = corr(tmp.time_shift_p1, tmp.time_shift_p2);

        % acceleration
        tmp.time_shift_p1 = acc(1:end-time_lag(lag),marker_idx(1,m));
        tmp.time_shift_p2 = acc(time_lag(lag)+1:end,marker_idx(2,m));
        corrMat_acc(idx_minus,m) = corr(tmp.time_shift_p1, tmp.time_shift_p2);
    end
end

% absolute correlations bc negative are also indicator for "*inter*action"
corrMat_vel = abs(corrMat_vel);
corrMat_acc = abs(corrMat_acc);

% calc max
corr_vel = max(corrMat_vel);
corr_acc = max(corrMat_acc);

%% results
results(1).feat = corr_vel;
results(1).name = 'sync_vel';
results(1).color = [0 .8 .6];
results(1).unit = '|Pearson r|';
results(1).fisherZ4paramTesting = true;

results(2).feat = corr_vel(marker_idx_arms);
results(2).name = 'sync_vel_arms';
results(2).color = [0 .8 .6];
results(2).unit = '|Pearson r|';
results(2).fisherZ4paramTesting = true;

results(3).feat = corr_vel(marker_idx_trunc);
results(3).name = 'sync_vel_trunc';
results(3).color = [0 .8 .6];
results(3).unit = '|Pearson r|';
results(3).fisherZ4paramTesting = true;

results(4).feat = corr_acc;
results(4).name = 'sync_acc';
results(4).color = [0 .8 .6];
results(4).unit = '|Pearson r|';
results(4).fisherZ4paramTesting = true;

results(5).feat = corr_acc(marker_idx_arms);
results(5).name = 'sync_acc_arms';
results(5).color = [0 .8 .6];
results(5).unit = '|Pearson r|';
results(5).fisherZ4paramTesting = true;

results(6).feat = corr_acc(marker_idx_trunc);
results(6).name = 'sync_acc_trunc';
results(6).color = [0 .8 .6];
results(6).unit = '|Pearson r|';
results(6).fisherZ4paramTesting = true;

end
