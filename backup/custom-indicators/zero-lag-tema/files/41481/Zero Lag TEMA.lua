-- Id: 7606
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=24108

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
    indicator:name("Zero Lag Triple Exponential Moving Average");
    indicator:description("Zero Lag Triple Exponential Moving Average");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("Period", "Period", "Period", 50,2,2000);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("width", "TEMA Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "TEMA Line Style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
    indicator.parameters:addColor("TC", "Color of TEMA", "Color of TEMA", core.rgb(0, 255, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Period;

local first;
local source = nil;

-- Streams block
local TEMA = nil;
local EMA1, EMA2, EMA3;
local EMA4, EMA5, EMA6;
local TEMA1, TEMA2; 
local TC = nil;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    TC = instance.parameters.TC;
    source = instance.source;
	
	first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    EMA1 = core.indicators:create("EMA", source, Period);
    EMA2 = core.indicators:create("EMA", EMA1.DATA, Period);
    EMA3 = core.indicators:create("EMA", EMA2.DATA, Period);
	
	TEMA1= instance:addInternalStream(EMA3.DATA:first(), 0);
	
	EMA4 = core.indicators:create("EMA", TEMA1, Period);
    EMA5 = core.indicators:create("EMA", EMA4.DATA, Period);
    EMA6 = core.indicators:create("EMA", EMA5.DATA, Period);
	
	TEMA2= instance:addInternalStream(EMA6.DATA:first(), 0);
	
    TEMA = instance:addStream("TEMA", core.Line, name, "TEMA", TC, EMA6.DATA:first());
	TEMA:setWidth(instance.parameters.width);
    TEMA:setStyle(instance.parameters.style);
end

-- Indicator calculation routine
function Update(period,mode)
    EMA1:update(mode);
    EMA2:update(mode);
    EMA3:update(mode);
	
    if period<  EMA3.DATA:first()  then
	return;
	end
        TEMA1[period] = 3 * EMA1.DATA[period] - 3 * EMA2.DATA[period] + EMA3.DATA[period];
 
	
	
	EMA4:update(mode);
    EMA5:update(mode);
    EMA6:update(mode);
	
	if period<  EMA6.DATA:first()  then
	return;
	end
	
 
     TEMA2[period] = 3 * EMA4.DATA[period] - 3 * EMA5.DATA[period] + EMA6.DATA[period];
  
	
	local Diff= TEMA1[period] - TEMA2[period];
	
	 TEMA[period]= TEMA1[period] + Diff;
end

