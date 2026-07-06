-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70846

--+------------------------------------------------------------------+
--|                               Copyright © 2021, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("RSI-OBV INDICATOR");
    indicator:description("RSI-OBV INDICATOR");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "RSI period", "RSI Period", 14);	
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addDouble("OB", "OB Level", "OB Level", 70);
    indicator.parameters:addDouble("OS", "OS Level", "OS Level", 30);
	
	indicator.parameters:addBoolean("Show", "Show OB/OS Zone", "", false);
	indicator.parameters:addInteger("transp", "Zone Transparency %","", 80, 0, 100);
	
	indicator.parameters:addColor("Top", "OB Zone Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Bottom", "OS Zone Color","", core.rgb(255, 0, 0));
	
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_DOT);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("color", "Line Color","", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Show;
local first;
local source = nil;

-- Streams block
local Line = nil;

local RSI,OBV ;
local OB,OS;
local UpLow,UpHigh,DownLow,DownHigh;
local Top,Bottom;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Show = instance.parameters.Show;
	Top = instance.parameters.Top;
	Bottom = instance.parameters.Bottom;
    source = instance.source;
   
	
	OB = instance.parameters.OB;
	OS = instance.parameters.OS;
     
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	OBV = instance:addInternalStream(0, 0);
    RSI = core.indicators:create("RSI",OBV , Period); 
	first = source:first() + Period ;
	 
    Line = instance:addStream("Line", core.Line,  "Line", "Line", instance.parameters.color, first); 
	Line:setPrecision(math.max(2, instance.source:getPrecision()));
	Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
	
	Line:addLevel(0 );
 
	
	UpLow = instance:addStream("UpLow", core.Line, name .. "", "", Top, first);
    DownLow = instance:addStream("DownLow", core.Line, name .. "", "", Bottom, first);
    UpHigh = instance:addStream("UpHigh", core.Line, name .. "", "", Top, first);
    DownHigh = instance:addStream("DownHigh", core.Line, name .. "", "", Bottom, first);
	
	
	UpLow:setWidth(instance.parameters.width2);
    UpLow:setStyle(instance.parameters.style2);
	
	
	DownHigh:setWidth(instance.parameters.width2);
    DownHigh:setStyle(instance.parameters.style2);
	
	
 
 
	
	if Show then
	instance:createChannelGroup("UP", "UP", UpLow, UpHigh, Top,100 - instance.parameters.transp);
	instance:createChannelGroup("DOWN", "DOWN", DownLow, DownHigh, Bottom, 100 - instance.parameters.transp);
	end
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    
	--OBV
	
	
	  if period == source:first() then
        OBV[period] = source.volume[period];
    elseif period > source:first() then
        if source.close[period] > source.close[period - 1] then
            OBV[period] = OBV[period - 1] + source.volume[period];
        elseif source.close[period] < source.close[period - 1] then
            OBV[period] = OBV[period - 1] - source.volume[period];
        else
            OBV[period] = OBV[period - 1];
        end
    end
     
	
	if period < first then
	return;
	end
	
	
	--RSI	
    RSI:update(mode); 
    
	UpLow[period] = OB;
    DownLow[period] = 0;
    UpHigh[period] = 100;
    DownHigh[period] = OS;
	
        Line[period] = RSI.DATA[period]; 
   
end

