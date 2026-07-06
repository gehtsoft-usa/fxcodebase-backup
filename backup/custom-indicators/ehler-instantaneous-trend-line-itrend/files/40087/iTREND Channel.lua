-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23276
-- Id: 9175

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("iTREND Channel");
    indicator:description("iTREND Channels");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
      indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("alpha", "Alpha", "Alpha", 0.07);
	
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "Pips");
    indicator.parameters:addStringAlternative("Method", "Percentage", "Percentage" , "Percentage");
    indicator.parameters:addStringAlternative("Method", "Pips", "Pips" , "Pips");
	
	
    indicator.parameters:addDouble("Delta", "Channel Width", "Channel Width", 50);
	
	  indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("iTrend_color", "Color of iTrend", "Color of iTrend", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);
	
	
	 indicator.parameters:addColor("Top_color", "Color of Top Channel", "Color of Top Channel", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width2", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", " Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addColor("Bottom_color", "Color of Bottom Channel", "Color of Bottom Channel", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", " Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local alpha;

local first;
local source = nil;
local Delta;
-- Streams block
local iTrend = nil;
local Top, Bottom;
local Method;
-- Routine
function Prepare(nameOnly)
    alpha = instance.parameters.alpha;
	Delta = instance.parameters.Delta;
	Method= instance.parameters.Method;
    source = instance.source;
    first = source:first()+2;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(alpha) .. ", " .. tostring(Delta).. ")";
    instance:name(name);

    if (not (nameOnly)) then
        iTrend = instance:addStream("iTrend", core.Line, name, "iTrend", instance.parameters.iTrend_color, first);
		iTrend:setWidth(instance.parameters.width1);
        iTrend:setStyle(instance.parameters.style1);
		
		
		Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.Top_color, first);
		Top:setWidth(instance.parameters.width2);
        Top:setStyle(instance.parameters.style2);
		
		Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.Bottom_color, first);
		Bottom:setWidth(instance.parameters.width3);
        Bottom:setStyle(instance.parameters.style3);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not source:hasData(period) then
	return;
	end
	
	if period < 7 then 
	iTrend[period] = source[period] + 2*source[period-1]+ source[period-2]/4;
	else	
	iTrend[period] = (alpha- alpha*alpha/4)*source[period] + 0.5* alpha * alpha * source[period-1] -
	(alpha - 0.75 * alpha*alpha) * source[period-2] + 2
	*(1 - alpha) * iTrend[period-1] -(1 - alpha)
	*(1-alpha)*iTrend[period-2];	
	end

	
       if Method == "Pips" then
	   Top[period]= iTrend[period]+ Delta* source:pipSize();
	   Bottom[period]= iTrend[period]- Delta* source:pipSize();
	   else
	   Top[period]= iTrend[period]+ Delta*iTrend[period]/100 ;
	   Bottom[period]= iTrend[period]- Delta*iTrend[period]/100 ;
	   end
    
end

