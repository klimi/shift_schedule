function proj = create(name,options)
%CREATE Create a new web project
%   Create a new MATLAB project to for either a JavaScript library or app.
%   The project is automatically configured with Category-Label pairs to
%   identify Callbacks, User Interface, and EntryPoint functions.
%
% Inputs:
%   name (string) - Name of the project.
%
%   (Name-Value Pairs)
%   Path (string) - Set the directory in which to create the project.
%       The directory must exist on the host computer.
%       [ pwd (default) | directory on host computer ]
%
%   Type (wasm.project.Type) - Select the project type from webwasm.project.Type.
%       Use the |webwasm.project.Type| enumeration to select the project type.
%       The default project type is |wasm.project.Type.WebApplication|.
%       For more information on the |wasm.project.Type| enumerations,
%       see |>> help wasm.project.Type|.
%
% Outputs:
%   proj (matlab.project.Project) - Project
%       Project, returned as a |matlab.project.Project| object.
%
% Example:
%   To create a new project in the current directory, run
%   >> proj = wasm.project.create("MyNewApp");
%
% Copyright 2021 The MathWorks, Inc.
%

arguments
    name {mustBeTextScalar}
    options.Type (1,1) wasm.project.Type = wasm.project.Type.SharedLibrary;
    options.Path {mustBeFolder} = pwd;
    options.Language {mustBeMember(options.Language,["C","C++"])} = "C++";
end


%% Create and Name Empty Project
proj = matlab.project.createProject(options.Path);
projectFile = fullfile(proj.RootFolder,"Blank_project.prj");
[status,msg] = movefile(projectFile,name+".prj");
assert(logical(status),msg);
proj.Name = name;
reload(proj);


%% Add Project Labels
runtimeCategory = createCategory(proj,"EntryPoint");
runtimeLabels = [   "Primary Function",...
                    "Function"];
for runtimeLabel = runtimeLabels                
    createLabel(runtimeCategory,runtimeLabel);
end

callbackCategory = createCategory(proj,"Callback");
callbackLabels = string(enumeration("wasm.project.EventInterface"))';
for callbackLabel = callbackLabels
    createLabel(callbackCategory,callbackLabel);
end


%% Add Project Folders
mkdir(fullfile(proj.RootFolder,"codegen"));
codegenFolder = proj.addFile("codegen");
codegenFolder.addLabel("Classification","Derived");


%% Add Code Configuration File
codeConfig = wasm.coder.config(options.Type,options.Language);
save(fullfile(proj.RootFolder,"CodeConfig.mat"),"codeConfig");
codeConfigFile = proj.addFile("CodeConfig.mat");
codeConfigFile.addLabel("Classification","Other");


end