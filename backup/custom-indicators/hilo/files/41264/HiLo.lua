-- Id: 7559
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=24006

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
    indicator:name("Hilo");
    indicator:description("Hilo");
    indicator:requiredSource(core.Bar); --??
    indicator:type(core.Oscillator); -- bedeutet au�erhalb vom Chart

  
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Hi", "High Color", " ", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Lo", "Low Color", " ", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local first;
local source = nil;
local Hi;
local Lo;
local tr = nil;

-- Routine
function Prepare(nameOnly)
    n = instance.parameters.N;
    source = instance.source;
	 first = source:first();
	
    local name = profile:id() .. "(" .. source:name() ..")";
    instance:name(name);
    if nameOnly then
        return;
    end
   
    Hi = instance:addStream("High", core.Line, name, "High", instance.parameters.Hi, first);
    Hi:setPrecision(math.max(2, instance.source:getPrecision()));
	Hi:setWidth(instance.parameters.width1);
    Hi:setStyle(instance.parameters.style1);
	Lo = instance:addStream("Low", core.Line, name, "Low", instance.parameters.Lo, first);
    Lo:setPrecision(math.max(2, instance.source:getPrecision()));
    Lo:setWidth(instance.parameters.width2);
    Lo:setStyle(instance.parameters.style2);
end
function getNumHi(period)
    local h0 = source.high[period];
    local h1 = source.high[period-1];

    if (h0 > h1) then
        Hi[period] = Hi[period-1] + 1;
    else
        Hi[period] = 0;
    end
   
end

function getNumLo(period)
    local l0 = source.low[period];
    local l1 = source.low[period-1];

    if (l0 < l1) then
        Lo[period] = Lo[period-1] + 1;
   else
        Lo[period] = 0;
    end
  
end

-- Indicator calculation routine
function Update(period)

    if period > first+1 then
        getNumHi(period); 
		getNumLo(period); 	
		
	end	
end