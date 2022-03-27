// Copyright 2019 The MathWorks, Inc.
#include "device/VirtualSensor.hpp"

mathworks::wasm::device::VirtualSensor::VirtualSensor(void) : window_(emscripten::val::global("window")){};

// Callbacks
auto mathworks::wasm::device::VirtualSensor::addEventListener(const std::string eventName, const std::string callbackFcnName) -> void
{
    const emscripten::val callbackWrapperFcn = emscripten::val::global("Module")[callbackFcnName];
    this->window_.call<void>("addEventListener", emscripten::val(eventName), callbackWrapperFcn);
    return;
};

auto mathworks::wasm::device::VirtualSensor::removeEventListener(const std::string eventName, const std::string callbackFcnName) -> void
{
    const emscripten::val callbackWrapperFcn = emscripten::val::global("Module")[callbackFcnName];
    this->window_.call<void>("removeEventListener", emscripten::val(eventName), callbackWrapperFcn);
    return;
};
