-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=28171
-- Id: 8298

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
    indicator:name("Bull Bear Ratio");
    indicator:description("Bull Bear Ratio");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	indicator.parameters:addBoolean("Composite", "Composite", "Composite", true);

	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Bull_color", "Color of Bull", "Color of Bull", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Bear_color", "Color of Bear", "Color of Bear", core.rgb(255, 0, 0));
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

-- Streams block
local Bull;
local Bear;
local BullUp, BullDown;
local BearUp, BearDown;
local Ratio;
local Composite;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Composite = instance.parameters.Composite;
    source = instance.source;
    first = source:first()+Period;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
	
        BullUp= instance:addInternalStream(0, 0);
        BullDown= instance:addInternalStream(0, 0); 	 
        BearUp= instance:addInternalStream(0, 0);
        BearDown= instance:addInternalStream(0, 0);
	
	   if Composite then
	   
	
	    Ratio = instance:addStream("Ratio", core.Line, name .. ".Ratio", "Ratio", instance.parameters.Bull_color, first);
    Ratio:setPrecision(math.max(2, instance.source:getPrecision()));
		Ratio:setWidth(instance.parameters.width1);
        Ratio:setStyle(instance.parameters.style1);
		
			Bull= instance:addInternalStream(0, 0);
            Bear= instance:addInternalStream(0, 0);
		
		else
	
        Bull = instance:addStream("Bull", core.Line, name .. ".Bull", "Bull", instance.parameters.Bull_color, first);
    Bull:setPrecision(math.max(2, instance.source:getPrecision()));
		Bull:setWidth(instance.parameters.width1);
        Bull:setStyle(instance.parameters.style1);
		
        Bear = instance:addStream("Bear", core.Line, name .. ".Bear", "Bear", instance.parameters.Bear_color, first);
    Bear:setPrecision(math.max(2, instance.source:getPrecision()));
		Bear:setWidth(instance.parameters.width2);
        Bear:setStyle(instance.parameters.style2);
		end
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)


    BullUp[period]=0;	
    BullDown[period]=0;
	BearUp[period]=0;
    BearDown[period]=0;
    
	if source.close[period] -source.open[period] > 0 then
    BullUp[period]=  source.close[period] -source.open[period];
	end
	
    BullDown[period]=  source.high[period] -math.max(source.open[period],source.close[period] );
	
	
	
	if source.open[period] - source.close[period]  > 0 then
    BearDown[period]= source.open[period] - source.close[period]
	end
	
	BearUp[period]=   math.min(source.open[period],source.close[period] ) - source.low[period];

    if period < first  then
	return;
	end
		    
	
        Bull[period] =  mathex.sum(BullUp , period-Period+1, period)/ mathex.sum(BullDown , period-Period+1, period);
		Bear[period] = mathex.sum(BearDown , period-Period+1, period) / mathex.sum(BearUp , period-Period+1, period);
	
     if Composite then	
		Ratio[period]=  Bull[period]-  Bear[period];
		
		
		if Ratio[period]> Ratio[period-1] then
		Ratio:setColor(period, instance.parameters.Bull_color);
		else
		Ratio:setColor(period, instance.parameters.Bear_color);
		end
	 end	
 end

