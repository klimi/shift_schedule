// Copyright 2021 The MathWorks, Inc.
#ifndef MATHWORKS_WASM_CONSOLE_H
#define MATHWORKS_WASM_CONSOLE_H

#include <iostream>
#include <string>
#include <emscripten/val.h>

namespace mathworks::wasm::console 
{
    void log(const char *message);

    void error(const char *message);

};

#endif // MATHWORKS_WASM_CONSOLE_H