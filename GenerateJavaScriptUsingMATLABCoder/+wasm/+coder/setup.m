function setup(userInstall)
%SETUP Generate, save, and register the toolchain and devices.
%
% Copyright 2021 The MathWorks, Inc.
%
arguments
    userInstall (1,1) logical = false;
end

% Add and Register Toolchain
[tc,res] = wasm.coder.emscriptenToolchain();

if res.error ~= 0
    errorID = "WASM:TOOLCHAIN:generationFailed";
    message = res.message;
    throwAsCaller(MException(errorID,message));
end

save(fullfile(wasm.utilities.getRootDirectory,"registry","emscripten_tc.mat"),"tc");
RTW.TargetRegistry.getInstance('reset');

% Add and Register Browser/NodeJS
wasm.coder.hardware(userInstall);

end