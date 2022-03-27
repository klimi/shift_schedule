// Copyright 2019 The MathWorks, Inc.
#ifndef MATHWORKS_WASM_DEVICE_VIRTUALSENSOR_H
#define MATHWORKS_WASM_DEVICE_VIRTUALSENSOR_H

#include <iostream>
#include <emscripten.h>
#include <emscripten/bind.h>
#include <emscripten/val.h>
#include <string>

namespace mathworks::wasm::device
{
    class VirtualSensor
    {

    private:
        const emscripten::val window_;

    public:
        VirtualSensor(void);

        // Callbacks
        auto addEventListener(const std::string eventName, const std::string callbackFcnName) -> void;
        auto removeEventListener(const std::string eventName, const std::string callbackFcnName) -> void;
    };
} // namespace Sensor

#endif // MATHWORKS_WASM_DEVICE_VIRTUALSENSOR_H