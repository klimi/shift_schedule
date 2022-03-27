function addCLinkage(buildInfo)
%ADDCLINKAGE Add C linkage to the entry-point functions
%   Post-codegen callback that updates the entry-point functions. If C++
%   code is generated, then extern "C" modifier gets added to the exposed
%   header file.
%
% Copyright 2019 The MathWorks, Inc.
%
arguments
    buildInfo (1,1) RTW.BuildInfo
end

codeInfo = matfile(fullfile(buildInfo.getBuildDirList,"codeInfo.mat"),"Writable",false).codeInfo;
configInfo = matfile(fullfile(buildInfo.getBuildDirList,"codeInfo.mat"),"Writable",false).configInfo;

entryPointTypes = ["InitializeFunctions","OutputFunctions","UpdateFunctions","TerminateFunctions"];

if strcmp(configInfo.TargetLang,'C++')
    for entryPointType = entryPointTypes
        for entryPointFnc = codeInfo.(entryPointType)
            wasm.coder.externC(fullfile(string(buildInfo.getBuildDirList),string(entryPointFnc.Prototype.HeaderFile)));
        end
    end    
end

end

