function handleFigure(figI, fileName, userOptions)
% handleFigure(figI, fileName, userOptions)
% 
% handleFigure is a function which will, based on the preferences set in userOptions, 
% save the current figure as a .pdf, a .tif, a .svg, or a .fig; and also either leaving 
% it open or closing it.
%
%   input:
%       - figI: 
%           figure handle. The figure handle of the figure to be saved.
% 
%       - fileName: 
%           string. The name of the file to be saved.
% 
%       - userOptions.fig_display
%           boolean. If true, the figure remains open after it is handles.
%           Defaults to true.
% 
%       - userOptions.fig_savePDF
%           boolean. If true, the figure is saved as a PDF.
%           Defaults to false.
% 
%       - userOptions.fig_saveTIF
%           A boolean value. If true, the figure is saved as a TIF.
%           Defaults to false.
% 
%       - userOptions.fig_saveSVG
%           A boolean value. If true, the figure is saved as a SVG.
%           Defaults to false.
% 
%       - userOptions.fig_saveFIG
%           A boolean value. If true, the figure is saved as a MATLAB .fig file.
%           Defaults to false.
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

%% Set defaults and check options struct
userOptions = sami.util.setIfUnset(userOptions, 'fig_display', true);
userOptions = sami.util.setIfUnset(userOptions, 'fig_savePDF', false);
userOptions = sami.util.setIfUnset(userOptions, 'fig_saveSVG', false);
userOptions = sami.util.setIfUnset(userOptions, 'fig_saveTIF', false);
userOptions = sami.util.setIfUnset(userOptions, 'fig_saveFIG', false);

%% set PaperSize to FigSize
figHandles = get(groot, 'Children');
fh = figHandles([figHandles(:).Number] == figI);
fh.PaperPositionMode = 'auto';
fig_pos = fh.PaperPosition;
fh.PaperSize = [fig_pos(3) fig_pos(4)];

%% saving
% saving PDF
if userOptions.fig_savePDF
	print('-dpdf',fileName,'-bestfit');
end

% saving SVG
if userOptions.fig_saveSVG
    print('-dsvg',sprintf('-r%d',userOptions.fig_dpi),fileName);
end

% saving TIF
if userOptions.fig_saveTIF
	print('-dtiff',sprintf('-r%d',userOptions.fig_dpi),fileName);
end

% saving Matlab figure
if userOptions.fig_saveFIG
	savefig(figI,fileName);
end

% closing figure
if ~userOptions.fig_display
	close(figI);
end

end
