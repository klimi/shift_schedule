// Copyright 2019 The MathWorks, Inc.
#include "dom/input.hpp"

mathworks::wasm::dom::Input::Input(const std::string id) : DOM::Element::Element(id){};

// Checked
auto mathworks::wasm::dom::Input::checked(void) -> bool
{
    return this->element_["checked"].as<bool>();
};

auto mathworks::wasm::dom::Input::setChecked(const bool value) -> void
{
    this->element_.set("checked", val(value));
    return;
};

// Value
auto mathworks::wasm::dom::Input::value(void) -> std::string
{
    return this->element_["value"].as<std::string>();
};

auto mathworks::wasm::dom::Input::setValue(const std::string value) -> void
{
    this->element_.set("value", val(value));
    return;
};