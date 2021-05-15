function drawSigAsterisks(inpX,inpP)
% drawSigAsterisks(inpX,inpP) 
% 
% draws asterisks at the top of the axis, indicating significance for one-sample 
% comparisons agains a testValue
% 
%   input:
%       - inpX:
%           double. index (= location on x-axis) of group which is compared against a
%           specific value
%   
%       - inpP:
%           double. pValues for each group, order according to inpX
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 03/2021

ast_col = [0 0 0];
ast_size = 18;
line_col = [0 0 0];
line_width = 1;
line_style = ':';

yAxisFactorLimit = .05;
yAxisFactorAsterisk = .055;

if any(inpP < 0.05)
    % get yCoords of sig. lines
    curYTicks = get(gca,'YTick');
    curYLim = ylim;
    curXLim = xlim;
    
    yMarks = curYLim(2) + range(curYLim)*yAxisFactorLimit .* [1 2];
    ylim([curYLim(1) yMarks(2)]);
    set(gca,'YTick',curYTicks);
        
    astH = curYLim(2) + range(curYLim)*yAxisFactorAsterisk;
        
    % plot line and asterisks
    for i = 1:numel(inpP)
        if inpP(i) < 0.05
            text(inpX(i),astH,'*',...
                'FontSize',ast_size,'Color',ast_col,...
                'VerticalAlignment','middle',...
                'HorizontalAlignment','center');
        end
    end
	line(curXLim,[yMarks(1) yMarks(1)],...
        'Color',line_col,'LineWidth',line_width,'LineStyle',line_style);
end
end

