-- Id: 8250
--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC | 
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
    indicator:name("Disparity Index");
    indicator:description("Disparity Index");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 10);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	 indicator.parameters:addDouble("InpLevelsCoeff", "Coefficient", "Coefficient", 3);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Color of DI Up", "Color of DI", core.rgb(0, 200, 0));
    indicator.parameters:addColor("UpOver", "Color of DI Up Over", "Color of DI", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Color of DI Down", "Color of DI", core.rgb(200, 0, 0));
	 indicator.parameters:addColor("DownUnder", "Color of DI Down Under", "Color of DI", core.rgb(255, 0, 0));
	
	indicator.parameters:addColor("Top_color", "Color of Top Line", "Color of Top Line", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Bottom_color", "Color of Bottom Line", "Color of Bottom Line", core.rgb(128,128, 128));
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
local InpLevelsCoeff;
local PriceMA, BufferMA;
local first;
local source = nil;
local Method;
-- Streams block
local DI = nil;
local Buffer;
local Up, Down;
local UpOver, DownUnder;
-- Routine
function Prepare(nameOnly)
    Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	UpOver = instance.parameters.UpOver;
	DownUnder = instance.parameters.DownUnder;
    Period = instance.parameters.Period;
	Method = instance.parameters.Method;
	InpLevelsCoeff = instance.parameters.InpLevelsCoeff;
    source = instance.source;
    first = source:first()+1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Method).. ", " .. tostring(InpLevelsCoeff) .. ")";
    instance:name(name);
	
	Buffer=instance:addInternalStream(0, 0);
	PriceMA = core.indicators:create(Method, source  , Period);
	BufferMA = core.indicators:create(Method, Buffer  , Period);

    if (not (nameOnly)) then
        DI = instance:addStream("DI", core.Bar, name, "DI", instance.parameters.Up, PriceMA.DATA:first());	
		
		Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.Top_color, BufferMA.DATA:first());
		Top:setWidth(instance.parameters.width1);
        Top:setStyle(instance.parameters.style1);
		
		Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.Bottom_color, BufferMA.DATA:first());
		Bottom:setWidth(instance.parameters.width2);
        Bottom:setStyle(instance.parameters.style2);
		
		DI:setPrecision(math.max(2, instance.source:getPrecision()));
		Top:setPrecision(math.max(2, instance.source:getPrecision()));
		Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
		
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)


    if period < first  then
	return;
	end
	
	Buffer[period] = math.abs(source[period]-source[period-1]) / source[period] * 100;
	
	
	
	PriceMA:update(mode);
	if period < PriceMA.DATA:first()  then
	return;
	end
	
    DI[period] = ((source[period] - PriceMA.DATA[period]) / PriceMA.DATA[period] *100);
	
	
	BufferMA:update(mode);
	
	if period < BufferMA.DATA:first()  then
	return;
	end
	
	Top[period] = BufferMA.DATA[period] * InpLevelsCoeff;
    Bottom[period] = -BufferMA.DATA[period] * InpLevelsCoeff;
	
	if DI[period] > 0 then
	     if  DI[period] > Top[period] then
		  DI:setColor(period, UpOver);
         else
		  DI:setColor(period, Up);
         end		 
	else
	     if  DI[period]  < Bottom[period] then
		  DI:setColor(period, DownUnder); 
         else
		  DI:setColor(period, Down);
         end	
	end
	
   
end

