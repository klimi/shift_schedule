// Copyright 2021 The MathWorks, Inc.
#ifndef MATHWORKS_WASM_EVENT_MESSAGEEVENT_H
#define MATHWORKS_WASM_EVENT_MESSAGEEVENT_H

#include <emscripten.h>
#include <emscripten/bind.h>
#include <emscripten/val.h>
#include <string>
#include <coder_array.h>
#include <rtwtypes.h>

namespace mathworks::wasm::event
{

    template <auto (*callback)(const MessageEvent *)->void>
    [[noreturn]] static void messageEventCallbackWrapper(emscripten::val event)
    {
        const MessageEvent messageEvent = {
            coder::array<char_t, 2>(event["data"].as<std::string>())};

        callback(&messageEvent);
    };

};

#endif // MATHWORKS_WASM_EVENT_MESSAGEEVENT_H