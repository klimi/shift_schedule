function addESMSupport(buildInfo)
%ADDESMSUPPORT Add ESM JavaScript generation to project
%   Add the Emscripten flags to the make to support the generation of ESM
%   JavaScript modules that can be called usign the following syntax:
%
%   import MyModule from './MyModule.js'
%
% Copyright 2021 The MathWorks, Inc.
%
arguments
    buildInfo (1,1) RTW.BuildInfo
end

buildInfo.addCompileFlags("-s EXPORT_ES6=1"); 
buildInfo.addLinkFlags("-s EXPORT_ES6=1"); 

buildInfo.addCompileFlags("-s MODULARIZE=1"); 
buildInfo.addLinkFlags("-s MODULARIZE=1"); 

end