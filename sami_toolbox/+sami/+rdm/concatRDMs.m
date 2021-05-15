function RDMs=concatRDMs(varargin)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

RDMs = [];
for RDMI = 1:nargin
    
    if ~isstruct(varargin{RDMI})
        varargin{RDMI} = sami.rdm.wrapRDMs(varargin{RDMI});
    end
    
    RDMs = [RDMs, varargin{RDMI}];
end

end%function