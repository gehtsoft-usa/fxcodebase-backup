-- Id: 7617

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1855

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
    indicator:name("DSS with Averages");
    indicator:description("DSS with Averages");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Frame", "Stochastic Period", "Stochastic Period", 13);	
	
	
    indicator.parameters:addInteger("EMAFrame1", "1. Smooth Period", "Smooth Period", 8);
	indicator.parameters:addString("Method1", "1. Smooth  MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	 indicator.parameters:addInteger("EMAFrame2", "2. Smooth Period", "Smooth Period", 8);
	indicator.parameters:addString("Method2", "2. Smooth  MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
		
	indicator.parameters:addInteger("SignalFrame", "Signal Period", "Signal Period", 8);	
	indicator.parameters:addString("Method", "Signal MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	
	 indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Stochastic_color", "Color of Stochastic", "Color of Stochastic", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("Signal_color", "Color of Signal", "Color of Signal", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addInteger("overbought", "Overbought Level","", 80);
    indicator.parameters:addInteger("oversold","Oversold Level","", 20);
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addGroup("OB/OS Zone");	
	indicator.parameters:addBoolean("Show" , "Show Overlay", "", true);	
	indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 75, 0, 100);
	indicator.parameters:addColor("OBColor", "Overbought Zone Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("OSColor", "Oversold Zone Color","", core.rgb(0, 255, 0));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Frame;
local EMAFrame1, EMAFrame2;
local SignalFrame;
local Method,Method1, Method2;
local first;
local source = nil;

-- Streams block
local DSS= nil;
local EMA = nil;

local HIGH=nil;
local LOW=nil;

local DELTA=nil;
local MIT=nil;


local Buffer=nil;
local Signal=nil;
local MIT1, MIT2;
local MA1, MA2;

local transparency; 
local OBColor, OSColor;
local Show;

-- Routine
function Prepare(nameOnly) 
    Frame = instance.parameters.Frame;
    EMAFrame1 = instance.parameters.EMAFrame1;
	EMAFrame2 = instance.parameters.EMAFrame2;
	SignalFrame = instance.parameters.SignalFrame;
    source = instance.source;
    first = source:first()+Frame;
	Method = instance.parameters.Method;
	Method1 = instance.parameters.Method1;
	Method2 = instance.parameters.Method2;
	
	Show = instance.parameters.Show; 
	OBColor = instance.parameters.OBColor;
	OSColor = instance.parameters.OSColor;
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. Frame .. ", " .. EMAFrame1 ..", ".. Method1 .. ", " .. EMAFrame2 ..", ".. Method2..", ".. SignalFrame..", ".. Method.. ")";
    instance:name(name);
	
	 if   (nameOnly) then
        return;
    end
   	
	Buffer=instance:addInternalStream(0, 0);
		
	 
	MIT1=instance:addInternalStream(0, 0);
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
    MA1 = core.indicators:create(Method1, MIT1, EMAFrame1);
	MIT2=instance:addInternalStream(0, 0);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
	MA2 = core.indicators:create(Method2, MIT2, EMAFrame2); 
	
	
	
	DSS = instance:addStream("DSS", core.Line, name .. ".DSS", "DSS", instance.parameters.Stochastic_color,  MA2.DATA:first());	
	if not Show then
    DSS:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    DSS:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	end
	
	 DSS:setWidth(instance.parameters.width);
     DSS:setStyle(instance.parameters.style);
	 
	 
	 
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	 EMA = core.indicators:create(Method, DSS, SignalFrame);
	
    Signal = instance:addStream("SIGNAL", core.Line, name .. ".Signal", "Signal", instance.parameters.Signal_color, EMA.DATA:first());
	Signal:setWidth(instance.parameters.width1);
    Signal:setStyle(instance.parameters.style1);
	
	DSS:setPrecision(math.max(2, instance.source:getPrecision()));
	Signal:setPrecision(math.max(2, instance.source:getPrecision()));

	instance:ownerDrawn(Show);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
	
    if period < first or not source:hasData(period) then
	return;
	end
	
	
	
	
			HIGH = mathex.max(source.high, period-Frame+1, period );
			LOW = mathex.min(source.low,  period-Frame+1, period );
			DELTA = source.close[period] - LOW;			
		
			MIT1[period] = DELTA/(HIGH - LOW)*100.0;
			
			MA1:update(mode);
			
			
			if period < MA1.DATA:first()  then
			return;
			end
			
			Buffer[period]=  MA1.DATA[period];
			
			if period < MA1.DATA:first() + Frame   then
			return;
			end
			
					LOW, HIGH = mathex.minmax(Buffer ,  period-Frame+1, period );
					 
					DELTA= Buffer[period] -LOW; 
					MIT2[period] = DELTA/(HIGH - LOW)*100.0;
					
					MA2:update(mode);
					
			if period < MA2.DATA:first()   then
			return;
			end							
							
         
					DSS[period]=  MA2.DATA[period];
			
            		
					
									
							EMA:update(mode);
							
			 if period <EMA.DATA:first()   then
			return;
			end						
							Signal[period] = EMA.DATA[period];
							
end
	


local init = false;
 
function Draw(stage, context)
    if stage ~= 0 then
	return;
	end 
	
	Height= context:bottom()-context:top();
	
        if not init then
            context:createSolidBrush(1, OBColor);
			context:createSolidBrush(2, OSColor);			 
            transparency =context:convertTransparency ( instance.parameters.transparency ) 

            init = true;
        end
		
		visible, y1 = context:pointOfPrice (instance.parameters.overbought);
		visible, y2 =  context:pointOfPrice (instance.parameters.oversold);

	context:drawRectangle (-1, 1, context:left (), context:top (), context:right (), y1, transparency);
	context:drawRectangle (-1, 2, context:left (),  y2,context:right (), context:bottom (), transparency);
	
end		


