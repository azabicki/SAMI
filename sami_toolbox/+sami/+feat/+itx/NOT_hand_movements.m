function results = hand_movements(data)
% 
% EXAMPLE HOW TO *SKIP* FUNCTIONS 
% just rename it and write "NOT" somewhere into the filename
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

%% init vars
timesteps = size(data.marker,1);
dt = 1/data.frameRate;

p1_lh = nan(timesteps,3);
p1_rh = nan(timesteps,3);
p2_lh = nan(timesteps,3);
p2_rh = nan(timesteps,3);

%% use this markers
marker_lh = {'LWRA', 'LWRB', 'LFIN'};
marker_rh = {'RWRA', 'RWRB', 'RFIN'};
marker_idx_p1_lh = [find(strcmp(data.labels, marker_lh{1})),find(strcmp(data.labels.p1, marker_lh{2})),find(strcmp(data.labels.p1, marker_lh{3}))];
marker_idx_p1_rh = [find(strcmp(data.labels, marker_rh{1})),find(strcmp(data.labels.p1, marker_rh{2})),find(strcmp(data.labels.p1, marker_rh{3}))];
marker_idx_p2_lh = [find(strcmp(data.labels, marker_lh{1})),find(strcmp(data.labels.p2, marker_lh{2})),find(strcmp(data.labels.p2, marker_lh{3}))];
marker_idx_p2_rh = [find(strcmp(data.labels, marker_rh{1})),find(strcmp(data.labels.p2, marker_rh{2})),find(strcmp(data.labels.p2, marker_rh{3}))];

%% TIME loop
for t = 1:timesteps   
    % calc midpoint of centroid for each Person and each Hand
    m_p1_lA = permute( data.marker.p1(t,marker_idx_p1_lh(1),:) ,[3 1 2]);
    m_p1_lB = permute( data.marker.p1(t,marker_idx_p1_lh(2),:) ,[3 1 2]);
    m_p1_lF = permute( data.marker.p1(t,marker_idx_p1_lh(3),:) ,[3 1 2]);
    p1_lh(t,1:3)  = (m_p1_lA + m_p1_lB + m_p1_lF) / 3;
    
    m_p1_rA = permute( data.marker.p1(t,marker_idx_p1_rh(1),:) ,[3 1 2]);
    m_p1_rB = permute( data.marker.p1(t,marker_idx_p1_rh(2),:) ,[3 1 2]);
    m_p1_rF = permute( data.marker.p1(t,marker_idx_p1_rh(3),:) ,[3 1 2]);
    p1_rh(t,1:3)  = (m_p1_rA + m_p1_rB + m_p1_rF) / 3;
    
    m_p2_lA = permute( data.marker.p2(t,marker_idx_p2_lh(1),:) ,[3 1 2]);
    m_p2_lB = permute( data.marker.p2(t,marker_idx_p2_lh(2),:) ,[3 1 2]);
    m_p2_lF = permute( data.marker.p2(t,marker_idx_p2_lh(3),:) ,[3 1 2]);
    p2_lh(t,1:3)  = (m_p2_lA + m_p2_lB + m_p2_lF) / 3;
    
    m_p2_rA = permute( data.marker.p2(t,marker_idx_p2_rh(1),:) ,[3 1 2]);
    m_p2_rB = permute( data.marker.p2(t,marker_idx_p2_rh(2),:) ,[3 1 2]);
    m_p2_rF = permute( data.marker.p2(t,marker_idx_p2_rh(3),:) ,[3 1 2]);
    p2_rh(t,1:3)  = (m_p2_rA + m_p2_rB + m_p2_rF) / 3;
    
    %% calc parameters
    if t > 1
        % way from last timestep to this timestep
        handway.timeseries_p1_lh(t-1,1) = pdist([p1_lh(t,:); p1_lh(t-1,:)],'euclidean');
        handway.timeseries_p1_rh(t-1,1) = pdist([p1_rh(t,:); p1_rh(t-1,:)],'euclidean');
        handway.timeseries_p2_lh(t-1,1) = pdist([p2_lh(t,:); p2_lh(t-1,:)],'euclidean');
        handway.timeseries_p2_rh(t-1,1) = pdist([p2_rh(t,:); p2_rh(t-1,:)],'euclidean');        
    end
