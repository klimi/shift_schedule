// Copyright 2019 The MathWorks, Inc.
#ifndef MATHWORKS_WASM_DOM_INPUT_H
#define MATHWORKS_WASM_DOM_INPUT_H

#include <iostream>
#include "dom/element.h"
#include <emscripten.h>
#include <emscripten/bind.h>
#include <emscripten/val.h>
#include <string>

namespace mathworks::wasm::dom
{
class Input : public Element
{

public:	
    Input(const std::string id): DOM::Element::Element(id) {};

    // Checked
    auto checked(void) -> bool;
    auto setChecked(const bool value) -> void;

    // Value
    auto value(void) -> std::string;
    auto setValue(const std::string value) -> void;
};

} // namespace DOM

#endif // MATHWORKS_WASM_DOM_INPUT_H