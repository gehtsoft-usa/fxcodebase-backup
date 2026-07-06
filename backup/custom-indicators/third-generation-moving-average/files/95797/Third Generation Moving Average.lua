-- Id: 12434
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61118

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
    indicator:name("Third Generation Moving Average");
    indicator:description("Third Generation Moving Average");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 220);
	indicator.parameters:addInteger("SamplingPeriod", "SamplingPeriod", "SamplingPeriod", 50);
	
	indicator.parameters:addString("MAType", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("MAType", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("MAType", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("MAType", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("MAType", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("MAType", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("MAType", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("MAType", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("MAType", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("TGMA_color", "Color of TGMA", "Color of TGMA", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local SamplingPeriod;
local first;
local source = nil;
local MAType;
-- Streams block
local TGMA = nil;
local movingAverage1, movingAverage2;
local alpha, lamda;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	SamplingPeriod = instance.parameters.SamplingPeriod;
	MAType= instance.parameters.MAType;
    source = instance.source;
    
    assert((Period > 2*SamplingPeriod), "Period >= Sampling Period * 2");	 

    lamda =  Period/SamplingPeriod;
    alpha = lamda*(Period - 1)/(Period - lamda);

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(SamplingPeriod).. ", " .. tostring(MAType).. ")";
    instance:name(name);

    if (not (nameOnly)) then
    assert(core.indicators:findIndicator(MAType) ~= nil, MAType .. " indicator must be installed");
        movingAverage1   = core.indicators:create(MAType, source,  Period); 
        movingAverage2   = core.indicators:create(MAType, movingAverage1.DATA, SamplingPeriod);
  
        first = math.max(movingAverage1.DATA:first(),movingAverage2.DATA:first());
        TGMA = instance:addStream("TGMA", core.Line, name, "TGMA", instance.parameters.TGMA_color, first);
		TGMA:setWidth(instance.parameters.width);
        TGMA:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    
	movingAverage1:update(mode);
	movingAverage2:update(mode);
	
	if period < first or not source:hasData(period) then
	return;
	end
	
	
	
        TGMA[period] =  (alpha + 1)*movingAverage1.DATA[period] - (alpha*movingAverage2.DATA[period]);
   
   
end


        


