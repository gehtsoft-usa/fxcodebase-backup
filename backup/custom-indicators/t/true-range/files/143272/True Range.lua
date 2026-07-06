-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71432

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+
 

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("True Range");
    indicator:description("True Range");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Volatility");

   
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrATR", "Line color","" , core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthATR", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleATR", "Line style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleATR", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
 

local first;
local source = nil;
local tr = nil;
local trFirst = nil;
local tAbs = math.abs;

-- Streams block
local ATR = nil;

-- Routine
function Prepare(nameOnly) 
    source = instance.source;

    local name = profile:id() .. "(" .. source:name()   .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
 
    tr = instance:addStream("ATR", core.Line, name, "ATR", instance.parameters.clrATR, source:first() + 1)
    tr:setWidth(instance.parameters.widthATR);
    tr:setStyle(instance.parameters.styleATR);
    local precision = math.max(2, source:getPrecision());
    tr:setPrecision(precision);
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
    if period <= trFirst then
	return;
	end
	
        tr[period] = getTrueRange(period);
 
end




