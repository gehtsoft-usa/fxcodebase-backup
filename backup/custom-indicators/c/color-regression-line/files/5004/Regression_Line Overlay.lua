-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=28&t=61403

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Regression_Line Overlay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("Calculation");
	 indicator.parameters:addInteger("Period", "Short EMA", "", 14, 2, 1000);
 
	
	 
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up Trend Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("UpDown", "Up Trend Down color", "", core.rgb(0, 200, 0));
	indicator.parameters:addColor("DownUp", "Down Trend Up color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Down", "Down Trend Down color", "", core.rgb(200, 0, 0));
	indicator.parameters:addColor("NeutralUp", "Neutral Trend Up color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("NeutralDown", "Neutral Trend Down color", "", core.rgb(0, 0, 100));
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Up,Down, NeutralUp;
local UpDown,DownUp, NeutralDown;
local first;
local source = nil;
 

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;
 

local Regression;


 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end


    Up = instance.parameters.Up;
    Down= instance.parameters.Down;
    NeutralUp= instance.parameters.NeutralUp;
	
	UpDown= instance.parameters.UpDown;
	DownUp= instance.parameters.DownUp;
	NeutralDown= instance.parameters.NeutralDown;
   
    Period = instance.parameters.Period;
	 
	source = instance.source;
	
	
	
	Regression = core.indicators:create("REGRESSION", source, Period);
    first = Regression.DATA:first();
 

    	
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
				if source.close[period]> source.open[period] then
				open:setColor(period, NeutralUp);	
				else
				open:setColor(period, NeutralDown );	
				end			
			return;
			end
	
 
	
			   Regression:update(mode);
	 
		 if Regression.DATA[period]>Regression.DATA[period-1] then
		        if source.close[period]> source.open[period] then
				open:setColor(period, Up);	
				else
				open:setColor(period, UpDown );	
				end		
				
		else		
				if source.close[period]> source.open[period] then
				open:setColor(period, DownUp);	
				else
				open:setColor(period, Down );	
				end		
				
        end
		
 end


