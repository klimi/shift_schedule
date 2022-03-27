function registerExportedFunctions(buildInfo)
%REGISTEREXPORTEDFUNCTIONS Register JavaScript exported function
%   Register all the entry-point functions to the Emscripten 
%   EXPORTED_FUNCTIONS list to make them available from JavaScript 
%   execution layer. For more information, see
%   https://emscripten.org/docs/porting/connecting_cpp_and_javascript/Interacting-with-code.html.
%
% Copyright 2021 The MathWorks, Inc.
%

arguments
    buildInfo (1,1) RTW.BuildInfo
end

codeInfo = matfile(fullfile(buildInfo.getBuildDirList,"codeInfo.mat"),"Writable",false).codeInfo;
configInfo = matfile(fullfile(buildInfo.getBuildDirList,"codeInfo.mat"),"Writable",false).configInfo;

entryPointTypes = ["InitializeFunctions","OutputFunctions","UpdateFunctions","TerminateFunctions"];

EXPORTED_FUNCTIONS=string.empty();

for entryPointType = entryPointTypes
    for entryPointFnc = codeInfo.(entryPointType)
        EXPORTED_FUNCTIONS(end+1) = "_" + entryPointFnc.Prototype.Name; %#ok<AGROW>
    end
end

if strcmp(configInfo.OutputType,'EXE')
    EXPORTED_FUNCTIONS(end+1) = "_main"; 
end

if ~strcmp(configInfo.DynamicMemoryAllocation,'Off')
    EXPORTED_FUNCTIONS(end+1) = "_malloc"; 
    EXPORTED_FUNCTIONS(end+1) = "_free";
    buildInfo.addLinkFlags("-s ALLOW_MEMORY_GROWTH=1");
end


EXPORTED_FUNCTIONS = """" + EXPORTED_FUNCTIONS + """";
EXPORTED_FUNCTIONS = EXPORTED_FUNCTIONS.join(",");

buildInfo.addLinkFlags("-s EXPORTED_FUNCTIONS='[" + EXPORTED_FUNCTIONS + "]'");
buildInfo.addLinkFlags("-s EXPORTED_RUNTIME_METHODS='[""ccall"",""cwrap""]'");

end