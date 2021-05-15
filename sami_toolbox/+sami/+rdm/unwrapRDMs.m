function [RDMs, nRDMs, RDMNames] = unwrapRDMs(RDMs_struct)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

nonameIdx = 1;

if isstruct(RDMs_struct)
    % in struct form
    nRDMs = size(RDMs_struct,2);
    
    RDMNames = cell(nRDMs,1);
    RDMs = nan(size(RDMs_struct(1).RDM,1),size(RDMs_struct(1).RDM,2),nRDMs);
    
    for i = 1:nRDMs
        RDMs(:,:,i) = double(RDMs_struct(i).RDM);
        try
            RDMNames{i} = RDMs_struct(i).name;
        catch
            RDMNames{i} = ['unnamed_RDM',num2str(nonameIdx)];
            nonameIdx = nonameIdx + 1;
        end
    end
else
    % bare already
    RDMs = RDMs_struct;
    nRDMs = size(RDMs,3);
    
    RDMNames = cell(nRDMs,1);
    [RDMNames{:}] = deal('unnamed_RDM');
end

end