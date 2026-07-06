-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=33781
-- Id: 8791

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
    indicator:name("TREND CHANNEL");
    indicator:description("TREND CHANNEL");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	indicator.parameters:addDouble("Multiplier", "Multiplier", "Multiplier", 2.5);
	indicator.parameters:addBoolean("Use"  , "Use PreSmoothing", "", true);	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Top_color", "Color of Top", "Color of Top", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Central_color", "Color of Central", "Color of Central", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Bottom_color", "Color of Bottom", "Color of Bottom", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Multiplier;
local first;
local source = nil;
local S1,S2 ;
-- Streams block
local Top = nil;
local Central = nil;
local Bottom = nil;
local s2, s3;
local Use;
local Variance, Avg1;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Multiplier = instance.parameters.Multiplier;
	Use = instance.parameters.Use;
    source = instance.source;
	
	s2= 2/(Period+1);
	s3= 2*(s2-1)

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Multiplier).. ")";
    instance:name(name);

    if (not (nameOnly)) then
		S1 = instance:addInternalStream(0, 0);
		S2 = instance:addInternalStream(0, 0);
		 
		Variance= instance:addInternalStream(0, 0);
		Avg1= instance:addInternalStream(0, 0);	 
		first = source:first()+11;
        Top = instance:addStream("Top", core.Line, name .. ".Top", "Top", instance.parameters.Top_color, first);
		Top:setWidth(instance.parameters.width1);
        Top:setStyle(instance.parameters.style1);
        Central = instance:addStream("Central", core.Line, name .. ".Central", "Central", instance.parameters.Central_color, first);
		Central:setWidth(instance.parameters.width2);
        Central:setStyle(instance.parameters.style2);
        Bottom = instance:addStream("Bottom", core.Line, name .. ".Bottom", "Bottom", instance.parameters.Bottom_color, first);
		Bottom:setWidth(instance.parameters.width3);
        Bottom:setStyle(instance.parameters.style3);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first+1  or period >= source:size()-1 then
	return;
	end
	if Use then 
	S1[period]= S1[period-1] +0.5 *(source[period]-S1[period-1]);
	S2[period]= S2[period-1] +s2 *(S1[period]-S2[period-1]);	
	else
	S2[period]= S2[period-1] +s2 *(source[period]-S2[period-1]);
	end
	 Central[period]= Central[period-1] +s2*(S2[period]-Central[period-1])+s3*(S2[period-1]-S2[period]);
	Variance[period]=(source[period]-Central[period])^2;
	
	if period < 6 then
	return;
	end
	
	Avg1[period]= mathex.avg(Avg1, period-5+1, period);
	
	
	if period < 11 then
	return;
	end
	
	local Sigma=math.sqrt( mathex.avg(Variance, period-5+1, period));

        Top[period] = Central[period]+Multiplier*Sigma;      
        Bottom[period] = Central[period]-Multiplier*Sigma;
    
end

