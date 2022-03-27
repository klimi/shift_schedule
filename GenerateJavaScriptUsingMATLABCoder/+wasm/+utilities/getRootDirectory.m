function rootDirectory = getRootDirectory()
%GETROOTDIRECTORY Get the WebWasm root directory
% Get the root directory of the webwasm support package
%
% Outputs:                
%   rootDirectory (string) - Full path to add-on root directory.
%
% Copyright 2021 The MathWorks, Inc.
%

filename = mfilename('fullpath');
partsOfFilePath = coder.const(split(filename,filesep));
partsOfFilePath = partsOfFilePath(1:(end-3));
rootDirectory = strjoin(partsOfFilePath,filesep);
rootDirectory = string(rootDirectory);

end