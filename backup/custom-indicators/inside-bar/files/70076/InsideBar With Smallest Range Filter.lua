-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=43376

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

function Init()
    indicator:name("InsideBar With Smallest Range Filter");
    indicator:description("InsideBar With Smallest Range Filter");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period", "Period", "", 5 );
	indicator.parameters:addBoolean("Live", "Live", "", false);
	indicator.parameters:addBoolean("Filter", "Use Filter", "", true);
    indicator.parameters:addGroup("Style"); 
	indicator.parameters:addInteger("Size", "Font Size", "", 10, 1 , 100);	 
	indicator.parameters:addColor("UP", "Color of Inside Bar Up Candle ", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DN", "Color of Inside Bar Dn Candle ", "", core.rgb(255, 0, 0));
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;
local Period;
local UP, DN;
local first;
local source = nil;
local Live;
local Range;
local up,down;
local Size;
local Filter;
-- Routine
function Prepare(nameOnly)
   
    source = instance.source;
	Period=instance.parameters.Period;
	Filter=instance.parameters.Filter;
	Live=instance.parameters.Live;
	Size=instance.parameters.Size;
    first = source:first()+Period+1;

    local name = profile:id() .. "(" .. source:name()  .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	UP=instance.parameters.UP;
	DN=instance.parameters.DN;
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, UP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, DN, 0);

 
	if Filter then
	Range = instance:addInternalStream(0, 0);
	end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

    up:setNoData (period);
	down:setNoData (period);
	
	if Filter   then	
	Range[period]=source.high[period]-source.low[period];	 
	end
	
	if not Live then
    period=period-1;
    end
	
    if period < first   then
	return;
	end
	
	
	if Filter and  (mathex.min(Range, period-Period+1, period) == Range[period]) then
	return;
	end
	

	
	if source.high[period] < source.high[period-1]  and source.low[period] >  source.low[period-1]  then
	   if source.close[period] > source.open[period] then				 
		  up:set(period , source.high[period ], "\226");
		elseif  source.close[period] <source.open[period] then			 
		 down:set(period , source.low[period], "\225");
		end
	end				  
				
    
end

