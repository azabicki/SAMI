function pCorr = multipleTesting(input,mtMethod,alpha)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 09/2020

if ~exist('alpha','var') || isempty(alpha), alpha = 0.05; end

pCorr = nan(size(input));

% loop columns
[~, nCols] = size(input);
for c = 1:nCols
    p = input(:,c);
    
    switch mtMethod
        case 'none'
            pCorr(:,c) = p;
        case 'bonf'
            pCorr(:,c) = sami.stat.bonf(p);
        case 'holm'
            pCorr(:,c) = sami.stat.holm(p);
        case 'FDR'
            pCorr(:,c) = sami.stat.FDR(p,alpha);
            
        otherwise
            pCorr = input;
            warning('multipleTesting:unknownMethod', 'Please set multiple testing method to "bonf", "holm", "FDR" or "none". Now, "none" correction will be done!!!'); 
            return;
    end
end
end
