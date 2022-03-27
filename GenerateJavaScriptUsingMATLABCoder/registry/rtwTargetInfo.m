function rtwTargetInfo(tr)
% RTWTARGETINFO Target info callback

tr.registerTargetInfo(@loc_createToolchain);

end

% -------------------------------------------------------------------------
% Create the ToolchainInfoRegistry entries
% -------------------------------------------------------------------------
function config = loc_createToolchain

config(1)           = coder.make.ToolchainInfoRegistry;

config(1).Name = coder.make.internal.formToolchainName(...
    'Emscripten',...
    computer('arch'),...
    char(wasm.utilities.ExternalTool.version("Emscripten")),...
    'gmake'...
    );

config(1).FileName  = fullfile(wasm.utilities.getRootDirectory,"registry","emscripten_tc.mat");
config(1).TargetHWDeviceType		 =  {'*'};
config(1).Platform  = {computer('arch')};

end

