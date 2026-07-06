-- Id: 15956

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2297

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


function Init()
    indicator:name("Sylvain Vervoort's RSI inverse fisher transform");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("RSI_N", "Number of periods for RSI", "", 4, 2, 1000);
    indicator.parameters:addInteger("MA_N", "Number of periods for MA", "", 4, 2, 1000);
	
	indicator.parameters:addString("Method", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
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
    indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method", "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative("Method", "HPF", "", "HPF");
    indicator.parameters:addStringAlternative("Method", "VAMA", "", "VAMA");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Indicator Line Color", "", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("width", "Indicator Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Indicator Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

    indicator.parameters:addGroup("Levels");
    indicator.parameters:addInteger("L1", "Level1", "", 12, 1, 100);
    indicator.parameters:addInteger("L2", "Level2", "", 88, 1, 100);
    indicator.parameters:addColor("clrL", "Level Line Color", "", core.rgb(192, 192, 192));
    indicator.parameters:addInteger("widthL", "Level Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleL", "Level Line Style", "", core.LINE_DOT);
    indicator.parameters:setFlag("styleL", core.FLAG_LINE_STYLE);
end

local sve_ra;
local rsi;
local x;
local ma1;
local ma2;
local out;
local first;
local Method;
function Prepare(nameOnly)
    Method= instance.parameters.Method;
    local name;
    name = profile:id() .. "(" .. instance.source:name() .. "," .. instance.parameters.RSI_N .. "," .. instance.parameters.MA_N .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end

    assert(core.indicators:findIndicator("SVE_RAINBOWAVERAGE AVERAGES") ~= nil, "Please download and install SVE_RAINBOWAVERAGE AVERAGES.lua indicator");
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please download and install AVERAGES.lua indicator");
	
    sve_ra = core.indicators:create("SVE_RAINBOWAVERAGE AVERAGES", instance.source, 2,Method);
    rsi = core.indicators:create("RSI", sve_ra.DATA, instance.parameters.RSI_N);
    x = instance:addInternalStream(rsi.DATA:first(), 0);
    ma1 = core.indicators:create("AVERAGES",  x,Method, instance.parameters.MA_N);
    ma2 = core.indicators:create("AVERAGES", ma1.DATA, Method, instance.parameters.MA_N);
    first = ma2.DATA:first();

    out = instance:addStream("SVE_RSI", core.Line, name, "SVE_RSI", instance.parameters.clr, first);
    out:setWidth(instance.parameters.width);
    out:setStyle(instance.parameters.style);

    out:addLevel(0, core.LINE_NONE, 1, instance.parameters.clrL);
    out:addLevel(instance.parameters.L1, instance.parameters.styleL, instance.parameters.widthL, instance.parameters.clrL);
    out:addLevel(instance.parameters.L2, instance.parameters.styleL, instance.parameters.widthL, instance.parameters.clrL);
    out:addLevel(100, core.LINE_NONE, 1, instance.parameters.clrL);
	
	
	out:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
    if period >= first then
        local zl_ema;
        sve_ra:update(mode);
        rsi:update(mode);
        x[period] = 0.1 * (rsi.DATA[period] - 50);
        ma1:update(mode);
        ma2:update(mode);

        zl_ema = ma1.DATA[period] + (ma1.DATA[period] - ma2.DATA[period]);
        out[period] = ((math.pow(2.71828183, 2 * zl_ema) - 1) / (math.pow(2.71828183, 2 * zl_ema) + 1) + 1) * 50;
    end
end
