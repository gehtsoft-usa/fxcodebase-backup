-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=12228
-- Id: 5633

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("SL_ATR indicator");
    indicator:description("SL_ATR indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("ATR_Period", "Period of ATR", "", 10,1,1000);
    indicator.parameters:addDouble("K", "K", "", 1);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Upper_Cloud_Clr", "Upper Cloud Color", "Upper Cloud Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Lower_Cloud_Clr", "Lower Cloud Color", "Lower Cloud Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Transparency", "Transparency", "", 50,0,100);
end

local first;
local source = nil;
local ATR_Period;
local K;
local ATR;
local H_Upper=nil;
local L_Upper=nil;
local H_Lower=nil;
local L_Lower=nil;

function Prepare(nameOnly)
    source = instance.source;
    ATR_Period=instance.parameters.ATR_Period;
    K=instance.parameters.K;
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.ATR_Period .. ", " .. instance.parameters.K .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    ATR = core.indicators:create("ATR", source, ATR_Period);
	first = ATR.DATA:first();
	
    H_Upper = instance:addInternalStream(first, 0);
    L_Upper = instance:addInternalStream(first, 0);
    H_Lower = instance:addInternalStream(first, 0);
    L_Lower = instance:addInternalStream(first, 0);
    instance:createChannelGroup("UpperCloud", "UpperCloud", H_Upper, L_Upper, instance.parameters.Upper_Cloud_Clr, 100 - instance.parameters.Transparency);
    instance:createChannelGroup("LowerCloud", "LowerCloud", H_Lower, L_Lower, instance.parameters.Lower_Cloud_Clr, 100 - instance.parameters.Transparency);
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
    ATR:update(mode);
    H_Upper[period]=source.high[period]+K*ATR.DATA[period];
    L_Upper[period]=source.low[period]+K*ATR.DATA[period];
    H_Lower[period]=source.high[period]-K*ATR.DATA[period];
    L_Lower[period]=source.low[period]-K*ATR.DATA[period];
   
end

