-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=226

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




-- The indicator corresponds to the Bollinger Bands indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 5 "Trend System" (page 91-94)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Bollinger Band - Bandwidth Oscillator");
    indicator:description("Provides a bandwidth histogram between two Bollinger Bands.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addInteger("N", "Number of periods", "Number of periods", 20);
	 indicator.parameters:addDouble("Dev", "Number of standard deviations", "Number of standard deviations", 2);
	
	indicator.parameters:addGroup("Style");	
	  indicator.parameters:addString("Style", "Line/Bar", "Bar", "Bar");
    indicator.parameters:addStringAlternative("Style", "Bar", "", "Bar");
    indicator.parameters:addStringAlternative("Style", "Line", "", "Line");   
    indicator.parameters:addColor("clrWBBB", "Widening Band histogram color", "The color of widening histogram.", core.rgb(0, 255, 0));
	indicator.parameters:addColor("clrNBBB", "Narrowing Band histogram color", "The color of narrowing histogram.", core.rgb(255, 0, 0));
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
-- Parameters block
local N;
local D;

local Style;

local firstPeriod;
local source = nil;

-- Streams block
local TL = nil;
local AL = nil;
local BL = nil;

local BAND = nil;

-- Routine
function Prepare(nameOnly)
    N = instance.parameters.N;
    D = instance.parameters.Dev;
    source = instance.source;
	
	Style= instance.parameters.Style;
	
    firstPeriod = source:first() + N - 1;

    local name = "Bollinger Bands - Bandwidth Oscillator";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
    
    -- TOP LINE AND BOTTOM LINE INTERNAL STREAMS
    TL = instance:addInternalStream(firstPeriod)
    BL = instance:addInternalStream(firstPeriod)
    AL = instance:addInternalStream(firstPeriod)
    
    -- BAND LINE
	
	if Style =="Line" then
	  BAND = instance:addStream("Bandwidth", core.Line, name .. ".BANDWIDTH", "BBBandwidth", instance.parameters.clrWBBB, firstPeriod);
	  BAND:setWidth(instance.parameters.width);
      BAND:setStyle(instance.parameters.style);
	else
    BAND = instance:addStream("Bandwidth", core.Bar, name .. ".BANDWIDTH", "BBBandwidth", instance.parameters.clrWBBB, firstPeriod);
	end
	
	BAND:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	BAND:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  
end

-- Indicator calculation routine
function Update(period)

    -- CALCULATE "Bollinger Bands" INTERNAL STREAMS 
    if(period<firstPeriod) then
	return;
	end
       
        local ml = mathex.avg(source, period-N+1, period);
        local d = mathex.stdev(source,  period-N+1, period);

        TL[period] = ml + D * d;
        BL[period] = ml - D * d;
        AL[period] = ml;
   
        
    -- CALCULATE "Bandwidth" LINE    
    	BAND[period] = ((TL[period] - BL[period]) / AL[period])
   
	
	if BAND[period] > BAND[period-1] then
	BAND:setColor(period, instance.parameters.clrWBBB);
	else 
	BAND:setColor(period, instance.parameters.clrNBBB);
	end  
	
end





