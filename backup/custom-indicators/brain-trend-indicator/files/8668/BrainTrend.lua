-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3605

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
    indicator:name("Brain trend indicator");
    indicator:description("Brain trend indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Stoch_K", "Stochastic K", "", 9);
    indicator.parameters:addInteger("Stoch_SD", "Stochastic SD", "", 9);
    indicator.parameters:addInteger("Stoch_Level", "Stochastic Level", "", 40);
    indicator.parameters:addInteger("ATR_Period", "ATR period", "", 7);
    indicator.parameters:addInteger("Shift", "Shift", "", 2);
    indicator.parameters:addDouble("Range", "Range", "", 2);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUP", "Color UP", "Color UP", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrDN", "Color DN", "Color DN", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width", "width", "width", 3, 1, 5);
end

local first;
local source = nil;
local Stoch_K;
local Stoch_SD;
local Stoch_Level;
local ATR_Period;
local Shift;
local Range;
local ATR;
local Stoch;
local BuffUP=nil;
local BuffDN=nil;

function Prepare(onlyName)
    source = instance.source;
    Stoch_K=instance.parameters.Stoch_K;
    Stoch_SD=instance.parameters.Stoch_SD;
    Stoch_Level=instance.parameters.Stoch_Level;
    ATR_Period=instance.parameters.ATR_Period;
    Shift=instance.parameters.Shift;
    Range=instance.parameters.Range;
    local name = profile:id() .. "(" .. source:name() .. ", " .. Stoch_K .. ", " .. Stoch_SD .. ", " .. Stoch_Level .. ", " .. ATR_Period .. ", " .. Shift .. ", " .. Range .. ")";
    instance:name(name);
    if onlyName then
        return;
    end
    ATR = core.indicators:create("ATR", source, ATR_Period);
    Stoch = core.indicators:create("STOCHASTIC", source, Stoch_K, Stoch_SD, 1);
    first = math.max(ATR.DATA:first(),Stoch.DATA:first())+2;
    BuffUP = instance:addStream("BuffUP", core.Dot, name .. ".UP", "UP", instance.parameters.clrUP, first);
    BuffDN = instance:addStream("BuffDN", core.Dot, name .. ".DN", "DN", instance.parameters.clrDN, first);
    BuffUP:setWidth(instance.parameters.width);
    BuffDN:setWidth(instance.parameters.width);
end

function Update(period, mode)
   if (period>first+Shift) then
    ATR:update(mode);
    Stoch:update(mode);
    local R=math.abs(source.close[period]-source.close[period-Shift]);
    if Stoch.K[period]<Stoch_Level and R>ATR.DATA[period]/Range then
     BuffDN[period]=source.high[period];
    elseif Stoch.K[period]>100-Stoch_Level and R>ATR.DATA[period] then
     BuffUP[period]=source.low[period];
    end
    
   end 
    
end

