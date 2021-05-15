function RDMs_struct = wrapRDMs(RDMs,refRDMs_struct)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

if isstruct(RDMs)
    % wrapped already, but replace the wrapping
    nRDMs = numel(RDMs);
else
    nRDMs = size(RDMs,3);
end    

if ~exist('refRDMs_struct','var')
    for iRDM = 1:nRDMs
        refRDMs_struct(iRDM).name = '[unnamed RDM]';
        refRDMs_struct(iRDM).color = [0 0 0];
    end
end

RDMs_struct = refRDMs_struct;
if isstruct(RDMs)
    % wrapped already, but replace the wrapping
    for iRDM = 1:nRDMs
        RDMs_struct(iRDM).RDM = RDMs(iRDM).RDM;
    end
else
    % RDMs need wrapping
    for iRDM = 1:nRDMs
        RDMs_struct(iRDM).RDM = RDMs(:,:,iRDM);
    end
end

end%function
