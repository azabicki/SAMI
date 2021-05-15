function options = setIfUnset(options,field,value)
% if options.(field) is empty or doesn't exist, this function sets options.(field) to value.
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

if ~isfield(options, field) || isempty(options.(field))
       options.(field) = value;
end

end
