classdef ExternalTool
    %EXTERNALTOOL Manage the directories of third-party external tools
    %   Add and manage the directories of third-party external tools, such
    %   as Emscripten and NodeJS.
    %
    % Example:
    %   Add and check tool installation
    %   >> wasm.utilities.ExternalTool.setFolder("Emscripten","C:\emsdk");
    %   >> wasm.utilities.ExternalTool.validate("Emscripten");
    %   >> tool = wasm.utilities.ExternalTool.getExecutable("Emscripten");   
    %   tool = 
    %       "D:\GitHub\generate-javascript-using-matlab-coder\emsdk"
    %
    %
    % Copyright 2021 The MathWorks, Inc.
    %
    
    properties (Constant)
        filename = fullfile(wasm.utilities.getRootDirectory,"ExternalTools");
    end
    
    methods (Static)
        function setFolder(name,folder)
            %SETFOLDER Set folder of specified tool
            %   Set folder of specified tool and saves the information to 
            %   an internal file in the add-on. 
            %
            % Inputs:
            %   name (string) - Name of the tool, must be "Emscripten" or
            %   "Node"
            %   folder (string) - Full path to tool root folder.
            %
            
            arguments
                name {mustBeMember(name,["Emscripten","Node"])}
                folder {mustBeFolder} = uigetdir(pwd,"Set Path to " + name);
            end            
            
            externalToolFile = matfile(wasm.utilities.ExternalTool.filename,'Writable',true); 
            
            switch name
                case "Emscripten"    
                    externalToolFile.(name) = string(folder);
                    wasm.utilities.ExternalTool.validate("Emscripten");
                    listing = dir(fullfile(folder,"node"));
                    externalToolFile.("Node") = fullfile(listing(3).folder,listing(3).name,"bin"); 
                    wasm.utilities.ExternalTool.validate("Node"); 
                case "Node"                    
                    externalToolFile.(name) = string(folder);
                    wasm.utilities.ExternalTool.validate(name);
            end
                              
                       
        end
                
        function tool = getExecutable(name)
            %GETEXECUTABLE Get fullpath to executable
            %   Get fullpath to executable previously saved.
            %
            % Inputs:
            %   name (string) - Name of the tool, must be "Emscripten" or
            %   "Node"
            %
            % Outputs:                
            %   tool (string) - Full path to tool executable.
            %
            arguments
                name {mustBeMember(name,["Emscripten","Node"])}
            end
            
            externalToolFile = matfile(wasm.utilities.ExternalTool.filename,'Writable',false);
            directory = externalToolFile.(name);
            
            switch name
                case "Node"
                    if ispc
                        tool = fullfile(RTW.transformPaths(char(directory)),"node.exe");  
                    else
                        tool = fullfile(RTW.transformPaths(char(directory)),"node");
                    end                
                case "Emscripten"
                    tool = fullfile(RTW.transformPaths(char(directory)),"emsdk");
            end            
        end
          
        function directory = getFolder(name)
            %GETFOLDER Get fullpath to tool folder
            %   Get fullpath to tool folder previously saved.
            %
            % Inputs:
            %   name (string) - Name of the tool, must be "Emscripten" or
            %   "Node"
            %
            % Outputs:                
            %   directory (string) - Full path to tool directory.
            %
            arguments
                name {mustBeMember(name,["Emscripten","Node"])}
            end
            
            externalToolFile = matfile(wasm.utilities.ExternalTool.filename,'Writable',false);
            directory = string(RTW.transformPaths(char(externalToolFile.(name))));
        end        
        
        function validate(name)
            %VALIDATE Validate the tool
            %   Validate the installation of the specified tool.
            %
            % Inputs:
            %   name (string) - Name of the tool, must be "Emscripten" or
            %   "Node"
            %            
            arguments
                name {mustBeMember(name,["Emscripten","Node"])}
            end
            
            switch name
                                    
                case "Emscripten"
                    tool = wasm.utilities.ExternalTool.getExecutable("Emscripten");
                    
                    try
                        mustBeFile(tool);
                    catch ME
                        ME = MException('WASM:EXTERNALTOOL:EMSDKNotFound', "EMSDK executable file is not valid. Update the EMSDK executable registered with this Add-On.");
                        throw(ME);
                    end
                    
                    [status,result] = system(tool + " --help");
                    
                    if status ~= 0
                        ME = MException('WASM:EXTERNALTOOL:EMSDKNotFound', result);
                        throw(ME);
                    end
                    
                    emsdkPattern = "emsdk: Available commands";
                    if ~contains(result,emsdkPattern,"IgnoreCase",true)
                        ME = MException('WASM:EXTERNALTOOL:EMSDKNotFound', result);
                        throw(ME);
                    end
                    
                case "Node"
                    tool = wasm.utilities.ExternalTool.getExecutable("Node");
                    
                    try
                        mustBeFile(tool);
                    catch ME
                        ME = MException('WASM:EXTERNALTOOL:NodeNotFound', "Node executable file is not valid. Update the Node executable registered with this Add-On.");
                        throw(ME);
                    end
                    
                    [status,result] = system(tool + " --help");
                    
                    if status ~= 0
                        ME = MException('WASM:EXTERNALTOOL:NodeNotFound', result);
                        throw(ME);
                    end
                    
                    emsdkPattern = "Usage: node [options] [ script.js ] [arguments]";
                    if ~contains(result,emsdkPattern,"IgnoreCase",true)
                        ME = MException('WASM:EXTERNALTOOL:NodeNotFound', result);
                        throw(ME);
                    end
                    
            end
            
        end
        
        function version = version(name,style)
            %VERSION Version of the tool
            %   Version the specified tool.
            %
            % Inputs:
            %   name (string) - Name of the tool, must be "Emscripten" or
            %   "Node"
            %
            % Outputs:                
            %   version (string|struct) - Version of the tool.
            % 
            arguments
                name {mustBeMember(name,["Emscripten","Node"])}
                style {mustBeMember(style,["string","struct"])} = "string";
            end
            
            cmd = wasm.utilities.ExternalTool.getExecutable(name);           
            
            [~,result] = system(cmd + " list");
            
            pattern = digitsPattern + "." + digitsPattern + "." + digitsPattern + optionalPattern("-" + lettersPattern) + whitespacePattern + "INSTALLED";            
            result = extract(string(result),pattern);
            version = extract(result(1),digitsPattern + "." + digitsPattern + "." + digitsPattern);
                         
            if strcmp(style,"struct")
                version = version.split(".");
                version = struct("Major",version(1),"Minor",version(2),"Patch",version(3)); 
            end
        end
        
    end
end

