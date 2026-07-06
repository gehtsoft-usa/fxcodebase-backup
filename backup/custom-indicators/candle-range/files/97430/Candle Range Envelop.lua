-- Id: 16829
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61561

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
    indicator:name("Candle Range Envelop");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");	
	
	indicator.parameters:addInteger("N", "Range Period", "Period" , 1);
		
	indicator.parameters:addString("Mode", "Method", "Method" , "High/Low");
    indicator.parameters:addStringAlternative("Mode", "High/Low", "High/Low" , "High/Low");
    indicator.parameters:addStringAlternative("Mode", "Open/Close", "Open/Close" , "Open/Close");
	indicator.parameters:addStringAlternative("Mode", "Volume", "Volume" , "Volume");
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("Period", "Period", "Period" , 14);
	
	indicator.parameters:addGroup("Envelop Calculation");	
	indicator.parameters:addString("EnvelopMethod", "Method", "Method" , "Dev");
    indicator.parameters:addStringAlternative("EnvelopMethod", "Deviation", "" , "Dev");
    indicator.parameters:addStringAlternative("EnvelopMethod", "Percentage", "" , "Pro");
	
	indicator.parameters:addInteger("DevPeriod", "Deviation Period", "Period" , 14);
	indicator.parameters:addDouble("DevMultiplier", "Deviation Multiplier", "Multiplier" , 2);
 
   indicator.parameters:addDouble("PercentageT", "Top Envelop Percentage", "Percentage" , 20);
   indicator.parameters:addDouble("PercentageB", "Bottom Envelop Percentage", "Percentage" , 20);
   
     indicator.parameters:addGroup("Confirmation MA Calculation");	
	indicator.parameters:addBoolean("Show", "Show Confirmation", "", false);
   	indicator.parameters:addString("Confirmation_Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Confirmation_Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Confirmation_Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Confirmation_Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Confirmation_Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Confirmation_Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Confirmation_Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Confirmation_Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Confirmation_Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("Confirmation_Period", "Period", "Period" , 28);
		
    indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Up", "Up Trend Color","Up Trend Color", core.COLOR_UPCANDLE);
	indicator.parameters:addColor("Down", "Down Trend Color","Down Trend Color", core.COLOR_DOWNCANDLE);
	indicator.parameters:addColor("Neutral", "Neutral Trend Color","Neutral Trend Color", core.COLOR_DOWNCANDLE);
	indicator.parameters:addColor("Signal_color", "Color of Signal", "Color of Signal", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("Confirmation_color", "Color of Signal", "Color of Signal", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("Top", "Top Line Color","Line Color", core.rgb(128, 128, 128));
	indicator.parameters:addColor("Bottom", "Bottom Line Color","Line Color", core.rgb(128, 128, 128));

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Show;
local first;
local source = nil;
local Method;
local Mode;
-- Streams block
local Range = nil;
local Period;
local Signal;
local MA;
local Up,Down,Neutral;
local Top, Bottom;
local DevPeriod, EnvelopMethod, DevMultiplier, PercentageT,PercentageB;
local N;
local Confirmation;
local Confirmation_MA, Confirmation_Period, Confirmation_Method;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
	Method=instance.parameters.Method;
	Mode=instance.parameters.Mode;
	Period=instance.parameters.Period;
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
	DevPeriod=instance.parameters.DevPeriod;
	EnvelopMethod=instance.parameters.EnvelopMethod;
	DevMultiplier=instance.parameters.DevMultiplier;
	PercentageT=instance.parameters.PercentageT;
	PercentageB=instance.parameters.PercentageB;
	N=instance.parameters.N;
	Confirmation_Period=instance.parameters.Confirmation_Period;
	Confirmation_Method=instance.parameters.Confirmation_Method;
	Show=instance.parameters.Show;

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

     if   (nameOnly) then
        return;
    end
        Range = instance:addStream("Range", core.Bar, name, "Range",Up, first);
		MA = core.indicators:create(Method, Range, Period);
		Confirmation_MA = core.indicators:create(Confirmation_Method, Range, Confirmation_Period);
		Signal = instance:addStream("Signal", core.Line, name, "Signal", instance.parameters.Signal_color, MA.DATA:first());
		Signal:setWidth(instance.parameters.width);
        Signal:setStyle(instance.parameters.style);
		
		if Show then
		Confirmation = instance:addStream("Confirmation", core.Line, name, "Confirmation", instance.parameters.Confirmation_color, Confirmation_MA.DATA:first());
		Confirmation:setWidth(instance.parameters.width1);
        Confirmation:setStyle(instance.parameters.style1);
		else
		Confirmation= instance:addInternalStream(0, 0);
		end
		
		
		if EnvelopMethod == "Dev" then
		DevFirst=MA.DATA:first()+DevPeriod;
		else
		DevFirst=MA.DATA:first();
		end
		
		Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.Top, DevFirst);
		Top:setWidth(instance.parameters.width);
        Top:setStyle(instance.parameters.style);
		
		Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.Bottom,DevFirst );
		Bottom:setWidth(instance.parameters.width);
        Bottom:setStyle(instance.parameters.style);
		
		
		Top:setPrecision(math.max(2, instance.source:getPrecision()));
		Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
		Confirmation:setPrecision(math.max(2, instance.source:getPrecision()));
		Signal:setPrecision(math.max(2, instance.source:getPrecision()));
		Range:setPrecision(math.max(2, instance.source:getPrecision()));
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    if period < first + N 
	or not source:hasData(period)	
	then
	return;
	end
	
	
	   

	    if Mode == "High/Low" then
		 local Min,Max=mathex.minmax(source,period-N+1, period);
        Range[period] =( Max-Min)/source:pipSize();
		elseif Mode ==  "Open/Close" then
		Range[period] =math.abs( source.open[period-N+1]-source.close[period])/source:pipSize();
		else
		 local Min,Max=mathex.minmax(source.volume,period-N+1, period);
		 Range[period] =( Max-Min)/source:pipSize();
		end
	
	MA:update(mode);
	Confirmation_MA:update(mode);
	if period< 	MA.DATA:first() then
	return;
	end
    Signal[period]= MA.DATA[period];
	
	if EnvelopMethod == "Dev" then
	
		if period <  MA.DATA:first() +DevPeriod then
		return;
		end
		
	DeltaT= mathex.stdev (MA.DATA, period-DevPeriod+1, period)*DevMultiplier;
	DeltaB= mathex.stdev (MA.DATA, period-DevPeriod+1, period)*DevMultiplier;
	
	else
	
	DeltaT =( MA.DATA[period]/100) *PercentageT;
	DeltaB =( MA.DATA[period]/100) *PercentageB;
	end
	
	Top[period]= Signal[period]+DeltaT;
	Bottom[period]= Signal[period]-DeltaB;
	
	
	if Range[period] > Top[period] then
	Range:setColor(period, Up);
	elseif Range[period] < Bottom[period]then
	Range:setColor(period,  Down);
	else
	Range:setColor(period,  Neutral);
	end
	
	if period< 	Confirmation_MA.DATA:first() then
	return;
	end
	
	Confirmation[period]= Confirmation_MA.DATA[period];
end

