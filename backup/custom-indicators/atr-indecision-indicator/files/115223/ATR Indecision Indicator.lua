-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65140

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


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("ATR Indecision Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Volatility");

	indicator.parameters:addGroup("Selector"); 
	indicator.parameters:addBoolean("S1", "Show ATR Line", "", true);
	indicator.parameters:addBoolean("S2", "Show Open Close Line", "", true);
	indicator.parameters:addBoolean("S3", "Show High Low Line", "", true);
	
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Period","", 14, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrATR", "ATR Line Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("clrOC", "Open Close Line Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("clrHL", "High Low Line Color","", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthATR","Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleATR", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleATR", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local n;
local S1, S2, S3;
local first;
local source = nil;
local tr = nil;
local trFirst = nil;
local tAbs = math.abs;


-- Streams block
local ATR = nil;
local HL;
local OC;
-- Routine
function Prepare(nameOnly)
    n = instance.parameters.N;
	S1 = instance.parameters.S1;
	S2 = instance.parameters.S2;
	S3 = instance.parameters.S3;
	
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ")";
    instance:name(name);
	if   (nameOnly) then
        return;
    end
	
	
    tr = instance:addInternalStream(source:first() + 1, 0);
    first = tr:first() + n;
	
	if S1 then
    ATR = instance:addStream("ATR", core.Line, name, "ATR", instance.parameters.clrATR, first)
    ATR:setWidth(instance.parameters.widthATR);
    ATR:setStyle(instance.parameters.styleATR);
	else
	ATR = instance:addInternalStream(0, 0);
	end
	
	if S2 then
	OC = instance:addStream("OC", core.Line, name, "OC", instance.parameters.clrOC, source:first())
    OC:setWidth(instance.parameters.widthATR);
    OC:setStyle(instance.parameters.styleATR);
	else
	OC = instance:addInternalStream(0, 0);
	end
	
	if S3 then
	HL = instance:addStream("HL", core.Line, name, "HL", instance.parameters.clrHL, source:first())
    HL:setWidth(instance.parameters.widthATR);
    HL:setStyle(instance.parameters.styleATR);
	else
	HL = instance:addInternalStream(0, 0);
	end
	
	
    local precision = math.max(2, source:getPrecision());
    ATR:setPrecision(precision);
	OC:setPrecision(precision);
	HL:setPrecision(precision);
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

-- Indicator calculation routine

function Update(period)
    if period >= trFirst then
        tr[period] = getTrueRange(period);
    end
    if period >= first then
        ATR[period] = mathex.avg(tr, period - n + 1, period);
    end
	
	HL[period]= source.high[period]-source.low[period];
	OC[period]= math.abs(source.open[period]-source.close[period]);
end