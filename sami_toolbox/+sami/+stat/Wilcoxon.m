function results = Wilcoxon(d,type,m)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 03/2021

%% define default behavior
if ~exist('m','var') || isempty(m), m = 0; end

%% perform appropriate Wilcoxon, as specified by 'type'
switch type
    case 'one_sample'
        % naming t-Test results
        results.test = 'one-sample Wilcoxon signed rank test';
        
        % Wilcoxon test
        for i=1:size(d,2)
            [WX.p(i),~,WX.stats(i)] = signrank(d(:,i),m);
            
            % calculate effect size as matched rank-biserial correlation
            dDiff = d(:,i) - m;
            
            epsdiff = eps(d(:,i));
            t = (abs(dDiff) <= epsdiff);
            dDiff(t) = [];
            epsdiff(t) = [];
        
            tr = tiedrank(abs(dDiff),0,0,epsdiff);
            W(1) = sum(tr(dDiff>0));
            W(2) = sum(tr(dDiff<0));
            
            n = size(dDiff,1);
            WX.r(i) = 4 * abs( min(W) - mean(W) ) / (n*(n+1));
        end
        
        % bonferonni correction of p-values
        if size(d,2) > 1
            results.info = ['p values bonferonni corrected by ' num2str(size(d,2)) ' indepedent tests'];
            WX.p = WX.p .* size(d,2);
        end
        
        % draw line, if tested against ~=0
        sami.fig.drawRefenceTestLine(m);
        
        % plot asterisks if sign. difference from 'm'
        sami.fig.drawSigAsterisks(1:size(d,2),WX.p);
        
    case 'two_sample'
        % naming t-Test results
        results.test = 'Wilcoxon rank sum test';

        % two-sided Wilcoxon rank sum test for independant samples
        [WX.p,~,WX.stats] = ranksum(d(:,1),d(:,2));
        
        % calculate effect size as rank biserial correlation
        n = size(d,1);
        tdrnk = tiedrank(d(:));       
        WX.r = 2*(mean(tdrnk(1:n))-mean(tdrnk(n+1:end))) / numel(d);
                
        % plot horizontal sign. lines if sign. pairwise comparisons exist
        sami.fig.drawSigLines([1 2],WX.p);
        
    case 'paired'
        % naming t-Test results
        results.test = 'paired two-sample Wilcoxon signed rank test';
        
        % Wilcoxon test
        [WX.p,~,WX.stats] = signrank(d(:,1),d(:,2));
        
        % calculate effect size as matched rank-biserial correlation
        dDiff = d(:,1)-d(:,2);
        
        epsdiff = eps(d(:,1)) + eps(d(:,2));
        t = (abs(dDiff) <= epsdiff);
        dDiff(t) = [];
        epsdiff(t) = [];
        
        tr = tiedrank(abs(dDiff),0,0,epsdiff);
        W(1) = sum(tr(dDiff>0));
        W(2) = sum(tr(dDiff<0));
        
        n = size(dDiff,1);
        WX.r = 4 * (min(W) - mean(W)) / (n*(n+1));
        
        % correct sign of r
        WX.r = WX.r .* sign(diff(W));
        
        %-------- to compare with JASP results, which makes some rounding errors ---------
%         dDiff = diff(round(d,3),[],2);
%         
%         t = (abs(dDiff) == 0);
%         dDiff(t) = [];
%         
%         tr = tiedrank(abs(dDiff));
%         W(1) = sum(tr(dDiff<0));
%         W(2) = sum(tr(dDiff>0));
%         
%         n = size(dDiff,1);
%         WX.r_JASP = 4 * ( min(W) - mean(W) ) / (n*(n+1));        
        %---------------------------------------------------------------------------------
                
        % plot horizontal sign. lines if sign. pairwise comparisons exist
        sami.fig.drawSigLines([1 2],WX.p)
                
    otherwise
        error('*** sami:ERROR *** Wilcoxon test ''type'' is not specified correctly. Please check input. returning.');
end


%% sorting/saving results into output variable
results.p = WX.p;
results.r = WX.r;
results.stats = WX.stats;

end
