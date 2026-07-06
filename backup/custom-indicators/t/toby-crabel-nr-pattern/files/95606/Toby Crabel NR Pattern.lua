-- Id: 12372
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61080

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+


function Init()
    indicator:name("Toby Crabel NR Pattern");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
   
    indicator.parameters:addGroup("Parameters");
	
	
	indicator.parameters:addString("Method", "Method", "Method" , "2NR");
    indicator.parameters:addStringAlternative("Method", "2NR", "2NR" , "2NR");
    indicator.parameters:addStringAlternative("Method", "3NR", "3NR" , "3NR");
    indicator.parameters:addStringAlternative("Method", "4NR", "4NR" , "4NR");
	indicator.parameters:addStringAlternative("Method", "8NR", "8NR" , "8NR");
	indicator.parameters:addStringAlternative("Method", "Customizable", "Customizable" , "Customizable");
	indicator.parameters:addBoolean("Previous", "Exclude the current period", "", true);
	
	indicator.parameters:addInteger("Sample", "Sample Period", "", 2, 0, 1000);
	indicator.parameters:addInteger("Period", "Range Period", "", 20, 0, 1000);
	
	indicator.parameters:addGroup("Show Patern");
	indicator.parameters:addBoolean("On1", "Show Wide Range Bar", "", false);
	indicator.parameters:addBoolean("On2", "Show Narrow Range Bar", "", true);

   
    indicator.parameters:addGroup("Style");
    indicator.parameters:addInteger("FontSize", "Font Size", "", 12, 4, 20);
    indicator.parameters:addColor("WColor", "Color for pattern labels", "", core.rgb(0,255,0));
	indicator.parameters:addColor("NColor", "Color for pattern labels", "", core.rgb(255,0,0));
end

local source;


local Period,Sample ;
local ON={};
local Raw;
local Wide,Narrow;
local first;
local Method;
local Previous;
function Prepare(nameOnly)
 
	Previous  = instance.parameters.Previous;
  	Period  = instance.parameters.Period;
	Sample  = instance.parameters.Sample;
	Method  = instance.parameters.Method;
	
	source = instance.source; 
	first=source:first();
	
	ON[1]  = instance.parameters.On1;
	ON[2]  = instance.parameters.On2;
      
	
	if Method == "2NR" then
	Sample  = 2;
	Period  = 20;
	elseif Method == "3NR" then
	Sample  = 3;
	Period  = 20;
	elseif Method == "4NR" then
	Sample  = 4;
	Period  = 40;
	elseif Method == "8NR" then
	Sample  = 8;
	Period  = 40;
	end

	
    local name;
    name = profile:id().. ", " .. Method .. ", " .. Sample.. ", " .. Period;
	instance:name(name);
	if nameOnly then
		return;
	end
	
	 Raw = instance:addInternalStream(0, 0);

   if ON[1] then 
   Wide = instance:createTextOutput("WideRange", "WideRange", "Wingdings", instance.parameters.FontSize, core.H_Center, core.V_Top, instance.parameters.WColor, 0);
   end
   if ON[2] then 
   Narrow = instance:createTextOutput("NarrowRange", "NarrowRange", "Wingdings", instance.parameters.FontSize, core.H_Center, core.V_Top, instance.parameters.NColor, 0);
   end 
end


function Update(period)
  

	
	if Previous then
	period=period-1;
	end
	
		
    if period<first+Sample then
	return;
	end
	
	min, max = mathex.minmax(source, period-Sample , period );		
	 
	 Raw[period]= max-min;
	 
	
		
			if period <  first +Sample+Period then	
            return;
            end			
			   
						 
				if ON[1] then  
						 if core.max(Raw, core.range(period-Period,period )) == Raw[period] then
						 Wide:set(period, source.high[period],  "\108","Wide");
						 else
						 Wide:setNoData (period);
						 end
				end		 
				if ON[2] then  		 
						 if core.min(Raw, core.range(period-Period,period )) == Raw[period] then
						 Narrow:set(period, source.high[period],  "\108","Narrow");
						 else 
						 Narrow:setNoData (period);
						 end
				 end
		   
  
end
