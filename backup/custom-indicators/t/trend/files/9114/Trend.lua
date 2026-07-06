-- Id: 3457

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3753

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
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("TREND");
    indicator:description("TREND");
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
	
	indicator.parameters:addString("Price", "MA Price Source", "", "close");
	indicator.parameters:addStringAlternative("Price", "Open", "", "open");
	indicator.parameters:addStringAlternative("Price", "High", "", "high");
	indicator.parameters:addStringAlternative("Price", "Low", "", "low");
	indicator.parameters:addStringAlternative("Price", "Close/Tick", "", "close");
	indicator.parameters:addStringAlternative("Price", "Median", "", "median");
	indicator.parameters:addStringAlternative("Price", "Typical", "", "typical");
	indicator.parameters:addStringAlternative("Price", "Weighted", "", "weighted");

    indicator.parameters:addInteger("Step", "Step", "Step", 1);
    indicator.parameters:addInteger("Max", "Max", "Maqx", 200);
	
	indicator.parameters:addGroup("Style");
	
	indicator.parameters:addInteger("Upwidth", "Up Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Upstyle", "Up Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Upstyle", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("Up_color", "Color of Up", "", core.rgb(0, 255, 0));
	
	indicator.parameters:addInteger("Downwidth", "Down Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Downstyle", "Down Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Downstyle", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("Down_color", "Color of Down", "", core.rgb(255, 0, 0));
	
	indicator.parameters:addInteger("Trendwidth", "Trend Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Trendstyle", "Trend Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Trendstyle", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("Trend_color", "Color of Trend", "", core.rgb(0, 0, 255));
	
	indicator.parameters:addGroup("Oversold Overbought Levels Style");
	indicator.parameters:addInteger("os_width", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("os_style", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("os_style", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("os_color", "Oversold Overbought Levels", "", core.rgb(128, 128, 128));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Step;
local Max;

local first;
local FIRST;
local source = nil;

-- Streams block
local Up = nil;
local Down = nil;
local Trend = nil;

local Method;
local indicator={};
local Price;
local MAsource;

local os_width,os_style, os_color;

-- Routine
function Prepare(nameOnly)
    Price= instance.parameters.Price;
    Method = instance.parameters.Method;
    Step = instance.parameters.Step;
    Max = instance.parameters.Max;
    source = instance.source;
    first = source:first();
	FIRST = source:first();
	os_width=instance.parameters.os_width;
	os_style=instance.parameters.os_style;
    os_color=instance.parameters.os_color;
	
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
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Step) .. ", " .. tostring(Max) .. ", " .. tostring(Price).. ", " .. tostring(Method).. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");

    
	local i;
	for i =2, Max, Step do
	indicator[i]  = core.indicators:create("AVERAGES", MAsource, Method, i, false);
	 first = math.max(first, indicator[i].DATA:first());
	end 

 
        Up = instance:addStream("Up", core.Line, name .. ".Up", "Up", instance.parameters.Up_color, first);
		Up:setWidth(instance.parameters.Upwidth);
        Up:setStyle(instance.parameters.Upstyle);
        Down = instance:addStream("Down", core.Line, name .. ".Down", "Down", instance.parameters.Down_color, first);
		Down:setWidth(instance.parameters.Downwidth);
        Down:setStyle(instance.parameters.Downstyle);
        Trend = instance:addStream("Trend", core.Line, name .. ".Trend", "Trend", instance.parameters.Trend_color, first);
		Trend:setWidth(instance.parameters.Trendwidth);
        Trend:setStyle(instance.parameters.Trendstyle);
		
		Up:setPrecision(math.max(2, instance.source:getPrecision()));
		Down:setPrecision(math.max(2, instance.source:getPrecision()));
		Trend:setPrecision(math.max(2, instance.source:getPrecision()));
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
		if period >= first and source:hasData(period) then
		local i;
		local count = 0;
		for i =2, Max, Step do
		 indicator[i]:update(mode);  	
		 count=count+1;	 
		end	
		
			if period== source:size()-1 then
			core.host:execute ("drawLine", 1,  source:date(FIRST), count, source:date(period), count, os_color, os_style, os_width);	
			core.host:execute ("drawLine", 2, source:date(FIRST), -count, source:date(period), -count, os_color, os_style, os_width);	
			end
		
		Up[period]=0;
		Down[period]=0;
		
				for i =2+Step, Max, Step do
				 
						 if  indicator[i-Step].DATA:hasData(period) and  indicator[i].DATA:hasData(period) then
									if  indicator[i-Step].DATA[period] >  indicator[i].DATA[period] then
									Up[period] = Up[period]+1;
									elseif  indicator[i-Step].DATA[period] <  indicator[i].DATA[period] then
									Down[period] = Down[period]-1;
									end
						
						end
				 end	
		Trend[period] = Up[period]+Down[period];			
		end		    	
end

