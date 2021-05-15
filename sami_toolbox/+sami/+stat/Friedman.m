function results = Friedman(d,CorrMethod,alpha)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

% KruskalWallis
[F.p,F.tbl,F.stats] = friedman(d,1,'off');
F.comp = multcompare(F.stats,'display','off','ctype',CorrMethod,'alpha',alpha);

% plot horizontal sign. lines if sign. pairwise comparisons exist
sami.fig.drawSigLines(F.comp(:,1:2),F.comp(:,6))

% calculate effect size
KendallW = F.tbl{2,5} / (size(d,1) * (size(d,2)-1));

% sorting ANOVA results
results.test = 'Friedman';
results.S = 'Chi^2';
results.V = F.tbl{2,5};
results.df = F.tbl{2,3};
results.p = F.tbl{2,6};
results.KendallW = KendallW;

results.tbl = F.tbl;
results.multComp = F.comp;

end