function configObj = config(buildType,language)
%CONFIG Create a configuration object for WASM build
%   Generate a coder configuration object for typical web applications or 
%   libraries.
%
% Inputs:
%   buildType (wasm.project.Type | string) - Type of coder configuration
%       Specify the type coder configuration to use to either generate libraries or executables.
%       [ "Executable" | "SharedLibrary" | "StaticLibrary" ]
%   language (string) - Specify the code generation language
%       Specify the intermediate language to used in the code generation process.
%       [ "C++" (default) | "C" ]
%
% Outputs:
%   configObj (coder.CodeConfig) - Coder configuration object
%       Coder configuration object configured for the Emscripten toolchain 
%       and specified buildType.
%
% Example:
%   Create a code configuration object:
%   >> configObj = wasm.coder.config("Executable","C")
%   
%   configObj = 
%   
%       Description: 'class CodeConfig: C code generation configuration.'
%       Name: 'CodeConfig'
%   
%   ---------------------------- Code Generation --------------------------
%   
%                           BuildConfiguration: 'Faster Runs'
%                       CustomToolchainOptions: [1x20 cell]
%                          DataTypeReplacement: 'CBuiltIn'
%                          FilePartitionMethod: 'MapMFileToCFile'
%                                  GenCodeOnly: false
%                          GenerateExampleMain: 'DoNotGenerate'
%                             GenerateMakefile: true
%             HighlightPotentialRowMajorIssues: true
%                            MultiInstanceCode: false
%                                   OutputType: 'EXE'
%                        PassStructByReference: true
%                           PostCodeGenCommand:
%                                               'wasm.coder.postcodegen.registerExportedFunctions(buildInfo);
%                                               wasm.coder.postcodegen.registerCallbackFunctions(buildInfo);
%                                               wasm.coder.postcodegen.addCLinkage(buildInfo);
%                                               wasm.coder.postcodegen.addESMSupport(buildInfo)'
%                      PreserveArrayDimensions: false
%                                     RowMajor: false
%                                   TargetLang: 'C'
%                                    Toolchain: 'Emscripten v2.0.26 | gmake (64-bit Windows)'
%
%
% Copyright 2021 The MathWorks, Inc.
%

arguments
    buildType (1,1) wasm.project.Type;    
    language {mustBeMember(language,["C","C++"])} = "C++";
end

switch buildType
    case "StaticLibrary"
        configObj = coder.config("lib","ecoder",false);
    case "SharedLibrary"
        configObj = coder.config("dll","ecoder",false);
    case "Executable"
        configObj = coder.config("exe","ecoder",false);        
end

configObj.Toolchain = coder.make.internal.formToolchainName(...
    'Emscripten',...
    computer('arch'),...
    char(wasm.utilities.ExternalTool.version("Emscripten")),...
    'gmake'...
    );

configObj.TargetLang = language;

configObj.PostCodeGenCommand = strjoin(...
    ["wasm.coder.postcodegen.registerExportedFunctions(buildInfo)",...
    "wasm.coder.postcodegen.registerCallbackFunctions(buildInfo)",...
    "wasm.coder.postcodegen.addCLinkage(buildInfo)"],...
    ";");

configObj.HardwareImplementation.ProdHWDeviceType = "Google-V8 Engine";

configObj.GenerateExampleMain = "DoNotGenerate";

if buildType == "Executable"
if language == "C"
    configObj.CustomSource = "main.c";
end    
if language == "C++"
    configObj.CustomSource = "main.cpp";
end    
end    

end