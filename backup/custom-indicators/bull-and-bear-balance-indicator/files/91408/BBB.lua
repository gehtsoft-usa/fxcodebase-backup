-- Id: 18537
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60072

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+
function Init()
    indicator:name("Bull And Bear Balance Indicator");
    indicator:description("Bull And Bear Balance Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Raw", "Raw Data Smooth Period", "Raw Data Smooth Period", 20);
	indicator.parameters:addString("Method1", "Raw MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
  indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
    indicator.parameters:addInteger("Smooth", "Smooth Period", "Smooth Period", 30);
	
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("BBB_color", "Color of BBB", "Color of BBB", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Raw;
local Smooth;
local Method2, Method1;
local first;
local source = nil;
local Bull, Bear;
-- Streams block
local BBB = nil;

-- Routine
function Prepare(nameOnly)
    Raw = instance.parameters.Raw;
	Method2 = instance.parameters.Method2;
	Method1 = instance.parameters.Method1;
    Smooth = instance.parameters.Smooth;
    source = instance.source;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Raw) .. ", " .. tostring(Method1).. ", " .. tostring(Smooth).. ", " .. tostring(Method2) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
		Bull = instance:addInternalStream(0, 0);
		Bear = instance:addInternalStream(0, 0);
			
		bull = core.indicators:create(Method1, Bull, Raw);
		bear = core.indicators:create(Method1, Bear, Raw);
		
		smooth= instance:addInternalStream(0, 0);
		smoothed = core.indicators:create(Method2, smooth, Smooth);
		
		first = smoothed.DATA:first();
        BBB = instance:addStream("BBB", core.Bar, name, "BBB", instance.parameters.BBB_color, first);
		
		
		BBB:setPrecision(math.max(2, instance.source:getPrecision()));
 
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

Bull[period]=BullPower(period) ;
Bear[period]=BearPower(period) ;

bull:update(mode);
bear:update(mode);
   
     if period < bull.DATA:first() then
	return;
	end
   
   smooth[period]=bull.DATA[period]-bear.DATA[period];
   
   smoothed:update(mode);
   
   if period < first then
	return;
	end
	
        BBB[period] = smoothed.DATA[period];
   
end

function BearPower(period) 

local  value = 0;
if(close(period) < open(period)) then
		if(close(period-1) > open(period)) then
		value = math.max(close(period-1) - open(period), high(period) - low(period));
		else
		value = high(period) - low(period);
		end
		
		
elseif (close(period) > open(period)) then
						if(close(period-1) > open(period)) then
							value = math.max(close(period-1) - low(period), high(period) - close(period));
						else
							value = math.max(open(period) - low(period),high(period) - close(period));
						end
						 
elseif(high(period) - close(period) > close(period) - low(period)) then
								if(close(period-1) > open(period)) then
								value = math.max(close(period-1) - open(period),high(period) - low(period));
								else
								value = high(period) - low(period);
								end
								
								
elseif(high(period) - close(period) < close(period) - low(period)) then
								if(close(period-1) > open(period)) then
								value = math.max(close(period-1) - low(period),high(period) - close(period));
								else
								value = open(period) - low(period);
								end
								
elseif(close(period-1) > open(period)) then
value = math.max(close(period-1) - open(period),high(period) - low(period));
elseif(close(period-1) < open(period)) then
value = math.max(open(period) - low(period),high(period) - close(period));
else
value = high(period) - low(period);
end
								
		
	 

return value;

end


function BullPower (period)
local  value = 0;


if(close(period) < open(period)) then
	if(close(period-1) < open(period))  then
	value = math.max(high(period) - close(period-1), close(period) - low(period));
	else
	value = math.max(high(period) - open(period), close(period) - low(period));
	end
elseif (close(period) > open(period))  then
	if(close(period-1) > open(period))  then
	value = high(period) - low(period);
	else
	value = math.max(open(period) - close(period-1),high(period) - low(period));
	end
elseif(high(period) - close(period) > close(period) - low(period))  then
	if(close(period-1) < open(period))  then
	value = math.max(high(period) - close(period-1),close(period) - low(period));
	else
	value = high(period) - open(period);
	end
elseif(high(period) - close(period) < close(period) - low(period))  then
	if(close(period-1) > open(period))  then
	value = high(period) - low(period);
	else
	value = math.max(open(period) - close(period-1),high(period) - low(period));
	end
elseif(close(period-1) > open(period))  then
value = math.max(high(period) - open(period),close(period) - low(period));
elseif(close(period-1) < open(period))  then
value = math.max(open(period) - close(period-1),high(period) - low(period));
else
value = high(period) - low(period);
end

return value;

end

function open(Shift)
return source.open[Shift];
end
function close(Shift)
return source.close[Shift];
end

function high(Shift)
return source.high[Shift];
end

function low(Shift)
return source.low[Shift];
end



