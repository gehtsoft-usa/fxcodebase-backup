-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=37403


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
    indicator:name("Accumulation/Distribution Price Overlay");
    indicator:description("Measures supply and demand by determining whether investors are generally accumulating (buying) or distributing (selling) a certain instrument by identifying divergences between the instrument price and volume flow.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Method", "Method","", "CI");
    indicator.parameters:addStringAlternative("Method", "Classic","", "CS");
    indicator.parameters:addStringAlternative("Method", "Classic Incremental","", "CI");
    indicator.parameters:addStringAlternative("Method", "Trade Station","", "", "TS");
   indicator.parameters:addInteger("Period", "Normalization Period", "Period", 50);
    indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Color", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
 
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Period;
-- Streams block
local AD, ad;
local Method;
 

-- Routine
function Prepare(nameOnly) 
    Method=instance.parameters.Method; 
    Period=instance.parameters.Period;	
    source = instance.source;
    ad = core.indicators:create("AD", source, Method);
     first = ad.DATA:first()+Period+1;
 
   local Label="";
   
   if Method == "CS" then
   Label="Classic";
   elseif Method == "CI" then
   Label="Classic Incremental";
   else
   Label="Trade Station";
   end
  
	 local name = profile:id() .. "(" .. source:name()  .. ", " .. Label .. ")";
    instance:name(name);

  if   (nameOnly) then
        return;
    end
         
		
		AD = instance:addStream("AD", core.Line, name, "", instance.parameters.Color, first);
		AD:setWidth(instance.parameters.width);
        AD:setStyle(instance.parameters.style);
	 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

     
	
	ad:update(mode);
	 
	
	
    if period < first   then
	return;
	end
	
	    

	  
        local min1, max1;
		local min2, max2;
		min1,max1=mathex.minmax(source.close,period-Period+1, period);
		min2,max2=mathex.minmax(ad.DATA,period-Period+1, period);
		AD[period] = ((ad.DATA[period] - min2)/ (max2-min2))*(max1-min1) +min1
	 
end

