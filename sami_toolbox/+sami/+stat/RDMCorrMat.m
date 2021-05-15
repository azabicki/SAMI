function [corrMat, pValMat] = RDMCorrMat(RDMs,type)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020


if ~exist('type','var') || isempty(type), type = 'Spearman'; end

nRDMs = size(RDMs,2);
RDMs_cols = sami.rdm.unwrapRDMs(sami.rdm.vectorizeRDMs(RDMs));
RDMs_cols = permute(RDMs_cols,[2 3 1]);

% For each pair of RDMs, ignore missing data only for this pair of RDMs
% (unlike just using corr, which would ignore it if ANY RDM had missing
% data at this point).
corrMat = nan(nRDMs);
pValMat = nan(nRDMs);
for iRDM = 1:nRDMs
    for jRDM = 1 : nRDMs
        if isequal(type,'Kendall_taua')
            [corrMat(iRDM,jRDM),pValMat(iRDM,jRDM)] = sami.stat.rankCorr_Kendall_taua(RDMs_cols(:,iRDM), RDMs_cols(:,jRDM));
        else
            [corrMat(iRDM,jRDM),pValMat(iRDM,jRDM)] = corr(RDMs_cols(:,iRDM), RDMs_cols(:,jRDM), 'type', type, 'rows', 'complete');
        end
    end
end

corrMat(logical(eye(nRDMs))) = 1; % make the diagonal artificially one

end
