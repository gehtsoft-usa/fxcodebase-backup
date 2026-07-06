-- Id: 9800

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
    indicator:name("WoodiesCCI");
    indicator:description("WoodiesCCI");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);


   indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("LP", " Period", " Period", 50);
    indicator.parameters:addInteger("NP", "Neutral Period", "Neutral Period", 5, 1 , 1000);
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Pozitiv", "Color of Pozitiv", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Negativ", "Color of Negativ", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Neutral", "Color of Neutral", "", core.rgb(128, 128, 128));


	
	   indicator.parameters:addGroup("Levels");
    -- Overbought/oversold level
    indicator.parameters:addDouble("overbought", "Overbought Level", "", 100, -1000, 1000);
    indicator.parameters:addDouble("oversold", "Oversold Level", "",  -100, -1000, 1000);
    indicator.parameters:addInteger("level_overboughtsold_width", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Style", "", core.LINE_SOLID);
	 indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("level_overboughtsold_color", "Line COlor", "", core.rgb(255, 255, 0));
	
	  indicator.parameters:addDouble("overbought2", "Overbought Level", "", 200, -1000, 1000);
    indicator.parameters:addDouble("oversold2", "Oversold Level", "",  -200, -1000, 1000);
    indicator.parameters:addInteger("level_overboughtsold_width2", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style2", "Style", "", core.LINE_SOLID);
	 indicator.parameters:setFlag("level_overboughtsold_style2", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("level_overboughtsold_color2", "Line COlor", "", core.rgb(255, 255, 0));
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local LP;
local NP;

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
    NP = instance.parameters.NP;
	
    source = instance.source;
   Count=0;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(LP) .. ", " .. tostring(NP) .. ")";
    instance:name(name);
	
	 Indicator["Long"] = core.indicators:create("CCI", source, LP);

	    first =  Indicator["Long"].DATA:first();

   if   (nameOnly) then
        return;
    end
      
        Long = instance:addStream("Long", core.Bar, name .. ".Long", "Long", instance.parameters.Neutral, first);
		
		  Long:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
           Long:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		   
		   Long:addLevel(instance.parameters.overbought2, instance.parameters.level_overboughtsold_style2, instance.parameters.level_overboughtsold_width2, instance.parameters.level_overboughtsold_color2);
           Long:addLevel(instance.parameters.oversold2, instance.parameters.level_overboughtsold_style2, instance.parameters.level_overboughtsold_width2, instance.parameters.level_overboughtsold_color2);
		   
		   Long:setPrecision(math.max(2, instance.source:getPrecision()));
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not  source:hasData(period) then
	return;
	end
	 
		Indicator["Long"]:update(mode);		
     
        Long[period] = Indicator["Long"].DATA[period];
	
		
		if   TEST(true, period)  then
		 	Long:setColor(period, instance.parameters.Pozitiv );
		elseif   TEST(false, period)  then
		     Long:setColor(period, instance.parameters.Negativ ); 
		else 
		    
				  Long:setColor(period, instance.parameters.Neutral );
					
        end  	    
end


function TEST (Flag, period)

local FLAG = true;

  if NP <= 0 then
  FLAG = false;
  end


local i;

	
	
	
		if Flag then	
		
		    for i = period, period- NP, -1 do
			    if Long[i] < 0 then
				    FLAG = false;
				end				
			end
			
		
		else
		      for i = period, period- NP, -1 do
			    if Long[i] > 0 then
				    FLAG = false;
				end
				
			  end
			
		end
		
		
		
		     		       return FLAG;
		
end

