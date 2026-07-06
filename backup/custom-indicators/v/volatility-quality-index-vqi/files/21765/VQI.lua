-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=10504
-- Id: 5439

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Volatility Quality Index ");
    indicator:description("Volatility Quality Index ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	
	   indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("P1", "Short Smoothing Period", "", 9);
	indicator.parameters:addInteger("P2", "Long Smoothing Period", "", 200);
 

   indicator.parameters:addString("Type", "Algorithm Selection", "", "One");
    indicator.parameters:addStringAlternative("Type", "One", "", "One");
    indicator.parameters:addStringAlternative("Type", "Two", "", "Two"); 


	
	  indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("S1_color", "VQI Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("S2_color", "First Smoothing Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("S3_color", "Second Smoothing Line Color", "", core.rgb(0, 0, 255));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local P1;
local P2;
local Type;

local first;
local source = nil;

-- Streams block
local S1 = nil;
local S2 = nil;
local S3 = nil;
local VQI;
local One, Two;
local ATR;
-- Routine
function Prepare(nameOnly)
    P1 = instance.parameters.P1;
	P2 = instance.parameters.P2;
	Type = instance.parameters.Type;
	
    source = instance.source;
  

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(P1) .. ", " .. tostring(P2).. ")";
    instance:name(name);	

    if (not (nameOnly)) then
	
        ATR=core.indicators:create("ATR", source, 14);
        
          first = ATR.DATA:first();
        
        VQI=instance:addInternalStream (0,0);
        S1 = instance:addStream("S1", core.Line, name .. ".S1", "S1", instance.parameters.S1_color, first);
    S1:setPrecision(math.max(2, instance.source:getPrecision()));
		One = core.indicators:create("MVA",  S1, P1);
		Two = core.indicators:create("MVA", S1, P2);
        S2 = instance:addStream("S2", core.Line, name .. ".S2", "S2", instance.parameters.S2_color, One.DATA:first());
    S2:setPrecision(math.max(2, instance.source:getPrecision()));
        S3 = instance:addStream("S3", core.Line, name .. ".S3", "S3", instance.parameters.S3_color,  Two.DATA:first());
    S3:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not source:hasData(period) then
	return;
	end
	
	ATR:update(mode);
	
	if period == first then
	  S1[period] =0;
	end
	

	

local  TR = math.max((source.high[period] - source.low[period]), ( source.close[period-1] - source.high[period]) ,  ( source.close[period-1] - source.low[period]));


if Type == "One" then
		if TR ~= 0 and (source.high[period] -source.low[period]) ~=  0 then
		VQI[period] =  ((source.close[period] - source.close[period-1]) / TR + (source.close[period] - source.open[period]) / (source.high[period] - source.low[period])) * 0.5;
		else
		VQI[period]=VQI[period-1];
		VQI[period] = math.abs(VQI[period]) * ((source.close[period] - source.close[period-1] + (source.close[period] - source.open[period])) * 0.5);
		end
else

--> (C-Ref(C,-1)/ATR(1)) + ((C-O)/(H-L)))*0.5

   if ATR.DATA[period] ~= 0 and (source.high[period] -source.low[period]) ~=  0 then
   VQI[period]= ((source.close[period] - source.close[period-1]) / ATR.DATA[period]  + (source.close[period] - source.open[period]) / (source.high[period] - source.low[period])) * 0.5;
   else
   VQI[period]= VQI[period-1];  
   end
   
    VQI[period] = math.abs(VQI[period]) * ((source.close[period] - source.close[period-1] + (source.close[period] - source.open[period])) * 0.5);   
   
end
		
		
S1[period] = S1[period-1] +VQI[period];

       One:update(mode);
	   Two:update(mode);
	   
	   if period > One.DATA:first() then
        S2[period] = One.DATA[period];
	   end
	   if period > Two.DATA:first() then
        S3[period] = Two.DATA[period];
		end
    
end

