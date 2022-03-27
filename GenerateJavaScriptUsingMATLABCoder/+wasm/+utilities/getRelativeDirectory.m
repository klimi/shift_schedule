function relativePath = getRelativeDirectory(actualPath,targetPath)
%GETRELATIVEPATH Get the relative path from actualPath to targetPath
%   Get the relative path between two paths, actualPath and targetPath. 
%   This only applies to absolute Linux paths.
%
% Inputs:
%   actualPath (string) - Actual path
%   targetPath (string) - Target path
%
% Outputs:                
%   relativePath (string) - Relative path
%
% Copyright 2021 The MathWorks, Inc.
%

if strcmp(actualPath,targetPath)
    relativePath = "";
    return;
end

actualPath = separatePath(actualPath);
targetPath = separatePath(targetPath);

while true
    if isempty(targetPath) || isempty(actualPath)
        break;
    end
        
    if actualPath(1) == targetPath(1)
        actualPath(1) = [];
        targetPath(1) = [];
    else
        break;
    end
end

relativePath = [repmat("..",1,numel(actualPath)),targetPath];
relativePath = strjoin(relativePath,"/");

end


function path = separatePath(path)
path = strsplit(path,"/");
path = path(path ~= "");
end