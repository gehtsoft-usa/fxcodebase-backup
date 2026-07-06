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
    indicator.parameters:addDouble("VF", "Volume Factor", "Volume Factor", 0.7);
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

local EMA1;
local EMA2;
local EMA3;
local EMA4;
local EMA5;
local EMA6;

local c1,c2,c3,c4;

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
	 EMA1 = core.indicators:create("EMA", source,   Frame);
	 EMA2 = core.indicators:create("EMA", EMA1.DATA,  Frame);
     EMA3 = core.indicators:create("EMA", EMA2.DATA,  Frame);
	 EMA4 = core.indicators:create("EMA", EMA3.DATA,  Frame);
	 EMA5 = core.indicators:create("EMA", EMA4.DATA,  Frame);
	 EMA6 = core.indicators:create("EMA", EMA5.DATA,  Frame);
	 
   c1= -b*b*b;
   c2= 3*b*b+3*b*b*b;
   c3= -6*b*b-3*b-3*b*b*b;
   c4= 1+3*b+b*b*b+3*b*b;
	 
	  first =  EMA6.DATA:first();

    T3 = instance:addStream("T3", core.Line, name, "T3", instance.parameters.T3_color, first);
	T3:setWidth(instance.parameters.width);
    T3:setStyle(instance.parameters.style);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

   
    EMA1:update(mode);
	EMA2:update(mode);
	EMA3:update(mode);
	EMA4:update(mode);
	EMA5:update(mode);
	EMA6:update(mode);
   
   if period < first then
   return;
   end
   
  
   T3[period] = c1*EMA6.DATA[period]+c2*EMA5.DATA[period]+c3*EMA4.DATA[period]+c4*EMA3.DATA[period];
   
end


