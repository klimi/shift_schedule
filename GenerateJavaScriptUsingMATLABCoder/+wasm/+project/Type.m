classdef Type
    %TYPE List of project types
    %   List of project types. Used as identifier in the project to
    %   indicate the type of project, e.g. executable vs library.
    %
    % Copyright 2020 The MathWorks, Inc.
    %
    
    enumeration
        Executable,
        SharedLibrary,
        StaticLibrary     
    end
    
    % Emscripten doesn't support DLL style libraries.
        
end