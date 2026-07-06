-- Id: 1790

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
    indicator.parameters:addInteger("EMA_N", "Number of periods for EMA", "", 4, 2, 1000);

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
local ema1;
local ema2;
local out;
local first;

function Prepare(nameOnly)
    local name;
    name = profile:id() .. "(" .. instance.source:name() .. "," .. instance.parameters.RSI_N .. "," .. instance.parameters.EMA_N .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end

    assert(core.indicators:findIndicator("SVE_RAINBOWAVERAGE") ~= nil, "Please download and install SVE_RainbowAverage.lua indicator");

    sve_ra = core.indicators:create("SVE_RAINBOWAVERAGE", instance.source, 2);
    rsi = core.indicators:create("RSI", sve_ra.DATA, instance.parameters.RSI_N);
    x = instance:addInternalStream(rsi.DATA:first(), 0);
    ema1 = core.indicators:create("EMA", x, instance.parameters.EMA_N);
    ema2 = core.indicators:create("EMA", ema1.DATA, instance.parameters.EMA_N);
    first = ema2.DATA:first();

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
        ema1:update(mode);
        ema2:update(mode);

        zl_ema = ema1.DATA[period] + (ema1.DATA[period] - ema2.DATA[period]);
        out[period] = ((math.pow(2.71828183, 2 * zl_ema) - 1) / (math.pow(2.71828183, 2 * zl_ema) + 1) + 1) * 50;
    end
end
