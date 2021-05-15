function [hf,ha,figI] = selectPlot(figI,visibleFig)
% - activates or creates figure figI(1)
% - activates or creates plot [figI(2:4)],
%   or [1 1 1] if figI(2:4) are missing
% - sets background color to white
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

if ~exist('figI','var'); figI = 0; end
if ~exist('visibleFig','var'); visibleFig = true; end

% default values
background_color = 'w';

% switch visivility from BOOL to on/off
if visibleFig, visibleFig = 'on'; else, visibleFig = 'off'; end

% handle figure
if figI
    if ishghandle(figI(1))
        set(0, 'currentfigure', figI(1));
        hf = gcf;
    else
        hf = figure(figI(1));
        set(hf,'Visible',visibleFig);
        set(hf,'Color',background_color);  
    end
    
    if numel(figI) >= 4
        ha = subplot(figI(2),figI(3),figI(4:end));
    else
        ha = subplot(1,1,1);
    end
else
    hf = figure;
    set(hf,'Visible',visibleFig);
    set(hf,'Color',background_color);
    figI(1) = hf;
    ha = subplot(1,1,1);
end

end
