function txt = deblank(txt)
% gets an input string and replaces "spaces" (' ') with underscores ('_').
% This avoids the problems when saving files, this way with displaying the names in which
% the first character after the underscore would be displayed as an index. 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

% replace spaces
if iscell(txt)
    for i = 1:numel(txt)
        line = txt{i};
        line(line==32) = '_';
        txt{i} = line;
    end
else
    txt(txt==32)='_';
end

end
