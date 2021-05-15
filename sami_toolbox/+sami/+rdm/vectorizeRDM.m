function RDM = vectorizeRDM(RDM)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020


if size(RDM,1)==size(RDM,2)
    RDM(logical(eye(size(RDM))))=0; % fix diagonal: zero by definition
    RDM = squareform(RDM);
end

end%function
