function drawSigLines(inpX,inpP)
% drawSigLines(inpX,inpP) 
% 
% draws lines above bar/box-plots for significant post-hoc pairwise comparisons
% 
%   input:
%       - inpX:
%           double. a [p x 2]-matrix, indicating for p pairwise comparisons the group 
%           which are compared against each other (corresponding location on x-axis)
%   
%       - inpP:
%           double. pValues for p pairwise comparisons, order according to rows in inpX
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 03/2021


line_col = [0 0 0];
line_width = 1;
line_compactness = 2;   % integer (!) values from intervall [0,9] makes sense

addYAxisWhiteSpaceFactor = .3;

if any(inpP < 0.05)
    % get yCoords of sig. lines
    curYTicks = get(gca,'YTick');
    curYLim = ylim;
    ylim([curYLim(1) curYLim(2)+range(curYLim)*addYAxisWhiteSpaceFactor]);
    set(gca,'YTick',curYTicks);
    
    linH2 = linspace(curYLim(2),curYLim(2)+range(curYLim)*addYAxisWhiteSpaceFactor,size(inpP,1)+2+(2*line_compactness));
    linSpread = range(linH2(1:2));
    linH = linH2(2+line_compactness:end-1-line_compactness);
    
    % show pairwise sign. lines
    tmpI = 0;
    for i = 1:size(inpP,1)
        if inpP(i) < 0.05
            tmpI = tmpI + 1;
            line([inpX(i,1) inpX(i,2)],[linH(tmpI) linH(tmpI)],'Color',line_col,'LineWidth',line_width);
        end
    end
    
    % update yLim and get rid of white_space above lines
    ylim([curYLim(1) linH(tmpI)+2*linSpread]);
end
end

