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

function Init()
    indicator:name("Timed ZeroLag Envelope");
    indicator:description("Timed ZeroLag Envelope");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
 
    indicator.parameters:addInteger("Duration", "MA Duration in seconds", "MA Duration in seconds", 60);
	indicator.parameters:addDouble("BandWidth", "Band Width", "", 25);
    indicator.parameters:addString("BandWidthUnits", "Band Width Units", "", "%%");
    indicator.parameters:addStringAlternative("BandWidthUnits", "In 1/100 of percent", "", "%%");
    indicator.parameters:addStringAlternative("BandWidthUnits", "In pips", "", "pip(s)");

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
local Duration;
local ZeroLag;
local Second; 
local BandWidthUnits, BandWidth;
local Top,Bottom;
local EMA = nil;

-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 

    if   (nameOnly) then
        return;
    end
		
    Duration = instance.parameters.Duration; 
	BandWidthUnits = instance.parameters.BandWidthUnits;
	BandWidth = instance.parameters.BandWidth;
    source = instance.source;
    first=source:first();
 	
	local date1= core.datetime (2014, 1, 1, 1, 1, 0);
	local date2= core.datetime (2014, 1, 1, 1, 2, 0);
	Second= ((date2 - date1)/60);
	    
    ZeroLag = instance:addStream("ZeroLag", core.Line, name .. ".ZeroLag", "ZeroLag", instance.parameters.Color1, source:first());
    ZeroLag:setWidth(instance.parameters.Width1);
    ZeroLag:setStyle(instance.parameters.Style1);

    EMA = instance:addInternalStream(0, 0);

    Top = instance:addStream("Top", core.Line, name .. ".Top", "Top", instance.parameters.Color2, first);
    Top:setWidth(instance.parameters.Width2);
    Top:setStyle(instance.parameters.Style2);

    Bottom = instance:addStream("Bottom", core.Line, name .. ".Bottom", "Bottom", instance.parameters.Color3, first);
    Bottom:setWidth(instance.parameters.Width3);
    Bottom:setStyle(instance.parameters.Style3);   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
	
	if period <= first then
        return;
	end
		  
	local P1= core.findDate (source, source:date(period)- Second * Duration, false);
	
    if P1==-1 or P1< first+1 or P1>= period
    then
        return;
    end 
	 
    EMA[period] = calculateEMA(source,P1, period, EMA);
	ZeroLag[period] = calculateZeroLag(source,P1, period, ZeroLag);
		
    if BandWidthUnits == "%%" then
        Delta =  ZeroLag[period] * BandWidth / 10000;
        Top[period] =  ZeroLag[period] + Delta;
        Bottom[period] =  ZeroLag[period] - Delta;
    else
        Top[period] =  ZeroLag[period] + BandWidth*source:pipSize();
        Bottom[period] =  ZeroLag[period] - BandWidth*source:pipSize();
    end 
	 
end

function calculateZeroLag(source, p, period, result)
	local n = period - p;
	if period <= n then
        return source[period];
    else
        local k = 2.0 /(period + 1);
        local x = (period - 1)/2;    
        return k * (2 * source[period] - source[period - x])+(1-k)* EMA[period-1];       
    end
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

 