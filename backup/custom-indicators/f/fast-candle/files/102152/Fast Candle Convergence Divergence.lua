-- Id: 14815
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62625

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Fast Candle");
    indicator:description("Fast Candle");
    indicator:requiredSource(core.Bar); 
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("Volume_Factor", "Volume Factor", "Volume Factor", 0.2);
    indicator.parameters:addInteger("Period", "Period", "Period", 3);
 
   indicator.parameters:addGroup("Style");
   indicator.parameters:addColor("Fast_color", "Color of Fast", "Color of Fast", core.rgb(0, 255, 0));   
   indicator.parameters:addColor("Slow_color", "Color of Slow", "Color of Slow", core.rgb(255, 0, 0));
   indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Volume_Factor;
local Period;

local first;
local source = nil;

-- Streams block
local fast,slow,delta;
local cdFast, cdSlow;
local T3_Fast, T3_Slow; 
-- Routine
function Prepare(nameOnly)
    Volume_Factor = instance.parameters.Volume_Factor;
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Volume_Factor) .. ", " .. tostring(Period) .. ")";
    instance:name(name);
	
	assert(core.indicators:findIndicator("T3") ~= nil, "Please, download and install T3.LUA indicator");
	assert(core.indicators:findIndicator("GD") ~= nil, "Please, download and install GD.LUA indicator");

    if (not (nameOnly)) then
		cdFast= instance:addInternalStream(first, 0);
		cdSlow= instance:addInternalStream(first, 0); 
		
		T3_Fast = core.indicators:create("T3", cdFast, Volume_Factor, Period);
		T3_Slow = core.indicators:create("T3", cdSlow, Volume_Factor, Period);
		
		fast =   instance:addStream("Fast", core.Line, name, "Fast", instance.parameters.Fast_color, T3_Fast.DATA:first()+1) ; 
    fast:setPrecision(math.max(2, instance.source:getPrecision()));
		slow =    instance:addStream("Slow", core.Line, name, "Slow", instance.parameters.Slow_color, T3_Slow.DATA:first()+1); 
    slow:setPrecision(math.max(2, instance.source:getPrecision()));
		fast:setWidth(instance.parameters.width);
		fast:setStyle(instance.parameters.style);
		slow:setWidth(instance.parameters.width);
		slow:setStyle(instance.parameters.style);
		
		core.host:execute ("attachOuputToChart", "Fast");
		core.host:execute ("attachOuputToChart", "Slow");
		
		delta =    instance:addStream("Delta", core.Bar, name, "Delta", instance.parameters.Fast_color, math.max( (T3_Fast.DATA:first()+1),(T3_Slow.DATA:first()+1) )); 
    delta:setPrecision(math.max(2, instance.source:getPrecision()));
 
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    
    if period < first or not source:hasData(period) then
	return;
	end
	
 
	
    if source.close[period] >source.open[period]   then
	cdFast[period]=(source.close[period]+source.high[period])/2
    else
	cdFast[period]=(source.close[period]+source.open[period])/2
	end
	
	
	if source.close[period] >source.open[period]   then
	cdSlow[period]=(source.open[period]+source.low[period])/2
    else
	cdSlow[period]=(source.open[period]+source.high[period])/2
	end
	
	T3_Fast:update(mode);
	T3_Slow:update(mode);
	
	if period < T3_Fast.DATA:first()+1 then
	return;
	end
	
	period= period-1;
	
	fast[period+1]= T3_Fast.DATA[period];
	slow[period+1]= T3_Slow.DATA[period-1]; 
	
	delta[period+1]= fast[period+1]-slow[period+1];
	
	if delta[period+1] > 0 then
	delta:setColor(period+1, instance.parameters.Fast_color);
	else
	delta:setColor(period+1, instance.parameters.Slow_color);
	end
end
 

