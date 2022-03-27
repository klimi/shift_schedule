function hardware(userInstall)
%HARDWARE Add the Google V8 Engine to the target registry
%   Adds the WASM target language implementation and V8 Engine processor to 
%   the target registry.
%
% Inputs:
%   userInstall (logical) - Add target to user between MATLAB sessions.
%       Add target implementations to user between MATLAB sessions.
%       [ false (default) | true]
%
% Example:
%   Build the current project, `proj`, run
%   >> wasm.coder.hardware();
%   target.add summary:
%       Objects added to internal database for current MATLAB session:
%           target.LanguageImplementation    "Web Assembly (WASM)"
%           target.Processor                 "Google-V8 Engine"
%
%
% Copyright 2021 The MathWorks, Inc.
%

arguments
    userInstall (1,1) logical = false;
end

    function language = wasmLanguageImplementation()

        % https://webassembly.org/docs/portability/
        language = target.create("LanguageImplementation","Name","Web Assembly (WASM)");
        
        language.Endianess = target.Endianess.Little;
        
        language.AtomicIntegerSize = 32;
        language.AtomicFloatSize = 32;
        language.WordSize = 32;
        
        language.DataTypes.Char.Size = 8;
        language.DataTypes.Short.Size = 16;
        language.DataTypes.Int.Size = 32;
        language.DataTypes.Long.Size = 32;
        language.DataTypes.LongLong.IsSupported = true;
        language.DataTypes.LongLong.Size = 64;
        language.DataTypes.Float.Size = 32;
        language.DataTypes.Double.Size = 64;
        
        language.DataTypes.Pointer.Size = 32;
        
        language.DataTypes.SizeT.Size = 64;
        language.DataTypes.PtrDiffT.Size = 64;

    end

v8engine = target.get("Processor", "Name","V8 Engine");
if ~isempty(v8engine)
    target.remove(v8engine);    
end
languageImplementation = target.get("LanguageImplementation", "Name","Web Assembly (WASM)");
if ~isempty(languageImplementation)
    target.remove(languageImplementation);    
end

v8engine = target.create("Processor","Name","V8 Engine","Manufacturer","Google");
v8engine.LanguageImplementations = wasmLanguageImplementation();

target.add(v8engine, "UserInstall", userInstall);

end