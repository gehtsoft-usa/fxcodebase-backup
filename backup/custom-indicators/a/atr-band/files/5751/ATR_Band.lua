-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2575

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
    indicator:name("Custom ATR Band");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Price Type");
	indicator.parameters:addString("Price", "Price", "", "close");
    indicator.parameters:addStringAlternative("Price", "Open", "", "open");
    indicator.parameters:addStringAlternative("Price", "High", "", "high");
    indicator.parameters:addStringAlternative("Price", "Low", "", "low");
    indicator.parameters:addStringAlternative("Price", "Close/Tick", "", "close");
    indicator.parameters:addStringAlternative("Price", "Median", "", "median");
    indicator.parameters:addStringAlternative("Price", "Typical", "", "typical");
    indicator.parameters:addStringAlternative("Price", "Weighted", "", "weighted");
	
	indicator.parameters:addGroup("MA Type");
	indicator.parameters:addString("Method", "Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "HMA", "HMA" , "HMA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
  
    indicator.parameters:addGroup("Parameters");
    indicator.parameters:addInteger("MAFrame", "MA Period", "No description", 14);
    indicator.parameters:addInteger("ATRFrame", "ATR period", "No description", 14);
    indicator.parameters:addDouble("WIDTH", "Band Width", "No description", 0.5);
	
	indicator.parameters:addBoolean("SHOW", "Show central line", "", false);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up_color", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("Upwidth", "Up Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("Upstyle", "Up Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Upstyle", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("Down_color", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Downwidth", "Down Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("Downstyle", "Down Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Downstyle", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("Central_color", "Color of Central", "Color of Central", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Centralwidth", "Central Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("Centralstyle", "Central Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Centralstyle", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local MAFrame;
local ATRFrame;
local WIDTH;
local SHOW;
local Method;

local first;
local source = nil;

-- Streams block
local Up = nil;
local Down = nil;
local Central = nil;

local ATR;
local MA;
local Price;

-- Routine
 function Prepare(nameOnly) 
    Method = instance.parameters.Method;
    Price = instance.parameters.Price;
    SHOW = instance.parameters.SHOW;
    MAFrame = instance.parameters.MAFrame;
    ATRFrame = instance.parameters.ATRFrame;
    WIDTH = instance.parameters.WIDTH;
    source = instance.source;
   
	 
    local name = profile:id() .. "(" .. source:name() .. ", " .. MAFrame .. ", " .. ATRFrame .. ", " .. WIDTH ..", ".. Price ..", "..Method.. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
		assert(core.indicators:findIndicator(Method) ~= nil, "Please download and install"..  Method .." indicator!");
	
 
	
	ATR = core.indicators:create("ATR", source, ATRFrame);
	MA = core.indicators:create(Method, source[Price], MAFrame);
	
	 first = math.max(ATR.DATA:first(),MA.DATA:first() );
	 
	
    Up = instance:addStream("Up", core.Line, name .. ".Up", "Up", instance.parameters.Up_color, first);
	Up:setWidth(instance.parameters.Upwidth);
    Up:setStyle(instance.parameters.Upstyle);
    Down = instance:addStream("Down", core.Line, name .. ".Down", "Down", instance.parameters.Down_color, first);
	Down:setWidth(instance.parameters.Downwidth);
    Down:setStyle(instance.parameters.Downstyle);
	if SHOW then
    Central = instance:addStream("Central", core.Line, name .. ".Central", "Central", instance.parameters.Central_color, first);
	Central:setWidth(instance.parameters.Centralwidth);
    Central:setStyle(instance.parameters.Centralstyle);
	end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    if period >= first and source:hasData(period) then
	   
	    ATR:update(mode);
		MA:update(mode);		 
	    
        Up[period] = MA.DATA[period]+ATR.DATA[period]*WIDTH;		
        Down[period] = MA.DATA[period] -ATR.DATA[period]*WIDTH;
		
		if SHOW then
        Central[period] = MA.DATA[period];
		end
     end
end

