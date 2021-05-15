function results = vertical_movement(data)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

%% init vars
nMarkerPerPerson = numel(data.labels)/2;

% calculations
vPath = abs(diff(data.marker(:,:,3)));
vPath_sum = sum(vPath);

% average across individuals
vPath_avg = mean(reshape(vPath_sum,nMarkerPerPerson,2),2);

%% Results
results.feat = vPath_avg;
results.name = 'vertical_movement';
results.color = [.8 .8 0];
results.unit = 'mm';


end
