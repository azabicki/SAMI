function [taua,pVal] = rankCorr_Kendall_taua(a,b)
% computes the Kendall's tau a correlation coefficient between the input vectors (a and b).
% NaN entries would be removed from both. 
% Also, p-Value is calculated to check for significance.
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 09/2020


%% preparations
a = a(:);
b = b(:);
validEntryIs = ~isnan(a) & ~isnan(b);
a = a(validEntryIs);
b = b(validEntryIs);
n = size(a,1);

%% compute Kendall rank correlation coefficient tau-a
K = 0;
for k = 1:n-1
    pairRelations_a = sign(a(k)-a(k+1:n));
    pairRelations_b = sign(b(k)-b(k+1:n));
    K = K + sum(pairRelations_a .* pairRelations_b);
end
taua = K / (n*(n-1)/2 ); % normalise by the total number of pairs 


%% compute significance (https://www.real-statistics.com/correlation/kendalls-tau-correlation/kendalls-tau-normal-approximation/)
C = nchoosek(n,2);

se = sqrt( (2*n+5)/ C ) / 3;
Z = taua / se;

pVal = normcdf(-abs(Z)) * 2;

%% in case statistics toolbox is missing
% F = @(x)(exp (-0.5*(x.^2))./sqrt (2*pi));
% p = integral (F, abs(Z), 100);
% pVal = 2*p;

end
