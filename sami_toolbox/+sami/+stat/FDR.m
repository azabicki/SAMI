function [pCorr, pCrit] = FDR(pVals,alpha)
% 
% 
% 
% References:
%   Benjamini, Y. & Hochberg, Y. (1995) Controlling the false discovery rate: A practical 
%       and powerful approach to multiple testing. Journal of the Royal Statistical 
%       Society, Series B (Methodological). 57(1), 289-300.
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

if nargin < 2
    alpha = .05;
end

% sort p-values 
[pSorted, sortIdx] = sort(pVals);
n = length(pSorted); %number of tests

% BH procedure 
thresh = (1:n)'*alpha/n;
pW = n*pSorted./(1:n)';


% compute adjusted p-values
pCorr = nan(n,1);
[pWsorted, pWindex] = sort(pW);
runI = 1;
for k = 1 : n
    if pWindex(k) >= runI
        pCorr(runI:pWindex(k)) = pWsorted(k);
        runI = pWindex(k)+1;
        if runI > n
            break;
        end
    end
end
pCorr(sortIdx,1) = pCorr;

% find greatest significant pvalue
r = pSorted <= thresh;
maxID = find(r,1,'last');
if isempty(maxID)
    pCrit = 0;
else
    pCrit = pSorted(maxID);
end
