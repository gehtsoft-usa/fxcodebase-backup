
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1589

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
    indicator:name("MVA/EMA Cloud Cloud");
    indicator:description("MVA/EMA Cloud Cloud");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator.parameters:addGroup("Method One");
	indicator.parameters:addInteger("SF", "First Averege Period", "First Averege  Period", 20);
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "HMA", "HMA" , "HMA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("Method1", "VAMA", "VAMA" , "VAMA");	
	indicator.parameters:addStringAlternative("Method1", "NONLAGMA", "NONLAGMA", "NONLAGMA"); 
	indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
	
	indicator.parameters:addString("Type1", "Price Type", "", "close");
    indicator.parameters:addStringAlternative("Type1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Type1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Type1", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Type1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Type1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Type1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Type1", "WEIGHTED", "", "weighted");
	
	
	indicator.parameters:addGroup("Method Two");
	indicator.parameters:addInteger("LF", "Second Averege Period", "Second Averege Period", 100);
	indicator.parameters:addString("Method2", "MA Method", " " , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "HMA", "HMA" , "HMA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("Method2", "VAMA", "VAMA" , "VAMA");	
	indicator.parameters:addStringAlternative("Method2", "NONLAGMA", "NONLAGMA", "NONLAGMA"); 
	indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
	
	
	indicator.parameters:addString("Type2", "Price Type", "", "close");
    indicator.parameters:addStringAlternative("Type2", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Type2", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Type2", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Type2","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Type2", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Type2", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Type2", "WEIGHTED", "", "weighted");
     
	
	indicator.parameters:addGroup("Style");	
	indicator.parameters:addBoolean("Lines", "Show MA Lines", "" , false);  
	indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);
    indicator.parameters:addColor("Up", "Color of Up", "Color of Up", core.rgb( 0, 255, 0));
    indicator.parameters:addColor("Down", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
	
	
	indicator.parameters:addGroup("Non Lag MA Parameters One");   
    indicator.parameters:addInteger("Filter1", "Filter", "Filter", 0);
    indicator.parameters:addInteger("ColorBarBack1", "ColorBarBack", "ColorBarBack", 2);
    indicator.parameters:addDouble("Deviation1", "Deviation", "Deviation", 0);
	
	indicator.parameters:addGroup("Non Lag MA Parameters Two");   
    indicator.parameters:addInteger("Filter2", "Filter", "Filter", 0);
    indicator.parameters:addInteger("ColorBarBack2", "ColorBarBack", "ColorBarBack", 2);
    indicator.parameters:addDouble("Deviation2", "Deviation", "Deviation", 0);
	
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local ShortFrame=nil;
local LongFrame=nil;
local Method1=nil;
local Method2=nil;
local Lines;
local Filter1;
local ColorBarBack1;
local Deviation1;
local Filter2;
local ColorBarBack2;
local Deviation2;

local first;
local source = nil;

-- Streams block
local LongDATA = nil;
local ShortDATA = nil;

local Top=nil;
local Bottom=nil;
 

local Transparency;
local Type1;
local Type2;

local Short, Long;

-- Routine
function Prepare(nameOnly) 

    Filter1=instance.parameters.Filter1;
    ColorBarBack1=instance.parameters.ColorBarBack1;
    Deviation1=instance.parameters.Deviation1;
	
	Filter2=instance.parameters.Filter2;
    ColorBarBack2=instance.parameters.ColorBarBack2;
    Deviation2=instance.parameters.Deviation2;
	
	Type1=instance.parameters.Type1;
	Type2=instance.parameters.Type2;
    Transparency= instance.parameters.Transparency;
    
    ShortFrame = instance.parameters.SF;
    LongFrame = instance.parameters.LF;
	Method = instance.parameters.Method;
	Method1 = instance.parameters.Method1;
	Method2 = instance.parameters.Method2;
	
	Lines = instance.parameters.Lines;
	
	
	Transparency= 100-Transparency;
	
    source = instance.source;
    first = source:first();
	
	 local name = profile:id() .. "(" .. source:name() .. ", " .. ShortFrame .. ", " .. LongFrame.. ", " .. Method1.. ", ".. Method2  .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	
	if Method1 == "VAMA" then
	ShortDATA= core.indicators:create(Method1, source, ShortFrame);
	elseif   Method1 == "NONLAGMA" then
	ShortDATA= core.indicators:create(Method1, source[Type1], ShortFrame, Filter1, ColorBarBack1,Deviation1,true);
	else
	ShortDATA= core.indicators:create(Method1, source[Type1], ShortFrame);
	end
	
	if Method2 == "VAMA" then
	LongDATA= core.indicators:create(Method2, source, LongFrame);
	elseif   Method2 == "NONLAGMA" then
	LongDATA= core.indicators:create(Method2, source[Type2], LongFrame, Filter2, ColorBarBack2,Deviation2,true);
	else
	LongDATA= core.indicators:create(Method2, source[Type2], LongFrame);
	end
	
	first = math.max(ShortDATA.DATA:first(),LongDATA.DATA:first());
	
	
	assert(core.indicators:findIndicator(Method1) ~= nil, "Please, download and install "..Method1..  " indicator");
	assert(core.indicators:findIndicator(Method2) ~= nil, "Please, download and install "..Method2..  " indicator");

   
    
    
  
   Short=instance:addStream("Short", core.Line, name, "Short", core.rgb( 128, 128, 128), first);
   Long=instance:addStream("Long", core.Line, name, "Long", core.rgb( 128, 128, 128), first);
    if Lines then
	Short:setWidth(instance.parameters.width);
    Long:setStyle(instance.parameters.style);
    else
    Short:setStyle(core.LINE_NONE);
    Long:setStyle(core.LINE_NONE);
   end
  
	instance:createChannelGroup("Channel","Channel" , Short, Long, instance.parameters.Up, Transparency);
	 
	 
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    
	
	    LongDATA:update(mode);
		ShortDATA:update(mode);
		
				if period < first then
				return;
				end
					 
		Long[period]=	LongDATA.DATA[period];		 
		Short[period]=	ShortDATA.DATA[period];		
		
						if Short[period] > Long[period] then
						Short:setColor(period, instance.parameters.Up);
						Long:setColor(period, instance.parameters.Up);
						else 
						Short:setColor(period, instance.parameters.Down);
						Long:setColor(period, instance.parameters.Down);
						end
		 
   
end