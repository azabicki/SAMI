function pCorr = holm(p)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

[numtests, nS] = size(p);
pCorr = nan(size(p));

% loop samples
for i = 1:nS    
    % next we will calculate the p value using the homls method.
    [psorted, idx_p] = sort(p(:,i));
    
    p_holm_sorted = zeros(numtests,1);
    p_holm_sorted(1,1) = numtests*psorted(1,1);
    for j=2:numtests
        p_holm_sorted(j,1) = (numtests-j+1)*psorted(j,1);
%         p_holm_sorted(j,1) = max(p_holm_sorted(j-1,1), (numtests-j+1)*psorted(j,1));
    end
    
    p_holm_sorted(:,1) = min(p_holm_sorted(:,1),1);
    for j=1:numtests
        pCorr(j,i) = p_holm_sorted(idx_p==j,1);
    end
end

% p_holm_sorted(idx_p)

end
