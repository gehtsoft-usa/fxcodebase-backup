-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=71043

--+------------------------------------------------------------------+
--|                               Copyright © 2021, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   Dogecoin : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("TSI Overlay");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	 indicator.parameters:addGroup("Source");	
	indicator.parameters:addString("Method", "MA Method", "Method" , "Price");
	indicator.parameters:addStringAlternative("Method", "Price", "Price" , "Price");
	indicator.parameters:addStringAlternative("Method", "HMA", "HMA" , "HMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	 indicator.parameters:addInteger("Method_Period", "Method Period", "", 7, 1, 2000);

	
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("P1", "Short Period", "", 7, 1, 2000);
    indicator.parameters:addInteger("P2", "Long Period", "", 14, 1, 2000);
     indicator.parameters:addInteger("Period", "Range Period", "", 200, 1, 2000);
	
	 indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("color_central", "Central Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
 
	
end

-- Indicator instance initialization routine
local first;
local P1, P2,Period;
local TSI;
local tsi_raw, tsi;
local Method;
local Method_Period;
local Source;
local MA;
-- Streams block
 
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
    P1 = instance.parameters.P1;
    P2 = instance.parameters.P2; 
    Period = instance.parameters.Period;
	Method= instance.parameters.Method;
	Method_Period= instance.parameters.Method_Period;
    source = instance.source;
	
	

 
    
    Source = instance:addInternalStream(0, 0);
	
    if Method ~= "Price" then
	
	assert(core.indicators:findIndicator(Method) ~= nil, "Please, download and install" .. Method .. ".LUA indicator");
		
	MA = core.indicators:create(Method, source, Method_Period);    
	end
	
	TSI = core.indicators:create("TSI", Source, P1, P2);    
 
	
    first = TSI.DATA:first() +Period ;
	
 
 
    tsi = instance:addStream("tsi", core.Line, name .. ".tsi", "tsi", instance.parameters.color, first);  
	tsi_raw = instance:addStream("tsi_raw", core.Line, name .. ".tsi_raw", "tsi_raw", instance.parameters.color, first)
	tsi:setWidth(instance.parameters.width);
    tsi:setStyle(instance.parameters.style);
 


	
	instance:ownerDrawn(true);
	
	tsi_raw:setVisible (false);


end

local init = false;
 
function Draw(stage, context)
    if stage ~= 2 then
	return;
	end
        if not init then
            context:createPen(1,context.SOLID,1, instance.parameters.color_central);
			
            init = true;
        end
		
	local Top = context:top();
	local Bottom = context:bottom();  	
	local Central= Bottom -(Bottom-Top)/2;
	local First=context:firstBar ();
	local Last=context:lastBar (); 
	 
	
	local bottom= context:priceOfPoint (Bottom);
	local top= context:priceOfPoint (Top);
	local delta= (top-bottom)  ;
	
	context:drawLine (1, context:left (),Central, context:right (),Central, 0);
		
	
	for period= First, Last, 1 do
	tsi[period]= bottom + (tsi_raw[period]/100)* delta ;
	end
end		

-- Indicator calculation routine
function Update(period, mode)

    
	
	 
     if Method == "Price" then
     Source[period]=source[period];
	 else
	 MA:update(mode);
	 Source[period]=MA.DATA[period];
	 end
	 
   

    TSI:update(mode);

    if (period <first) then
	return;
	end
	
	
        local min, max;
        local range;        
        min,max = mathex.minmax(TSI.DATA,period-Period+1, period);
      
        if (min == max) then
            tsi_raw[period] = 100;
        else
            tsi_raw[period] = (TSI.DATA[period] - min) / (max - min) * 100;
        end
     
	
end	 

