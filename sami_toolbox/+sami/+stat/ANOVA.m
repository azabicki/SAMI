function results = ANOVA(d,CorrMethod,alpha)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

% ANOVA
[aR.p,aR.tbl,aR.stats] = anova1(d,[],'off');
aR.comp = multcompare(aR.stats,'display','off','ctype',CorrMethod,'alpha',alpha);

% plot horizontal sign. lines if sign. pairwise comparisons exist
sami.fig.drawSigLines(aR.comp(:,1:2),aR.comp(:,6))

% calculate eta^2
etaSq = aR.tbl{2,2} / aR.tbl{4, 2};

% sorting ANOVA results
results.test = 'ANOVA';
results.S = 'F';
results.V = aR.tbl{2,5};
results.df1 = aR.tbl{2,3};
results.df2 = aR.tbl{3,3};
results.p = aR.tbl{2,6};
results.etaSq = etaSq;

% store anova- and multCompare-tables
results.tbl = aR.tbl;
results.multComp = aR.comp;

end
