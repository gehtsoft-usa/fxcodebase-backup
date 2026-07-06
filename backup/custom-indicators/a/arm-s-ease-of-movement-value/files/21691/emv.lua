-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=10454
-- Id: 5418

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
    indicator:name("emv");
    indicator:description("Arm's Ease of Movement Value");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 14);
    indicator.parameters:addString("Method", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth");

    indicator.parameters:addGroup("Style");
    --indicator.parameters:addColor("MainClr", "Main Color", "Main Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("SignalClr", "Signal Color", "Signal Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Method;
local M;
local Main=nil;
local Signal=nil;
local volume;

function Prepare(nameOnly)
    source = instance.source;
	Method=instance.parameters.Method;
    Period=instance.parameters.Period;
    volume = instance.source.volume;
 
    local name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ", " ..Method .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");

    Main =instance:addInternalStream (0, 0);
    MA = core.indicators:create("AVERAGES", Main, Method, Period, false);
	
	   first = MA.DATA:first();
	
    Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.SignalClr, first);
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
    Main:setWidth(instance.parameters.widthLinReg);
    Main:setStyle(instance.parameters.styleLinReg);
    Signal:setWidth(instance.parameters.widthLinReg);
    Signal:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)

if period < source:first()+1 then
return;
end


local highCurr = source.high[period];
local lowCurr = source.low[period];
local highP = source.high[period-1];
local lowP = source.low[period-1];

  Main[period] = (((highCurr + lowCurr)/2) - ((highP + lowP)/2)) / ((volume[period])/( highCurr - lowCurr)) ; 

   if (period>first) then
   MA:update(mode);  
   Signal[period]=MA.DATA[period];
   end

end