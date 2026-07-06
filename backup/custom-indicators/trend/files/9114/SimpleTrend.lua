-- Id: 5040

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
    indicator:name("SimpleTrend");
    indicator:description("SimpleTrend");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("Calculation"); 
    
    indicator.parameters:addString("Method", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "WMA", "", "WMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");

	indicator.parameters:addString("Price", "MA Price Source", "", "close");
	indicator.parameters:addStringAlternative("Price", "Open", "", "open");
	indicator.parameters:addStringAlternative("Price", "High", "", "high");
	indicator.parameters:addStringAlternative("Price", "Low", "", "low");
	indicator.parameters:addStringAlternative("Price", "Close/Tick", "", "close");
	indicator.parameters:addStringAlternative("Price", "Median", "", "median");
	indicator.parameters:addStringAlternative("Price", "Typical", "", "typical");
	indicator.parameters:addStringAlternative("Price", "Weighted", "", "weighted");

    indicator.parameters:addInteger("Step", "Step", "Step", 1, 1, 200);
    indicator.parameters:addInteger("Max", "Max", "Maqx", 200 , 2,2000);
	 indicator.parameters:addInteger("Look", "Look back Period", "", 200,1, 2000);
	
	indicator.parameters:addGroup("Style");
			
	indicator.parameters:addInteger("Trendwidth", "Trend Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Trendstyle", "Trend Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Trendstyle", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("Trend_color", "Color of Trend", "", core.rgb(0, 0, 255));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Step;
local Max;
local Look;
local first=1;
local source = nil;

-- Streams block
local Up = nil;
local Trend = nil;

local Method;
local indicator={};
local Price;
local MAsource;
local MAX;
-- Routine
function Prepare(nameOnly)
    Look= instance.parameters.Look;
    Price= instance.parameters.Price;
    Method = instance.parameters.Method;
    Step = instance.parameters.Step;
    Max = instance.parameters.Max;
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
    

	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Step) .. ", " .. tostring(Max) .. ", " .. tostring(Price).. ", " .. tostring(Method).. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	local i;
	for i =2, Max, Step do
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	indicator[i]  = core.indicators:create(Method, MAsource, i);
	 first = math.max(first, indicator[i].DATA:first());
	end 
	
	
		MAX = math.max(Look, Max);
		first = math.max(first, MAX);

   
        Up =  instance:addInternalStream(0, 0);		      

        Trend = instance:addStream("Trend", core.Line, name .. ".Trend", "Trend", instance.parameters.Trend_color, first);
    Trend:setPrecision(math.max(2, instance.source:getPrecision()));
		Trend:setWidth(instance.parameters.Trendwidth);
        Trend:setStyle(instance.parameters.Trendstyle);
		Trend:addLevel(0);
		Trend:addLevel(100);
		Trend:addLevel(50);

   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
		if period >= source:size()-1  - MAX and source:hasData(period) then
		local i;		
		for i =2, Max, Step do
		 indicator[i]:update(mode);  		
		end	
	
		Up[period]=0;
	
		
				for i =2+Step, Max, Step do
				 
						 if  indicator[i-Step].DATA:hasData(period) and  indicator[i].DATA:hasData(period) then
									if  indicator[i-Step].DATA[period] >  indicator[i].DATA[period] then
									Up[period] = Up[period]+1;
								    end
						
						end
				 end	
		Trend[period] = Up[period]  /  (Max/100) ;			
		end		    	
end

