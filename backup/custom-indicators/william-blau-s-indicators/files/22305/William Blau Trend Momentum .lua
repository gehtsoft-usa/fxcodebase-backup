-- Id: 5490
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=10878


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
-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Trend Momentum ");
    indicator:description("Up/ Down Trend Momentum");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UDM_color", "Color of UDM", "", core.rgb(0, 0, 255));
	--indicator.parameters:addColor("Up_color", "Color of Up", "", core.rgb(0, 255, 0));
	--indicator.parameters:addColor("Down_color", "Color of Down", "", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;

-- Streams block
local UDM = nil;
local High, Low;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first()+Period;
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
  --  High = instance:addStream("Up", core.Line, name, "Up", instance.parameters.Up_color, first);
    High:setPrecision(math.max(2, instance.source:getPrecision()));
	--Low = instance:addStream("Down", core.Line, name, "Down", instance.parameters.Down_color, first);
    --Low:setPrecision(math.max(2, instance.source:getPrecision()));
	
	High = instance:addInternalStream(0, 0);
	Low = instance:addInternalStream(0, 0);
	
     
        UDM = instance:addStream("UDM", core.Line, name, "UDM", instance.parameters.UDM_color, first);
    UDM:setPrecision(math.max(2, instance.source:getPrecision()));
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period >= first and source:hasData(period) then
       
	if source.high[period] -  source.high[period-Period] > 0 then  
	High[period] = source.high[period] -  source.high[period-Period];
	else
	High[period]= 0;
	end

	if source.low[period] -  source.low[period-Period] < 0 then  
	Low[period] = -( source.low[period] -  source.low[period-Period]);
	else
	Low[period]= 0;
	end
	
	   
	    UDM[period] = High[period]-Low[period];
    end
end

