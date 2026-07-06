-- Id: 14467
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62436


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
    indicator:name("Smoothed RSI");
    indicator:description("Smoothed RSI");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Source Calculation"); 
    indicator.parameters:addInteger("SourceFrame", "Period", "", 6);
 
	indicator.parameters:addString("SourceMethod", "Source MA Method", "", "EMA");
    indicator.parameters:addStringAlternative("SourceMethod", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("SourceMethod", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("SourceMethod", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("SourceMethod", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("SourceMethod", "TMA", "", "TMA"); 
	
	indicator.parameters:addGroup("RSI Calculation"); 
    indicator.parameters:addInteger("RSIFrame", "Period", "", 14);
 
	indicator.parameters:addString("RSIMethod", "RSI MA Method", "", "MVA");
    indicator.parameters:addStringAlternative("RSIMethod", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("RSIMethod", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("RSIMethod", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("RSIMethod", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("RSIMethod", "TMA", "", "TMA"); 

	
	indicator.parameters:addGroup("Line Style");	
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	
			
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 70);
    indicator.parameters:addDouble("oversold","Oversold Level","", 30);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE); 
	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local RSIFrame,RSIMethod;
local SourceMethod,SourceFrame;
local  source;
local Source;
local positive, negative;
local Positive, Negative;
local RSI;
-- Routine
function Prepare(nameOnly)
    SourceMethod = instance.parameters.SourceMethod;    
    SourceFrame = instance.parameters.SourceFrame;
    RSIMethod = instance.parameters.RSIMethod;    
    RSIFrame = instance.parameters.RSIFrame;
	
    source = instance.source;
   
   
    assert(core.indicators:findIndicator(SourceMethod) ~= nil, SourceMethod .. " indicator must be installed");
	Source= core.indicators:create(SourceMethod, source, SourceFrame);	 
    positive = instance:addInternalStream(0, 0);
	negative = instance:addInternalStream(0, 0);
    
    assert(core.indicators:findIndicator(RSIMethod) ~= nil, RSIMethod .. " indicator must be installed");
	Positive= core.indicators:create(RSIMethod, positive, RSIFrame);	 
	Negative= core.indicators:create(RSIMethod, negative, RSIFrame);	 
    local name = profile:id() .. "(" .. source:name() .. ", " .. SourceFrame .. ", " .. SourceMethod .. ", " .. RSIFrame .. ", " .. RSIMethod .. ")";
    instance:name(name);	
	
	
	if   (nameOnly) then
        return;
    end
 
		
    RSI = instance:addStream("RSI", core.Line, name .. ".RSI", "RSI", instance.parameters.color, Negative.DATA:first());
    RSI:setPrecision(math.max(2, instance.source:getPrecision()));
    RSI:setWidth(instance.parameters.width);
    RSI:setStyle(instance.parameters.style);	
	
	RSI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	RSI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    
    RSI:addLevel(0); 
    RSI:addLevel(50);   
    RSI:addLevel(100);
 
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
 
	
 
	
	Source:update(mode);	
    if period < Source.DATA:first() then
    return;
    end
	
	local diff = Source.DATA[period] - source[period] ;
	if diff > 0  then
	positive[period]=diff;
	negative[period]=0;
	else
	positive[period]=0;
	negative[period]=-diff;
	end
	 
	
	Negative:update(mode);	 
	Positive:update(mode)
	
	 if period < Negative.DATA:first()	 then
    return;
    end
		 
        if (Negative.DATA[period] == 0) then
            RSI[period] = 0;
        else
            RSI[period] = 100 - (100 / (1 + Positive.DATA[period] / Negative.DATA[period]));
        end
     
		 
end	

