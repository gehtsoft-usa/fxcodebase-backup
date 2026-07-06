-- Id: 5845
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=13598&sid=e771a98f6d78bea9bee97875e3ca9bbb

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
    indicator:name("SAR Oscillator");
    indicator:description("SAR Oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

     indicator.parameters:addGroup("SAR Calculation");
	indicator.parameters:addDouble("Step", "Step","", 0.02, 0.001, 1);
    indicator.parameters:addDouble("Max", "Max", "", 0.2, 0.001, 10);
	
	 indicator.parameters:addGroup("MA Calculation");
	 indicator.parameters:addInteger("Period", "Ma Period","", 7, 1, 2000);
	
    indicator.parameters:addGroup("Style");
	 indicator.parameters:addColor("UP", "Up Trend ", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("DN", "Down Trend ", "", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block


local first;
local source = nil;

-- Streams block
local Step, Max;

local SARO
local SAR;
local MA;
local Buffer;
local Period;
-- Routine
function Prepare(nameOnly)
   Step = instance.parameters.Step;
    Max = instance.parameters.Max;
	Period = instance.parameters.Period;
    source = instance.source;
	
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Step).. ", " .. tostring(Max).. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
		SAR = core.indicators:create("SAR", source, Step, Max);
		Buffer = instance:addInternalStream(0, 0);
		MA= core.indicators:create("MVA", Buffer, Period);
	   
	   first = math.max( SAR.UP:first(),  SAR.DN:first());
		   SARO = instance:addStream("SARO", core.Bar, name, "SARO", instance.parameters.UP, first);
    SARO:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)


      SAR:update(mode);
	
	  
	  
    if period < first or not source:hasData(period) then
	return;
	end
	
	if SAR.UP:hasData(period) then
        Buffer[period] = source.close[period] -SAR.UP[period];
	elseif SAR.DN:hasData(period) then  
	    Buffer[period] = source.close[period] -  SAR.DN[period];
    end	
	
	  MA:update(mode);
	
	SARO[period] = MA.DATA[period];
	
	if SARO[period] > SARO[period-1] then
	SARO:setColor(period, instance.parameters.UP);
	else
	SARO:setColor(period, instance.parameters.DN);
	end
	
    
end

