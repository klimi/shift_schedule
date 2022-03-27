function build(proj)
%BUILD Build the WASM Project
%   Builds the web application using MATLAB Coder and the Emscripten 
%   toolchain to create a standalone set of JavaScript (.js) and 
%   WebAssembly (.wasm) files that can be executed in the browser.
%
% Inputs:
%   proj (matlab.project.Project) - Project
%       Project, returned as a |matlab.project.Project| object.
%
% Example:
%   Build the current project, proj, run
%   >> proj = currentProject;
%   >> wasm.project.build(proj);
%
% Copyright 2021 The MathWorks, Inc.
%

arguments
    proj (1,1) matlab.project.Project;
end

codeConfig = matfile(fullfile(proj.RootFolder,"CodeConfig.mat"),"Writable",false).codeConfig;

entryPointFcns = cell.empty();

for file = proj.Files
    if isempty(findLabel(file,"EntryPoint","Primary Function"))
        continue;
    end
    
    entryPointFcns{end+1} = file.Path; %#ok<AGROW>
    break;
end

for file = proj.Files
    if isempty(findLabel(file,"EntryPoint","Function"))
        continue;
    end
    
    entryPointFcns{end+1} = file.Path; %#ok<AGROW>
    break;
end

for labelDefinition = findCategory(proj,"Callback").LabelDefinitions
    
    files = wasm.project.getFiles(proj,labelDefinition);
    
    if isempty(files)
        continue;
    end
    
    for file = files
        entryPointFcns{end+1} = file.Path; %#ok<AGROW>
        entryPointFcns{end+1} = "-args"; %#ok<AGROW>
        entryPointFcns{end+1} = getSignature(wasm.project.EventInterface.(labelDefinition.Name)); %#ok<AGROW>        
    end    
end


out_folder = fullfile(proj.RootFolder,"codegen");

if strcmp(codeConfig.OutputType,'EXE')    
    [~,rootFcn,~] = fileparts(entryPointFcns{1});    
    main = wasm.coder.Main(fullfile(proj.RootFolder,"codegen"),string(codeConfig.TargetLang));
    main.mainFcn(rootFcn);   
end

codegen(entryPointFcns{:},...
    "-config",codeConfig,...
    "-d",out_folder,...
    "-v");

for listing = dir(fullfile(proj.RootFolder,"codegen"))'
    if strcmp(listing.name,"."); continue; end
    if strcmp(listing.name,".."); continue; end
    
    codegenFile = proj.addFile(fullfile(listing.folder,listing.name));
    codegenFile.addLabel("Classification","Derived");
    
end

end

