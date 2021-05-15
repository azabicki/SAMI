function samiOptions = loadSamiOptions()
% samiOptions = loadSamiOptions()
%   this function serves as some kind of 'config' file and contains variables, which are 
%   used at different locations across the toolbox. these variables are thought to be 
%   rather static, and does not to be edited by the user usually.
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

%% definition of labels used
% this cell array also defines the order in which the markers will be sorted during the
% reading process of raw c3d-files.
samiOptions.labels = {'HEAD','LSHO','LELB','LWRI','LHIP','LKNE','LANK','RSHO','RELB','RWRI','RHIP','RKNE','RANK'};

%% definition of colormaps for different purposes
% each 'style' is defined by 'positions' and corresponding 'colors'. then, 
% sami.fig.createColormap('style') uses this information to generate color-gradients
% between these position.
% 
%   - samiOptions.cmap.'style'.pos:
%       double. Array defining color positions between 0 and 1. Note that the first 
%       position must be 0, and the last one must be 1
% 
%   - samiOptions.cmap.'style'.col:
%   	double. Colors to place in each position. Must be a RGB matrix [n_colors x 3]

% resolution (# of columns) of colormap
samiOptions.cmap.nCols = 256;

% 1st order RDMs showing dissimilarities between features/particpants 
samiOptions.cmap.RDMs.pos = [0 .25 .5 .75 1];
samiOptions.cmap.RDMs.col = [    0     0   0.5;...
                                 0 0.625 0.625;...
                              0.75  0.75  0.75;...
                             0.875     0     0;...
                                 1     1     0];

% 2nd order RDMs showing dissimilarities between 1st order RDMs
samiOptions.cmap.RDMofRDMs.pos = [ 0 .5  1];
samiOptions.cmap.RDMofRDMs.col = [ 1  0  0;...
                                  .8 .8 .8;...
                                   0  0  1];

% confusion matrix for categorical behavioral rating analysis
samiOptions.cmap.confMatrix.pos = [0 .01 .1 1];
samiOptions.cmap.confMatrix.col = [  1   1   1;...
                                   .95 .95 .95;...
                                    .8  .8  .8;...
                                     0 .27 .53];

end