end % end TIMESTEPS loop

%% calc stuff in LAST TIMESTEP
% ****** save coordinates ******
results.coordinates.coord_p1_lh = p1_lh;
results.coordinates.coord_p1_rh = p1_rh;
results.coordinates.coord_p2_lh = p2_lh;
results.coordinates.coord_p2_rh = p2_rh;

% ****** handway ******
results.way = handway;
results.way.p1_lh = sum(results.way.timeseries_p1_lh);
results.way.p1_rh = sum(results.way.timeseries_p1_rh);
results.way.p2_lh = sum(results.way.timeseries_p2_lh);
results.way.p2_rh = sum(results.way.timeseries_p2_rh);

results.way.mean = mean([results.way.p1_lh; results.way.p1_rh; results.way.p2_lh; results.way.p2_rh]);
results.way.mean_p1 = mean([results.way.p1_lh; results.way.p1_rh]);
results.way.mean_p2 = mean([results.way.p2_lh; results.way.p2_rh]);

% ****** velocity ******
results.velo.timeseries_p1_lh = (results.way.timeseries_p1_lh) / dt;
results.velo.timeseries_p1_rh = (results.way.timeseries_p1_rh) / dt;
results.velo.timeseries_p2_lh = (results.way.timeseries_p2_lh) / dt;
results.velo.timeseries_p2_rh = (results.way.timeseries_p2_rh) / dt;

results.velo.p1_lh = mean(results.velo.timeseries_p1_lh);
results.velo.p1_rh = mean(results.velo.timeseries_p1_rh);
results.velo.p2_lh = mean(results.velo.timeseries_p2_lh);
results.velo.p2_rh = mean(results.velo.timeseries_p2_rh);

results.velo.mean = mean([results.velo.p1_lh; results.velo.p1_rh; results.velo.p2_lh; results.velo.p2_rh]);
results.velo.mean_p1 = mean([results.velo.p1_lh; results.velo.p1_rh]);
results.velo.mean_p2 = mean([results.velo.p2_lh; results.velo.p2_rh]);

% ****** acceleration ******
results.acc.timeseries_p1_lh = diff(results.velo.timeseries_p1_lh) / dt;
results.acc.timeseries_p1_rh = diff(results.velo.timeseries_p1_rh) / dt;
results.acc.timeseries_p2_lh = diff(results.velo.timeseries_p2_lh) / dt;
results.acc.timeseries_p2_rh = diff(results.velo.timeseries_p2_rh) / dt;

results.acc.p1_lh = mean(results.acc.timeseries_p1_lh);
results.acc.p1_rh = mean(results.acc.timeseries_p1_rh);
results.acc.p2_lh = mean(results.acc.timeseries_p2_lh);
results.acc.p2_rh = mean(results.acc.timeseries_p2_rh);

results.acc.mean = mean([results.acc.p1_lh; results.acc.p1_rh; results.acc.p2_lh; results.acc.p2_rh]);
results.acc.mean_p1 = mean([results.acc.p1_lh; results.acc.p1_rh]);
results.acc.mean_p2 = mean([results.acc.p2_lh; results.acc.p2_rh]);


