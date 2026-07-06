-- Id: 16635

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63871

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
function Init()
    indicator:name("Ichimoku Cloud Bandwidth");
    indicator:description("Provides a bandwidth histogram between two Ichimoku Cloud lines.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
       indicator.parameters:addInteger("X", "Tenkan-sen period","", 9, 1, 10000);
    indicator.parameters:addInteger("Y", "Kijun-sen period","", 26, 1, 10000);
    indicator.parameters:addInteger("Z", "Senkou Span period","", 52, 1, 10000);
	
	indicator.parameters:addGroup("Style");	
	  indicator.parameters:addString("Style", "Line/Bar", "Bar", "Bar");
    indicator.parameters:addStringAlternative("Style", "Bar", "", "Bar");
    indicator.parameters:addStringAlternative("Style", "Line", "", "Line");   
    indicator.parameters:addColor("clrW", "Widening Band histogram color", "The color of widening histogram.", core.rgb(0, 255, 0));
	indicator.parameters:addColor("clrN", "Narrowing Band histogram color", "The color of narrowing histogram.", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 0);
    indicator.parameters:addDouble("oversold","Oversold Level","", 0);
	    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
 
local Style;
local X, Y, Z;
local first;
local source = nil;

local BAND = nil;
local ICH;
-- Routine
function Prepare(nameOnly)
   
    source = instance.source;
	X= instance.parameters.X;
	Y= instance.parameters.Y;
	Z= instance.parameters.Z;
	Style= instance.parameters.Style;
	ICH= core.indicators:create("ICH", source, X, Y, Z);
    first = source:first()+Y;

       local name = string.format("(%s, %s)", profile:id(), source:name());
    instance:name(name);
    
    if   (nameOnly) then
        return;
    end
    
    -- BAND LINE
	
	if Style =="Line" then
	  BAND = instance:addStream("Bandwidth", core.Line, name .. ".BANDWIDTH", "Bandwidth", instance.parameters.clrW, first, Y);
	  BAND:setWidth(instance.parameters.width);
      BAND:setStyle(instance.parameters.style);
	else
    BAND = instance:addStream("Bandwidth", core.Bar, name .. ".BANDWIDTH", "Bandwidth", instance.parameters.clrW, first, Y);
	end
	
	BAND:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	BAND:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  
	
	BAND:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
function Update(period,mode)

 
    ICH:update(mode);
 
    if(period<first) then
	return;
	end
	
    BAND[period+Y] = (ICH.SA[period+Y] - ICH.SB[period+Y])/source:pipSize();
	
	if BAND[period] > BAND[period-1] then
	BAND:setColor(period, instance.parameters.clrW);
	else 
	BAND:setColor(period, instance.parameters.clrN);
	end  
	
end





