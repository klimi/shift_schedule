classdef DevelopmentServer < handle
    %DEVELOPEMENTSERVER Small development server to locally host apps
    %   A small development server to locally host apps.
    %
    %   Creation:
    %       server = webcoder.utilities.DevelopmentServer()
    %       server = webcoder.utilities.DevelopmentServer(_,'Port',value,_)
    %           value is an integer between 1 and 65536, 8000 (default).
    %       server = webcoder.uitlitiea.DevelopmentServer(_,'Diectory',value,_)
    %           value is the directory path for the server, '.' (default).
    %
    %   Methods:
    %       server.start()
    %           Launches the server. A browser can be used to see th page
    %           by going to the address localhost:8000.
    %       server.stop()
    %           Closes the server.
    %
    
    %
    % Copyright 2019 The MathWorks, Inc.
    %
    
    properties
        processId = []
        outputFile
        errorFile
        directory {mustBeFolder} = pwd;
        port {mustBeInRange(port,8000,65534)} = 8000;
    end
    
    properties (Hidden)
        cleanup
    end
    
    methods
        function devServer = DevelopmentServer(namevaluepair)            
            arguments
                namevaluepair.Port {mustBeInRange(namevaluepair.Port,8000,65534)} = 8000;
                namevaluepair.Directory {mustBeFolder} = pwd;
            end            
            devServer.port = namevaluepair.Port;
            devServer.directory = namevaluepair.Directory;
            devServer.cleanup = onCleanup(@()delete(devServer));
        end 
        
        function delete(devServer)
            stop(devServer);
        end  
        
        function devServer = start(devServer)
            
            % Server script            
            httpServerScript = fullfile(wasm.utilities.getRootDirectory,"js","utilities","minimal-server.js");
            
            node = wasm.utilities.ExternalTool.getExecutable("Node"); 
            
            arguments = join([httpServerScript,devServer.directory,num2str(devServer.port)]," ");                     
            
            [devServer.processId,devServer.outputFile,devServer.errorFile] = ...
                rtw.connectivity.Utils.launchProcess(char(node),char(arguments));  
            
            if rtw.connectivity.Utils.isAlive(devServer.processId)
                switch true
                    case isunix || ismac
                        command = "ifconfig | grep netmask | awk '{print $2}'| cut -f2 -d:";                        
                    case ispc
                        command = "ipconfig | findstr /i ""ipv4""";
                    otherwise
                        
                end
                
                [~,result] = system(command);
                
                expression = "\d+\.\d+\.\d+.\d+"; 
                [startIndex,endIndex] = regexp(result,expression);
                ipAddresses = strings(numel(startIndex)+1,1);
                for ii = 1:numel(startIndex)
                    ipAddresses(ii) = string(result(startIndex(ii):endIndex(ii)));
                end
                ipAddresses(end) = "localhost";
                
                disp("Development Server serving directory '" + devServer.directory + "' at locations:");
                for i = 1:numel(ipAddresses)
                    ipAddress = char("http://" + ipAddresses(i) + ":" + devServer.port);
                    % disp(['    <a href ="',ipAddress,'">',ipAddress,'</a>']);
                    disp(['    ',ipAddress]);
                end   
            end 
        end
        
        function devServer = stop(devServer)
            if rtw.connectivity.Utils.isAlive(devServer.processId)
                rtw.connectivity.Utils.killProcess(...
                    devServer.processId,...
                    devServer.outputFile,...
                    'exeErrorFile',devServer.errorFile);
            end            
        end
        
        function showOutputLog(devServer)
            text = fileread(devServer.outputFile);
            disp(text);
        end
        
        function showErrorLog(devServer)
            text = fileread(devServer.errorFile);
            disp(text);
        end
        
    end
        
end

