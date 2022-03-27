 function registerCallbackFunctions(buildInfo)
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

proj = currentProject;

str = "// registered_callbacks.h" + newline;
str = str.append("#ifndef CALLBACK_REGISTRATION_H" + newline);
str = str.append("#define CALLBACK_REGISTRATION_H" + newline);
str = str.append("#include <emscripten.h>" + newline);
str = str.append("#include <emscripten/bind.h>" + newline);
str = str.append("#include <emscripten/val.h>" + newline + newline);
str = str.append("#include ""events.hpp""" + newline + newline);

str = str.append("#include """ + buildInfo.getBuildName + "_types.h""" + newline);


for label = findCategory(proj,"Callback").LabelDefinitions
    if isempty(wasm.project.getFiles(proj,label))
        continue
    end
        
    for file = wasm.project.getFiles(proj,label)
        [~,fileName,~] = fileparts(file.Path); 
        str = str.append("#include """ + fileName + ".h""" + newline + newline);
    end
end


for label = findCategory(proj,"Callback").LabelDefinitions    
    files = wasm.project.getFiles(proj,label);    
    if isempty(files)
        continue;
    end    
    str = str + "EMSCRIPTEN_BINDINGS(" + label.Name + "_callbacks) {" + newline;    
    for file = files
        [~,fileName,~] = fileparts(file.Path);        
        str = str + ...
            "    emscripten::function(""" + fileName + """, &mathworks::wasm::event::callbackWrapper<mathworks::wasm::event::" + label.Name + "," + fileName + ">);" + newline;
    end    
    str = str + "};" + newline + newline;    
end

str = str.append("#endif");

% Add file to build directory
filename = fullfile(buildInfo.getBuildDirList{1},"registered_callbacks.cpp");
fileID = fopen(filename,"w");
fprintf(fileID,str);
fclose(fileID);

% Add file to build
buildInfo.addSourceFiles("registered_callbacks.cpp",buildInfo.getBuildDirList{1},"");
buildInfo.addSourceFiles("events.cpp","$(SUPPORTPACKAGESRC)");
buildInfo.addIncludePaths(fullfile(matlabroot,"extern","include"));
buildInfo.addIncludePaths(fullfile(wasm.utilities.getRootDirectory,"cpp","include"));
buildInfo.addIncludePaths(fullfile(wasm.utilities.getRootDirectory,"emsdk","upstream","emscripten","system","include"));

% Add binding to build
buildInfo.addLinkFlags("--bind");

end


