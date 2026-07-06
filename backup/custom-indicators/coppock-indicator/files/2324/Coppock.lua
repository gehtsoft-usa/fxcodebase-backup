-- Id: 808
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1225

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Coppock Indicator");
    indicator:description("Identify the commencement of bull markets");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("ShortROC", "ShortROC", "ShortROC", 14,2,2000);
    indicator.parameters:addInteger("LongROC", "LongROC", "LongROC", 11,2,2000);
    indicator.parameters:addInteger("Frame", "Weighted Moving Average Period", "Weighted Moving Average Period", 10,2,2000);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Coppock_color", "Color of Coppock", "Color of Coppock", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local ShortRSI;
local LongRSI;
local Frame;
local ShortFrame;
local LongFrame;

local first;
local source = nil;

-- Streams block
local Coppock = nil;
local Temp=nil;
local LWMA=nil;

-- Routine
function Prepare(nameOnly)
    ShortFrame = instance.parameters.ShortROC;
    LongFrame = instance.parameters.LongROC;
    Frame = instance.parameters.Frame;
    source = instance.source;
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. ShortFrame .. ", " .. LongFrame .. ", " .. Frame .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	LongRSI = core.indicators:create("ROC", source, LongFrame);
	ShortRSI = core.indicators:create("ROC", source, ShortFrame);
	Temp = instance:addInternalStream(0, 0);
	LWMA = core.indicators:create("LWMA", Temp, Frame);
	
	first =  LWMA.DATA:first();
    Coppock = instance:addStream("Coppock", core.Line, name, "Coppock", instance.parameters.Coppock_color, first);
	Coppock:setWidth(instance.parameters.width);
    Coppock:setStyle(instance.parameters.style);
	
	Coppock:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
   ShortRSI:update(mode);
   LongRSI:update(mode);
   
  if period < math.max(LongRSI.DATA:first() ,ShortRSI.DATA:first()  ) or not source:hasData(period) then
  return;
  end
   

	 Temp[period]=ShortRSI.DATA[period] + LongRSI.DATA[period];
	
   
	LWMA:update(mode);  
   if period <first then
   return;
   end	 
    
        Coppock[period] = LWMA.DATA[period];
	 
   
end

