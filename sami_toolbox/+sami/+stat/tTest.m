function results = tTest(d,type,m)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 03/2021

%% define default behavior
if ~exist('m','var') || isempty(m), m = 0; end

%% perform appropriate t-test, as specified by 'type'
switch type
    case 'one_sample'
        % naming t-Test results
        results.test = 'one-sample t-Test';
        
        % t-Test
        [~,tt.p,tt.ci,tt.stats] = ttest(d,m);
        
        % bonferonni correction of p-values
        if size(d,2) > 1
            results.info = ['p values bonferonni corrected by ' num2str(size(d,2)) ' indepedent tests'];
            tt.p = tt.p .* size(d,2);
        end
        
        % calculate cohen's d
        cd = abs( mean(d)-m ) ./ std(d);
        
        % plot asterisks if sign. difference from 'm'
        sami.fig.drawSigAsterisks(1:size(d,2),tt.p);
        
        % draw line, if tested against ~=0
        sami.fig.drawRefenceTestLine(m);
        
    case 'two_sample'
        % naming t-Test results
        results.test = 'two-sample t-Test';
        
        % t-Test
        [~,tt.p,tt.ci,tt.stats] = ttest2(d(:,1),d(:,2));
        
        % calculate cohen's d
        SDp = sqrt((std(d(:,1))^2+std(d(:,2))^2)/2);
        cd = abs(diff(mean(d))) / SDp;
        
        % plot horizontal sign. lines if sign. pairwise comparisons exist
        sami.fig.drawSigLines([1 2],tt.p);
        
    case 'paired'
        % naming t-Test results
        results.test = 'paired t-Test';
        
        % t-Test
        [~,tt.p,tt.ci,tt.stats] = ttest(d(:,1),d(:,2));
        
        % calculate cohen's d
        D = d(:,1) - d(:,2);
        cd = mean(D) / std(D);
        
        % plot horizontal sign. lines if sign. pairwise comparisons exist
        sami.fig.drawSigLines([1 2],tt.p)
        
    otherwise
        error('*** sami:ERROR *** t-test ''type'' is not specified correctly. Please check input. returning.');
end

%% sorting/saving results into output variable
results.S = 't';
results.V = tt.stats.tstat;
results.df = tt.stats.df;
results.p = tt.p;
results.d = cd;
results.ci = tt.ci;
results.stats = tt.stats;

end
