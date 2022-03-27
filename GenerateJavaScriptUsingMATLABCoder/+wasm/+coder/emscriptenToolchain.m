function [tc, results] = emscriptenToolchain()
%GETSCRIPTENTOOLCHAIN Generate specification of Emscripten toolchain
%   Generate the specification of Emscripten toolchain object. This 
%   function automatically recognizes your host platform and customizes the 
%   Emscripten toolchain in this add-on to use the appropriate installation 
%   of the Emscripten software development kit (EMSDK). The toolchain 
%   object must be saved and registered to be used by MATLAB Coder.
%
% Outputs:
%   tc (coder.make.ToolchainInfo) - Toolchain object
%       MATLAB toolchain project that specifies the tools needed to compile 
%       C/C++ code into JS/WASM. 
%   result (struct) - Results structure
%       Results structure contains debug and error information about the 
%       toolchain generation process.
%
% Example:
%   Generate the Emscripten toolchain object, tc, run
%   >> [tc,res] = wasm.coder.emscriptenToolchain();
%
% Copyright 2019 The MathWorks, Inc.
%

toolchain.Platforms  = {computer('arch')};
toolchain.Versions   = {char(wasm.utilities.ExternalTool.version("Emscripten"))};
toolchain.Artifacts  = {'gmake'};
toolchain.FuncHandle = str2func('getToolchainInfoFor');
toolchain.ExtraFuncArgs = {};

[tc, results] = ...
    coder.make.internal.generateToolchainInfoObjects(...
    mfilename, toolchain, nargout...
    );

end


function toolchain = getToolchainInfoFor(...
    platform, version, artifact, varargin...
    )

% Toolchain Information
toolchain = coder.make.ToolchainInfo(...
    'BuildArtifact','gmake makefile',...
    'SupportedLanguages',{'C/C++'});

toolchain.Name = coder.make.internal.formToolchainName(...
    'Emscripten',...
    platform,...
    version,...
    artifact...
    );

toolchain.Platform = platform;
toolchain.setBuilderApplication(platform);


% ------------------------------
% Macros
% ------------------------------
toolchain.addMacro('SUPPORTPACKAGEINCLUDE',char(fullfile(wasm.utilities.getRootDirectory,"cpp","include")));
toolchain.addMacro('SUPPORTPACKAGESRC',char(fullfile(wasm.utilities.getRootDirectory,"cpp","src")));

if isunix || ismac
    toolchain.addMacro('EMSDK_UPSTREAM_EMSCRIPTEN',...
        char(fullfile(wasm.utilities.ExternalTool.getFolder("Emscripten"),"upstream","emscripten")));
end    

% ------------------------------
% Setup
% ------------------------------
if ispc
    shellSetup = "call " + wasm.utilities.ExternalTool.getExecutable("Emscripten") + " activate latest";
else
    shellSetup = wasm.utilities.ExternalTool.getExecutable("Emscripten") + " activate latest" + ...
        " && " + ...
        "source " + fullfile(wasm.utilities.ExternalTool.getFolder("Emscripten"),"emsdk_env.sh");    
end
toolchain.ShellSetup{1} = char(shellSetup);


% Toolchain's attribute
toolchain.addAttribute('TransformPathsWithSpaces', true);
toolchain.addAttribute('SupportsUNCPaths',     false);
toolchain.addAttribute('SupportsDoubleQuotes', true);
if ispc
    toolchain.addAttribute('RequiresBatchFile', true);
end


