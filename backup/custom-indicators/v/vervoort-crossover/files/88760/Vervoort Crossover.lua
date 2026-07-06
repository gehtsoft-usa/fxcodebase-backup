-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59240

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Vervoort Crossover");
    indicator:description("Vervoort Crossover");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 55);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("ZIHA_color", "Color of ZIHA", "Color of ZIHA", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("ZICI_color", "Color of ZICI", "Color of ZICI", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;

-- Streams block
local ZIHA = nil;
local ZICI = nil;
local EMA1, EMA2, EMA3, EMA4, EMA5, EMA6,EMA7, EMA8, EMA9, EMA10, EMA11, EMA12;
local TMA1, TMA2, TMA3, TMA4;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
	
	
	
	  local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	
	
	HA = core.indicators:create("HA", source);
	
	EMA1 = core.indicators:create("EMA", HA.DATA, Period);
    EMA2 = core.indicators:create("EMA", EMA1.DATA, Period);
    EMA3 = core.indicators:create("EMA", EMA2.DATA, Period);
	
	TMA1 = instance:addInternalStream(0, 0);
	
	EMA4 = core.indicators:create("EMA", TMA1, Period);
    EMA5 = core.indicators:create("EMA", EMA4.DATA, Period);
    EMA6 = core.indicators:create("EMA", EMA5.DATA, Period);
	
	TMA2 = instance:addInternalStream(0, 0);
		
	EMA7 = core.indicators:create("EMA", source.typical, Period);
    EMA8 = core.indicators:create("EMA", EMA7.DATA, Period);
    EMA9 = core.indicators:create("EMA", EMA8.DATA, Period);
	
	TMA3 = instance:addInternalStream(0, 0);
	
	EMA10 = core.indicators:create("EMA", TMA3, Period);
    EMA11 = core.indicators:create("EMA", EMA10.DATA, Period);
    EMA12 = core.indicators:create("EMA", EMA11.DATA, Period);
	
	TMA4 = instance:addInternalStream(0, 0);	
    

  

 
        ZIHA = instance:addStream("ZIHA", core.Line, name .. ".ZIHA", "ZIHA", instance.parameters.ZIHA_color, EMA6.DATA:first());
		ZIHA:setWidth(instance.parameters.width1);
        ZIHA:setStyle(instance.parameters.style1);
        ZICI = instance:addStream("ZICI", core.Line, name .. ".ZICI", "ZICI", instance.parameters.ZICI_color, EMA9.DATA:first());
		ZICI:setWidth(instance.parameters.width2);
        ZICI:setStyle(instance.parameters.style2);
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    HA:update(mode);

    EMA1:update(mode);
    EMA2:update(mode);
    EMA3:update(mode);
	
	if period < EMA3.DATA:first() then
	return;
	end
	
	TMA1[period]  = 3 * EMA1.DATA[period] - 3 * EMA2.DATA[period] + EMA3.DATA[period];	
	
	EMA4:update(mode);
    EMA5:update(mode);
    EMA6:update(mode);
	
	if period < EMA6.DATA:first() then
	return;
	end
	
	TMA2[period] = 3 * EMA4.DATA[period] - 3 * EMA5.DATA[period] + EMA6.DATA[period];
	
	local Diff;
	
	Diff= TMA1[period]-TMA2[period];	
	ZIHA[period]= TMA1[period]+Diff
	
	
	EMA7:update(mode);
    EMA8:update(mode);
    EMA9:update(mode);
	
	if period < EMA9.DATA:first() then
	return;
	end
	
	TMA3[period] = 3 * EMA7.DATA[period] - 3 * EMA8.DATA[period] + EMA9.DATA[period];
	
	
	
	EMA10:update(mode);
    EMA11:update(mode);
    EMA12:update(mode);
	
	if period < EMA12.DATA:first() then
	return;
	end

	TMA4[period] = 3 * EMA10.DATA[period] - 3 * EMA11.DATA[period] + EMA12.DATA[period];
	
	Diff = TMA3[period]-TMA4[period];	
	ZICI[period]= TMA3[period]+Diff
	
	    
end

