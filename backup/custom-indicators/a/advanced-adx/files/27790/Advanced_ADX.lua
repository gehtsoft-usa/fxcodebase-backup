-- Id: 6010
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
	indicator.parameters:addColor("PozitivUp", "Color of Pozitiv Up Trend", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("PozitivDn", "Color of Negativ Up Trend", "", core.rgb(0, 200, 0));
    indicator.parameters:addColor("NegativDn", "Color of Negativ Down Trend ", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("NegativUp", "Color of Pozitiv Down Trend ", "", core.rgb(200, 0, 0));

	
	   indicator.parameters:addGroup("Levels");
    -- Overbought/oversold level
    indicator.parameters:addDouble("overbought", "Strong Trend Line", "",  25, 0, 100);
    indicator.parameters:addDouble("oversold", "Weak Trend Line", "",  20, 0, 100);
    indicator.parameters:addInteger("level_overboughtsold_width", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Style", "", core.LINE_SOLID);
	 indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("level_overboughtsold_color", "Line COlor", "", core.rgb(255, 255, 0));
   
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
	  

 
     
        Long = instance:addStream("Long", core.Bar, name .. ".Long", "Long",  instance.parameters.PozitivUp, first);
		
		  Long:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
           Long:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
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
		
		
		
		
				 if Indicator["DMI"].DIP[period] > Indicator["DMI"].DIM[period] then
						if  Long[period] > Long[period-1] then
						Long:setColor(period, instance.parameters.PozitivUp );
						Long:setColor(period, instance.parameters.PozitivDn );
						end
				else
						 if Long[period] > Long[period-1] then
						 Long:setColor(period, instance.parameters.NegativUp );
						 Long:setColor(period, instance.parameters.NegativDn );
						 end
				 end
        	    
end

