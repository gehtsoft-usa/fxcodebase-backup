--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("ATR Channel");
    indicator:description("ATR Channel");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("P1", "ATR Period", "ATR Period", 10);
	indicator.parameters:addInteger("P3", "MA Period", "MA Period", 20);
	indicator.parameters:addInteger("Multiplier", "ATR Multiplier", "", 1);
	
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
	indicator.parameters:addString("MORE", "Show additional lines", "Yes", "Yes");
    indicator.parameters:addStringAlternative("MORE", "Yes", "Show additional lines", "Yes");
    indicator.parameters:addStringAlternative("MORE", "No", "Show additional lines", "No");
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Central_color", "Central", "Color of Central", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Top_color", "Top", "Color of Top", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("Bottom_color", "Bottom", "Color of Bottom", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local P1;
local P2;
local P3;
local MORE;
local Method;
local Multiplier;

local first;
local source = nil;

-- Streams block
local S1 = nil;
local S2 = nil;
local S3 = nil;
local S4 = nil;
local S5 = nil;
local S6 = nil;
local S7 = nil;

local ATR;
local Indicator;

-- Routine
function Prepare() 
    Multiplier= instance.parameters.Multiplier;
    Method= instance.parameters.Method;
    P1 = instance.parameters.P1;
	P2 = instance.parameters.P2;
	P3 = instance.parameters.P3;
	MORE = instance.parameters.MORE;
    
	source = instance.source;
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. ",".. P1..", " ..P3 .. ",".. Method..", " .. Multiplier..")";
    instance:name(name);
    	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");
  
	ATR = core.indicators:create("ATR", source, P1);
	Indicator = core.indicators:create("AVERAGES", source.close, Method, P3, false);
	first= math.max(Indicator.DATA:first(), ATR.DATA:first())+1;
	
	S1 = instance:addStream("Central", core.Line, name .. "Central", "Central", instance.parameters.Central_color, first);
	S1:setWidth(instance.parameters.width1);
    S1:setStyle(instance.parameters.style1);

    S2 = instance:addStream("Top1", core.Line, name .. "Top", "Top", instance.parameters.Top_color, first);
	S1:setWidth(instance.parameters.width2);
    S1:setStyle(instance.parameters.style2);
	
	S3 = instance:addStream("Bottom1", core.Line, name .. "Bottom", "Bottom", instance.parameters.Bottom_color, first);
	S3:setWidth(instance.parameters.width3);
    S3:setStyle(instance.parameters.style3);
	
	
    S4 = instance:addStream("Top2", core.Line, name .. "Top", "",  instance.parameters.Top_color, first);
	S4:setWidth(instance.parameters.width2);
    S4:setStyle(instance.parameters.style2);
	
	S5 = instance:addStream("Bottom2", core.Line, name .. "Bottom", "", instance.parameters.Bottom_color, first);
	S5:setWidth(instance.parameters.width3);
    S5:setStyle(instance.parameters.style3);
	
    S6 = instance:addStream("Top3", core.Line, name .. "Top", "", instance.parameters.Top_color, first);
	S6:setWidth(instance.parameters.width2);
    S6:setStyle(instance.parameters.style2);
	
	S7 = instance:addStream("Bottom3", core.Line, name .. "Bottom", "", instance.parameters.Bottom_color, first);
	S7:setWidth(instance.parameters.width3);
    S7:setStyle(instance.parameters.style3);
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    if period >= first and source:hasData(period) then
	
	    ATR:update(mode);
		Indicator:update(mode);
		
		
        S1[period] = Indicator.DATA[period];
		
		S4[period] = Indicator.DATA[period]+2*Multiplier*ATR.DATA[period];
		S5[period] = Indicator.DATA[period]-2*Multiplier*ATR.DATA[period];
		if MORE == "Yes" then
		S2[period] = Indicator.DATA[period]+Multiplier*ATR.DATA[period];
		S3[period] = Indicator.DATA[period]-Multiplier*ATR.DATA[period];
		S6[period] = Indicator.DATA[period]+3*Multiplier*ATR.DATA[period];
		S7[period] = Indicator.DATA[period]-3*Multiplier*ATR.DATA[period];
		end
			
        
    end
end

