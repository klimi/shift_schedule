// Copyright 2021 The MathWorks, Inc.
#ifndef MATHWORKS_WASM_DOM_ELEMENT_H
#define MATHWORKS_WASM_DOM_ELEMENT_H

#include <iostream>
#include <emscripten.h>
#include <emscripten/bind.h>
#include <emscripten/val.h>
#include <string>

namespace mathworks::wasm::dom
{
    class Element
    {
    private:
        emscripten::val element_;

    public:
        Element(const std::string id);

        // Inner Text and HTML
        auto getInnerText(void) -> std::string;
        auto getInnerHTML(void) -> std::string;
        auto setInnerText(const std::string innerText) -> void;
        auto setInnerHTML(const std::string innerHTML) -> void;

        // Cascading Style Sheet (CSS)
        auto getStyle(const std::string property) -> std::string;
        auto setStyle(const std::string property, const std::string value) -> void;

        // Callbacks
        auto addEventListener(const std::string eventName, const std::string callbackFcnName) -> void;
        auto removeEventListener(const std::string eventName, const std::string callbackFcnName) -> void;
    };
};

#endif // MATHWORKS_WASM_DOM_ELEMENT_H