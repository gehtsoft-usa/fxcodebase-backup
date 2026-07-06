-- Id: 10759
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60155

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Weight Volume Move-Adjusted Moving Average");
    indicator:description("Weight Volume Move-Adjusted Moving Average");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addString("Show", "Show VOMOMA/WEVOMO/Both", "", "Both");
    indicator.parameters:addStringAlternative("Show", "VOMOMA", "", "VOMOMA");
    indicator.parameters:addStringAlternative("Show", "WEVOMO", "", "WEVOMO");
	indicator.parameters:addStringAlternative("Show", "Both", "", "Both")
	
    indicator.parameters:addColor("WEVOMO_color1", "Color of WEVOMO", "Color of WEVOMO", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("WEVOMO_color2", "Color of VOMOMA", "Color of VOMOMA", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;
local Show;
-- Streams block
local WEVOMO,VOMOMA;
local Difference;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Show = instance.parameters.Show;
    source = instance.source;
	
    first = source:first()+Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
		Difference = instance:addInternalStream(0, 0);	
	
	    if Show ~= "VOMOMA" then
			WEVOMO = instance:addStream("WEVOMO", core.Line, name, "WEVOMO", instance.parameters.WEVOMO_color1, first);
			WEVOMO:setWidth(instance.parameters.width1);
			WEVOMO:setStyle(instance.parameters.style1);
		else
			WEVOMO = instance:addInternalStream(0, 0);	
		end 
		
		if Show ~= "WEVOMO" then
			VOMOMA = instance:addStream("VOMOMA", core.Line, name, "VOMOMA", instance.parameters.WEVOMO_color2, first);
			VOMOMA:setWidth(instance.parameters.width2);
			VOMOMA:setStyle(instance.parameters.style2);
		else
			VOMOMA = instance:addInternalStream(0, 0);	
		end
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    Difference[period]= math.abs(source.close[period]-source.close[period-1]);
	
    if period < first or not source:hasData(period) then
	return;
	end
	
	local DifferenceSum = mathex.sum(Difference, period-Period+1, period);
	local VolumeSum = mathex.sum(source.volume, period-Period+1, period);
	
	local VOMA=0;	
	local MOMA=0;
	local Count=0;
	local WMA=0;
	 
	
	for i= 1, Period, 1 do
	MOMA= MOMA  +  source.close[period-Period+i] * ( Difference[period-Period+i] /DifferenceSum);
	VOMA= VOMA  +  source.close[period-Period+i] * ( source.volume[period-Period+i] /VolumeSum);
	WMA= WMA + (source.close[period-Period+i] *i);
	Count= Count+i;
	end
	
	WMA=WMA/Count;
	
	VOMOMA[period]=(MOMA+VOMA)/2;
		
     WEVOMO[period] =(MOMA+VOMA+WMA)/3;
    
end

