-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=22685
-- Id: 7193

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
    indicator:name("PRO GO II");
    indicator:description("PRO GO II");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period1", "Prof Period", "Prof Period", 14);
    indicator.parameters:addInteger("Period2", "Public Period", "Public Period", 14);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Prof_color", "Color of Prof", "Color of Prof", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Public_color", "Color of Public", "Color of Public", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period1;
local Period2;

local first;
local source = nil;

-- Streams block
local Prof = nil;
local Public = nil;
local EMA1,EMA2;
local DATA1, DATA2;
-- Routine
function Prepare(nameOnly)
    Period1 = instance.parameters.Period1;
    Period2 = instance.parameters.Period2;
    source = instance.source;
   

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period1) .. ", " .. tostring(Period2) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
	
        DATA1 =instance:addInternalStream(0, 0);
        DATA2 =instance:addInternalStream(0, 0);
            
        EMA1 = core.indicators:create("EMA", DATA1 , Period1);
        EMA2 = core.indicators:create("EMA",  DATA2 , Period2);
        
        
         first = math.max(EMA1.DATA:first(), EMA1.DATA:first());
        Prof = instance:addStream("Prof", core.Line, name .. ".Prof", "Prof", instance.parameters.Prof_color, first);
    Prof:setPrecision(math.max(2, instance.source:getPrecision()));
		Prof:setWidth(instance.parameters.width1);
        Prof:setStyle(instance.parameters.style1);
        Public = instance:addStream("Public", core.Line, name .. ".Public", "Public", instance.parameters.Public_color, first);
    Public:setPrecision(math.max(2, instance.source:getPrecision()));
		Public:setWidth(instance.parameters.width2);
        Public:setStyle(instance.parameters.style2);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
 
	
	DATA1[period]=source.close[period]-source.open[period];
	DATA2[period]=source.open[period]-source.close[period-1];
	
	 EMA1:update(mode); 
	 EMA2:update(mode);

     if period <  first or not  source:hasData(period) then
	return;
	end	 
	 
        Prof[period] = EMA1.DATA[period];
        Public[period] = EMA2.DATA[period];
    
end

