function pCorr = bonf(p)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 09/2020

nTests = size(p,1);
pCorr = max(p .* nTests,1);

end

