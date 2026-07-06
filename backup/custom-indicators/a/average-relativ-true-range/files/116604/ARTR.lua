-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65473

--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+
 

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Average Relativ True Range");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Volatility");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Number of periods", "The number of periods.", 14, 2, 1000);
	indicator.parameters:addBoolean("Simple", "Simple Range", "Use Simple range", false);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrATR", "Line color","", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthATR", "Line width","", 1, 1, 5);
    indicator.parameters:addInteger("styleATR", "Line style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleATR", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Period;

local first;
local source = nil;
local tr = nil;
local rtr = nil;
local trFirst = nil;
local tAbs = math.abs;

-- Streams block
local ATR = nil;
local Simple;

-- Routine
function Prepare(nameOnly)  
    Period = instance.parameters.Period;
	Simple= instance.parameters.Simple;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    tr = instance:addInternalStream(source:first(), 0);
	rtr = instance:addInternalStream(source:first(), 0);
    first = source:first() + 1;
    ATR = instance:addStream("ARTR", core.Line, name, "ARTR", instance.parameters.clrATR,  first +Period*2)
    ATR:setWidth(instance.parameters.widthATR);
    ATR:setStyle(instance.parameters.styleATR);
    local precision = math.max(2, source:getPrecision());
    ATR:setPrecision(precision);
    
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
    if period < first then
    return;
    end
   
    tr[period] = getTrueRange(period);
		
    if period < first +Period then
    return;
    end
	
		local min,max=mathex.minmax(tr, period-Period+1, period );
		
		if Simple then
			rtr[period]=(tr[period])/(max)
		else
		rtr[period]=(tr[period]-min)/(max-min)
		end

     if period < first +Period*2 then
    return;
    end
	
        ATR[period] = mathex.avg(rtr, period - Period + 1, period);        
    
    
end




