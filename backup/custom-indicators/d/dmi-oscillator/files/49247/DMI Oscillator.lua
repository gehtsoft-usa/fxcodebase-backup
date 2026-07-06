-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=28048
-- Id: 8260

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("DMI Oscillator");
    indicator:description("DMI Oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 14);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP", "Color DMI", "Color DMI", core.rgb(255, 0, 0));    
    indicator.parameters:addInteger("width", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local DMI, dmi;
 
local Bar=nil;


function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
    dmi = core.indicators:create("DMI", source, Period);   
	first = dmi.DATA:first();
    DMI = instance:addStream("DMI", core.Line, name .. ".DMI", "DMI", instance.parameters.UP, first);
    DMI:setWidth(instance.parameters.width);
    DMI:setStyle(instance.parameters.style);	
	
	DMI:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   
    dmi:update(mode);
	
	
   if (period<first) then
   return;
   end
    
     
    DMI[period]=dmi.DIP[period]-dmi.DIM[period];
	
   
   
end

