-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1256
-- Id:  
--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+
-- I have simplified this indicator a bit
--Indicator does not calculate the value of HA for each period alone.
--Values are calculated by External function
--Standard Heiken Ashi Indicator 

function Init()
    indicator:name("Price Trend Line");
    indicator:description("Price Trend Line");
	--Sets the type of the required source of the indicator Bar or Tick 
    indicator:requiredSource(core.Bar);
	--Sets the type - Indicator or Oscillator. 
    indicator:type(core.Indicator);
	indicator.parameters:addColor("Up", "Up Color", "Color", core.rgb(0, 255 , 0));
	indicator.parameters:addColor("Dn", "Down Color", "Color", core.rgb(255,0 , 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

--definition of variables
local source = nil;
local LINE=nil;
 
local Up, Dn;
local first = 0;

-- Routine
function Prepare(nameOnly)
    source = instance.source;
   
	
	Up = instance.parameters.Up;
	Dn = instance.parameters.Dn;
	
    local name = "Heiken Ashi Trend Line" .. "(" .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
  	
	--Creates an instance of the indicator
	--Calls Heiken Ashi indicator
	--Heiken Ashi indicator return indicator stream.
	 
	first = source:first() + 1;
	--Adds a stream to the indicator output
	LINE = instance:addStream("Line", core.Line, name, "close", Up, first)
	LINE:setWidth(instance.parameters.width);
    LINE:setStyle(instance.parameters.style);
	
end

-- Indicator calculation routine
function Update(period, mode)


   		 
    if period < first or not  source:hasData(period) then
	return;
	end
	
				
			 
				if source.open[period]< source.close[period] then 
				 
					 LINE[period]=source.high[period];		
					LINE:setColor(period, Dn); 
				  else				
				 
					LINE[period]=source.low[period];
					LINE:setColor(period, Up);  
				 end
				  
                				 
	  
end



