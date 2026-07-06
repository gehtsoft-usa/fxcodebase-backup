-- Id: 5190
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=8966

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
    indicator:name("Advanced_ADX");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

   -- indicator.parameters:addInteger("SP", "Short Period", "Short Period", 12);
   indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("LP", " Period", " Period", 14);   
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Pozitiv", "Color of Up Trend", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Negativ", "Color of Down Trend ", "", core.rgb(255, 0, 0));
   -- indicator.parameters:addColor("Neutral", "Color of Neutral", "", core.rgb(128, 128, 128));
--	indicator.parameters:addColor("Last", "Live Candle Color", "", core.rgb(0, 0, 0));

	
	   indicator.parameters:addGroup("Levels");
    -- Overbought/oversold level
    indicator.parameters:addDouble("overbought", "Strong Trend Line", "",  25, 0, 100);
    indicator.parameters:addDouble("oversold", "Weak Trend Line", "",  20, 0, 100);
    indicator.parameters:addInteger("level_overboughtsold_width", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Style", "", core.LINE_SOLID);
	 indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("level_overboughtsold_color1", "Line Color", "", core.rgb(255, 255, 0));
	indicator.parameters:addColor("level_overboughtsold_color2", "Line Color", "", core.rgb(0, 255, 255));
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local LP;


local first;
local source = nil;

-- Streams block
local Short = nil;
local Long = nil;
local Indicator={};
local Count;
-- Routine
function Prepare(nameOnly)

    LP = instance.parameters.LP;
   
	
    source = instance.source;
   Count=0;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(LP).. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	 Indicator["ADX"] = core.indicators:create("ADX", source, LP);
	  Indicator["DMI"] = core.indicators:create("DMI", source, LP);
	  
	   first = math.max(Indicator["ADX"].DATA:first(), Indicator["DMI"].DATA:first());
	  
 
     
        Long = instance:addStream("Long", core.Bar, name .. ".Long", "Long", core.rgb(0, 0, 0), first);
		
		  Long:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color1);
           Long:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color2);
         Long:setPrecision(math.max(2, instance.source:getPrecision())); 
		 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not  source:hasData(period) then
	return;
	end
	   Indicator["ADX"]:update(mode);
		Indicator["DMI"]:update(mode);
		
      
        Long[period] = Indicator["ADX"].DATA[period];
		
		
		
		       if Indicator["ADX"].DATA[period]>instance.parameters.overbought then
								 if Indicator["DMI"].DIP[period] > Indicator["DMI"].DIM[period] then
								Long:setColor(period, instance.parameters.Pozitiv );
								else
								 Long:setColor(period, instance.parameters.Negativ );
								 end
		        elseif Indicator["ADX"].DATA[period]< instance.parameters.oversold then
				    Long:setColor(period, instance.parameters.level_overboughtsold_color2);
				else
				
			        Long:setColor(period, instance.parameters.level_overboughtsold_color1);
			    end  		 
        	    
end

