function results = symmetry(data)
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

%% define markers
marker_shoulder = {'LSHO', 'RSHO'};
marker_hip = {'LHIP', 'RHIP'};

%% loop persons
for p = 1:nP
    %% find marker indices
    % shoulder + hip
    marker_idx.shoulder = [find(strcmp(data.labels, ['p' num2str(p) marker_shoulder{1}])), find(strcmp(data.labels, ['p' num2str(p) marker_shoulder{2}]))];
    marker_idx.hip      = [find(strcmp(data.labels, ['p' num2str(p) marker_hip{1}])), find(strcmp(data.labels, ['p' num2str(p) marker_hip{2}]))];
    
    % all left and right markers
    marker_idx.left = [];
    marker_idx.right = [];
    for i = 1:numel(data.labels)
        if strcmp(data.labels{1,i}(1:3), ['p' num2str(p) 'L'])
            marker_idx.left = [marker_idx.left i];
            % find coresponding right marker (should be in corresponding order, but u never know...)
            tmpLabel = [data.labels{1,i}(1:2) 'R' data.labels{1,i}(4:end)];
            marker_idx.right =  [marker_idx.right find(strcmp(data.labels, tmpLabel))];
        end
    end
    nMarker = numel(marker_idx.right);
    
    %% calculate difference in height (z-axes) between body-sides, for each marker in each timestep
    symmetry.height.diff(:,:,p) = abs( ( data.marker(:,marker_idx.left,3) - data.marker(:,marker_idx.right,3) ) );
    
    %% calculate deviations (angle and distance) from symmetry-line
    for t = 1:timesteps
        % calculate midline [location and pointing_vector] for each person
        [ml_loc, ml_vec] = calc_midline(data,t,marker_idx);
        
        % loop marker and get distance/angle with respect to midline
        for m = 1:nMarker
            % distance to symmetry_line
            tmpL = squeeze(data.marker(t,marker_idx.left(m),1:2));
            tmpR = squeeze(data.marker(t,marker_idx.right(m),1:2));
            symmetry.ml_dist.left(t,m,p) = dist_to_symmetry_line(tmpL, ml_loc, ml_loc + ml_vec);
            symmetry.ml_dist.right(t,m,p) = dist_to_symmetry_line(tmpR, ml_loc, ml_loc + ml_vec);
            
            % circular segment
            tmpLRnorm = mean([norm(tmpL - ml_loc) norm(tmpR - ml_loc)]);
            tmpLalpha =  asin(symmetry.ml_dist.left(t,m,p) / norm(ml_loc - tmpL));
            tmpRalpha =  asin(symmetry.ml_dist.right(t,m,p) / norm(ml_loc - tmpR));
            symmetry.ml_circSeg.left(t,m,p) = tmpLRnorm * tmpLalpha;
            symmetry.ml_circSeg.right(t,m,p) = tmpLRnorm * tmpRalpha;
        end %marker loop
    end %time loop
end %person loop

% average anatomical marker across persons
symmetry.height.avg_per_marker = mean(symmetry.height.diff);
symmetry.height.avg_diff = mean(symmetry.height.avg_per_marker, 3)';

symmetry.ml_dist.diff = abs(symmetry.ml_dist.right - symmetry.ml_dist.left);
symmetry.ml_dist.avg_per_marker = mean(symmetry.ml_dist.diff);
symmetry.ml_dist.avg_diff = mean(symmetry.ml_dist.avg_per_marker, 3)';

symmetry.ml_circSeg.diff = abs(symmetry.ml_circSeg.right - symmetry.ml_circSeg.left);
symmetry.ml_circSeg.avg_per_marker = mean(symmetry.ml_circSeg.diff);
symmetry.ml_circSeg.avg_diff = mean(symmetry.ml_circSeg.avg_per_marker, 3)';

symmetry.results = [symmetry.height.avg_diff; symmetry.ml_dist.avg_diff; symmetry.ml_circSeg.avg_diff];

%% Results
results.feat = symmetry.results;
results.name = 'symmetry';
results.color = [.2 .5 0];
results.unit = 'delta(mm)';

end

%% ******** SUB FUNCTIONS ******************************************************************
function [r_mid, v_f] = calc_midline(data,t,marker_idx)
% shoulder *********************************************************************************
% get coordinates of each marker
r_ls = permute( data.marker(t,marker_idx.shoulder(1),1:2) ,[3 1 2]);
r_rs = permute( data.marker(t,marker_idx.shoulder(2),1:2) ,[3 1 2]);

% calc pointing vector as normal_vector between shoulders
v_lr_shoulder = r_rs - r_ls;

v_lr_k_shoulder = norm(v_lr_shoulder);         % k ~ k times n_vector is lenght of shoulder
v_lr_n_shoulder = v_lr_shoulder ./ v_lr_k_shoulder;   % n ~ norm (einheitsvektor)

% orthogonal vector, pointing forward
v_f_n_shoulder = (v_lr_n_shoulder' * [cosd(-90) -sind(-90); sind(-90) cosd(-90)])';
v_f_shoulder = v_f_n_shoulder * 3000;

% middle between shoulders
r_mid_shoulder = r_ls + (v_lr_k_shoulder/2 * v_lr_n_shoulder);

% hip *************************************************************************************
% get coordinates of each marker
r_lh = permute( data.marker(t,marker_idx.hip(1),1:2), [3,1,2]);
r_rh = permute( data.marker(t,marker_idx.hip(2),1:2), [3,1,2]);

% calc pointing vector as normal_vector between shoulders
v_lr_hip = r_rh - r_lh;

v_lr_k_hip = norm( v_lr_hip);         % k ~ k times n_vector is lenght of shoulder
v_lr_n_hip = v_lr_hip ./ v_lr_k_hip;   % n ~ norm (einheitsvektor)

% orthogonal vector, pointing forward
v_f_n_hip= (v_lr_n_hip' * [cosd(-90) -sind(-90); sind(-90) cosd(-90)])';
v_f_hip = v_f_n_hip * 3000;

% middle between shoulders
r_mid_hip = r_lh + (v_lr_k_hip/2 * v_lr_n_hip);

% mean(shoulder+hip) LOCATION *************************************************************
r_mid = mean([r_mid_shoulder,r_mid_hip],2);

% mean(shoulder+hip) NORMAL_VECTOR *********************************************************
v_f = mean([v_f_shoulder,v_f_hip],2);
end

function d = dist_to_symmetry_line(pt, v1, v2)
pt(3) = 0;
v1(3) = 0;
v2(3) = 0;

a = v1 - v2;
b = pt - v2;
d = norm(cross(a,b)) / norm(a);
end
