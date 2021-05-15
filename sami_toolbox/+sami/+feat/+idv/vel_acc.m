function results = vel_acc(data)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

%% init vars
dt = 1/data.frameRate; % set time interval
nMarkerPerPerson = numel(data.labels)/2;

%% calculations
% pathlength of each marker in 3d space
path_diff = diff(data.marker);
path = sqrt(sum(path_diff.*path_diff,3));

% velocity
vel = path ./ dt;
vel_avg_marker = mean(vel);

% acceleration
acc = diff(vel) ./ dt;
acc_avg_marker = mean(acc);

% average across individuals
vel_avg = mean(reshape(vel_avg_marker,nMarkerPerPerson,2),2);
acc_avg = mean(reshape(acc_avg_marker,nMarkerPerPerson,2),2);

%% Results
results(1).feat = vel_avg;
results(1).name = 'velocity';
results(1).color = [.8 .8 .0];
results(1).unit = 'mm*s^-1';

results(2).feat = acc_avg;
results(2).name = 'acceleration';
results(2).color = [.8 .8 .0];
results(2).unit = 'mm*s^-2';

end