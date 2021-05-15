function results = personalzone_time(data)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

%% init vars
timesteps = size(data.marker,1);
np = 2;

%% use this markers
marker_idx.p1 = find(contains(data.labels, 'p1'));
marker_idx.p2 = find(contains(data.labels, 'p2'));
LabelsArms = {'LSHO', 'LELB', 'LWRI', 'RSHO', 'RELB', 'RWRI'};
marker_idx.arms(1,:) = [find(strcmp(data.labels, ['p1' LabelsArms{1}])), find(strcmp(data.labels, ['p1' LabelsArms{2}])), find(strcmp(data.labels, ['p1' LabelsArms{3}])), find(strcmp(data.labels, ['p1' LabelsArms{4}])), find(strcmp(data.labels, ['p1' LabelsArms{5}])), find(strcmp(data.labels, ['p1' LabelsArms{6}]))];
marker_idx.arms(2,:) = [find(strcmp(data.labels, ['p2' LabelsArms{1}])), find(strcmp(data.labels, ['p2' LabelsArms{2}])), find(strcmp(data.labels, ['p2' LabelsArms{3}])), find(strcmp(data.labels, ['p2' LabelsArms{4}])), find(strcmp(data.labels, ['p2' LabelsArms{5}])), find(strcmp(data.labels, ['p2' LabelsArms{6}]))];
LabelsCore = {'LSHO', 'RSHO', 'LHIP', 'RHIP'};
marker_idx.core(1,:) = [find(strcmp(data.labels, ['p1' LabelsCore{1}])), find(strcmp(data.labels, ['p1' LabelsCore{2}])), find(strcmp(data.labels, ['p1' LabelsCore{3}])), find(strcmp(data.labels, ['p1' LabelsCore{4}]))];
marker_idx.core(2,:) = [find(strcmp(data.labels, ['p2' LabelsCore{1}])), find(strcmp(data.labels, ['p2' LabelsCore{2}])), find(strcmp(data.labels, ['p2' LabelsCore{3}])), find(strcmp(data.labels, ['p2' LabelsCore{4}]))];

%% get length arm
for p = 1:np
    % all coords for each joint
    tmp.lS = squeeze(data.marker(:,marker_idx.arms(p,1),:));
    tmp.lE = squeeze(data.marker(:,marker_idx.arms(p,2),:));
    tmp.lW = squeeze(data.marker(:,marker_idx.arms(p,3),:));
    tmp.rS = squeeze(data.marker(:,marker_idx.arms(p,4),:));
    tmp.rE = squeeze(data.marker(:,marker_idx.arms(p,5),:));
    tmp.rW = squeeze(data.marker(:,marker_idx.arms(p,6),:));
    
    % left Shoulder_Elbow
    tmp.lSE = [reshape(tmp.lS,1,3*timesteps);reshape(tmp.lE,1,3*timesteps)];
    tmp.lSE = reshape(tmp.lSE,2*timesteps,3);
    tmp.lSE = squareform(pdist(tmp.lSE,'euclidean'));
    % left Elbow_Wrist
    tmp.lEW = [reshape(tmp.lE,1,3*timesteps);reshape(tmp.lW,1,3*timesteps)];
    tmp.lEW = reshape(tmp.lEW,2*timesteps,3);
    tmp.lEW = squareform(pdist(tmp.lEW,'euclidean'));
    % right Shoulder_Elbow    
    tmp.rSE = [reshape(tmp.rS,1,3*timesteps);reshape(tmp.rE,1,3*timesteps)];
    tmp.rSE = reshape(tmp.rSE,2*timesteps,3);
    tmp.rSE = squareform(pdist(tmp.rSE,'euclidean'));
    % right Elbow_Wrist
    tmp.rEW = [reshape(tmp.rE,1,3*timesteps);reshape(tmp.rW,1,3*timesteps)];
    tmp.rEW = reshape(tmp.rEW,2*timesteps,3);
    tmp.rEW = squareform(pdist(tmp.rEW,'euclidean'));
    
    % save timeseries of distances
    tmp.lSE_ts(:,p) = diag(tmp.lSE(1:2:2*timesteps,2:2:2*timesteps));
    tmp.lEW_ts(:,p) = diag(tmp.lEW(1:2:2*timesteps,2:2:2*timesteps));
    tmp.rSE_ts(:,p) = diag(tmp.rSE(1:2:2*timesteps,2:2:2*timesteps));
    tmp.rEW_ts(:,p) = diag(tmp.rEW(1:2:2*timesteps,2:2:2*timesteps));
