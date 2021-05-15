function results = interpersonal_distance(data)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

%% init vars
timesteps = size(data.marker,1);
IPD_ts = nan(timesteps,1);

%% use this markers to calculate virtual marker at assumed "center" of each person
marker = {'LHIP', 'RHIP'};
marker_idx_p1 = [find(strcmp(data.labels, ['p1' marker{1}])), find(strcmp(data.labels, ['p1' marker{2}]))];
marker_idx_p2 = [find(strcmp(data.labels, ['p2' marker{1}])), find(strcmp(data.labels, ['p2' marker{2}]))];

%% loop TIME
for t = 1:timesteps
    % calc virtual center for each person
    r_p1_m1 = data.marker(t,marker_idx_p1(1),:);
    r_p1_m2 = data.marker(t,marker_idx_p1(2),:);
    mdp_p1 = squeeze((r_p1_m1 + r_p1_m2) / 2);

    r_p2_m1 = data.marker(t,marker_idx_p2(1),:);
    r_p2_m2 = data.marker(t,marker_idx_p2(2),:);
    mdp_p2 = squeeze((r_p2_m1 + r_p2_m2) / 2);
    
    % calc interpersonal distance between virtual centers
    IPD_ts(t) = pdist([mdp_p1, mdp_p2]','euclidean');
end % end TIME loop

%% calc mean interpersonal distance
IPD_mean = mean(IPD_ts);
IPD_std = std(IPD_ts);

%% Results
results(1).feat = IPD_mean;
results(1).name = 'IP_distance_avg';
results(1).color = [0 .8 .6];
results(1).unit = 'mm';

results(2).feat = IPD_std;
results(2).name = 'IP_distance_std';
results(2).color = [0 .8 .6];
results(2).unit = 'mm';

end