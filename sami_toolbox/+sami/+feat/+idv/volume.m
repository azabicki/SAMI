function results = volume(data)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

%% init vars
timesteps = size(data.marker,1);
nP = 2;

%% get range of marker-3d-values for each timestep, each person and in each dimension
marker_range = nan(timesteps,nP,3);
for p = 1:nP
    for a = 1:3
        marker_range(:,p,a) = range( data.marker(:,contains(data.labels, ['p' num2str(p)]),a)' ) ./ 1000; % convert into [m]
    end
end


%% calculate vol for each person seperately
vol_ts = prod(marker_range,3);
vol_MN = mean(vol_ts);
vol_STD = std(vol_ts);

% average across persons
volume_avg = mean(vol_MN);
volume_std = mean(vol_STD);

%% Results
results(1).feat = volume_avg;
results(1).name = 'volume_average';
results(1).color = [.2 .5 0];
results(1).unit = 'm^3';

results(2).feat = volume_std;
results(2).name = 'volume_std';
results(2).color = [.2 .5 0];
results(2).unit = 'm^3';

end
