function txt = deunderscore(txt)
% gets an input string and adds to an underscores ('_') a backslash
% ('\_').This avoids the problems with displaying the names in which the
% first character after the underscore would be displayed as an index. 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

% replace underscores
if iscell(txt)
    for i = 1:numel(txt)
        line = txt{i};
        line = strrep(line,'_','\_');
        txt{i} = line;
    end
else
    txt = strrep(txt,'_','\_');
end

end
