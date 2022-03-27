function files = getFiles(proj,labelDefinition)
%GETFILES Get project files with label
%   
%   Copyright 2021 The MathWorks, Inc.
%
arguments
    proj (1,1) matlab.project.Project    
    labelDefinition (1,1) matlab.project.LabelDefinition
end

files = matlab.project.ProjectFile.empty();

for file = proj.Files    
    if ~isempty(findLabel(file,labelDefinition))    
        files(end+1) = file; %#ok<AGROW>
    end 
end

end