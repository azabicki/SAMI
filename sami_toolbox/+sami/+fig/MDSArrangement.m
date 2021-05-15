function MDSArrangement(RDM, MDSOptions)
% MDSArrangement(RDM, MDSOptions) 
% 
% draws a multidimensional scaling (MDS) arrangement of colored dots reflecting the 
% dissimilarity structure of the items whose representational dissimilarity matrix is 
% passed in argument RDM. 
%
%   input:
%       - RDM:
%           struct. dissimilarity matrix as a struct RDM, containg 'RDM' and 'name' field.
%   
%       - MDSOpions.fig_display:
%           boolean. 
%           defaults to true.
% 
%       - MDSOpions.figI:
%           double. number of current figure handle. 
%           defaults to "next available number".
% 
%       - MDSOpions._____:
%           boolean. 
%           defaults to true.
% 
%       - MDSOpions._____:
%           boolean. 
%           defaults to true.
% 
%       - MDSOpions._____:
%           boolean. 
%           defaults to true.
% 
%       - MDSOpions._____:
%           boolean. 
%           defaults to true.
% 
%       - MDSOpions._____:
%           boolean. 
%           defaults to true.
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 03/2021


%% define defaults
if ~exist('MDSOptions','var') || isempty(MDSOptions), MDSOptions = struct; end
MDSOptions = sami.util.setIfUnset(MDSOptions, 'fig_display',true);
MDSOptions = sami.util.setIfUnset(MDSOptions, 'figI',sami.util.getFigI());
MDSOptions = sami.util.setIfUnset(MDSOptions, 'MDSCriterion', 'metricstress');
MDSOptions = sami.util.setIfUnset(MDSOptions, 'plotLabels', false);
MDSOptions = sami.util.setIfUnset(MDSOptions, 'plotLegend', false);
MDSOptions = sami.util.setIfUnset(MDSOptions, 'dotSize', 20);
MDSOptions = sami.util.setIfUnset(MDSOptions, 'dotColors', repmat([0 0 0],size(RDM.RDM,1),1));
MDSOptions = sami.util.setIfUnset(MDSOptions, 'fontSize', 9);
MDSOptions = sami.util.setIfUnset(MDSOptions, 'titleString', sami.util.deunderscore(RDM.name));

%% perform multidimensional scaling (MDS)
D = sami.rdm.unwrapRDMs(RDM);
try
    xyCoords = mdscale(D, 2,'criterion',MDSOptions.MDSCriterion, 'options', struct('MaxIter', 100000));
catch
    try
        xyCoords = mdscale(D, 2,'criterion','stress');
        disp(['   -> MDS Info: ' RDM.name ' -> reverted to stress (' MDSOptions.MDSCriterion ' failed)']);
    catch
        try
            D2 = D + 0.2;
            D2(logical(eye(length(D)))) = 0;
            xyCoords = mdscale(D2, 2,'criterion',MDSOptions.MDSCriterion);
            disp(['   -> MDS Info: ' RDM.name ', ' MDSOptions.MDSCriterion ' , added 0.2 to distances to avoid colocalization']);
        catch
            disp(['   -> MDS Info: ' RDM.name ', MDS failed...']);
            return
        end
    end
end

%% plot MDS arrangement using text labels
sami.util.selectPlot(MDSOptions.figI,MDSOptions.fig_display);
set(gcf,'Position',[200 50 750 580]);
hold on;

% plot DOTS
for itemI = 1:size(D,1)
    plot(xyCoords(itemI,1), xyCoords(itemI,2),'o',...
        'MarkerFaceColor',MDSOptions.dotColors(itemI, :),...
        'MarkerEdgeColor','none',...
        'MarkerSize', MDSOptions.dotSize);
end

% fix axis limits for 1-dimensional MDS-plot
axLim = [min(xyCoords(:,1)) 1.1*max(xyCoords(:,1)) min(xyCoords(:,2)) 1.1*max(xyCoords(:,2))];
if isequal(axLim([3 4]),[0 0])
    axLim([3 4]) = [-1 3];
end

% edit axis
axis square equal off;
axis(axLim);
title({['\fontsize{11}' MDSOptions.titleString],...
       ['\fontsize{10}distance measure:\rm ' MDSOptions.MDSDistance '  |  \bfcriterion:\rm ' MDSOptions.MDSCriterion]});

% plot legend
if MDSOptions.plotLegend == 1
    h = flipud(get(gca,'Children')); % grab all the axes handles at once
    l = legend(h(MDSOptions.legend.DotIdx),MDSOptions.legend.Labels,'Location','EastOutside');
    if ~isempty(MDSOptions.legend.title)
        title(l,MDSOptions.legend.title);
    end
end

% plot text labels in black
% --> shift y-coordinate of text -> "MDSOptions.dotSize" in point-unit
df = .03;
dx = range(xlim) * df * 0;
dy = range(ylim) * df * -1;

if MDSOptions.plotLabels == 1
    for itemI = 1:size(D,1)
        text(xyCoords(itemI,1) + dx, xyCoords(itemI,2) + dy,...
            sami.util.deunderscore(MDSOptions.dotLabels{itemI}),...
            'Color','k',...
            'FontSize',MDSOptions.fontSize,...
            'VerticalAlignment','top',...
            'HorizontalAlignment','center');
    end
end

end

