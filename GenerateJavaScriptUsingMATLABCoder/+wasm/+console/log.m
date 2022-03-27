function log(str)

if coder.target("MATLAB")
    disp(str);
else
    coder.updateBuildInfo("addIncludePaths","$(SUPPORTPACKAGEINCLUDE)");    
    coder.cinclude("console.hpp");
    coder.updateBuildInfo("addSourceFiles","console.cpp","$(SUPPORTPACKAGESRC)");
    coder.ceval("mathworks::wasm::console::log",char([str,0]));
end

end

