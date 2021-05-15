function cols = createColormap(style)
% cols = createColormap(style) 
% 
% calculates a customized colormap given the requested 'style', which is defined in 
% the samiOptions.m file
% 
%   input:
%       - style:
%           string. Defining which field within samiOtions.cmap.'style' is used to
%           create colormap
%   
%   output:
%       - cols:
%           colormap in RGB values (dimensions [m x 3])
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 03/2021

%% loading samiOptions
samiOptions = sami.loadSamiOptions();
nCols = samiOptions.cmap.nCols;

%% get positions+colors for requested style
positions = samiOptions.cmap.(style).pos;
colors = samiOptions.cmap.(style).col;

%% computations
% compute positions along the samples
colSamp = round((nCols-1)*positions)+1;

% make the gradients among colors
cols = zeros(nCols,3);
cols(colSamp,:) = colors;
diffS = diff(colSamp)-1;
for d = 1:1:length(diffS)
    if diffS(d)~=0
        col1 = colors(d,:);
        col2 = colors(d+1,:);
        G = zeros(diffS(d),3);
        for idx = 1:3
            g = linspace(col1(idx), col2(idx), diffS(d)+2);
            g([1, length(g)]) = [];
            G(:,idx) = g';
        end
        cols(colSamp(d)+1:colSamp(d+1)-1,:) = G;
    end
end
end


