function gotoDir(path)
% gotoDir(path)
%     Goes to path, making all required directories on the way.
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

sIndices = strfind(path, filesep);

% test all directories within path
for i = 1:numel(sIndices)
    if i == 1 && sIndices(i) == 1
        continue;
    end
    
    try
        cd(path(1:sIndices(i)-1));
    catch
%         fprintf(['The directory "' path(1:sIndices(i)-1) '" doesn''t exist... making it.\n']);
        mkdir(path(1:sIndices(i)-1));
        cd(path(1:sIndices(i)-1));
    end
end

% cleanup final directory!
try
    cd(path);
catch
%     fprintf(['The directory "' path '" doesn''t exist... making it.\n']);
    mkdir(path);
end

cd(path);

end
