classdef VirtualSensor
    %DEVICEMOTION Virtual sensor on Supported Device
    %   The DeviceMoiton object is a virtual sensor that combines the real
    %   accelerometer, rate gyrometer, and magnetometer into a single
    %   sensor that provides full-axis measurements of the device
    %   translation and orientation.
    %
    %   Copyright 2019 The MathWorks, Inc.
    
    properties (GetAccess = private, SetAccess = immutable)
        cppVirtualSensor
    end
        
    methods
        %% Constructor
        function virtualSensor = VirtualSensor
            coder.cinclude("<functional>");
            coder.cinclude("<memory>");
            coder.cinclude("<string>");
            coder.cinclude("device/VirtualSensor.hpp"); 
            coder.updateBuildInfo("addSourceFiles","VirtualSensor.cpp","$(SUPPORTPACKAGESRC)/device");
            
            virtualSensor.cppVirtualSensor = coder.opaque("std::unique_ptr<mathworks::wasm::device::VirtualSensor>","NULL","HeaderFile","device/VirtualSensor.hpp");
            virtualSensor.cppVirtualSensor = coder.ceval("std::make_unique<mathworks::wasm::device::VirtualSensor>");            
        end
    end
    
    methods                  
        
        %% Callback Interaction
        function addDeviceOrientationEventListener(virtualSensor,callbackFcnName)
            % Add DeviceOrientation event listener to the app
            %
            % Use the addDeviceOrientationEventListener method to add a 
            % callback function to the app that is run when new device 
            % orientation data arrives. The callback function must be 
            % labelled in your project as a DeviceOrientation and
            % must use the following syntax:
            % 
            %   function callbackFcnName(event)
            %
            % where event is a MATLAB structure with the following form:
            %
            %   event = struct with fields:
            %           alpha: [double] - Yaw of device in degrees
            %            beta: [double] - Pitch of device in degrees
            %           gamma: [double] - Roll of device in degrees
            %        absolute: [logical] - Is measurement magnetometer corrected?       
			%       timeStamp: [double]
			%       isTrusted: [logical] - was event triggered by trusted source?
            %
            %
            % Inputs:
            %   obj - Element object
            %       webcoder.dom.Element            
            %   callbackFcnName - Name of callback function
            %       character vector
            %
            % Example:
            %   obj = webcoder.sensor.DeviceMotion();
            %   addDeviceOrientationEventListener(obj,'myCallbackFcn');
            %
            %   where
            %
            %   function myCallbackFcn(event)
            %       webcoder.console.log(['Pitch is ', sprintf('%f',event.beta)]);
            %   end
            %
            coder.cinclude("<functional>");
            coder.cinclude("<memory>");
            coder.cinclude("<string>");
            coder.cinclude("device/VirtualSensor.hpp"); 
            
            coder.extrinsic('wasm.project.isCallback');
            cond = coder.const(wasm.project.isCallback(string(callbackFcnName),"DeviceOrientationEvent"));
            coder.internal.assert(cond,'wasm:codegen:CallbackFunctionRequiresDeviceOrientationEventLabel',callbackFcnName);
                           
            eventNameStr = coder.opaque("std::string","""deviceorientation""");
            
            callbackFcnNameStr = coder.opaque("std::string","NULL"); %#ok<*NASGU> 
            callbackFcnNameStr = coder.ceval("std::string",[callbackFcnName,0]); 
            
            coder.ceval(...
                'std::mem_fn(&mathworks::wasm::device::VirtualSensor::addEventListener)',...
                virtualSensor.cppVirtualSensor,eventNameStr,callbackFcnNameStr);
        end
                      
        function removeDeviceOrientationEventListener(virtualSensor,callbackFcnName)
            % Remove DeviceOrientation event listener from the app
            %
            % Use the removeDeviceOrientationEventListener method to remove
            % a callback function from the app that is run when new device 
            % orientation data arrives. The callback function must have 
            % been previously added to the app using the 
            % addDeviceOrientationEventListener method. 
            %
            %
            % Inputs:
            %   obj - Element object
            %       webcoder.dom.Element            
            %   callbackFcnName - Name of callback function
            %       character vector
            %
            % Example:
            %   obj = webcoder.sensor.DeviceMotion();
            %   removeDeviceOrientationEventListener(obj,'myCallbackFcn');
            %
            %   where
            %
            %   function myCallbackFcn(event)
            %       webcoder.console.log(['Pitch is ', sprintf('%f',event.beta)]);
            %   end
            %
            coder.cinclude("<functional>");
            coder.cinclude("<memory>");
            coder.cinclude("<string>");
            coder.cinclude("device/VirtualSensor.hpp");  
            
            coder.extrinsic('wasm.project.isCallback');
            cond = coder.const(wasm.project.isCallback(string(callbackFcnName),"DeviceOrientationEvent"));
            coder.internal.assert(cond,'wasm:codegen:CallbackFunctionRequiresDeviceOrientationEventLabel',callbackFcnName);
                           
            eventNameStr = coder.opaque("std::string","""deviceorientation""");
            
            callbackFcnNameStr = coder.opaque("std::string","NULL");
            callbackFcnNameStr = coder.ceval("std::string",[callbackFcnName,0]); 
                        
            coder.ceval(...
                'std::mem_fn(&mathworks::wasm::device::VirtualSensor::removeEventListener)',...
                virtualSensor.cppVirtualSensor,eventNameStr,callbackFcnNameStr);
        end
   
        function addDeviceMotionEventListener(virtualSensor,callbackFcnName)
            % Add DeviceMotion event listener to the app
            %
            % Use the addDeviceOrientationEventListener method to add a 
            % callback function to the app that is run when new device 
            % orientation data arrives. The callback function must be 
            % labelled in your project as a DeviceOrientation and
            % must use the following syntax:
            % 
            %   function callbackFcnName(event)
            %
            % where event is a MATLAB structure with the following form:
            %
            %   event = struct with fields:
            %       acceleration: [struct]
            %               .x: [double] - Acceleration in x-axis
            %               .y: [double] - Acceleration in y-axis
            %               .z: [double] - Acceleration in z-axis
            %   accelerationIncludingGravity: [struct]
            %               .x: [double] - Acceleration in x-axis
            %               .y: [double] - Acceleration in y-axis
            %               .z: [double] - Acceleration in z-axis
            %       rotationRate: [struct]
            %           .alpha: [double] - Yaw of device in degrees
            %            .beta: [double] - Pitch of device in degrees
            %           .gamma: [double] - Roll of device in degrees
            %       absolute: [logical] - Is measurement magnetometer corrected?       
			%       timeStamp: [double]
			%      isTrusted: [logical] - was event triggered by trusted source?
            %        interval: [double]
            %
            %
            % Inputs:
            %   obj - Element object
            %       webcoder.dom.Element            
            %   callbackFcnName - Name of callback function
            %       character vector
            %
            % Example:
            %   obj = webcoder.sensor.DeviceMotion();
            %   addDeviceMotionEventListener(obj,'myCallbackFcn');
            %
            %   where
            %
            %   function myCallbackFcn(event)
            %       webcoder.console.log(['Pitch is ', sprintf('%f',event.beta)]);
            %   end
            %
            coder.cinclude("<functional>");
            coder.cinclude("<memory>");
            coder.cinclude("<string>");
            coder.cinclude("device/VirtualSensor.hpp");  
            
            coder.extrinsic('wasm.project.isCallback');
            cond = coder.const(wasm.project.isCallback(string(callbackFcnName),"DeviceMotionEvent"));
            coder.internal.assert(cond,'wasm:codegen:CallbackFunctionRequiresDeviceMotionEventLabel',callbackFcnName);
                           
            eventNameStr = coder.opaque("std::string","""devicemotion""");
            
            callbackFcnNameStr = coder.opaque("std::string","NULL");
            callbackFcnNameStr = coder.ceval("std::string",[callbackFcnName,0]); 
            
            coder.ceval(...
                'std::mem_fn(&mathworks::wasm::device::VirtualSensor::addEventListener)',...
                virtualSensor.cppVirtualSensor,eventNameStr,callbackFcnNameStr);
        end
                      
        function removeDeviceMotionEventListener(virtualSensor,callbackFcnName)
            % Remove DeviceMotion event listener to the app
            %
            % Use the removeDeviceMotionEventListener method to remove
            % a callback function from the app that is run when new device 
            % motion data arrives. The callback function must have been 
            % previously added to the app using the 
            % addDeviceMotionEventListener method. 
            %
            %
            % Inputs:
            %   obj - Element object
            %       webcoder.dom.Element            
            %   callbackFcnName - Name of callback function
            %       character vector
            %
            % Example:
            %   obj = webcoder.sensor.DeviceMotion();
            %   removeDeviceMotionEventListener(obj,'myCallbackFcn');
            %
            %   where
            %
            %   function myCallbackFcn(event)
            %       webcoder.console.log(['Pitch is ', sprintf('%f',event.beta)]);
            %   end
            %
            coder.cinclude("<functional>");
            coder.cinclude("<memory>");
            coder.cinclude("<string>");
            coder.cinclude("device/VirtualSensor.hpp");   
            
            coder.extrinsic('wasm.project.isCallback');
            cond = coder.const(wasm.project.isCallback(string(callbackFcnName),"DeviceMotionEvent"));
            coder.internal.assert(cond,'wasm:codegen:CallbackFunctionRequiresDeviceMotionEventLabel',callbackFcnName);
                           
            eventNameStr = coder.opaque("std::string","""devicemotion""");
            
            callbackFcnNameStr = coder.opaque("std::string","NULL");
            callbackFcnNameStr = coder.ceval("std::string",[callbackFcnName,0]); 
                        
            coder.ceval(...
                'std::mem_fn(&mathworks::wasm::device::VirtualSensor::removeEventListener)',...
                virtualSensor.cppVirtualSensor,eventNameStr,callbackFcnNameStr);
        end
        
    end
end
