function bootstrapRs = bootstrapRDMs(bootstrappableRefRDMs, featRDMs, userOptions)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

% Sort out defaults
userOptions = sami.util.setIfUnset(userOptions, 'rdms_nBootstrap', 1000);
userOptions = sami.util.setIfUnset(userOptions, 'rdms_pairWiseCorr', 'Kendall_taua');

% Constants
nBS = userOptions.rdms_nBootstrap;
nConditions = size(bootstrappableRefRDMs, 1);
nSubjects = size(bootstrappableRefRDMs, 3);
nFeatRDMs = size(featRDMs, 3);

if ~(size(bootstrappableRefRDMs, 1) == size(featRDMs, 1))
    error('bootstrapRDMComparison:DifferentSizedRDMs', 'Two RDMs being compared are of different sizes. This is incompatible with bootstrap methods!');
end

fprintf(['     -> resampling ''conditions'' ' num2str(nBS) ' times: 0%%']);
tic;

% Come up with the random samples (with replacement)
resampledConditionIs = ceil(nConditions * rand(nBS, nConditions));

% Preallocation
bootstrapRs = nan(nFeatRDMs, nBS);

% replace the diagonals for each instance of the candidate RDMs with NaN entries
for subI = 1:nSubjects
    temp = bootstrappableRefRDMs(:,:,subI);
    temp(logical(eye(size(temp,1)))) = nan;
    bootstrappableRefRDMs(:,:,subI) = temp;
end

% Need to create one candidate RDM for each reference because we don't want
% to correlate averaged RDMs.
candRDMs3rd = cell(nFeatRDMs, 1);
for candRDMI = 1:nFeatRDMs
    candRDMs3rd{candRDMI} = repmat(featRDMs(:,:,candRDMI), ...
        [1, 1, nSubjects]);
end

% Bootstrap
for b = 1:nBS
    for candRDMI = 1:nFeatRDMs
        localReferenceRDMs = bootstrappableRefRDMs(resampledConditionIs(b,:),resampledConditionIs(b,:),:);
        localTestRDM = candRDMs3rd{candRDMI}(resampledConditionIs(b,:), resampledConditionIs(b,:), :);

        if isequal(userOptions.rdms_pairWiseCorr,'Kendall_taua')
            bootstrapRs(candRDMI, b) = mean(diag(sami.stat.rankCorr_Kendall_taua(squeeze(sami.rdm.vectorizeRDMs(localReferenceRDMs)),squeeze(sami.rdm.vectorizeRDMs(localTestRDM)))));
        else
            c1 = squeeze(sami.rdm.vectorizeRDMs(localReferenceRDMs));
            c2 = squeeze(sami.rdm.vectorizeRDMs(localTestRDM));
            tmp = corr(c1, c2, 'type',userOptions.rdms_pairWiseCorr,'rows','pairwise');
            bootstrapRs(candRDMI, b) = mean(diag( tmp ));
        end
    end
    
    if mod(b,nBS/100) == 0
        perc = round(b / nBS * 100);
        fprintf([repmat('\b',1,numel(num2str(perc-1)) + 1) '%d%%'],perc);
    end
end

t = toc;
fprintf([' ... DONE [in ' num2str(ceil(t)) 's]\n']);
end
