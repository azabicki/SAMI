function results = rmANOVA(d,CorrMethod,alpha)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

% prepare rmANOVA
design = '';
for i = 1:size(d,2)
    design = [design 'd' num2str(i) ',']; %#ok<AGROW>
end
design = [design(1:end-1) '~1'];
condT = table((1:size(d,2))','VariableNames',{'Conditions'});

% fit the repeated measures model
rmModel = fitrm(array2table(d),design,'WithinDesign',condT);

% get results for rmANOVA + post-hoc pairwise comparisons
[aR,~,cMat] = ranova(rmModel);
posthoc = multcompare(rmModel,'Conditions','ComparisonType',CorrMethod,'alpha',alpha);

% calculate partial eta^2
aR.pEtaSq(1) = aR.SumSq(1)/sum(aR.SumSq(1:2));

% calculat mauchly test + epsilon and add to anova table
res_mauchly = mauchly(rmModel,cMat);
res_epsilon = epsilon(rmModel,cMat);

aR.mauchlyChiSq(1) = res_mauchly.ChiStat;
aR.mauchlyDF(1) = res_mauchly.DF;
aR.mauchlyPvalue(1) = res_mauchly.pValue;
aR.epsilonGG = reshape(repmat(res_epsilon.GreenhouseGeisser',[2 1]),numel(res_epsilon.GreenhouseGeisser)*2,1);
aR.epsilonHF = reshape(repmat(res_epsilon.HuynhFeldt',[2 1]),numel(res_epsilon.HuynhFeldt)*2,1);

% adjust degrees of freedom 
aR.dfGG = aR.DF .* aR.epsilonGG;
aR.dfHF = aR.DF .* aR.epsilonHF;

% decide if, and which, correction will be used, according to Girden (1992)
if aR.mauchlyPvalue(1) > 0.05
    aR.correction{1} = 'none';
elseif aR.epsilonGG(1) > .75
    aR.correction{1} = 'HF';
else
    aR.correction{1} = 'GG';
end

% plot horizontal sign. lines if sign. pairwise comparisons exist
ph_index = diff([posthoc.Conditions_1,posthoc.Conditions_2],[],2) > 0;
sami.fig.drawSigLines([posthoc.Conditions_1(ph_index),posthoc.Conditions_2(ph_index)],posthoc.pValue(ph_index));

% sorting rmANOVA results, depending on sphericity
results.test = 'rmANOVA';
switch aR.correction{1}
    case 'none'
        results.info = sprintf('no correction <- Mauchly: chi^2(%d) = %.2f, %s',...
                                        aR.mauchlyDF(1),...
                                        aR.mauchlyChiSq(1),...
                                        sami.util.getPString(aR.mauchlyPvalue(1)));
        results.S = 'F';
        results.V = aR.F(1);
        results.df1 = aR.DF(1);
        results.df2 = aR.DF(2);
        results.p = aR.pValue(1);
        
    case 'GG'
        results.info = sprintf('Greenhouse-Geisser correction <- Mauchly: chi^2(%d) = %.2f, %s, epsilon = %.3f',...
                                        aR.mauchlyDF(1),...
                                        aR.mauchlyChiSq(1),...
                                        sami.util.getPString(aR.mauchlyPvalue(1)),...
                                        aR.epsilonGG(1));
        results.S = 'F';
        results.V = aR.F(1);
        results.df1 = aR.dfGG(1);
        results.df2 = aR.dfGG(2);
        results.p = aR.pValueGG(1);
        
    case 'HF'
        results.info = sprintf('Huyn-Feldt correction <- Mauchly: chi^2(%d) = %.2f, %s, epsilon = %.3f',...
                                        aR.mauchlyDF(1),...
                                        aR.mauchlyChiSq(1),...
                                        sami.util.getPString(aR.mauchlyPvalue(1)),...
                                        aR.epsilonGG(1));
        results.S = 'F';
        results.V = aR.F(1);
        results.df1 = aR.dfHF(1);
        results.df2 = aR.dfHF(2);
        results.p = aR.pValueHF(1);
        
end
results.pEtaSq = aR.pEtaSq(1);

% store anova- and multCompare-tables
results.tbl = aR;
results.multComp = posthoc;

end
