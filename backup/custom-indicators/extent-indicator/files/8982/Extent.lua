-- Id: 3444
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3707

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
    indicator:name("Extent Indicator");
    indicator:description("Extent Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

   
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("PERIOD", "MA PERIOD", "", 36);
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
	
	        indicator.parameters:addString("Price", "MA Price Source", "", "close");
			indicator.parameters:addStringAlternative("Price", "Open", "", "open");
			indicator.parameters:addStringAlternative("Price", "High", "", "high");
			indicator.parameters:addStringAlternative("Price", "Low", "", "low");
			indicator.parameters:addStringAlternative("Price", "Close/Tick", "", "close");
			indicator.parameters:addStringAlternative("Price", "Median", "", "median");
			indicator.parameters:addStringAlternative("Price", "Typical", "", "typical");
			indicator.parameters:addStringAlternative("Price", "Weighted", "", "weighted");
			
			
	indicator.parameters:addGroup("Style"); 
	indicator.parameters:addColor("color_r", "Color of Extent Bar", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("color_f", "Color of Extent Bar", "", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Method;
local PERIOD;

local first;
local source = nil;

-- Streams block
local Extent = nil;
local indicator;
local Price;
local MAsource;

-- Routine
function Prepare(nameOnly)
   Price= instance.parameters.Price;
    Method = instance.parameters.Method;
	PERIOD = instance.parameters.PERIOD;
    source = instance.source;
	
	if Price == "open" then
        MAsource = source.open;
    elseif Price == "high" then
        MAsource = source.high;
    elseif Price == "low" then
        MAsource = source.low;
    elseif Price == "close" then
        MAsource = source.close;
    elseif Price == "median" then
        MAsource = source.median;
    elseif Price == "typical" then
        MAsource = source.typical;
    elseif Price == "weighted" then
        MAsource = source.weighted;
    else
        MAsource = source.close;
    end
   

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(PERIOD).. ", " .. tostring(Method).. ", " .. tostring(Price) .. ")";
    instance:name(name);
    if (not (nameOnly)) then
        assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");
        
        indicator  = core.indicators:create("AVERAGES", MAsource, Method, PERIOD, false);
         first = indicator.DATA:first();
        
        Extent = instance:addStream("Extent", core.Bar, name, "Extent", instance.parameters.color_r, first);
    Extent:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not  source:hasData(period) then
	return;
	end
	
	 indicator:update(mode);
	 
        Extent[period] = source.close[period] - indicator.DATA[period];
		if  Extent[period]  > Extent[period-1] then
		Extent:setColor(period, instance.parameters.color_r);
		else  
		Extent:setColor(period, instance.parameters.color_f);
		end
    
end

