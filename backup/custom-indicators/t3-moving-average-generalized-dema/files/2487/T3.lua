-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1302

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("T3 Average");
    indicator:description("T3 Average");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("VF", "Volume Factor", "Volume Factor", 0.7, 0, 1);
    indicator.parameters:addInteger("F", "Period", "Period",20,2,2000);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("T3_color", "Color of T3", "Color of T3", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local b=nil;
local Frame=nil;
local T3=nil;

local first;
local source = nil;

-- Streams block

local GD1;
local GD2;
local GD3;

-- Routine
function Prepare(nameOnly)
    b = instance.parameters.VF;
    Frame = instance.parameters.F;
    source = instance.source;
   
	local name = profile:id() .. "(" .. source:name() .. ", " .. b .. ", " .. Frame .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	 assert(core.indicators:findIndicator("GD") ~= nil, "Please, download and install GD.LUA indicator"); 	
	 GD1 = core.indicators:create("GD", source, b, Frame);
	 GD2 = core.indicators:create("GD", GD1.DATA, b, Frame);
     GD3 = core.indicators:create("GD", GD2.DATA, b, Frame);
	 
	first = GD3.DATA:first();
	
    T3 = instance:addStream("T3", core.Line, name, "T3", instance.parameters.T3_color, first);
	T3:setWidth(instance.parameters.width);
    T3:setStyle(instance.parameters.style);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

   
    GD1:update(mode);
	GD2:update(mode);
	GD3:update(mode);
	
 
   if period < first then
   return;
   end
   
	
    T3[period] = GD3.DATA[period];
    
end


