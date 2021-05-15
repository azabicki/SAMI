function results = KruskalWallis(d,CorrMethod,alpha)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

% KruskalWallis
[KW.p,KW.tbl,KW.stats] = kruskalwallis(d,[],'off');
KW.comp = multcompare(KW.stats,'display','off','ctype',CorrMethod,'alpha',alpha);

% plot horizontal sign. lines if sign. pairwise comparisons exist
sami.fig.drawSigLines(KW.comp(:,1:2),KW.comp(:,6))

% calculate effect size 
etaSq = (KW.tbl{2,5} - size(d,2) + 1) / (numel(d) - size(d,2));

% sorting ANOVA results
results.test = 'Kruskal-Wallis';
results.S = 'H';
results.V = KW.tbl{2,5};
results.df = KW.tbl{2,3};
results.p = KW.tbl{2,6};
results.etaSq = etaSq;

results.tbl = KW.tbl;
results.multComp = KW.comp;

end