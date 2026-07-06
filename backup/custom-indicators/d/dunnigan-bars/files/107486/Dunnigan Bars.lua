
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63737

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
    indicator:name("Dunnigan Bars");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
  
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("IColor", "Inside Bars color", "", core.rgb(0, 255, 255));
	indicator.parameters:addColor("EColor", "Engulfing bar color", "", core.rgb(255, 0, 255));
    indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Up,Down;
local IColor,EColor;
local Neutral;
local first;
local source = nil;
 

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;
 

function Prepare(nameOnly)

    Up = instance.parameters.Up;
    Down= instance.parameters.Down;
    IColor = instance.parameters.IColor;
    EColor= instance.parameters.EColor;  
    Neutral= instance.parameters.Neutral;
 
     source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ", " .. source:barSize() 	 
	..  ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	first=source:first();

    	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
		
end

-- Indicator calculation routine
function Update(period, mode)
	
    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
			if period < first then
			open:setColor(period, Neutral);	
			return;
			end
	
 
		 
	     if source.high[period]> source.high[period-1] and source.low[period]> source.low[period-1] then
		 open:setColor(period, Up);			
		 elseif source.high[period]< source.high[period-1] and source.low[period]< source.low[period-1] then
         open:setColor(period, Down);
		 elseif source.high[period]< source.high[period-1] and source.low[period]> source.low[period-1] then
         open:setColor(period, IColor);
		 elseif source.high[period]> source.high[period-1] and source.low[period]< source.low[period-1] then
         open:setColor(period, EColor);
         else
		 open:setColor(period, Neutral);
         end		 

		
 end
 