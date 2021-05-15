function drawRefenceTestLine(m)
% drawRefenceTestLine(m)
% 
% draws dashed line for testValue, against groups are tested for a significant difference
% 
%   input:
%       - m:
%           double. test value, against tests are performed
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 03/2021

line_col = [0 0 0];
line_width = 2;
line_style = '--';

if m ~= 0
    curXLim = xlim;
    curYLim = ylim;
    curYTicks = get(gca,'ytick');
    line(curXLim,[m m],'Color',line_col,'LineWidth',line_width,'LineStyle',line_style);
    
    % adjust y-axis-limits and yTicks
    if m < curYLim(1)
        curYLim(1) = m * (4/5);
        ylim([curYLim(1) curYTicks(end)]);
        set(gca, 'YTickMode', 'auto', 'YTickLabelMode', 'auto');
        curYTicks = get(gca,'YTick');
        ylim(curYLim);
        set(gca,'YTick',curYTicks);
    end
end
end

