-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=20563

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
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
    indicator:name("Turtle Trading Channel");
    indicator:description("Turtle Trading Channel");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("TradePeriod", "TradePeriod", "TradePeriod", 20);
    indicator.parameters:addInteger("StopPeriod", "StopPeriod", "StopPeriod", 10);
    indicator.parameters:addBoolean("Strict", "Strict Turtles Rules", "Strict Turtles Rules", false);
	
	indicator.parameters:addString("Show", "Show", "", "B");
	indicator.parameters:addStringAlternative("Show", "Outer", "", "O");
    indicator.parameters:addStringAlternative("Show", "Inner", "", "I");
    indicator.parameters:addStringAlternative("Show", "Both", "", "B");
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Outer", "Color of Outer TTC Line", "Color of Outer TTC Line", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("owidth", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("ostyle", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("ostyle", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("Inner", "Color of Inner TTC Line", "Color of Inner TTC Line", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("iwidth", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("istyle", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("istyle", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local TradePeriod;
local StopPeriod;
local Strict;

local first;
local source = nil;
local Show;
-- Streams block
local TrendDirection;
local Inner = nil;
local Outer=nil;

-- Routine
function Prepare(nameOnly)
    Show = instance.parameters.Show;
    TradePeriod = instance.parameters.TradePeriod;
    StopPeriod = instance.parameters.StopPeriod;
    Strict = instance.parameters.Strict;
    source = instance.source;
    first = source:first()+math.max(TradePeriod, StopPeriod);
	
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(TradePeriod) .. ", " .. tostring(StopPeriod) .. ", " .. tostring(Strict) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	TrendDirection= instance:addInternalStream(0, 0);

 
	    if Show ~= "I" then
        Outer = instance:addStream("Outer", core.Line, name, "Outer", instance.parameters.Outer, first);
		Outer:setWidth(instance.parameters.owidth);
        Outer:setStyle(instance.parameters.ostyle);
		else
		Outer =instance:addInternalStream(first, 0);		
		end
		 if Show ~= "O" then
		Inner = instance:addStream("Inner", core.Line, name, "Inner", instance.parameters.Inner, first);
		Inner:setWidth(instance.parameters.iwidth);
        Inner:setStyle(instance.parameters.istyle);
		else
		Inner =instance:addInternalStream(first, 0);
		end
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or  not source:hasData(period) then
	return;
	end
   
         local rlow,  rhigh; 
		 rlow,  rhigh=  mathex.minmax (source,  period-TradePeriod+1-1 , period-1);
       
         local  slow, shigh ;
		 slow, shigh=  mathex.minmax (source,  period-StopPeriod+1-1 , period-1);
		 
		 local CLOSE, HIGH, LOW;
		        
         CLOSE = source.close[period];
         HIGH = source.high[period];
         LOW = source.low[period];
		 
		  TrendDirection[period] = TrendDirection[period-1];
		 
		 --&&  And
		 --|| Or
		  -- Change to uptrend
         if((CLOSE > rhigh  or (HIGH > rhigh and Strict )) and TrendDirection[period-1] ~= 1) then
        
            TrendDirection[period] = 1;       
			Outer:setBreak (period, true);
			Inner:setBreak (period, true);
         
        -- Change to downtrend
         elseif((CLOSE < rlow  or (LOW < rlow and Strict )) and TrendDirection[period-1] ~=   -1)  then
            
            TrendDirection[period] = -1; 
            Outer:setBreak (period, true);
			Inner:setBreak (period, true);
			
        end
		
		
		-- Draw lines
         if(TrendDirection[period] == 1)  then
        
            Outer[period] = rlow;
            Inner[period] = slow;
            
         -- Draw lines
         elseif(TrendDirection[period] == -1)  then
         
            Outer[period] = rhigh;
            Inner[period] = shigh;
         end
		 
		 
end

