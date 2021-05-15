function [pStr, stars] = getPString(p,depth)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 09/2020

if ~exist('depth','var') || isempty(depth), depth = 3; end

if p < 0.0001 && depth >= 4
    pStr = 'p < .0001';
    stars = '****';
elseif p < 0.001 && depth >= 3
    pStr = 'p < .001';
    stars = '***';
elseif p < 0.01 && depth >= 2
    pStr = 'p < .01';
    stars = '**';
elseif p < 0.05
    pStr = 'p < .05';
    stars = '*';
else
    pStr = sprintf('p = %0.2f', p);
    stars = 'n.s.';
end

end

