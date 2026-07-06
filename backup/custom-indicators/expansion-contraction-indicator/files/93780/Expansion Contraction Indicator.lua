-- Id: 11637
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60627&p=93780#p93780

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
    indicator:name("Expansion/Contraction Indicator");
    indicator:description("Expansion/Contraction Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	
	 indicator.parameters:addGroup("ATR Calculation");	
    indicator.parameters:addInteger("ATR_Period", "Period", "Period", 14);
	indicator.parameters:addDouble("ATR_Multiplier", "Multiplier", "Multiplier", 2);
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Range_color", "Color of Range", "Color of Range", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("Average_color", "Color of Average", "Color of Average", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("ATR_color", "Color of ATR", "Color of ATR", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addBoolean("Show", "Show Average Line", "", false);
	indicator.parameters:addBoolean("Use_ATR", "Show ATR Line", "", false);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Show;
local source = nil;
local ATR_Period, ATR,Use_ATR,ATR_Multiplier, atr;
-- Streams block
local Range = nil;
local Average = nil;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Show = instance.parameters.Show;
	ATR_Period = instance.parameters.ATR_Period;
	Use_ATR = instance.parameters.Use_ATR;
	ATR_Multiplier = instance.parameters.ATR_Multiplier;
	
	
    source = instance.source;    

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

	if (not (nameOnly)) then
		if  Use_ATR then
			ATR= core.indicators:create("ATR", source, ATR_Period);	 
		end
        Range = instance:addStream("Range", core.Line, name .. ".Range", "Range", instance.parameters.Range_color, source:first()+Period);
    Range:setPrecision(math.max(2, instance.source:getPrecision()));
		Range:setWidth(instance.parameters.width1);
        Range:setStyle(instance.parameters.style1);
		if Show then
        Average = instance:addStream("Average", core.Line, name .. ".Average", "Average", instance.parameters.Average_color, source:first()+Period*2);
    Average:setPrecision(math.max(2, instance.source:getPrecision()));
		Average:setWidth(instance.parameters.width2);
        Average:setStyle(instance.parameters.style2);
		else
		Average = instance:addInternalStream(0, 0);
		end
		
		if  Use_ATR then
        atr = instance:addStream("ATR", core.Line, name .. ".ATR", "ATR", instance.parameters.ATR_color, ATR.DATA:first());
    atr:setPrecision(math.max(2, instance.source:getPrecision()));
		atr:setWidth(instance.parameters.width3);
        atr:setStyle(instance.parameters.style3);
		else
		atr = instance:addInternalStream(0, 0);
		end
		
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)



    if  Use_ATR then
    ATR:update(mode);
	if period > ATR.DATA:first() then
	atr[period]= ATR.DATA[period]*ATR_Multiplier;
    end
	end
	
	
    if period < source:first()+Period or not  source:hasData(period) then
	return;
	end
	
	
	
	local min,max= mathex.minmax(source, period-Period+1, period); 
	
	
    Range[period] = max-min;
	
	  if period < source:first()+Period*2  then
	return;
	end
	
    Average[period] = mathex.avg(Range, period-Period+1, period);
	
	
     
end

