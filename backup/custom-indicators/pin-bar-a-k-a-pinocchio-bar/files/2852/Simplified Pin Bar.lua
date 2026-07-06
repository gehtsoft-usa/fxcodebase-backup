-- Id: 20784
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1459

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
    indicator:name("Simplified Pin Bar");
    indicator:description("Simplified Pin Bar");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator.parameters:addGroup("Calculation");   
    indicator.parameters:addInteger("BB", "Body Lengt", "Body Lengt", 33);
	indicator.parameters:addInteger("BP", "Body Position", "Body Position", 33);
	indicator.parameters:addInteger("NB", "Nose Lengt", "Nose Lengt", 33);
 
	

	
	indicator.parameters:addGroup("Trend Filter");
	indicator.parameters:addBoolean("Filter", "Use Filter", "", false);
	  indicator.parameters:addInteger("Period", "Period", "", 34);
	 indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
   indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addGroup("Range Filter");
	indicator.parameters:addBoolean("RangeFilter", "Use Filter", "", false);
	  indicator.parameters:addInteger("RangePeriod", "Period", "", 34);
	   indicator.parameters:addDouble("MinRange", "Range minimum", "", 30);
	  indicator.parameters:addString("RangeMethod", "Range Method", "Method" , "OC");
    indicator.parameters:addStringAlternative("RangeMethod", "Open/Close", "Open/Close" , "OC");
    indicator.parameters:addStringAlternative("RangeMethod", "High/Low", "High/Low" , "HL");
	
	
	indicator.parameters:addGroup("Signal Mode");
	indicator.parameters:addBoolean("Signal", "Signal Mode", "", false);
	
	
		indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Top", "Color of Pin bar", "Color of Pin bar", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Bottom", "Color of Pin bar", "Color of Pin bar", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("Size", "Arrow Size", "Arrow Size", 10);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Body=nil;
local Nose=nil;
local Position=nil;
 
local Size;
local first;
local source = nil;

-- Streams block
local up = nil;
local down = nil;
local Period, Method, MA,Filter;
local Signal,signal;
	
local RangeFilter, RangePeriod,Range,MinRange, RangeMethod;

-- Routine
 function Prepare(nameOnly)
 
    source = instance.source;
    
	Nose= instance.parameters.NB;
	Body = instance.parameters.BB;
	Position= instance.parameters.BP;
	Size= instance.parameters.Size;
	Signal= instance.parameters.Signal;
	
	RangeFilter= instance.parameters.RangeFilter;
	RangePeriod= instance.parameters.RangePeriod;
	MinRange= instance.parameters.MinRange;
	RangeMethod= instance.parameters.RangeMethod;
 
	Filter=  instance.parameters.Filter;
	
	Period =  instance.parameters.Period;
	Method =  instance.parameters.Method;
	
	
	 local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	Range=instance:addInternalStream(0, 0);
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	MA = core.indicators:create(Method, source.close, Period);	
	first = MA.DATA:first();
   
	if not Signal then
	down = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Bottom, 0);
    up = instance:createTextOutput ("Down", "Down", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Top, 0);
	else	
	signal= instance:addStream("signal", core.Bar, name .. ".signal", "signal", instance.parameters.Top, 0);
	end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

if Filter then
MA:update(mode);
end 


if RangeFilter then

if RangeMethod == "OC" then
Range[period]= math.abs(source.close[period]-source.open[period]);
else
Range[period]=  (source.high[period]-source.low[period]);
end


end

    if period < first+1 or not  source:hasData(period) then
	return;
	end
	
	if not Signal then
	up:setNoData (period);
	down:setNoData (period);
	else
	signal[period]=0;
	end
	
    Calculation (period);
	 
end

function Calculation(period)
	local Bar= (source.high[period]- source.low[period])/100;
	
  local AverageRange=0;		 
   if RangeFilter and period > RangePeriod then
   
   AverageRange= mathex.avg(Range, period-RangePeriod+1, period);
   end
   
   
			   
			        if  math.abs(source.close[period]-source.open[period]) <= Bar* Body 
					and  ((RangeFilter and (Range[period]/(AverageRange/100)) > MinRange ) or not RangeFilter) 
					then
					  
					
								 if math.max(source.close[period], source.open[period]) <= source.low[period] +  Bar *Position then 
									 if (source.high[period]- math.max(source.open[period],source.close[period] )) >= Nose *Bar then
										 if (not Filter  or (Filter and source.close[period]> MA.DATA[period]))
										 then 
										 if Signal then
										 signal[period]=-1;
										 else
										 up:set(period, source.high[period], "\226");
										 end
										 end
									 end
								 end
								 if math.min(source.close[period], source.open[period]) >= source.high[period] -  Bar *Position then 
								   
									 if ( math.min(source.open[period],source.close[period] ) - source.low[period])  >= Nose *Bar then
									     if  (not Filter  or ( Filter and source.close[period]< MA.DATA[period]))
										 then 
										 if Signal then
										  signal[period]=1;
										 else
									      down:set(period, source.low[period], "\225");
										  end
										  end
									end
								 end			 
					end
			         
		 

end