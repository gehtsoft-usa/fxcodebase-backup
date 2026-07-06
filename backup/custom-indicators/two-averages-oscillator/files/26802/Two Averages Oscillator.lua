-- Id: 5905
-- More information about this indicator can be found at:
-- http://fxcodebase.com

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
    indicator:name("Two Averages Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Method1", "Short MA Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method1", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method1", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method1", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method1", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method1", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method1", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method1", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method1", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method1", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method1", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method1", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method1", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method1", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method1", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method1", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method1", "JSmooth", "", "JSmooth");

    indicator.parameters:addInteger("Period1", "Short MA Period", "", 20);
	

    indicator.parameters:addString("Method2", "Long MA Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method2", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method2", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method2", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method2", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method2", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method2", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method2", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method2", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method2", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method2", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method2", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method2", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method2", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method2", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method2", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method2", "JSmooth", "", "JSmooth");

    indicator.parameters:addInteger("Period2", "Long MA Period", "", 50);
	
    indicator.parameters:addGroup("Style");
	 indicator.parameters:addColor("UPUP", "Up in Up Trend ", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("UPDN", "Down in Up Trend ", "", core.rgb(0, 200, 0));
	 indicator.parameters:addColor("DNUP", "Up in Down Trend ", "", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("DNDN", "Down in Down Trend ", "", core.rgb(200, 0, 0));
	 
	 indicator.parameters:addGroup("Line Style");
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255));
	 indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
     indicator.parameters:addInteger("style", "Line style", "", core.LINE_NONE);
     indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block


local first;
local source = nil;
local One
local Two;
local Out;

local Method2,Method1;
local Period1, Period2;
-- Routine
function Prepare(nameOnly)
    Period1 = instance.parameters.Period1;
    Period2 = instance.parameters.Period2;
	Method2 = instance.parameters.Method2;
	Method1 = instance.parameters.Method1;
    source = instance.source;
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");
	
	if (Period1 >= Period2) then
       error("The short MA period must be smaller than long MA period");
    end
	
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period1).. ", " .. tostring(Method1).. ", " .. tostring(Period2).. ", " .. tostring(Method2) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        One = core.indicators:create("AVERAGES", source, Method1, Period1);
        Two = core.indicators:create("AVERAGES", source, Method2 , Period2);
           
        first = math.max(One.DATA:first(),  Two.DATA:first());
   
          Out = instance:addStream("TAO", core.Bar, name, "TAO", instance.parameters.UPUP, first);
    Out:setPrecision(math.max(2, instance.source:getPrecision()));
		 Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first);
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
		 Line:setWidth(instance.parameters.width);
         Line:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)


     One:update(mode);
	 Two:update(mode);
	
	  
	  
    if period < first or not source:hasData(period) then
	return;
	end

	
	
	Out[period] =One.DATA[period] - Two.DATA[period];
	Line[period]=Out[period];
	
	if Out[period] > 0 then
	    if  Out[period] > Out[period-1] then
		Out:setColor(period, instance.parameters.UPUP);
		else
		Out:setColor(period, instance.parameters.UPDN);
		end                	
	else
	    if  Out[period] > Out[period-1] then
		Out:setColor(period, instance.parameters.DNUP);
		else
		Out:setColor(period, instance.parameters.DNDN);
		end       
	end
	
    
end