% ---------------------------------------------
% COMPILERS, LINKERS, and ARCHIVERS
%----------------------------------------------
    function c_compiler()
        c_compiler = toolchain.getBuildTool( 'C Compiler');
        c_compiler.setName(           'Emscripten C Compiler'); 
        if ispc
            c_compiler.setCommand(        'emcc');       
        else
            c_compiler.setCommand(        '$(EMSDK_UPSTREAM_EMSCRIPTEN)/emcc');
        end
        c_compiler.setPath(           '');
        c_compiler.setDirective(      'CompileFlag',          '-c');
        c_compiler.setDirective(      'PreprocessFile',       '-E');
        c_compiler.setDirective(      'IncludeSearchPath',    '-I');
        c_compiler.setDirective(      'PreprocessorDefine',   '-D');
        c_compiler.setDirective(      'OutputFlag',           '-o ');
        c_compiler.setDirective(      'Debug',                '-g');
        c_compiler.setFileExtension(  'Source',               '.c');
        c_compiler.setFileExtension(  'Header',               '.h');
        c_compiler.setFileExtension(  'Object',               '.o');
        c_compiler.setCommandPattern('|>TOOL<| |>TOOL_OPTIONS<| |>OUTPUT_FLAG<||>OUTPUT<|');        
    end

    function cpp_compiler()
        cpp_compiler = toolchain.getBuildTool( 'C++ Compiler');
        cpp_compiler.setName(           'Emscripten C++ Compiler');        
        if ispc
            cpp_compiler.setCommand(        'em++');       
        else
            cpp_compiler.setCommand(        '$(EMSDK_UPSTREAM_EMSCRIPTEN)/em++');
        end       
        cpp_compiler.setPath(           '');
        cpp_compiler.setDirective(      'CompileFlag',          '-c');
        cpp_compiler.setDirective(      'PreprocessFile',       '-E');
        cpp_compiler.setDirective(      'IncludeSearchPath',    '-I');
        cpp_compiler.setDirective(      'PreprocessorDefine',   '-D');
        cpp_compiler.setDirective(      'OutputFlag',           '-o ');
        cpp_compiler.setDirective(      'Debug',                '-g');
        cpp_compiler.setFileExtension(  'Source',               '.cpp');
        cpp_compiler.setFileExtension(  'Header',               '.h');
        cpp_compiler.setFileExtension(  'Object',               '.o');
        cpp_compiler.setCommandPattern('|>TOOL<| |>TOOL_OPTIONS<| |>OUTPUT_FLAG<||>OUTPUT<|');
    end

    function c_linker()
        c_linker = toolchain.getBuildTool( 'Linker');
        c_linker.setName(           'Emscripten C Linker');        
        if ispc
            c_linker.setCommand(        'emcc');       
        else
            c_linker.setCommand(        '$(EMSDK_UPSTREAM_EMSCRIPTEN)/emcc');
        end        
        c_linker.setPath(           '');
        c_linker.setDirective(      'Library',              '-l');
        c_linker.setDirective(      'LibrarySearchPath',    '-L');
        c_linker.setDirective(      'OutputFlag',           '-o ');
        c_linker.setDirective(      'Debug',                '-g');
        c_linker.setDirective(      'FileSeparator',        '/');
        c_linker.setFileExtension(  'Executable',           '.js');
        c_linker.setFileExtension(  'Shared Library',       '.js');
        c_linker.setCommandPattern('|>TOOL<| |>TOOL_OPTIONS<| |>OUTPUT_FLAG<||>OUTPUT<|');
    end

    function cpp_linker()
        cpp_linker = toolchain.getBuildTool( 'C++ Linker');
        cpp_linker.setName(           'Emscripten C++ Linker');        
        if ispc
            cpp_linker.setCommand(        'em++');       
        else
            cpp_linker.setCommand(        '$(EMSDK_UPSTREAM_EMSCRIPTEN)/em++');
        end        
        cpp_linker.setPath(           '');
        cpp_linker.setDirective(      'Library',              '-l');
        cpp_linker.setDirective(      'LibrarySearchPath',    '-L');
        cpp_linker.setDirective(      'OutputFlag',           '-o ');
        cpp_linker.setDirective(      'Debug',                '-g');
        cpp_linker.setDirective(      'FileSeparator',        '/');
        cpp_linker.setFileExtension(  'Executable',           '.js');
        cpp_linker.setFileExtension(  'Shared Library',       '.js');
        cpp_linker.setCommandPattern('|>TOOL<| |>TOOL_OPTIONS<| |>OUTPUT_FLAG<||>OUTPUT<|');        
    end

    function archiver()
        archiver = toolchain.getBuildTool( 'Archiver');
        archiver.setName(           'Emscripten C Archiver');       
        if ispc
            archiver.setCommand(        'emar');       
        else
            archiver.setCommand(        '$(EMSDK_UPSTREAM_EMSCRIPTEN)/emar');
        end        
        archiver.setPath(           '');
        archiver.setDirective(      'OutputFlag',           '-r ');
        archiver.setDirective(      'FileSeparator',        '/');
        archiver.setFileExtension(  'Static Library',       '.bc');
        archiver.setCommandPattern( '|>TOOL<| |>TOOL_OPTIONS<| |>OUTPUT_FLAG<||>OUTPUT<|');
    end

c_compiler();
c_linker();
cpp_compiler();
cpp_linker();
archiver();


% --------------------------------------------
% BUILD CONFIGURATIONS
% --------------------------------------------
optimsOffOpts    = {'-O0'};
optimsOnOpts     = {'-O3'};
cCompilerOpts    = {'-c -Wall'};
cppCompilerOpts  = {'-c -Wall -std=c++17'};
linkerOpts       = {'-s DEMANGLE_SUPPORT=1'};

archiverOpts     = {''};

% Get the debug flag per build tool
debugFlag.CCompiler   = '-g -D"_DEBUG"';   
debugFlag.Linker      = '-g';    
debugFlag.Archiver    = '-g';  

    function fasterBuildConfig()
        cfg = toolchain.getBuildConfiguration("Faster Builds");
        cfg.setOption( 'C Compiler',            horzcat(cCompilerOpts,   optimsOffOpts));
        cfg.setOption( 'C++ Compiler',          horzcat(cppCompilerOpts, optimsOffOpts));
        cfg.setOption( 'Linker',                linkerOpts);
        cfg.setOption( 'C++ Linker',            linkerOpts);
        cfg.setOption( 'Archiver',              archiverOpts);
    end

    function fasterRunsConfig()
        cfg = toolchain.getBuildConfiguration('Faster Runs');
        cfg.setOption( 'C Compiler',            horzcat(cCompilerOpts,   optimsOnOpts));
        cfg.setOption( 'C++ Compiler',          horzcat(cppCompilerOpts,   optimsOnOpts));
        cfg.setOption( 'Linker',                linkerOpts);
        cfg.setOption( 'C++ Linker',            linkerOpts);
        cfg.setOption( 'Archiver',              archiverOpts);
    end

    function debugConfig()
        cfg = toolchain.getBuildConfiguration('Debug');
        cfg.setOption( 'C Compiler',            horzcat(cCompilerOpts,   optimsOffOpts, debugFlag.CCompiler));
        cfg.setOption( 'C++ Compiler',          horzcat(cppCompilerOpts,   optimsOffOpts, debugFlag.CCompiler));
        cfg.setOption( 'Linker',                horzcat(linkerOpts,       debugFlag.Linker));
        cfg.setOption( 'C++ Linker',            horzcat(linkerOpts,       debugFlag.Linker));
        cfg.setOption( 'Archiver',              horzcat(archiverOpts,     debugFlag.Archiver));
    end

fasterBuildConfig();
fasterRunsConfig();
debugConfig();

% Set the toolchain flags for 'All' build configuration
toolchain.setBuildConfigurationOption('all', 'Download',      '');
toolchain.setBuildConfigurationOption('all', 'Execute',       '');
toolchain.setBuildConfigurationOption('all', 'Make Tool',     '-j32 -f $(MAKEFILE)');

end


