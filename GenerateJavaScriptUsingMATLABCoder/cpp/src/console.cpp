// Copyright 2021 The MathWorks, Inc.
#include "console.hpp"
void mathworks::wasm::console::log(const char *message)
{
    std::cout << std::string(message) << std::endl;
};

void mathworks::wasm::console::error(const char *message)
{
    std::cerr << std::string(message) << std::endl;
};
