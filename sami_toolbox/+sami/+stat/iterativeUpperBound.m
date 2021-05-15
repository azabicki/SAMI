function ceiling_upperBound = iterativeUpperBound(refRDMs, bestFitRDM, meanRDM_avgCorr, monitor)
% Iterative approach to optimise the estimate by searching an RDM that yields a higher
% average tau a correlation with the single-subject RDMs.
% 
% Iterations stops and returns best estimate of the upper bound, when A) convergence criteria
% are fulfilled, or B) maxIter are reached 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 09/2020


%% preparations
if ~exist('monitor','var'), monitor = false; end
[~, nDiss, nSubj] = size(refRDMs);

%% find best-fit RDM by gradient descent to estimate upper bound for ceiling
fprintf('     -> iterative optimisation of the upper bound... of max. iterations: 0%%');
tic;
nExploredDirections = 50;
maxIter = 100;

stepSize = 1/nSubj/10;
bestFitRDMcorrHistory = nan(maxIter,1);

if monitor
    propOfSuccessSamplesHistory = nan(maxIter,1);
    propOfStationSamplesHistory = nan(maxIter,1);
    stepSizeHistory = nan(maxIter,1);
end

convergenceZoneLength = 10;
convergenceStdThreshold = 0.000001;
converged = false;

nImproved = 0;
iter = 0;

while true
    iter = iter + 1;
    if mod(iter,maxIter/100) == 0
        perc = round(iter / maxIter * 100);
        fprintf([repmat('\b',1,numel(num2str(perc-1)) + 1) '%d%%'], perc);
    end
        
    % create RANDOM candidate RDMs
    candRDMs = repmat(bestFitRDM,[1 1 nExploredDirections])+stepSize*randn(1,nDiss,nExploredDirections);
    candRDMs = cat(3,candRDMs,bestFitRDM); % the last one is the current best-fit RDM
    
    % calculate correlations for each candidate RDM
    RDMcorrs = nan(nExploredDirections,nSubj);
    for iSubj = 1:nSubj
        for directionI = 1:nExploredDirections+1
            RDMcorrs(directionI,iSubj) = sami.stat.rankCorr_Kendall_taua(candRDMs(1,:,directionI),refRDMs(1,:,iSubj));
        end
    end
    currBestFitRDMcorr = mean(RDMcorrs(end,:),2);
    candRDMcorrs = mean(RDMcorrs(1:end-1,:),2);
    bestFitRDMcorrHistory(iter) = currBestFitRDMcorr;

    % test for convergence
    if iter >= convergenceZoneLength && std(bestFitRDMcorrHistory(iter-convergenceZoneLength+1:iter)) < convergenceStdThreshold
        converged = true;
    end
    
    % visualise
    if monitor && (mod(iter,2) == 0 || converged || iter >= maxIter)
        h=figure(400); set(h,'Color','w'); clf;
        
        subplot(3,1,1); hold on;
        plot([1 iter],[meanRDM_avgCorr meanRDM_avgCorr],'-k','LineWidth',5);
        plot(bestFitRDMcorrHistory(1:iter),'r','LineWidth',2); 
        xlabel('time step'); ylabel('current best-fit RDM''s average corr. to ref. RDM estimates','LineWidth',2);
        legend('mean-RDM avg. corr.','optimised-RDM avg. corr.','Location','SouthEast');
        title(['current best-fit RDM''s average Kendall_taua correlation to the RDM estimates: ',num2str(currBestFitRDMcorr)]);
        
        subplot(3,2,3); plot(stepSizeHistory(1:iter),'LineWidth',3); xlabel('iteration'); ylabel('step size');
        subplot(3,2,4); hold on;
        plot(propOfSuccessSamplesHistory(1:iter),'r','LineWidth',4); xlabel('iteration');
        plot(propOfStationSamplesHistory(1:iter),'b','LineWidth',2); 
        xlabel('iteration'); ylabel('proportions of samples');
        legend('successful','stationary','Location','NorthEast');
        
        subplot(3,2,5); hold on; 
        image(squareform(bestFitRDM),'CDataMapping','scaled','AlphaData',~isnan(squareform(bestFitRDM)));
        colormap(gca, sami.fig.createColormap('RDMs'));
        set(gca,'XTick',[],'YTick',[]);
        title('current best-fit RDM');
        axis square off;
        drawnow;
    end
    
    % break if converged or time out or subject pressed 'p' for 'proceed'
    if converged
        t = toc;
        fprintf('\n       -> converged + upper bound improved %d times... DONE [in %ds]\n', nImproved, ceil(t))
        break; 
    end
    
    if iter >= maxIter
        t = toc;
        warning(['       >>> WARNING <<< noiseCeilingOfAvgRDMcorr: iterative ceiling estimation procedure did not converge [within ' num2str(t) 's].']);
        break;
    end
   
    % check if any of the explored direction led to an improvement
    avgRDMcorrDiffs = candRDMcorrs - currBestFitRDMcorr;
    
    [mxImprovement, mxImprovementI] = max(avgRDMcorrDiffs);
    if mxImprovement > 0
        bestFitRDM = candRDMs(1,:,mxImprovementI);
        nImproved = nImproved  + 1;
    end
    
    if monitor
        propOfSuccessSamplesHistory(iter) = sum(avgRDMcorrDiffs > 0) / nExploredDirections;
        propOfStationSamplesHistory(iter) = sum(avgRDMcorrDiffs == 0) / nExploredDirections;
        stepSizeHistory(iter) = stepSize;
    end
    
    if 0.3 < sum(avgRDMcorrDiffs > 0) / nExploredDirections || 0.1 < sum(avgRDMcorrDiffs == 0) / nExploredDirections
        % more than 30% of our samples improve the fit or more than 10% of our samples are
        % on a local plateau, either way: take bigger steps
        stepSize = stepSize*(2^(1/2)); % move faster
    elseif sum(avgRDMcorrDiffs > 0) / nExploredDirections < 0.1
        % less than 10% of the explored directions improve the fit (and we're not on a plateau). 
        % might be close to the peak, where every way is down, so look more locally.
        stepSize = stepSize/(2^(1/2)); % move slower
    end
end % while true

% define ceiling upper bound
ceiling_upperBound = currBestFitRDMcorr;

end

