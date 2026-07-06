-- Id: 2783
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3092

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
    indicator:name("Trend / Revers Pressure");
    indicator:description("Trend / Revers Pressure");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Frame", "Period", "Periof", 20);    
	indicator.parameters:addInteger("transparency", "Highlight transparency (%)", "", 30);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Color of Up","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Color of Down","",  core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Frame;

local first;
local source = nil;

-- Streams block
local Trend = nil;
local Revers = nil;
local Up,Down;
local T, R;
-- Routine
 function Prepare(nameOnly) 
    Frame = instance.parameters.Frame;
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
    source = instance.source;
    first = source:first()+Frame;
	
	
	 local name = profile:id() .. "(" .. source:name() .. ", " .. Frame .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

	
	T =instance:addInternalStream (0, 0);
	R =instance:addInternalStream (0, 0);
	
   
    Trend = instance:addStream("Trend", core.Line, name .. ".Trend", "Trend", core.rgb(128, 128, 128), first);
    Trend:setPrecision(math.max(2, instance.source:getPrecision()));
    Revers = instance:addStream("Revers", core.Line, name .. ".Revers", "Revers", core.rgb(128, 128, 128), first);
    Revers:setPrecision(math.max(2, instance.source:getPrecision()));
	
	 Trend:setStyle(core.LINE_NONE);
	 Revers:setStyle(core.LINE_NONE);

    instance:createChannelGroup("os", "os", Trend, Revers, core.rgb(128, 128, 128), 100 - instance.parameters.transparency);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first  or not source:hasData(period) then
	return;
	end
	
	
	    if  source.close[period]>source.open[period] then
        T[period] =source.close[period]-source.open[period];		
        R[period] = (source.open[period]-source.low[period])- (source.high[period]-source.close[period]);
		else
		 T[period] =source.close[period]-source.open[period];		
       R[period] = (source.close[period]-source.low[period])- (source.high[period]-source.open[period]);
		end
		
	
		 Trend[period]= mathex.sum(T,period-Frame+1 , period);		 
		 Revers[period]= mathex.sum(R,period-Frame+1 , period);
		 
		 if Trend[period] >  Revers[period] then
		Trend:setColor(period, Up);
		 else
		 Trend:setColor(period, Down);
		 end
    
end

