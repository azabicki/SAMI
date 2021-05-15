function drawBoxPlot(d,category,userOptions)
% drawBoxPlot(d,category,userOptions)
% 
% draws a boxplots, overlayed with dots representing each datapoint.
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
dot_spread = .2;
dot_col = [.4 .4 .4];
dot_size = 20;
xAxisWhiteSpace = .6;
box_col = [.8 .8 .8];

% preparing
[~, cI] = ismember(category,{userOptions.stimuli_naming_key.name});

% first box plot to obtain x-and-y-data
boxplot(d,'colors',[0 0 0],'Labels',userOptions.stimuli_naming_key(cI).condition,'Notch','off','Widths',0.6,'OutlierSize',0.001,'Symbol','w.');
hold on;

% patches
h = findobj(gca,'Tag','Box');
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),box_col,'FaceAlpha',1);
end

% dots
for i = 1:size(d,2)
    pointXs = linspace(-dot_spread,dot_spread,size(d,1));
    plot(pointXs+i,d(:,i),'.','Color',dot_col,'MarkerSize',dot_size);
end

% second boxplot on the top
boxplot(d,'colors',[0 0 0],'Labels',userOptions.stimuli_naming_key(cI).condition,'Notch','off','Widths',0.6,'OutlierSize',0.001,'Symbol','w.');

% edit stuff
h=gca; h.XAxis.TickLength = [0 0];
set(gca, 'YGrid', 'on', 'XGrid', 'off')
xlim([1-xAxisWhiteSpace size(d,2)+xAxisWhiteSpace]);

end