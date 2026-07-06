-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41449
-- Id: 9374

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    indicator:name("AMA slope oscillator");
    indicator:description("AMA slope oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("AMA_Period", "AMA period", "", 9);
    indicator.parameters:addInteger("Fast_MA_Period", "Fast MA period", "", 2);
    indicator.parameters:addInteger("Slow_MA_Period", "Slow MA period", "", 30);
    indicator.parameters:addDouble("G", "G", "", 2);
    indicator.parameters:addDouble("dK", "dK", "", 1);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local AMA_Period;
local Fast_MA_Period;
local Slow_MA_Period;
local G;
local dK;
local slowSC, fastSC;
local dSC;
local AMA;
local pipSize;
local AMA_Slope=nil;

function Prepare(nameOnly)
    source = instance.source;
    AMA_Period=instance.parameters.AMA_Period;
    Fast_MA_Period=instance.parameters.Fast_MA_Period;
    Slow_MA_Period=instance.parameters.Slow_MA_Period;
    G=instance.parameters.G;
    dK=instance.parameters.dK;
    first = source:first()+AMA_Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.AMA_Period .. ", " .. instance.parameters.Fast_MA_Period .. ", " .. instance.parameters.Slow_MA_Period .. ", " .. instance.parameters.G .. ", " .. instance.parameters.dK .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    AMA=instance:addInternalStream(0, 0);
    AMA_Slope = instance:addStream("AMA_Slope", core.Line, name .. ".AMA_Slope", "AMA_Slope", instance.parameters.clr, first);
    AMA_Slope:setPrecision(math.max(2, instance.source:getPrecision()));
    AMA_Slope:setWidth(instance.parameters.widthLinReg);
    AMA_Slope:setStyle(instance.parameters.styleLinReg);
    slowSC=2/(Slow_MA_Period+1);
    fastSC=2/(Fast_MA_Period+1);
    dSC=fastSC-slowSC;
    pipSize=source:pipSize();
end

function Update(period, mode)
   if period>first then
    local i;
    local noise=0;
    for i=0, AMA_Period-1, 1 do
     noise=noise+math.abs(source[period-i]-source[period-i-1]);
    end
    local signal=math.abs(source[period]-source[period-AMA_Period]);
    local ER=signal/noise;
    local ERSC=ER*dSC;
    local SSC=ERSC+slowSC;
    AMA[period]=AMA[period-1]+math.pow(SSC, G)*(source[period]-AMA[period-1]);
    AMA_Slope[period]=(AMA[period]-AMA[period-1])/pipSize;
   elseif period==first then
    AMA[period]=source[period];
   end 
end

