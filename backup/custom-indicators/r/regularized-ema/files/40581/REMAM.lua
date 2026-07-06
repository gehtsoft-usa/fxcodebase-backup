-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23582
-- Id: 7441

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
    indicator:name("REMA Momentum");
    indicator:description("REMA Momentum");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
     indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("MP", "Momentum Period", "Period", 1); 
    indicator.parameters:addInteger("RP", "REMA Period", "Period", 14);
    indicator.parameters:addDouble("Lambda", "Lambda", "factor controlling the amount of �regularization�", 0.5);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("REMA_color", "Color of REMA", "Color of REMA", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Alpha;
local Lambda;
local MP, RP
local first;
local source = nil;

-- Streams block
local REMA,REMAM;

-- Routine
function Prepare(nameOnly)
    MP = instance.parameters.MP;
	RP = instance.parameters.RP;
    Lambda = instance.parameters.Lambda;
    source = instance.source;
    first = source:first()+2+MP;
	
	Alpha=2/(RP+1)
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(RP) .. ", " .. tostring(Lambda) .. ", " .. tostring(MP).. ")";
    instance:name(name);

    if (not (nameOnly)) then
        REMA= instance:addInternalStream(0, 0);
        REMAM = instance:addStream("REMAM", core.Line, name, "REMAM", instance.parameters.REMA_color, first);
    REMAM:setPrecision(math.max(2, instance.source:getPrecision()));
		REMAM:setWidth(instance.parameters.width);
        REMAM:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

     REMA[period]=0;   
	
    if period < source:first()+2 or not  source:hasData(period) then
	return;
	end	
	 
    REMA[period] =(REMA[period-1]*(1+2*Lambda)+Alpha*(source[period]-REMA[period-1])-Lambda*REMA[period-2])/(1+Lambda);
	
	if period < first  then
	return;
	end

	
	REMAM[period]= (REMA[period]-REMA[period-MP])/REMA[period-MP];
	
end

