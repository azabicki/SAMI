function figI = getFigI(varargin)
% find figure number (or numbers), which is (are) not in use by any open figure
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

%% init
if isempty(varargin)
    n = 1; 
else
    n = varargin{1};
end

%% get open figs
figHandles = get(groot, 'Children');
if ~isempty(figHandles)
    inUse = [figHandles(:).Number];
else
    inUse = [];
end

%% get fist n possible figNumbers
figI = nan(1,n);
for f = 1:n
    allUsed = [inUse figI(~isnan(figI))];
    
    figI(f) = 1;
    while ~isempty(allUsed) && any(ismember(allUsed,figI(f)))
        figI(f) = figI(f) + 1;
    end
end
end
