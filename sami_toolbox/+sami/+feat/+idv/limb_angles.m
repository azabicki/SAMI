function results = limb_angles(data)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

%% use this markers
calc_angles = {{'RELB', 'RSHO', 'RHIP'};...
               {'LELB', 'LSHO', 'LHIP'};...
               {'RSHO', 'RELB', 'RWRI'};...
               {'LSHO', 'LELB', 'LWRI'};...
               {'RSHO', 'RHIP', 'RKNE'};...
               {'LSHO', 'LHIP', 'LKNE'};...
               {'RHIP', 'RKNE', 'RANK'};...
               {'LHIP', 'LKNE', 'LANK'}};

%% init vars
timesteps = size(data.marker,1);
nP = 2; % soften ??
nAngles = size(calc_angles,1);

%% get marker indices in dataset in a [angle*marker*person] matrix 
mIdx = nan(nAngles,3,nP);
for p = 1:nP
    for a = 1:nAngles
        mIdx(a,:,p) = [find(strcmp(data.labels, ['p' num2str(p) calc_angles{a}{1}])), find(strcmp(data.labels, ['p' num2str(p) calc_angles{a}{2}])), find(strcmp(data.labels, ['p' num2str(p) calc_angles{a}{3}]))];
    end
end

%% loop: time * angles * persons
angles_ts = nan(timesteps,nAngles,nP);
for p = 1:nP
    for t = 1:timesteps
        for a = 1:nAngles
            % extract specific marker-information for each angle to calculate
            % into [marker*xyz] matrix containing 3d information of each marker
            m3d = squeeze(data.marker(t,mIdx(a,:,p),:));
            
            % define vector in space and calculate angle between them
            vec.B2A = m3d(1,:) - m3d(2,:);
            vec.B2C = m3d(3,:) - m3d(2,:);
            angles_ts(t,a,p) = acosd( dot ( vec.B2A, vec.B2C ) / ( norm( vec.B2A ) * norm( vec.B2C ) ) );
        end
    end
end

% average timeseries
angle_mean = squeeze(mean(angles_ts));
% average across persons
limbAngle_avg = mean(angle_mean,2);

%% Results
results.feat = limbAngle_avg;
results.name = 'limb_angles';
results.color = [.2 .5 0];
results.unit = 'deg';

end
