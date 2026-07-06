-- Id: 3056
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3337

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
    indicator:name("HA Oscillator");
    indicator:description("HA Oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	
	indicator.parameters:addGroup("Calculation");	
	
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
	
	
	indicator.parameters:addString("PriceType", "CLOSE", "", "C");
    indicator.parameters:addStringAlternative("PriceType", "OPEN", "", "O");
    indicator.parameters:addStringAlternative("PriceType", "HIGH", "", "H");
    indicator.parameters:addStringAlternative("PriceType", "LOW", "", "L");
    indicator.parameters:addStringAlternative("PriceType","CLOSE", "", "C");
    indicator.parameters:addInteger("Period", "Period", "", 20);
	
	
	indicator.parameters:addGroup("Style");	
	
    indicator.parameters:addString("Type", "Line/Bar", "", "Line");
    indicator.parameters:addStringAlternative("Type", "Line", "", "Line");
    indicator.parameters:addStringAlternative("Type", "Bar", "", "Bar");
   
    indicator.parameters:addColor("Up_color", "Color of Up", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("Down_color", "Color of Down", "", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local MA_Period, MA_Method,Type, PriceType;

local first;
local source = nil;

-- Streams block
local DATA, HA_DATA;
local Out = nil;
local HA_PRICE;

-- Routine
function Prepare(nameOnly)
  
    source = instance.source;   
	PriceType = instance.parameters.PriceType;
	Type = instance.parameters.Type;
	MA_Period = instance.parameters.Period;
    MA_Method = instance.parameters.Method;

    local name = profile:id() .. "(" .. source:name() .. ", " .. MA_Period ..", " ..MA_Method..", ".. PriceType.. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES indicator");	
	HA_DATA=core.indicators:create("HA", source);
	
	if PriceType == "O" then       
		HA_PRICE= HA_DATA.open;
    elseif PriceType == "H" then
		HA_PRICE= HA_DATA.high;
    elseif PriceType == "L" then
		HA_PRICE= HA_DATA.low;    
    else
		HA_PRICE= HA_DATA.close;
    end
	
	 DATA=core.indicators:create("AVERAGES", HA_PRICE, MA_Method, MA_Period, false);
	
	
	first= DATA.DATA:first();
	
	if Type == "Line" then
	Out = instance:addStream("Out", core.Line, name, "Out", core.rgb(128, 128, 128), first);
  	else
    Out = instance:addStream("Out", core.Bar, name, "Out", core.rgb(128, 128, 128), first);
    end
    Out:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not  source:hasData(period) then
	return;
	end
		
	 DATA:update(mode);
	 HA_DATA:update(mode);
	 
	 if not  DATA.DATA:hasData(period) or not  HA_DATA.DATA:hasData(period)then
	 return;
	 end
	
        Out[period] = HA_PRICE[period]  - DATA.DATA[period];
		
		if Out[period]> Out[period-1] then
		Out:setColor(period, instance.parameters.Up_color);
		else
        Out:setColor(period, instance.parameters.Down_color); 	
        end		
   
end

