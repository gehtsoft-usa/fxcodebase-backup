-- Id: 14211
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62242


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
    indicator:name("Tick Volume Percentage Change");
    indicator:description("Tick Volume Percentage Change");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addString("Method", "Method", "Method" , "Pre-Smoothed");
    indicator.parameters:addStringAlternative("Method", "Pre-Smoothed", "Pre-Smoothed" , "Pre-Smoothed");
    indicator.parameters:addStringAlternative("Method", "Raw", "Raw" , "Raw");
	
	indicator.parameters:addInteger("Period", "MA Period", "Period" , "14");
	indicator.parameters:addString("MA_Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("MA_Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("MA_Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("MA_Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("MA_Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("MA_Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("MA_Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addString("Presentation_Method", "Presentation Method", "Presentation Method" , "Normalized");
    indicator.parameters:addStringAlternative("Presentation_Method", "Raw", "Raw" , "Raw");
	indicator.parameters:addStringAlternative("Presentation_Method", "Normalized", "Raw" , "Normalized");
	 
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Up", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Up, Down;
local Method;
-- Streams block
local TVPC = nil;
local Period;
local MA_Method;
local MA;
local Presentation_Method;
-- Routine
 function Prepare(nameOnly) 
    source = instance.source;
	
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Method=instance.parameters.Method;
	Period=instance.parameters.Period;
	MA_Method=instance.parameters.MA_Method;
	Presentation_Method=instance.parameters.Presentation_Method;
	
	local name = profile:id() .. "(" .. source:name() .. ", "  .. Method.. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	if Method == "Raw" then
    first = source:first();
	else
    assert(core.indicators:findIndicator(MA_Method) ~= nil, MA_Method .. " indicator must be installed");
	MA = core.indicators:create(MA_Method, source.volume, Period);
	first = MA.DATA:first();
	end 

    if (not (nameOnly)) then
        TVPC = instance:addStream("TVPC", core.Bar, name, "TVPC", Down, first);
    TVPC:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)


    if period < first or not source:hasData(period) then
	return;
	end
	
	if Presentation_Method == "Normalized" then
	
	    if Method == "Raw" then
        TVPC[period] = ( source.volume[period]/(source.volume[period-1]/100) -100) ;
		elseif Method == "Pre-Smoothed" then
		MA:update(mode);
		 TVPC[period] = ( MA.DATA[period]/(MA.DATA[period-1]/100) -100) ;
		end
		
		
    else
	    
		if Method == "Raw" then
        TVPC[period] = ( source.volume[period]/(source.volume[period-1]/100) ) ;
		elseif Method == "Pre-Smoothed" then
		MA:update(mode);
		 TVPC[period] = ( MA.DATA[period]/(MA.DATA[period-1]/100) ) ;
		end
		
		 
	end
	
	
	   if TVPC[period] > TVPC[period-1] then
		TVPC:setColor(period, Up);
		else
		TVPC:setColor(period, Down);
		end
end

