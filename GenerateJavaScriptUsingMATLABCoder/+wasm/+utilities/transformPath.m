function str = transformPath(str)
%TRANSFORMPATH Transform paths to expected CMake path
%   Transform paths from windows paths to mapped WSL paths. Remove
%   whitespace paths and replace with corrected string.
%

arguments
    str (:,:) string;
end

if ispc
    str = replace(str,"\","/");  
end

str = strrep(str," ","\ ");
str = strrep(str,"(","\(");
str = strrep(str,")","\)");

end