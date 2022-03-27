classdef EventInterface
    %EVENTiNTERFACE Enumeration of event interface structures
    %   This enumeration class defines the event interface structures for
    %   interacting with the document object module (DOM) in the browser.
    %   A set of methods also return the respective structures.
    %
    % Example:
    %   Get the structure for an Event, run
    %   >> sig = getSignature(wasm.project.EventInterface.Event)
    %
    %   sig = 
    %   coder.StructType
    %      1×1 Event struct
    %         timeStamp: 1×1 double
    %         isTrusted: 1×1 logical
    %
    % Copyright 2021 The MathWorks, Inc.
    %
    enumeration
        Event,...
        UIEvent,...
        MouseEvent,...
        MessageEvent,
        DeviceMotionEvent,
        DeviceOrientationEvent
    end
    
    methods
        function signature = getSignature(eventInterface)
            %GETSIGNATURE Get event signature structure
            %   Get the structure of the event signature for the specified
            %   event.
            %
            % Inputs:
            %   eventInterface (this) - Event interface enumeration
            %       The event interface enumeration.
            %
            % Outputs:
            %   signature (coder.StructType) - Structure interface
            %             
            switch eventInterface
                case "Event"       
                    S = eventInterface.eventSignature();
                    signature = coder.cstructname(S,"mathworks::wasm::event::Event","extern","HeaderFile","events.hpp");                    
                    
                case "UIEvent"
                    S = eventInterface.uiEventSignature();  
                    signature = coder.cstructname(S,"mathworks::wasm::event::UIEvent","extern","HeaderFile","events.hpp");                    
                                        
                case "MouseEvent"
                    S = eventInterface.mouseEventSignature();
                    signature = coder.cstructname(S,"mathworks::wasm::event::MouseEvent","extern","HeaderFile","events.hpp");                    
                                        
                case "MessageEvent"
                    S = eventInterface.messageEventSignature();
                    signature = coder.cstructname(S,"mathworks::wasm::event::MessageEvent","extern","HeaderFile","events.hpp");                    
                                                           
                case "DeviceMotionEvent"
                    S = eventInterface.deviceMotionEventSignature();
                    signature = coder.cstructname(S,"mathworks::wasm::event::DeviceMotionEvent","extern","HeaderFile","events.hpp");
                    
                case "DeviceOrientationEvent"
                    S = eventInterface.deviceOrientationEventSignature();                                       
                    signature = coder.cstructname(S,"mathworks::wasm::event::DeviceOrientationEvent","extern","HeaderFile","events.hpp");   
            end
            
        end
    end
    
    methods (Access = private)
        function S = eventSignature(~)            
            S.timeStamp = coder.typeof(double(0));
            S.isTrusted = coder.typeof(false);            
        end
        
        function S = uiEventSignature(eventInterface)
            S = eventInterface.eventSignature();
            S.id = coder.newtype('char',[1,inf],[0,1]);
            S.offsetX = coder.typeof(double(0));
            S.offsetY = coder.typeof(double(0));
        end
        
        function S = mouseEventSignature(eventInterface)
            S = eventInterface.uiEventSignature();
            S.altKey = coder.typeof(false);
            S.ctrlKey = coder.typeof(false);
            S.shiftKey = coder.typeof(false);
            S.metaKey = coder.typeof(false);
        end
        
        function S = messageEventSignature(eventInterface)
            S = eventInterface.eventSignature();
            S.data = coder.newtype('char',[1,inf],[0,1]);
            S.origin = coder.newtype('char',[1,inf],[0,1]);
        end
        
        function S = deviceMotionEventSignature(obj)
            S = obj.eventSignature();  
            Acceleration.x = coder.typeof(double(0));
            Acceleration.y = coder.typeof(double(0));
            Acceleration.z = coder.typeof(double(0));
            Acceleration = coder.cstructname(Acceleration,"mathworks::wasm::event::Acceleration","extern","HeaderFile","events.hpp");      

            S.acceleration = Acceleration;
            S.accelerationIncludingGravity = Acceleration;

            RotationRate.alpha = coder.typeof(double(0));
            RotationRate.beta = coder.typeof(double(0));
            RotationRate.gamma = coder.typeof(double(0));
            RotationRate = coder.cstructname(RotationRate,"mathworks::wasm::event::RotationRate","extern","HeaderFile","events.hpp");      

            S.rotationRate = RotationRate;

            S.interval = coder.typeof(double(0));
        end
        
        function S = deviceOrientationEventSignature(obj)
            S = obj.eventSignature();
            S.absolute = coder.typeof(false);
            S.alpha = coder.typeof(double(0));
            S.beta = coder.typeof(double(0));
            S.gamma = coder.typeof(double(0));
        end
    end
    
end
