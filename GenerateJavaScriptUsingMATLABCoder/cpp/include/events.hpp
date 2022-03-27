// Copyright 2021 The MathWorks, Inc.
#ifndef MATHWORKS_WASM_EVENT_H
#define MATHWORKS_WASM_EVENT_H

#include <emscripten.h>
#include <emscripten/bind.h>
#include <emscripten/val.h>
#include "coder/coder_array/coder_array_rtw_cpp11.h" // matlabroot/extern/include
#include <rtwtypes.h>
#include <cmath>

namespace mathworks::wasm::event
{
    template <typename T, auto (*callback)(const T *)->void>
    void callbackWrapper(emscripten::val event)
    {
        const T transformedEvent(event);
        callback(&transformedEvent);
    };

    struct Event
    {
        double timeStamp;
        bool isTrusted;
        Event(const emscripten::val event);
    };

    struct UIEvent : Event
    {
        coder::array<char, 2> id;
        double offsetX;
        double offsetY;
        UIEvent(const emscripten::val event);
    };

    struct MouseEvent : UIEvent
    {
        bool altKey;
        bool ctrlKey;
        bool shiftKey;
        bool metaKey;
        MouseEvent(const emscripten::val event);
    };

    struct Acceleration
    {
        double x, y, z;
    };

    struct RotationRate
    {
        double alpha, beta, gamma;
    };

    struct DeviceMotionEvent
    {
        Acceleration acceleration, accelerationIncludingGravity;
        RotationRate rotationRate;
        double interval;
        DeviceMotionEvent(const emscripten::val event);
    };

    struct DeviceOrientationEvent
    {
        double absolute, alpha, beta, gamma;
        DeviceOrientationEvent(const emscripten::val event);
    };
}

#endif // MATHWORKS_WASM_EVENT_H