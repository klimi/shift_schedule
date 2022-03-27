// Copyright 2021 The MathWorks, Inc.

#include "events.hpp"

mathworks::wasm::event::Event::Event(const emscripten::val event) : timeStamp{event["timeStamp"].as<double>()},
                                                                    isTrusted{event["isTrusted"].as<bool>()} {};

mathworks::wasm::event::UIEvent::UIEvent(const emscripten::val event) : Event(event),
                                                                        id{coder::array<char, 2>(event["target"]["id"].as<std::string>())},
                                                                        offsetX{event["offsetX"].as<double>()},
                                                                        offsetY{event["offsetY"].as<double>()} {};

mathworks::wasm::event::MouseEvent::MouseEvent(const emscripten::val event) : UIEvent(event),
                                                                              altKey{event["altKey"].as<bool>()},
                                                                              ctrlKey{event["ctrlKey"].as<bool>()},
                                                                              shiftKey{event["shiftKey"].as<bool>()},
                                                                              metaKey{event["metaKey"].as<bool>()} {};

mathworks::wasm::event::DeviceMotionEvent::DeviceMotionEvent(const emscripten::val event)
{
    auto convert = [](emscripten::val input)
    {
        if (input.isNumber())
            return input.as<double>();
        else
            return std::nan("1");
    };

    this->acceleration = {.x = convert(event["acceleration"]["x"]),
                          .y = convert(event["acceleration"]["y"]),
                          .z = convert(event["acceleration"]["z"])};
    this->accelerationIncludingGravity = {.x = convert(event["accelerationIncludingGravity"]["x"]),
                                          .y = convert(event["accelerationIncludingGravity"]["y"]),
                                          .z = convert(event["accelerationIncludingGravity"]["z"])};
    this->rotationRate = {.alpha = convert(event["rotationRate"]["alpha"]),
                          .beta = convert(event["rotationRate"]["beta"]),
                          .gamma = convert(event["rotationRate"]["gamma"])};
    this->interval = event["interval"].as<double>();
};

mathworks::wasm::event::DeviceOrientationEvent::DeviceOrientationEvent(const emscripten::val event)
{
    auto convert = [](emscripten::val input)
    {
        if (input.isNumber())
            return input.as<double>();
        else
            return std::nan("1");
    };
    this->absolute = convert(event["absolute"]);
    this->alpha = convert(event["alpha"]);
    this->beta = convert(event["beta"]);
    this->gamma = convert(event["gamma"]);
};