-- Id: 16141
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63546&p=106547#p106547

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
    indicator:name("Welles Wilder");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
 
    indicator.parameters:addInteger("Period", "Period", "Period", 14);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "Color of ADX", "Color of ADX", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color2", "Color of ADX", "Color of ADX", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("color3", "Color of ADX", "Color of ADX", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first;
local source = nil;
-- Streams block
local ADX, DP, DN;
local Period;
local TrueRange, RawTrueRange;
local RawDP, RawDN;
local DX;
-- Routine
function Prepare(nameOnly)
    
	Period = instance.parameters.Period;
	RawTrueRange = instance:addInternalStream(0, 0);
	TrueRange = instance:addInternalStream(0, 0);
	RawDP = instance:addInternalStream(0, 0);
	RawDN = instance:addInternalStream(0, 0);
	
	SmoothedDP = instance:addInternalStream(0, 0);
	SmoothedDN = instance:addInternalStream(0, 0);
	
	DX = instance:addInternalStream(0, 0);
	
    source = instance.source; 
	first=source:first()+Period+1;
  

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	 
    if (not (nameOnly)) then
        ADX = instance:addStream("ADX", core.Line, ".ADX", "ADX",   instance.parameters.color1, first+Period); 
    ADX:setPrecision(math.max(2, instance.source:getPrecision()));
		ADX:setWidth(instance.parameters.width1);
        ADX:setStyle(instance.parameters.style1);
		DP = instance:addStream("DP", core.Line, ".DP", "DP",   instance.parameters.color2, first);
    DP:setPrecision(math.max(2, instance.source:getPrecision()));
		DP:setWidth(instance.parameters.width2);
        DP:setStyle(instance.parameters.style2);
		DN = instance:addStream("DN", core.Line, ".DN", "DN",   instance.parameters.color3, first);
    DN:setPrecision(math.max(2, instance.source:getPrecision()));
		DN:setWidth(instance.parameters.width3);
        DN:setStyle(instance.parameters.style3);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
 
  
     if period < 1 then
	 return;
	 end
	 
	 RawTrueRange[period]= 
	 math.max(
	 math.abs(source.high[period]-source.low[period]),
	 math.abs(source.high[period]-source.close[period-1]),
	 math.abs(source.close[period-1]-source.low[period])
	 );
	 
	    local upperMove = source.high[period] - source.high[period - 1];
        local lowerMove = source.low[period - 1] - source.low[period];
        if (upperMove < 0) then upperMove = 0 end
        if (lowerMove < 0) then lowerMove = 0 end
        if (upperMove == lowerMove) then
            upperMove = 0;
            lowerMove = 0;
        elseif (upperMove < lowerMove) then
            upperMove = 0;
        elseif (lowerMove < upperMove) then
            lowerMove = 0;
        end
		
		RawDP[period]=upperMove;
		RawDN[period]=lowerMove;
		

    if period < first then
    return;
    end
	
	if period == first then
	TrueRange[period]= mathex.sum(RawTrueRange, period-Period+1, period);
	else
	TrueRange[period]= TrueRange[period-1] -(TrueRange[period-1]/Period)+RawTrueRange[period]
	end
	
	
	if period == first then
	SmoothedDP[period]= mathex.sum(RawDP, period-Period+1, period);
	else
	SmoothedDP[period]= SmoothedDP[period-1] -(SmoothedDP[period-1]/Period)+RawDP[period]
	end

   	if period == first then
	SmoothedDN[period]= mathex.sum(RawDN, period-Period+1, period);
	else
	SmoothedDN[period]= SmoothedDN[period-1] -(SmoothedDN[period-1]/Period)+RawDN[period]
	end	
		
	 DN[period] = 100 * SmoothedDN[period] / TrueRange[period];
     DP[period] = 100 * SmoothedDP[period] / TrueRange[period];	
	 
	 
	 local div = DP[period] + DN[period];
        if (div == 0) then
            DX[period]   = 0;
        else
           DX[period]   = 100 * (math.abs(DP[period] - DN[period]) / div)
        end
		
		if period == first+Period then	
		ADX[period]= mathex.avg(DX, period-Period+1, period);
		elseif period > first+Period then	
		ADX[period]= ((ADX[period-1]*(Period-1))+DX[period])/Period;
		end
 
	
 
     
	 
end
 