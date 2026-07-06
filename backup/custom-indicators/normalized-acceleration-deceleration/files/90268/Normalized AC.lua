-- Id: 10278
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59725

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
    indicator:name("Normalized Acceleration/Deceleration");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("Calulation");	
    indicator.parameters:addInteger("FM", "Fast Moving Average for Awesome oscillator", "The number of periods to calculate the fast moving average of the median price", 5, 2, 10000);
    indicator.parameters:addInteger("SM", "Slow Moving Average for Awesome oscillator", "The number of periods to calculate the slow moving average of the median price", 35, 2, 10000);
    indicator.parameters:addInteger("M", "Moving Average for Acceleration/Deceleration", "The number of periods to calculate the moving average of the AO", 5, 2, 10000);

	indicator.parameters:addInteger("Level", "Normalization Level" , "Normalization Level", 50);
	indicator.parameters:addInteger("Scale", "Scale" , "Scale", 100);
	indicator.parameters:addInteger("Period", "Normalization Period" , "Period", 0);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Line Color", "Line Color", core.rgb(0, 0, 255));
    
	
end

local FM;
local SM;
local M;


local first;
local source = nil;
local Period;
-- Streams block
local AC,RawAC;


local AO = nil;
local MVA = nil;
local Level,Scale;

function Prepare(nameOnly)
    Level = instance.parameters.Level;
	Period = instance.parameters.Period;
    FM = instance.parameters.FM;
    SM = instance.parameters.SM;
    M = instance.parameters.M; 
	Scale = instance.parameters.Scale;

    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. FM .. ", " .. SM .. ", " .. M.. ", " .. Level.. ", " .. Scale.. ", " .. Period .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
    AO = core.indicators:create("AO", source, FM, SM, true);
    MVA = core.indicators:create("MVA", AO.DATA, M);
    first = MVA.DATA:first();
       RawAC= instance:addInternalStream(0, 0);
       AC = instance:addStream("AC", core.Line, name .. ".AC", "AC", instance.parameters.Up, first);
    AC:setPrecision(math.max(2, instance.source:getPrecision()));
      
end

function Update(period, mode)
    AO:update(mode);
    MVA:update(mode);

    if (period < first) then
	return;
	end
	
	
		
        RawAC[period] = AO.DATA[period] - MVA.DATA[period];
    
	
	
	if Period == 0 then
	
	if period < source:size()-1 then
	return;
	end
	
	
 
	local min, max;
	
    
     min,max=mathex.minmax(RawAC,first, period);	
	 if Scale == 0 then
	 Scale=max- min;
	 end
	 
	 local Max= math.abs(min,max);
		
	
	for period = first, source:size()-1, 1 do		
		AC[period] = Level +RawAC[period] * ( Scale/ Max);
	end
	
	else
	
			
				if period < first + Period then
			return;
			end
			
			
		 
			local min, max;
			
			
			 min,max=mathex.minmax(RawAC,period-Period, period);	
			 if Scale == 0 then
			 Scale=max- min;
			 end
			 
			 local Max= math.abs(min,max);
				
			
			 
				AC[period] = Level +RawAC[period] * ( Scale/ Max);
			 
	
	end
	
end

