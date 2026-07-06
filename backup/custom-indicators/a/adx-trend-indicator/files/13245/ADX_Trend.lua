-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=5530

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
    indicator:name("ADX trend indicator");
    indicator:description("ADX trend indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("ADX1_Period", "ADX 1 Period", "", 10);
    indicator.parameters:addInteger("ADX2_Period", "ADX 2 Period", "", 14);
    indicator.parameters:addInteger("ADX3_Period", "ADX 3 Period", "", 20);
    indicator.parameters:addDouble("Level1", "Level 1", "", 35);
    indicator.parameters:addDouble("Level2", "Level 2", "", 30);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 3, 1, 5);
end

local first;
local source = nil;
local ADX1_Period;
local ADX2_Period;
local ADX3_Period;
local Level1;
local Level2;
local ADX1;
local ADX2;
local ADX3;
local DMI;
local Buff=nil;

function Prepare(nameOnly)
    source = instance.source;
    ADX1_Period=instance.parameters.ADX1_Period;
    ADX2_Period=instance.parameters.ADX2_Period;
    ADX3_Period=instance.parameters.ADX3_Period;
    Level1=instance.parameters.Level1;
    Level2=instance.parameters.Level2;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.ADX1_Period .. ", " .. instance.parameters.ADX2_Period .. ", " .. instance.parameters.ADX3_Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    ADX1 = core.indicators:create("ADX", source, ADX1_Period);
    ADX2 = core.indicators:create("ADX", source, ADX2_Period);
    ADX3 = core.indicators:create("ADX", source, ADX3_Period);
    DMI = core.indicators:create("DMI", source, ADX1_Period);
    Buff = instance:addStream("Buff", core.Dot, name .. ".Dot", "Dot", instance.parameters.UPclr, first);
    Buff:setWidth(instance.parameters.DotSize);
end

function Update(period, mode)
   if (period>first) then
    ADX1:update(mode);
    ADX2:update(mode);
    ADX3:update(mode);
    DMI:update(mode);
    if ADX1.DATA[period-1]<ADX1.DATA[period] and ADX2.DATA[period-1]<ADX2.DATA[period] and ADX3.DATA[period-1]<ADX3.DATA[period] and ADX1.DATA[period]>Level1 and ADX2.DATA[period]>Level2 then
     local di=DMI.DIP[period]-DMI.DIM[period];
     if di>0 then
      Buff[period]=source.high[period];
      Buff:setColor(period,instance.parameters.UPclr);
     else
      Buff[period]=source.low[period];
      Buff:setColor(period,instance.parameters.DNclr);
     end
    end
   end 
end

