// Copyright 2021 The MathWorks, Inc.

#include "dom/element.hpp"

mathworks::wasm::dom::Element::Element(const std::string id) : element_(emscripten::val::global("document").call<emscripten::val>("getElementById", id)){
                                                                   // throw excpetion for element not found.
                                                               };

// Inner Text and HTML
auto mathworks::wasm::dom::Element::getInnerText(void) -> std::string
{
    return this->element_["innerText"].as<std::string>();
};

auto mathworks::wasm::dom::Element::getInnerHTML(void) -> std::string
{
    return this->element_["innerHTML"].as<std::string>();
};

auto mathworks::wasm::dom::Element::setInnerText(const std::string innerText) -> void
{
    this->element_.set("innerText", emscripten::val(innerText));
};

auto mathworks::wasm::dom::Element::setInnerHTML(const std::string innerHTML) -> void
{
    this->element_.set("innerHTML", emscripten::val(innerHTML));
};

// Cascading Style Sheet (CSS)
auto mathworks::wasm::dom::Element::getStyle(const std::string property) -> std::string
{
    const emscripten::val window = emscripten::val::global("window");
    const emscripten::val style = window.call<emscripten::val>("getComputedStyle", this->element_);
    return style[property].as<std::string>();
};

auto mathworks::wasm::dom::Element::setStyle(const std::string property, const std::string value) -> void
{
    this->element_["style"].call<void>("setProperty", property, value);
};

// Callbacks
auto mathworks::wasm::dom::Element::addEventListener(const std::string eventName, const std::string callbackFcnName) -> void
{
    const emscripten::val callbackWrapperFcn = emscripten::val::global("Module")[callbackFcnName];
    this->element_.call<void>("addEventListener", emscripten::val(eventName), callbackWrapperFcn);
};

auto mathworks::wasm::dom::Element::removeEventListener(const std::string eventName, const std::string callbackFcnName) -> void
{
    const emscripten::val callbackWrapperFcn = emscripten::val::global("Module")[callbackFcnName];
    this->element_.call<void>("removeEventListener", emscripten::val(eventName), callbackWrapperFcn);
    return;
};
