
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2583

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
    indicator:name("Avereges Price Overlay");
    indicator:description("Avereges Price Overlay");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	           
            indicator.parameters:addGroup("Calculation");
  	        indicator.parameters:addInteger("Period", "Period", "", 20); 
			
			indicator.parameters:addString("TYPE", "Overlay Type", "", "BOTH");
			indicator.parameters:addStringAlternative("TYPE", "BOTH", "", "BOTH");
			indicator.parameters:addStringAlternative("TYPE", "Price / MA", "", "PRICE");
			indicator.parameters:addStringAlternative("TYPE", "MA", "", "MA");
			
			indicator.parameters:addString("Method", "Method", "", "MVA");
			indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
			indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
			indicator.parameters:addStringAlternative("Method", "Wilder", "", "Wilder");
			indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
			indicator.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA");
			indicator.parameters:addStringAlternative("Method", "TriMA", "", "TriMA");
			indicator.parameters:addStringAlternative("Method", "LSMA", "", "LSMA");
			indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");
			indicator.parameters:addStringAlternative("Method", "HMA", "", "HMA");
			indicator.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA");
			indicator.parameters:addStringAlternative("Method", "DEMA", "", "DEMA");
			indicator.parameters:addStringAlternative("Method", "T3", "", "T3");
			indicator.parameters:addStringAlternative("Method", "ITrend", "", "ITrend");
			indicator.parameters:addStringAlternative("Method", "Median", "", "Median");
			indicator.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean");
			indicator.parameters:addStringAlternative("Method", "REMA", "", "REMA");
			indicator.parameters:addStringAlternative("Method", "ILRS", "", "ILRS");
			indicator.parameters:addStringAlternative("Method", "IE/2", "", "IE/2");
			indicator.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen");
			indicator.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth");
			
			indicator.parameters:addString("Price", "Price", "", "close");
			indicator.parameters:addStringAlternative("Price", "Open", "", "open");
			indicator.parameters:addStringAlternative("Price", "High", "", "high");
			indicator.parameters:addStringAlternative("Price", "Low", "", "low");
			indicator.parameters:addStringAlternative("Price", "Close/Tick", "", "close");
			indicator.parameters:addStringAlternative("Price", "Median", "", "median");
			indicator.parameters:addStringAlternative("Price", "Typical", "", "typical");
			indicator.parameters:addStringAlternative("Price", "Weighted", "", "weighted");
			
		   indicator.parameters:addGroup("Style");
		   indicator.parameters:addColor("Up", "Up Color", "", core.rgb(255, 0, 0));
            indicator.parameters:addColor("Down", "Down Color", "", core.rgb(0, 255, 0));
             indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

local Frame;
local INDICATOR = nil;
local Method;
local Price;
local TYPE;
local isource;
local Up,Down, Neutral;
function Prepare(nameOnly)
    Frame = instance.parameters.Period;
	Method= instance.parameters.Method;
	Price= instance.parameters.Price;
	TYPE= instance.parameters.TYPE;
	
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	Neutral= instance.parameters.Neutral;
		
	source = instance.source;
	
    
	if Price == "open" then
        isource = source.open;
    elseif Price == "high" then
        isource = source.high;
    elseif Price == "low" then
        isource = source.low;
    elseif Price == "close" then
        isource = source.close;
    elseif Price == "median" then
        isource = source.median;
    elseif Price == "typical" then
        isource = source.typical;
    elseif Price == "weighted" then
        isource = source.weighted;
    else
        isource = source.close;
    end
      
    local name = profile:id() .. "(" .. source:name() ..", ".. Frame..", ".. Method .. "," .. Price.. ", " .. TYPE.. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");
                                     
    INDICATOR = core.indicators:create("AVERAGES", isource, Method ,  Frame, false);
	first= INDICATOR.DATA:first();
	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("TREND", "TREND", open, high, low, close);
	
 
		
end

-- Indicator calculation routine
function Update(period, mode)
    
	    open:setColor(period, Neutral);
		
		if period < first then
		return;
		end
		
		 
		
			                open[period]=source.open[period];
							close[period]= source.close[period];
							high[period]=source.high[period];
							low[period]=source.low[period];	
		
		   INDICATOR:update(mode);
		   
				if TYPE == "MA" then	
						
							if INDICATOR.DATA[period] > INDICATOR.DATA[period-1] then 	
							open:setColor(period, Up);
							else
						    open:setColor(period, Down);
							end
							
						
				elseif TYPE == "PRICE" then	
				      
							if  isource[period] > INDICATOR.DATA[period] then 	
						    open:setColor(period, Up);
							else
						    open:setColor(period, Down);
							end
						  
				elseif TYPE == "BOTH" then			
				        
							if  isource[period] > INDICATOR.DATA[period] and INDICATOR.DATA[period] > INDICATOR.DATA[period-1]  then 	
							open:setColor(period, Up);
							elseif isource[period] < INDICATOR.DATA[period] and INDICATOR.DATA[period] < INDICATOR.DATA[period-1] then							
						    open:setColor(period, Down);
							end
							
					  
                end				
	 	
end				