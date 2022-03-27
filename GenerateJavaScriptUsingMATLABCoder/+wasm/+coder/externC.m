function externC(filename)
%EXTERNC Update entry-point functions as extern "C"
%   Update a .h or .hpp entry-point function by making the call extern "C" 
%   to allow external linking with other libraries.
%
% Copyright 2021 The MathWorks, Inc.
%

arguments
    filename {mustBeFile,mustBeHeaderFile}    
end

str = fileread(filename);
%str = strip(str,"←");
str = strrep(str,"extern","extern ""C""");

str = uint8(char(str));
str = str(str ~= uint8(13));

fileID = fopen(filename,"w");
fwrite(fileID,str);
fclose(fileID);

end

function mustBeHeaderFile(filename)
    [~,~,ext] = fileparts(filename);
    if ~(strcmp(ext,".h") || strcmp(ext,".hpp"))
        errorID = "WASM:ExternC:mustBeCppHeader";
        message = "File must be a C++ header file.";
        throwAsCaller(MException(errorID,message));
    end
end