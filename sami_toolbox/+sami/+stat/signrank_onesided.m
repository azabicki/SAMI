function p = signrank_onesided(x)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

p_signrank = signrank(x,[],'alpha',0.05,'method','exact');

% correct p value for testing values > 0
if median(x) > 0
     p_signrank = p_signrank/2;
else
    p_signrank = 1-p_signrank/2;
end

p = p_signrank;

end%function
