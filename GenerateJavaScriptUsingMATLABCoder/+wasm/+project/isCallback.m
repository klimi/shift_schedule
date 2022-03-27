function tf = isCallback(fcnName,labelName)
%ISCALLBACK Determine if callback in project
%   Use this function to check if the function, fcnName, is a labelled
%   callback in the current project
%
%   Copyright 2021 The MathWorks, Inc.
%
arguments
    fcnName (1,1) string;
    labelName (1,1) wasm.project.EventInterface;    
end

file = findFile(currentProject,fcnName+".m");
label = findLabel(file,"Callback",string(labelName));
tf = ~isempty(label);

end



