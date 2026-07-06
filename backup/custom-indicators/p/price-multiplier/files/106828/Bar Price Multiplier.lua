
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63609

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
    indicator:name("Price Multiplier");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addDouble("Multiplier", "Multiplier", "", 1 );
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.COLOR_UPCANDLE );
	indicator.parameters:addColor("Down", "Down color", "", core.COLOR_DOWNCANDLE );
	 
	
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Up,Down;
local first;
local source = nil;

local Multiplier;

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;
 


function Prepare(nameOnly) 

    Up = instance.parameters.Up;
    Down= instance.parameters.Down;
     
   
    
	Multiplier = instance.parameters.Multiplier;
 
	source = instance.source;
	first=source:first(); 
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. source:barSize()..", ".. Multiplier 
	..  ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	 

    	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
		
end

-- Indicator calculation routine
function Update(period, mode)
	
    open[period] = source.open[period]*Multiplier;
	close[period] = source.close[period]*Multiplier;
	high[period] = source.high[period]*Multiplier;
	low[period] = source.low[period]*Multiplier;
	
		 
        if close[period]> open[period] then
		open:setColor(period, Up);
        else
		open:setColor(period, Down);
        end
 		
		 
		
		
				

		
 end


