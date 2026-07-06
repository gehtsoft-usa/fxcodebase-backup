-- Id: 877
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1297

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("TMAGi indicator");
    indicator:description("TMAGi indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
     
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("FastMA", "FastMA", "FastMA", 8);
    indicator.parameters:addInteger("MidMA", "MidMA", "MidMA", 16);
    indicator.parameters:addInteger("SlowMA", "SlowMA", "SlowMA", 25);
    indicator.parameters:addInteger("SlowingSMA", "SlowingSMA", "SlowingSMA", 3);
    indicator.parameters:addInteger("SlowingLWMA", "SlowingLWMA", "SlowingLWMA", 8);
    indicator.parameters:addInteger("ADX_Period", "ADX_Period", "ADX_Period", 14);
     
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr_1", "Color 1", "Color 1", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("clr_2", "Color 2", "Color 2", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);

end

local first;
local source = nil;
local FastMA;
local MidMA;
local SlowMA;
local SlowingSMA;
local SlowingLWMA;
local ADX_Period;
local buff_1=nil;
local buff_2=nil;
local Buff;
local MA_S;
local MA_M;
local MA_F;
local ADX_H;
local ADX_L;
local MA_Res1;
local MA_Res2;


function Prepare(nameOnly)
    source = instance.source;
    FastMA=instance.parameters.FastMA;
    MidMA=instance.parameters.MidMA;
    SlowMA=instance.parameters.SlowMA;
    SlowingSMA=instance.parameters.SlowingSMA;
    SlowingLWMA=instance.parameters.SlowingLWMA;
    ADX_Period=instance.parameters.ADX_Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.FastMA .. ", " .. instance.parameters.MidMA .. ", " .. instance.parameters.SlowMA .. ", " .. instance.parameters.SlowingSMA .. ", " .. instance.parameters.SlowingLWMA .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    MA_F = core.indicators:create("MVA", source.close, FastMA);
    MA_M = core.indicators:create("MVA", source.close, MidMA);
    MA_S = core.indicators:create("MVA", source.close, SlowMA);
    ADX_H = core.indicators:create("DMI", source, ADX_Period);
    ADX_L = core.indicators:create("DMI", source, ADX_Period);
    Buff = instance:addInternalStream(0, 0);
    MA_Res1 = core.indicators:create("MVA", Buff, SlowingSMA);
    MA_Res2 = core.indicators:create("LWMA", Buff, SlowingLWMA);
    first = math.max(MA_F.DATA:first(),MA_M.DATA:first(),MA_S.DATA:first())+2;
    buff_1 = instance:addStream("buff_1", core.Line, name .. ".buff1", "buff2", instance.parameters.clr_1, first);
    buff_1:setPrecision(math.max(2, instance.source:getPrecision()));
	buff_1:setWidth(instance.parameters.width1);
    buff_1:setStyle(instance.parameters.style1);
    buff_2 = instance:addStream("buff_2", core.Line, name .. ".buff1", "buff2", instance.parameters.clr_2, first);
    buff_2:setPrecision(math.max(2, instance.source:getPrecision()));
	buff_2:setWidth(instance.parameters.width2);
    buff_2:setStyle(instance.parameters.style2);
end

function Update(period, mode)
    if (period>first) then
     MA_F:update(mode);
     MA_M:update(mode);
     MA_S:update(mode);
     ADX_H:update(mode);
     ADX_L:update(mode);
     local di=ADX_H.DIP[period]-ADX_L.DIM[period];
     Buff[period]=(math.abs(MA_F.DATA[period]-MA_M.DATA[period])+math.abs(MA_F.DATA[period]-MA_S.DATA[period])+math.abs(MA_M.DATA[period]-MA_S.DATA[period]))*di/source:pipSize();
     MA_Res1:update(mode);
     MA_Res2:update(mode);
     buff_1[period]=MA_Res1.DATA[period];
     buff_2[period]=MA_Res2.DATA[period];
    
    end 
end

