
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63125

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
    indicator:name("Timed Moving Averages Envelope");
    indicator:description("Timed Moving Averages Envelope");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
 
    indicator.parameters:addInteger("DurationOfFast", "Fast MA Duration in seconds", "Fast MA Duration in seconds", 60);
    indicator.parameters:addInteger("DurationOfSlow", "Slow MA Duration in seconds", "Slow MA Duration in seconds", 2500);
    
	indicator.parameters:addDouble("BandWidth", "Band Width", "", 25);
    indicator.parameters:addString("BandWidthUnits", "Band Width Units", "", "%%");
    indicator.parameters:addStringAlternative("BandWidthUnits", "In 1/100 of percent", "", "%%");
    indicator.parameters:addStringAlternative("BandWidthUnits", "In pips", "", "pip(s)");
    
    indicator.parameters:addString("Method", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color1", "Color of Central Line", "Color of Line", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Color2", "Color of Top Line", "Color of Line", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style2", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("Color3", "Color of Bottom Line", "Color of Line", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("Width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style3", core.FLAG_LINE_STYLE);
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first;
local source = nil;
-- Streams block
local MA;
local RawFast,RawSlow;
local Fast, Slow;

local BandWidthUnits, BandWidth;
local Top,Bottom;
local calculateAvg;
local DurationOfFast;
local DurationOfSlow;
local PeriodOfFast;
local PeriodonOfSlow;

-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
		
    DurationOfFast = instance.parameters.DurationOfFast;
    DurationOfSlow = instance.parameters.DurationOfSlow;
	BandWidthUnits = instance.parameters.BandWidthUnits;
	BandWidth = instance.parameters.BandWidth;
    source = instance.source;
    first=source:first();
 	
    RawFast= instance:addInternalStream(0, 0);
    RawSlow= instance:addInternalStream(0, 0);
    Fast= instance:addInternalStream(0, 0);
    Slow= instance:addInternalStream(0, 0);	 
   
    MA = instance:addStream("MA", core.Line, name .. ".MA", "MA", instance.parameters.Color1, source:first());
    MA:setWidth(instance.parameters.Width1);
    MA:setStyle(instance.parameters.Style1);

    Top = instance:addStream("Top", core.Line, name .. ".Top", "Top", instance.parameters.Color2, first);
    Top:setWidth(instance.parameters.Width2);
    Top:setStyle(instance.parameters.Style2);

    Bottom = instance:addStream("Bottom", core.Line, name .. ".Bottom", "Bottom", instance.parameters.Color3, first);
    Bottom:setWidth(instance.parameters.Width3);
    Bottom:setStyle(instance.parameters.Style3);
    
    if instance.parameters.Method == "MVA" then
        calculateAvg = calculateMVA;
    elseif instance.parameters.Method == "EMA" then
        calculateAvg = calculateEMA;
    elseif instance.parameters.Method == "SMMA" then
        calculateAvg = calculateSMMA;
    end 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
	
	if period <= first then
        return;
	end
	
    local One=1/86400;		
    local P1= core.findDate (source, source:date(period)-One*DurationOfFast, false);
	local P2= core.findDate (source, source:date(period)-One*DurationOfSlow, false);
	
	if P1==-1 or P2==-1 or
       P1< first+1 or P2< first+1 or
       P1 >= period or P2  >= period
    then
        return;
    end 
    
    RawFast[period] = calculateAvg(source ,P1, period, RawFast);
    RawSlow[period] = calculateAvg(source ,P2, period, RawSlow);
	
	local FastMA,SlowMA;
		
    FastMA= mathex.avg(RawFast,P1, period);
    SlowMA=  mathex.avg(RawSlow, P2, period);
		
    Fast[period]= RawFast[period] + RawFast[period] - FastMA;
    Slow[period]= RawSlow[period] + RawSlow[period] - SlowMA;
    MA[period]= RawFast[period] + (Fast[period] - Slow[period]);
 
    if BandWidthUnits == "%%" then
         Delta =  MA[period] * BandWidth / 10000;
         Top[period] =  MA[period] + Delta;
         Bottom[period] =  MA[period] - Delta;
    else
         Top[period] =  MA[period] + BandWidth*source:pipSize();
         Bottom[period] =  MA[period] - BandWidth*source:pipSize();
    end 
	 
end

function calculateMVA(source, p, period, result)
	return mathex.avg(source, p, period);
end

function calculateEMA(source, p, period, result)
	local n = period - p;
	if period <= n then
        return source[period];
    else
		local k = 2.0 / (n + 1.0);
        return (1 - k) * result[period - 1] + k * source[period];
    end
end

function calculateSMMA(source, p, period, result)
	local n = period - p;
	if period <= n then
        return mathex.avg(source, p, period);
    else
        return (result[period - 1] * n + source[period]) / (n + 1);
    end
end
 