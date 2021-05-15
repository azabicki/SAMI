function  [binRDM, nCatCrossingsRDM] = categoricalRDM(categoryVectors, figI, monitor)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

import sami.*
import sami.fig.*
import sami.rdm.*
import sami.util.*

%% preparations
if ~exist('monitor','var'), monitor = false; end
if ~exist('figI','var') || isempty(figI), figI = sami.util.getFigI(); end
if min(size(categoryVectors)) == 1, categoryVectors = categoryVectors(:); end

[nCond, nCats] = size(categoryVectors);

%% count category crossings for each pair of conditions
nCatCrossingsRDM = zeros(nCond,nCond);

for catI=1:nCats
    cCatBinRDM = repmat(categoryVectors(:,catI),[1 nCond]) ~= repmat(categoryVectors(:,catI)',[nCond 1]);
    nCatCrossingsRDM = nCatCrossingsRDM + cCatBinRDM;
end

binRDM = double(logical(nCatCrossingsRDM));

%% visualise
if monitor
    plotRDMs(concatRDMs(binRDM,nCatCrossingsRDM),figI);
end


end%function
