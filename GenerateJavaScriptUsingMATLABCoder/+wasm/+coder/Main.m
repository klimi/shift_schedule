classdef Main < handle
    
    properties (SetObservable, AbortSet, Access = private)
        str string = string.empty();
    end
    
    properties (Access = private)
        filename string = string.empty();
        language {mustBeMember(language,["C","C++"])} = "C++";
    end
    
    methods (Access = private)
        function updateFile(mainfile)
            arguments
                mainfile
            end
            
            fileID = fopen(mainfile.filename,"a");
            fprintf(fileID,"%s",mainfile.str + newline);
            fclose(fileID);
        end
    end
    
    methods
        function main = Main(folder,language)
            arguments
                folder {mustBeFolder};
                language {mustBeMember(language,["C","C++"])};
            end
            
            if strcmp(language,"C")
                filename = fullfile(folder,"main.c");
            else
                filename = fullfile(folder,"main.cpp");
            end
            
            fileID = fopen(filename,"w");
            fprintf(fileID,"%s",main.str + newline);
            fclose(fileID);
            
            main.filename = filename;
            main.language = language;
            addlistener(main,"str","PostSet",@(~,eventData)eventData.AffectedObject.updateFile());
        end
        
        
        function str = mainFcn(main,FUNCTION)
            
            arguments
                main (1,1) wasm.coder.Main;
                FUNCTION {mustBeTextScalar};
            end
            
            main.include("LOCAL",[FUNCTION+"_initialize.h",FUNCTION+".h",FUNCTION+"_terminate.h"]);   
            
            if strcmp(main.language,"C++")                
                main.include("GLOBAL","cstdlib");                
                str = "int main() {" + newline;
                str = str + "    " + FUNCTION + "_initialize();" + newline;
                str = str + "    " + FUNCTION + "();" + newline;
                str = str + "    std::atexit(" + FUNCTION + "_terminate);" + newline;
                str = str + "    return 0;" + newline;
                str = str + "}";                
            else                
                str = "int main() {" + newline;
                str = str + "    " + FUNCTION + "_initialize();" + newline;
                str = str + "    " + FUNCTION + "();" + newline;
                str = str + "    " + FUNCTION + "_terminate();" + newline;
                str = str + "    return 0;" + newline;
                str = str + "}";                
            end
                        
            main.str = str;
        end   
        
        
        function str = include(main,TYPE,HEADERS)
            arguments
                main (1,1) wasm.coder.Main;
            end
            
            arguments (Repeating)
                TYPE {mustBeMember(TYPE,["LOCAL","GLOBAL"])}
                HEADERS (1,:) string
            end
            
            str = "";
            for i = 1:length(TYPE)
                if TYPE{i} == "LOCAL"
                    for headerfile = HEADERS{i}
                        str = str + "#include """ + headerfile + """" + newline;
                    end
                else
                    for headerfile = HEADERS{i}
                        str = str + "#include <" + headerfile + ">" + newline;
                    end
                end
            end
            
            main.str = str;
        end
    end
   
end