% ****** handvol of ellipsoid ******
[ellipsoid_p1l] = MinVolEllipse(p1_lh'./1000,0.01); [~,Q,~] = svd(ellipsoid_p1l);
handvol.p1_lh = 4/3 * pi * ( 1/sqrt(Q(1,1)) ) * ( 1/sqrt(Q(2,2)) ) * ( 1/sqrt(Q(3,3)) );
[ellipsoid_p1r] = MinVolEllipse(p1_rh'./1000,0.01); [~,Q,~] = svd(ellipsoid_p1r);
handvol.p1_rh = 4/3 * pi * ( 1/sqrt(Q(1,1)) ) * ( 1/sqrt(Q(2,2)) ) * ( 1/sqrt(Q(3,3)) );
[ellipsoid_p2l] = MinVolEllipse(p2_lh'./1000,0.01); [~,Q,~] = svd(ellipsoid_p2l);
handvol.p2_lh = 4/3 * pi * ( 1/sqrt(Q(1,1)) ) * ( 1/sqrt(Q(2,2)) ) * ( 1/sqrt(Q(3,3)) );
[ellipsoid_p2r] = MinVolEllipse(p2_rh'./1000,0.01); [~,Q,~] = svd(ellipsoid_p2r);
handvol.p2_rh = 4/3 * pi * ( 1/sqrt(Q(1,1)) ) * ( 1/sqrt(Q(2,2)) ) * ( 1/sqrt(Q(3,3)) );

results.vol.mean = mean([handvol.p1_lh; handvol.p1_rh; handvol.p2_lh; handvol.p2_rh]);
results.vol.mean_p1 = mean([handvol.p1_lh; handvol.p1_rh]);
results.vol.mean_p2 = mean([handvol.p2_lh; handvol.p2_rh]);

%% Results
results.feat = 123;
results.name = 'avg_distance';
results.color = [0 .8 .2];
results.unit = 'idk';

end



function [A , c] = MinVolEllipse(P, tolerance)
% [A , c] = MinVolEllipse(P, tolerance)
% Finds the minimum volume enclsing ellipsoid (MVEE) of a set of data
% points stored in matrix P. The following optimization problem is solved: 
%
% minimize       log(det(A))
% subject to     (P_i - c)' * A * (P_i - c) <= 1
%                
% in variables A and c, where P_i is the i-th column of the matrix P. 
% The solver is based on Khachiyan Algorithm, and the final solution 
% is different from the optimal value by the pre-spesified amount of 'tolerance'.
%
% inputs:
%---------
% P : (d x N) dimnesional matrix containing N points in R^d.
% tolerance : error in the solution with respect to the optimal value.
%
% outputs:
%---------
% A : (d x d) matrix of the ellipse equation in the 'center form': 
% (x-c)' * A * (x-c) = 1 
% c : 'd' dimensional vector as the center of the ellipse. 
% 
% example:
% --------
%      P = rand(5,100);
%      [A, c] = MinVolEllipse(P, .01)
%
%      To reduce the computation time, work with the boundary points only:
%      
%      K = convhulln(P');  
%      K = unique(K(:));  
%      Q = P(:,K);
%      [A, c] = MinVolEllipse(Q, .01)
%
%
% Nima Moshtagh (nima@seas.upenn.edu)
% University of Pennsylvania
%
% December 2005
% UPDATE: Jan 2009



%%%%%%%%%%%%%%%%%%%%% Solving the Dual problem%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% ---------------------------------
% data points 
% -----------------------------------
[d, N] = size(P);

Q = zeros(d+1,N);
Q(1:d,:) = P(1:d,1:N);
Q(d+1,:) = ones(1,N);


% initializations
% -----------------------------------
count = 1;
err = 1;
u = (1/N) * ones(N,1);          % 1st iteration


% Khachiyan Algorithm
% -----------------------------------
while err > tolerance
    X = Q * diag(u) * Q';       % X = \sum_i ( u_i * q_i * q_i')  is a (d+1)x(d+1) matrix
%     M = diag(Q' * inv(X) * Q);  % M the diagonal vector of an NxN matrix
    M = diag(Q' * (X\Q));  % M the diagonal vector of an NxN matrix
    [maximum, j] = max(M);
    step_size = (maximum - d -1)/((d+1)*(maximum-1));
    new_u = (1 - step_size)*u ;
    new_u(j) = new_u(j) + step_size;
    count = count + 1;
    err = norm(new_u - u);
    u = new_u;
end



%%%%%%%%%%%%%%%%%%% Computing the Ellipse parameters%%%%%%%%%%%%%%%%%%%%%%
% Finds the ellipse equation in the 'center form': 
% (x-c)' * A * (x-c) = 1
% It computes a dxd matrix 'A' and a d dimensional vector 'c' as the center
% of the ellipse. 

U = diag(u);

% the A matrix for the ellipse
% --------------------------------------------
% A = (1/d) * inv(P * U * P' - (P * u)*(P*u)' );
A = (1/d) / (P * U * P' - (P * u)*(P*u)' );


% center of the ellipse 
% --------------------------------------------
c = P * u;

end