function ltv_RDMs = vectorizeRDMs(RDMs)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

if isstruct(RDMs)
    % wrapped
    nRDMs = size(RDMs,2);
    ltv_RDMs = [];
    
    for iRDM = 1:nRDMs
        thisRDM = RDMs(iRDM).RDM;
        ltv_RDMs = cat(3,ltv_RDMs,sami.rdm.vectorizeRDM(thisRDM));
    end
    
    ltv_RDMs = sami.rdm.wrapRDMs(ltv_RDMs,RDMs);
else
    % bare
    nRDMs = size(RDMs,3);
    ltv_RDMs = [];
    
    for iRDM = 1:nRDMs
        ltv_RDMs = cat(3,ltv_RDMs,sami.rdm.vectorizeRDM(RDMs(:,:,iRDM)));
    end
end


end%function
