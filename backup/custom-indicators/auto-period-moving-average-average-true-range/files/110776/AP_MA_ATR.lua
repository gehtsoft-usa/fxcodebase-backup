-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64366

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
    indicator:name("Auto Period Moving Average Average true range");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addDouble("Imult", "Imult", "Imult", 0.635);
    indicator.parameters:addDouble("Qmult", "Qmult", "Qmult", 0.338);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrATR", "Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthATR", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleATR", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleATR", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Imult;
local Qmult;
local first;
local source = nil;
local tr = nil;
local trFirst = nil;
local tAbs = math.abs;

-- Streams block
local ATR = nil;
local MA;
-- Routine
function Prepare()
    Imult = instance.parameters.Imult;
	Qmult = instance.parameters.Qmult;
    source = instance.source;
	
	assert(core.indicators:findIndicator("AP_MA") ~= nil, "Please, download and install AP_MA.BIN indicator");
	assert(core.indicators:findIndicator("TICK_CP") ~= nil, "Please, download and install TICK_CP.LUA indicator");

    local name = profile:id() .. "(" .. source:name()   .. ")";
    instance:name(name);
    tr = instance:addInternalStream(source:first() + 1, 0);
	MA= core.indicators:create("AP_MA", tr, Imult,Qmult );
    first = source:first()
    ATR = instance:addStream("ATR", core.Line, name, "ATR", instance.parameters.clrATR, first)
    ATR:setWidth(instance.parameters.widthATR);
    ATR:setStyle(instance.parameters.styleATR);
    local precision = math.max(2, source:getPrecision());
	 
    ATR:setPrecision(precision);
    trFirst = tr:first();
end

function getTrueRange(period)
    local hl = tAbs(source.high[period] - source.low[period]);
    local hc = tAbs(source.high[period] - source.close[period - 1]);
    local lc = tAbs(source.low[period] - source.close[period - 1]);

    local tr = hl;
    if (tr < hc) then
        tr = hc;
    end
    if (tr < lc) then
        tr = lc;
    end
    return tr;
end


function Update(period, mode)
    if period >= trFirst then
        tr[period] = getTrueRange(period);
    end
	
	MA:update(mode);
	
    if  MA.DATA:hasData(period) then
        ATR[period] = MA.DATA[period];
    end
end

