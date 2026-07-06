-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59637
-- Id: 10197

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
    indicator:name("Modified ATR Trailing Stop indicator");
    indicator:description("Modified ATR Trailing Stop indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 10);
    indicator.parameters:addDouble("Coeff", "Coeff", "", 4);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Coeff;
local HL;
local Diff;
local MVA;
local Wilder;
local TS=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Coeff=instance.parameters.Coeff;
    first = source:first() ;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Coeff .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
	
    HL=instance:addInternalStream(first, 0);
    Diff=instance:addInternalStream(first, 0);
    MVA=core.indicators:create("MVA", HL, Period);
    Wilder=core.indicators:create("AVERAGES", Diff, "Wilder", Period, false);
    TS = instance:addStream("TS", core.Line, name .. ".TS", "TS", instance.parameters.UPclr, first+Period);
    TS:setWidth(instance.parameters.widthLinReg);
    TS:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
  
    HL[period]=source.high[period]-source.low[period];
    MVA:update(mode);
	
	 if period>first+Period then
	 
    local HiLo=math.min(HL[period], MVA.DATA[period]);
    local Href;
    if source.low[period]<=source.high[period-1] then
     Href=source.high[period]-source.close[period-1];
    else
     Href=(HL[period]-source.close[period-1]+source.high[period-1])/2;
    end
    local Lref;
    if source.high[period]>=source.low[period-1] then
     Lref=source.close[period-1]-source.low[period];
    else
     Lref=(source.close[period-1]-source.low[period-1]+HL[period])/2;
    end
    Diff[period]=math.max(HiLo, Href, Lref);
    Wilder:update(mode);
    local loss=Coeff*Wilder.DATA[period];
    if source.close[period]>TS[period-1] and source.close[period-1]>TS[period-1] then
     TS[period]=math.max(TS[period-1], source.close[period]-loss);
     TS:setColor(period, instance.parameters.DNclr);
    elseif source.close[period]<TS[period-1] and source.close[period-1]<TS[period-1] then
     TS[period]=math.min(TS[period-1], source.close[period]+loss);
     TS:setColor(period, instance.parameters.UPclr);
    elseif source.close[period]>TS[period-1] then
     TS[period]=source.close[period]-loss;
     TS:setColor(period, instance.parameters.DNclr);
    else
     TS[period]=source.close[period]+loss;
     TS:setColor(period, instance.parameters.UPclr);
    end
   end 
end

