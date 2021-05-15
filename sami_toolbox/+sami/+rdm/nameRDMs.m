function RDMs = nameRDMs(RDMs,names)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

for nameI = 1:numel(names)
    RDMs(nameI).name = names{nameI};
end

end
