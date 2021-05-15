function [ceiling_upperBound, ceiling_lowerBound, bestFitRDM] = noiseCeilingOfAvgRDMcorr(refRDMs, corrType)
% This function estimates the lower and upper bounds of the noise ceilling, i.e. the 
% heighest average RDM correlation, across a given set of reference RDMs [refRDMs], a true
% model's RDM prediction could achieve, depending on the variability of the reference RDMs.
% 
% The lower bound is estimated via a leave-one-subject-out crossvalidation procedure.
% 
% The upper bound is estimated, depending on the type of correlation, by finding the 
% hypothetical model RDM, that maximises the average correlation to the reference RDMs.
% 
% For further information and a more detailed explanation please see:
%   Nili H, et al., (2014) A Toolbox for Representational Similarity Analysis. 
%   PLoS Comput Biol 10(4): e1003553. https://doi.org/10.1371/journal.pcbi.1003553 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 09/2020


%% preparations
if ~exist('corrType','var'), corrType = 'Kendall_taua'; end
monitor_itUpperBound = false;

disp('   -> Estimating the ceiling for the average RDM correlation...');

refRDMs = sami.rdm.vectorizeRDMs(sami.rdm.unwrapRDMs(refRDMs));
[~, nDiss, nSubj] = size(refRDMs);

%% compute the upper bound for the ceiling
switch  corrType
    case 'Pearson'
        % Pearson correlation distance = const * Euclidean dist. squared in z-transformed 
        % RDM space. Thus, z-transform RDMs to make the mean RDM minimise the average 
        % correlation distance to the single-subject RDMs.
        refRDMs = refRDMs - repmat(mean(refRDMs,2),[1 nDiss 1]);
        refRDMs = refRDMs ./ repmat(std(refRDMs,[],2),[1 nDiss 1]);
        bestFitRDM = mean(refRDMs,3);
        
    case 'Spearman'
        % Spearman correlation distance = const * Euclidean dist squares in rank-transformed 
        % RDM space. Thus, rank-transform RDMs to make the mean RDM minimise the average 
        % correlation distance to the single-subject RDMs.
        refRDMs = reshape( tiedrank( reshape(refRDMs,[nDiss nSubj]) ) ,[1 nDiss nSubj]);
        bestFitRDM = mean(refRDMs,3);
        
    case 'Kendall_taua'
        % No closed-form solution providing a tight upper bound for the ceiling (to our 
        % knowledge), so initialise with the mean of the rank-transformed RDMs and 
        % optimise iteratively. 
        refRDMs = reshape( tiedrank( reshape(refRDMs,[nDiss nSubj]) ) ,[1 nDiss nSubj]);
        bestFitRDM = mean(refRDMs,3);
end    

%% estimate lower bound on the ceiling
LOSOcorrs = nan(nSubj,1);
for iSubj = 1:nSubj
    currSubjRDM = refRDMs(:,:,iSubj);
    
    LOSOrefRDMs = refRDMs;
    LOSOrefRDMs(:,:,iSubj) = [];
    avgLOSORefRDM = nanmean(LOSOrefRDMs,3);

    LOSOcorrs(iSubj) = correlation(currSubjRDM,avgLOSORefRDM,corrType);
end
ceiling_lowerBound = mean(LOSOcorrs);

%% estimate the upper bound on the ceiling
    avgRDM_corrs = nan(nSubj,1);
    for iSubj = 1:nSubj
        avgRDM_corrs(iSubj) = correlation(bestFitRDM,refRDMs(1,:,iSubj),corrType);
    end
if isequal(corrType,'Pearson') || isequal(corrType,'Spearman')
    ceiling_upperBound = mean(avgRDM_corrs);
    
elseif isequal(corrType,'Kendall_taua')
    ceiling_upperBound = sami.stat.iterativeUpperBound(refRDMs, bestFitRDM, mean(avgRDM_corrs), monitor_itUpperBound);
end

end % noise_ceiling_function

%% compute correlations of all types
function r = correlation(a,b,corrType)
    switch corrType
        case 'Kendall_taua'
            r = sami.stat.rankCorr_Kendall_taua(a(:),b(:));
        otherwise
            r = corr(a(:),b(:),'type',corrType);
    end
end