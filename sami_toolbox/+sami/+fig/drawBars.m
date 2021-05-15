function drawBars(d,category,userOptions)
% drawBars(d,category,userOptions) 
% 
% draws a bar plot (bar + errorbar), overlayed with dots representing each datapoint.
% 
%   input:
%       - d:
%           double. [d*g]-matrix containg 'n' datapoints for each of the 'g' groups
% 
%       - category:
%           string. the category by which the groups were formed
% 
%       - userOptions.stimuli_naming_key:
%           struct. contains labels for each group, according to the respective category
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 10/2020

% plotting options
dot_spread = .3;
dot_col = [.4 .4 .4];
dot_size = 16;
bar_col = [.8 .8 .8];
xAxisWhiteSpace = .6;

% preparing
dMN = mean(d);
dSEM = std(d) ./ sqrt(size(d,1));
[~, cI] = ismember(category,{userOptions.stimuli_naming_key.name});

% bar plot
bar(dMN,'FaceColor',bar_col); hold on;

% dots
for i = 1:numel(dMN)
    tmpXplus1 = mod(size(d,1),2);
    pointXs = [linspace(-dot_spread,-0.1,floor(size(d,1)/2)) ,...
        linspace(0.1,dot_spread,floor(size(d,1)/2)+tmpXplus1)];
    plot(pointXs+i,d(:,i),'.','Color',dot_col,'MarkerSize',dot_size);
end

% errorbars
errorbar(1:numel(dMN),dMN,dSEM,'LineStyle','none','CapSize',0,'LineWidth',3,'Color','k')

% edit axis 
set(gca,'Xtick',1:numel(dMN),'XTickLabel',userOptions.stimuli_naming_key(cI).condition);
h=gca; h.XAxis.TickLength = [0 0];
set(gca, 'YGrid', 'on', 'XGrid', 'off')
xlim([1-xAxisWhiteSpace numel(dMN)+xAxisWhiteSpace]);

end
