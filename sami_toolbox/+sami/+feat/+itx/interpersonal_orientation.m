function results = interpersonal_orientation(data)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

%% init vars
timesteps = size(data.marker,1);
IPO_p1_p2 = zeros(timesteps,1);   % if p1 toward p2
IPO_p2_p1 = zeros(timesteps,1);   % if p2 toward p1

%% use this markers
marker = {'LSHO', 'RSHO'};
marker_idx_p1 = [find(strcmp(data.labels, ['p1' marker{1}])), find(strcmp(data.labels, ['p1' marker{2}]))];
marker_idx_p2 = [find(strcmp(data.labels, ['p2' marker{1}])), find(strcmp(data.labels, ['p2' marker{2}]))];

%% TIME loop
for t = 1:timesteps
    % get coordinates of each marker
    r_p1_ls = permute( data.marker(t,marker_idx_p1(1),1:2) ,[3 1 2]);
    r_p1_rs = permute( data.marker(t,marker_idx_p1(2),1:2) ,[3 1 2]);
    r_p2_ls = permute( data.marker(t,marker_idx_p2(1),1:2) ,[3 1 2]);
    r_p2_rs = permute( data.marker(t,marker_idx_p2(2),1:2) ,[3 1 2]);
    
    r_p1_mdp = [mean([r_p1_ls(1) r_p1_rs(1)]); mean([r_p1_ls(2) r_p1_rs(2)])];
    r_p2_mdp = [mean([r_p2_ls(1) r_p2_rs(1)]); mean([r_p2_ls(2) r_p2_rs(2)])];
    
    % get max dist between all shoulder markers
    dist(1) = pdist([r_p1_ls, r_p2_ls]','euclidean');
    dist(2) = pdist([r_p1_ls, r_p2_rs]','euclidean');
    dist(3) = pdist([r_p1_rs, r_p2_ls]','euclidean');
    dist(4) = pdist([r_p1_rs, r_p2_rs]','euclidean');
    dist = max(dist);
    
    % calc pointing vector as normal_vector between shoulders
    v_p1_lr = r_p1_rs - r_p1_ls;
    v_p2_lr = r_p2_rs - r_p2_ls;
    
    v_p1_lr_k = norm( v_p1_lr);         % k ~ k times n_vector is lenght of shoulder
    v_p1_lr_n = v_p1_lr ./ v_p1_lr_k;   % n ~ norm (einheitsvektor)
    v_p2_lr_k = norm( v_p2_lr);
    v_p2_lr_n = v_p2_lr ./ v_p2_lr_k;
    
    % orthogonal vector, pointing forward
    v_p1_f_n = (v_p1_lr_n' * [cosd(-90) -sind(-90); sind(-90) cosd(-90)])';
    v_p2_f_n = (v_p2_lr_n' * [cosd(-90) -sind(-90); sind(-90) cosd(-90)])';
    v_p1_f = v_p1_f_n * dist * 1.1;
    v_p2_f = v_p2_f_n * dist * 1.1;
    
    % check if persons are oriented towards each other
    d_p1_ls_p2 = point_to_line(r_p2_mdp, r_p1_ls, r_p1_ls+v_p1_f);
    d_p1_rs_p2 = point_to_line(r_p2_mdp, r_p1_rs, r_p1_rs+v_p1_f);
    d_p2_ls_p1 = point_to_line(r_p1_mdp, r_p2_ls, r_p2_ls+v_p2_f);
    d_p2_rs_p1 = point_to_line(r_p1_mdp, r_p2_rs, r_p2_rs+v_p2_f);
    
    % if p1 toward p2
    if (d_p1_ls_p2 <= v_p1_lr_k) && (d_p1_rs_p2 <= v_p1_lr_k)
        IPO_p1_p2(t) = 1;
    end
    
    % if p2 toward p1
    if (d_p2_ls_p1 <= v_p2_lr_k) && (d_p2_rs_p1 <= v_p2_lr_k)
        IPO_p2_p1(t) = 1;
    end
end % end TIMESTEPS loop

% average across time
IPO_pp(1) = nanmean(IPO_p1_p2) * 100;
IPO_pp(2) = nanmean(IPO_p2_p1) * 100;

% average IPO across persons
IPO_mean = mean(IPO_pp);

% balance of IPO between persons
IPO_balance = 1 - abs(diff(IPO_pp)) / sum(IPO_pp);

% catch case when both persons never look at each other
if isnan(IPO_balance)
    IPO_balance = 0;
end

%% Results
results(1).feat = IPO_mean;
results(1).name = 'IP_orientation_average';
results(1).color = [0 .8 .6];
results(1).unit = '%';

results(2).feat = IPO_balance;
results(2).name = 'IP_orientation_balance';
results(2).color = [0 .8 .6];
results(2).unit = 'AU';

end


function d = point_to_line(pt, v1, v2)
pt(3) = 0;
v1(3) = 0;
v2(3) = 0;

a = v1 - v2;
b = pt - v2;
d = norm(cross(a,b)) / norm(a);
end
