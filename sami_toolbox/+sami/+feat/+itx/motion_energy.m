function results = motion_energy(data)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

%% calculations
% indices of person specific markers
marker_idx(1,:) = find(contains(data.labels, 'p1'));
marker_idx(2,:)= find(contains(data.labels, 'p2'));

% difference between frames for each dimension
diff_p1 = diff(data.marker(:,marker_idx(1,:),:));
diff_p2 = diff(data.marker(:,marker_idx(2,:),:));

% length of 3d-interframe-difference (pythagoras)
disp_p1 = sqrt(sum(diff_p1.*diff_p1,3));
disp_p2 = sqrt(sum(diff_p2.*diff_p2,3));

% balance of "motion_energy" between persons
MoEn(1) = mean(mean(disp_p1));
MoEn(2) = mean(mean(disp_p2));
MoEn_balance = 1 - abs(diff(MoEn)) / sum(MoEn);

%% results
results.feat = MoEn_balance;
results.name = 'motion_energy_balance';
results.color = [0 .8 .6];
results.unit = 'AU';

    
end