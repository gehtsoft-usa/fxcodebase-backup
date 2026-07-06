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
    indicator:name("Generalized DEMA");
    indicator:description("Generalized DEMA");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("VF", "Volume Factor", "Volume Factor", 0.7,0,1);
    indicator.parameters:addInteger("F", "Period", "Period", 20, 2,2000);
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("GD_color", "Color of GD", "Color of GD", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local VF=nil;
local Frame=nil;
local EMA=nil;
local EMAofEMA=nil;

local first;
local source = nil;

-- Streams block
local GD = nil;

-- Routine
function Prepare(nameOnly)
    VF = instance.parameters.VF;
    Frame = instance.parameters.F;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. VF .. ", " .. Frame .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end     
	
	 EMA = core.indicators:create("EMA", source, Frame);
	 EMAofEMA = core.indicators:create("EMA", EMA.DATA, Frame);
	 first = EMAofEMA.DATA:first();

    GD = instance:addStream("GD", core.Line, name, "GD", instance.parameters.GD_color, Frame*2);
	GD:setWidth(instance.parameters.width);
    GD:setStyle(instance.parameters.style);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    EMA:update(mode);
    EMAofEMA:update(mode);

 
     if period < first then
   return;
   end
 
    GD[period] = EMA.DATA[period]* (1+VF) - EMAofEMA.DATA[period]*VF;
    
end