end

% calculating armLengths
tmp.lArm = mean(tmp.lSE_ts) + mean(tmp.lEW_ts);
tmp.rArm = mean(tmp.rSE_ts) + mean(tmp.rEW_ts);
armLength = mean(mean([tmp.lArm; tmp.rArm]));

clear tmp;

%% loop timesteps and check for "in-zone"
personalDist.p1in2 = zeros(timesteps,1);
personalDist.p2in1 = zeros(timesteps,1);

for t = 1:timesteps
    % calculate polygon for shoulder and hips
    % get coordinates of each marker
    r_p1_ls = permute( data.marker(t,marker_idx.core(1,1),:) ,[1 3 2]);
    r_p1_rs = permute( data.marker(t,marker_idx.core(1,2),:) ,[1 3 2]);
    r_p1_lh = permute( data.marker(t,marker_idx.core(1,3),:) ,[1 3 2]);
    r_p1_rh = permute( data.marker(t,marker_idx.core(1,4),:) ,[1 3 2]);
    r_p2_ls = permute( data.marker(t,marker_idx.core(2,1),:) ,[1 3 2]);
    r_p2_rs = permute( data.marker(t,marker_idx.core(2,2),:) ,[1 3 2]);
    r_p2_lh = permute( data.marker(t,marker_idx.core(2,3),:) ,[1 3 2]);
    r_p2_rh = permute( data.marker(t,marker_idx.core(2,4),:) ,[1 3 2]);
    
    % get coordinates of orthogonal vec, pointing forward and backward
    [p1f_ls, p1f_rs, p1b_ls, p1b_rs] = calc_point_front_back(r_p1_ls, r_p1_rs, armLength);
    [p1f_lh, p1f_rh, p1b_lh, p1b_rh] = calc_point_front_back(r_p1_lh, r_p1_rh, armLength);
    [p2f_ls, p2f_rs, p2b_ls, p2b_rs] = calc_point_front_back(r_p2_ls, r_p2_rs, armLength);
    [p2f_lh, p2f_rh, p2b_lh, p2b_rh] = calc_point_front_back(r_p2_lh, r_p2_rh, armLength);
    
    % define convex hull
    c_h_p1 = [p1f_ls; p1f_rs; p1b_ls; p1b_rs; p1f_lh; p1f_rh; p1b_lh; p1b_rh];
    c_h_p2 = [p2f_ls; p2f_rs; p2b_ls; p2b_rs; p2f_lh; p2f_rh; p2b_lh; p2b_rh];
    
    %% check distance between each marker
    % in p1 in p2 ?
    for m = 1:numel(marker_idx.p1)
        % check this marker
        markerToCheckP1 = permute(data.marker(t, marker_idx.p1(m), :), [3,1,2]);
        % inhull
        inHull_p1in2_AZ = inhull(markerToCheckP1', c_h_p2);
        % sphere
        coreP2 = squeeze(data.marker(t, marker_idx.core(2,:), :));
        tmp_dist = pdist([markerToCheckP1'; coreP2],'euclidean');
        tmp_dist = tmp_dist(1:numel(LabelsCore));
        inSphere_p1in2 = tmp_dist <= armLength;
        % check
        if inHull_p1in2_AZ || any(inSphere_p1in2)
            personalDist.p1in2(t) = 1;
            break
        end        
    end
    % is p2 in p1 ?
    for m = 1:numel(marker_idx.p2)
        % check this marker
        markerToCheckP2 = permute(data.marker(t, marker_idx.p2(m),:), [3,1,2]);
        % inhull
        inHull_p2in1_AZ = inhull(markerToCheckP2', c_h_p1);
        % sphere
        coreP1 = squeeze(data.marker(t, marker_idx.core(1,:), :));
        tmp_dist = pdist([markerToCheckP2'; coreP1],'euclidean');
        tmp_dist = tmp_dist(1:numel(LabelsCore));
        inSphere_p2in1 = tmp_dist <= armLength;
        % check
        if inHull_p2in1_AZ || any(inSphere_p2in1)
            personalDist.p2in1(t) = 1;
            break
        end
    end
end


%% results in %
p1in2_perc = sum(personalDist.p1in2) / timesteps * 100;
p2in1_perc = sum(personalDist.p2in1) / timesteps * 100;
result_PZ(1,1) = (p1in2_perc + p2in1_perc) / 2;

%% results
results.feat = result_PZ;
results.name = 'personalspace';
results.color = [0 .8 .6];
results.unit = '%';

end 

%% +++++++++++ sub functions ++++++++++++++++++++++++++++++++++++++++++++++
function [l_f, r_f, l_b, r_b] = calc_point_front_back(l_p, r_p, armLength)
    % calc pointing vector as normal_vec
    v_p_lr = r_p(1:2) - l_p(1:2);
    v_p_lr_n = v_p_lr ./ norm( v_p_lr);   % n ~ norm (einheitsvektor)
    
    % orthogonal vector, pointing forward and backward
    v_p_f_n = v_p_lr_n * [cosd(-90) -sind(-90); sind(-90) cosd(-90)];
    v_p_f_s = v_p_f_n * armLength;
    
    % create corners by adding vector to shoulder/hips
    l_f = l_p + [v_p_f_s, 0];
    r_f = r_p + [v_p_f_s, 0];
    l_b = l_p - [v_p_f_s, 0];
    r_b = r_p - [v_p_f_s, 0];
end

function in = inhull(testpts,xyz,tess,tol)
% inhull: tests if a set of points are inside a convex hull
% usage: in = inhull(testpts,xyz)
% usage: in = inhull(testpts,xyz,tess)
% usage: in = inhull(testpts,xyz,tess,tol)
%
% arguments: (input)
%  testpts - nxp array to test, n data points, in p dimensions
%       If you have many points to test, it is most efficient to
%       call this function once with the entire set.
%
%  xyz - mxp array of vertices of the convex hull, as used by
%       convhulln.
%
%  tess - tessellation (or triangulation) generated by convhulln
%       If tess is left empty or not supplied, then it will be
%       generated.
%
%  tol - (OPTIONAL) tolerance on the tests for inclusion in the
%       convex hull. You can think of tol as the distance a point
%       may possibly lie outside the hull, and still be perceived
%       as on the surface of the hull. Because of numerical slop
%       nothing can ever be done exactly here. I might guess a
%       semi-intelligent value of tol to be
%
%         tol = 1.e-13*mean(abs(xyz(:)))
%
%       In higher dimensions, the numerical issues of floating
%       point arithmetic will probably suggest a larger value
%       of tol.
%
%       DEFAULT: tol = 0
%
% arguments: (output)
%  in  - nx1 logical vector
%        in(i) == 1 --> the i'th point was inside the convex hull.
%  
% Example usage: The first point should be inside, the second out
%
%  xy = randn(20,2);
%  tess = convhulln(xy);
%  testpoints = [ 0 0; 10 10];
%  in = inhull(testpoints,xy,tess)
%
% in = 
%      1
%      0
%
% A non-zero count of the number of degenerate simplexes in the hull
% will generate a warning (in 4 or more dimensions.) This warning
% may be disabled off with the command:
%
%   warning('off','inhull:degeneracy')
%
% See also: convhull, convhulln, delaunay, delaunayn, tsearch, tsearchn
%
% Author: John D'Errico
% e-mail: woodchips@rochester.rr.com
% Release: 3.0
% Release date: 10/26/06

% get array sizes
% m points, p dimensions
p = size(xyz,2);
[n,c] = size(testpts);
if p ~= c
  error 'testpts and xyz must have the same number of columns'
end
if p < 2
  error 'Points must lie in at least a 2-d space.'
end

% was the convex hull supplied?
if (nargin<3) || isempty(tess)
  tess = convhulln(xyz);
end
[nt,c] = size(tess);
if c ~= p
  error 'tess array is incompatible with a dimension p space'
end

% was tol supplied?
if (nargin<4) || isempty(tol)
  tol = 0;
end

% build normal vectors
switch p
  case 2
    % really simple for 2-d
    nrmls = (xyz(tess(:,1),:) - xyz(tess(:,2),:)) * [0 1;-1 0];
    
    % Any degenerate edges?
    del = sqrt(sum(nrmls.^2,2));
    degenflag = (del<(max(del)*10*eps));
    if sum(degenflag)>0
      warning('inhull:degeneracy',[num2str(sum(degenflag)), ...
        ' degenerate edges identified in the convex hull'])
      
      % we need to delete those degenerate normal vectors
      nrmls(degenflag,:) = [];
      nt = size(nrmls,1);
    end
  case 3
    % use vectorized cross product for 3-d
    ab = xyz(tess(:,1),:) - xyz(tess(:,2),:);
    ac = xyz(tess(:,1),:) - xyz(tess(:,3),:);
    nrmls = cross(ab,ac,2);
    degenflag = false(nt,1);
  otherwise
    % slightly more work in higher dimensions, 
    nrmls = zeros(nt,p);
    degenflag = false(nt,1);
    for i = 1:nt
      % just in case of a degeneracy
      % Note that bsxfun COULD be used in this line, but I have chosen to
      % not do so to maintain compatibility. This code is still used by
      % users of older releases.
      %  nullsp = null(bsxfun(@minus,xyz(tess(i,2:end),:),xyz(tess(i,1),:)))';
      nullsp = null(xyz(tess(i,2:end),:) - repmat(xyz(tess(i,1),:),p-1,1))';
      if size(nullsp,1)>1
        degenflag(i) = true;
        nrmls(i,:) = NaN;
      else
        nrmls(i,:) = nullsp;
      end
    end
    if sum(degenflag)>0
      warning('inhull:degeneracy',[num2str(sum(degenflag)), ...
        ' degenerate simplexes identified in the convex hull'])
      
      % we need to delete those degenerate normal vectors
      nrmls(degenflag,:) = [];
      nt = size(nrmls,1);
    end
end

% scale normal vectors to unit length
nrmllen = sqrt(sum(nrmls.^2,2));
% again, bsxfun COULD be employed here...
%  nrmls = bsxfun(@times,nrmls,1./nrmllen);
nrmls = nrmls.*repmat(1./nrmllen,1,p);

% center point in the hull
center = mean(xyz,1);

% any point in the plane of each simplex in the convex hull
a = xyz(tess(~degenflag,1),:);

% ensure the normals are pointing inwards
% this line too could employ bsxfun...
%  dp = sum(bsxfun(@minus,center,a).*nrmls,2);
dp = sum((repmat(center,nt,1) - a).*nrmls,2);
k = dp<0;
nrmls(k,:) = -nrmls(k,:);

% We want to test if:  dot((x - a),N) >= 0
% If so for all faces of the hull, then x is inside
% the hull. Change this to dot(x,N) >= dot(a,N)
aN = sum(nrmls.*a,2);

% test, be careful in case there are many points
in = false(n,1);

% if n is too large, we need to worry about the
% dot product grabbing huge chunks of memory.
memblock = 1e6;
blocks = max(1,floor(n/(memblock/nt)));
aNr = repmat(aN,1,length(1:blocks:n));
for i = 1:blocks
   j = i:blocks:n;
   if size(aNr,2) ~= length(j)
      aNr = repmat(aN,1,length(j));
   end
   in(j) = all((nrmls*testpts(j,:)' - aNr) >= -tol,1)';
end

end

