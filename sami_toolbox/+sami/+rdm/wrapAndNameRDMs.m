function RDMs = wrapAndNameRDMs(RDMs,names)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

RDMs = sami.rdm.wrapRDMs(RDMs);
RDMs = sami.rdm.nameRDMs(RDMs,names);

end
