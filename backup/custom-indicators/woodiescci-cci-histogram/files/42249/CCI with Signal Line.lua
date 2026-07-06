-- Id: 7710

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=8964

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
    indicator:name("CCI with Signal Line");
    indicator:description("CCI with Signal Line");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

 
     indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("CP", "CCI Period", "", 50);
	
    indicator.parameters:addInteger("MP", "Signal Period", "", 14);
	  indicator.parameters:addString("Method", "Signal MA Method", "Method" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 100);
    indicator.parameters:addDouble("oversold","Oversold Level","", -100);
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);

	
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Pozitiv", "Color of Pozitiv", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Negativ", "Color of Negativ", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Neutral", "Color of Neutral", "", core.rgb(128, 128, 128));
	 indicator.parameters:addColor("Signal", "Color of Signal", "", core.rgb(0,0 ,255));
 
 
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local CP;
local MP;
local Method;

local first;
local source = nil;

-- Streams block
local MA
local CCI;
local Signal;
local Histogram;
local Zero;
-- Routine
function Prepare(nameOnly)
    
    CP = instance.parameters.CP;
	MP = instance.parameters.MP;
	Method= instance.parameters.Method;
	
    source = instance.source;
   

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(CP) .. ", " .. tostring(Method) .. ", " .. tostring(MP).. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	 CCI = core.indicators:create("CCI", source, CP);
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	 MA = core.indicators:create(Method, CCI.DATA, MP);
	 
	    first =  MA.DATA:first();

  
      
            Out = instance:addStream("CCI", core.Bar, name .. ".CCI", "CCI", instance.parameters.Neutral, first);	
			Out:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		    Out:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
            Out:addLevel(0, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 			
			Signal = instance:addStream("SIGNAL", core.Line, name .. ".SIGNAL", "SIGNAL", instance.parameters.Signal, first);
            	
            Out:setPrecision(math.max(2, instance.source:getPrecision()));
			Signal:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not  source:hasData(period) then
	return;
	end
	 
		CCI:update(mode);
		MA:update(mode);
		
      
        Out[period] = CCI.DATA[period];
		Signal[period] = MA.DATA[period];
		 
		
	
				 if Out[period] > MA.DATA[period] then
				 Out:setColor(period, instance.parameters.Pozitiv );
				elseif  Out[period] <  MA.DATA[period] then
				 Out:setColor(period, instance.parameters.Negativ );
				 end
        	    
end

