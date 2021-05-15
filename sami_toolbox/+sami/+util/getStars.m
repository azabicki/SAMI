function stars = getStars(p,depth)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 09/2020

if ~exist('depth','var') || isempty(depth), depth = 3; end

stars = '';

if p < 0.0001 && depth >= 4
    stars = '****';
elseif p < 0.001 && depth >= 3
    stars = '***';
elseif p < 0.01 && depth >= 2
    stars = '**';
elseif p < 0.05
    stars = '*';
end

end

