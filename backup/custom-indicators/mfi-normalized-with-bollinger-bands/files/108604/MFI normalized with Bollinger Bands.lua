-- Id: 16801
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63976&p=108604#p108604

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
    indicator:name("MFI normalized with Bollinger Bands");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Volume Indicators");

    indicator.parameters:addGroup("MFI Calculation");
    indicator.parameters:addInteger("Period", "Periods", "", 10, 1, 1000);
	
	indicator.parameters:addGroup("BB Calculation");
    indicator.parameters:addInteger("Period2", "Periods", "", 40, 1, 1000);
	 indicator.parameters:addDouble("Deviation2", "Deviation", "", 2, 1, 1000);
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

local source;
local Period;

local MFI;
local BB, Period2, Deviation2;
local Normalized;
function Prepare(nameOnly)
    source = instance.source;
    Period = instance.parameters.Period;
	Period2= instance.parameters.Period2;
	Deviation2= instance.parameters.Deviation2;
    name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);
    if (nameOnly) then
        return;
    end
	assert(core.indicators:findIndicator("MFI") ~= nil, "Please, download and install MFI.LUA indicator");
	MFI = core.indicators:create("MFI", source, Period);
	BB = core.indicators:create("BB", MFI.DATA, Period2, Deviation2);
	
     
   Normalized = instance:addStream("Normalized", core.Line, name, "Normalized", instance.parameters.color,  BB.DATA:first());   
    Normalized:setPrecision(math.max(2, instance.source:getPrecision()));
   Normalized:setWidth(instance.parameters.width);
   Normalized:setStyle(instance.parameters.style);
	
	Normalized:addLevel(1);
    Normalized:addLevel(0);
end

function Update(period, mode)

   MFI:update(mode);
   BB:update(mode);
   
   if period < BB.DATA:first() then
   return;
   end   
   
   
   Normalized[period] =(MFI.DATA[period] - BB.BL[period]) / (BB.TL[period] - BB.BL[period]);
    
end
 
