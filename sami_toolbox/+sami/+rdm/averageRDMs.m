function avgRDM = averageRDMs(RDMs,new_name,new_color)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

%% preparations
if ~exist('new_name','var') || isempty(new_name), new_name = 'averageRDM'; end
if ~exist('new_color','var') || isempty(new_color), new_color = RDMs(1).color; end

%% init
n = numel(RDMs);
suSum = nan(size(RDMs(1).RDM,1),size(RDMs(1).RDM,1),n);

%% average
% for su = 1:n
%     if su == 1
%         suSum = RDMs(su).RDM;
%     else
%         suSum = suSum + RDMs(su).RDM;
%     end%if:su==1
% end%for:su
% 
% avgRDM.RDM = suSum ./ n;

for su = 1:n
    suSum(:,:,su) = RDMs(su).RDM;
end
avgRDM.RDM = nanmean(suSum,3);

avgRDM.name = new_name;
avgRDM.color = new_color;

end

