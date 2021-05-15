function p = relRank(null,value)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 09/2020

null = [null(:); value];
p = sum( null(:) < value ) / numel(null);

end
