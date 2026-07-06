-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1166
-- Id: 792

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Random Walk Index");
    indicator:description("Random Walk Index");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("RWIH_color", "Color of RWIH", "Color of RWIH", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("RWIL_color", "Color of RWIL", "Color of RWIL", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period=nil;

local first;
local source = nil;

-- Streams block
local RWIH = nil;
local RWIL = nil;

-- Routine
function Prepare(nameOnly)
    local i;
	High = instance.parameters.RWIH_color;
    Low = instance.parameters.RWIL_color;
	Period = instance.parameters.Period;
    source = instance.source;
    	
	first=source:first()+1;			
	

	
    local name = profile:id() .. "(" .. source:name() .. ", " .. Period  .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	TR=instance:addInternalStream(source:first(),0);
    RWIH = instance:addStream("RWIH", core.Line, name .. "High", "High", High,  first + Period);
    RWIH:setPrecision(math.max(2, instance.source:getPrecision()));
	RWIH:setWidth(instance.parameters.width1);
    RWIH:setStyle(instance.parameters.style1);
    RWIL = instance:addStream("RWIL", core.Line, name .. "Low", "Low", Low,  first +  Period);
    RWIL:setPrecision(math.max(2, instance.source:getPrecision()));
	RWIL:setWidth(instance.parameters.width2);
    RWIL:setStyle(instance.parameters.style2);
end
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

if period > first then
TR[period]=math.max(source.high[period]-source.low[period],math.abs(source.high[period]-source.close[period-1]),math.abs(source.close[period-1]-source.low[period]));
end


local i;


			if period < first + Period and source:hasData(period) then
			return;
			end
			
			local min=0;
            local max=0;
			local MIN, MAX;
			
						for  i = 1 , Period, 1 do
					
						  local ATR= core.avg (TR, core.range  (period-i, period));
					
									if ATR~= 0 then
									          MAX = ((source.high[period] - source.low[period-i]) / (ATR / math.sqrt(i+1)));
											  MIN = ((source.high[period-i] - source.low[period]) / (ATR / math.sqrt(i+1)));
											  
									          max = math.max( max, MAX);
											  min =  math.max( min, MIN);											
											
									end							
						end	
		
	     RWIH[period]=max;
		 RWIL[period]=min;
	
end

