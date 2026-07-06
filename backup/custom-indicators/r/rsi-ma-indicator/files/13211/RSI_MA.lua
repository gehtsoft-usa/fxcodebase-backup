-- Id: 4379
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=5502

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
    indicator:name("RSI of MA indicator");
    indicator:description("RSI of MA indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("MA_Period", "MA_Period", "", 14);
    indicator.parameters:addInteger("RSI_Period", "RSI_Period", "", 21);
    indicator.parameters:addInteger("MA_RSI_Period", "MA_RSI_Period", "", 15);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("RSI_clr", "RSI Color", "RSI Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("MA_RSI_clr", "MA_RSI Color", "MA_RSI Color", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local MA_Period;
local RSI_Period;
local MA_RSI_Period;
local MA;
local RSI;
local MA_RSI;
local BuffRSI=nil;
local BuffMARSI=nil;

function Prepare(nameOnly)
    source = instance.source;
    MA_Period=instance.parameters.MA_Period;
    RSI_Period=instance.parameters.RSI_Period;
    MA_RSI_Period=instance.parameters.MA_RSI_Period;
   
	first = MA_RSI.DATA:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.MA_Period .. ", " .. instance.parameters.RSI_Period .. ", " .. instance.parameters.MA_RSI_Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    MA = core.indicators:create("EMA", source, MA_Period);
    RSI = core.indicators:create("RSI", MA.DATA, RSI_Period);
    MA_RSI = core.indicators:create("EMA", RSI.DATA, MA_RSI_Period);
    BuffRSI = instance:addStream("BuffRSI", core.Line, name .. ".RSI", "RSI", instance.parameters.RSI_clr, RSI.DATA:first());
    BuffRSI:setPrecision(math.max(2, instance.source:getPrecision()));
    BuffMARSI = instance:addStream("BuffMARSI", core.Line, name .. ".MA_RSI", "MA_RSI", instance.parameters.MA_RSI_clr, first);
    BuffMARSI:setPrecision(math.max(2, instance.source:getPrecision()));
    BuffRSI:addLevel(20);
    BuffRSI:addLevel(50);
    BuffRSI:addLevel(80);
end

function Update(period, mode)
 
    MA:update(mode);
    RSI:update(mode);
    MA_RSI:update(mode);
	
	 if (period<RSI.DATA:first()) then
	 return;
	 end
    BuffRSI[period]=RSI.DATA[period];
	 if (period<first) then
	 return;
	 end
    BuffMARSI[period]=MA_RSI.DATA[period];
   
end

