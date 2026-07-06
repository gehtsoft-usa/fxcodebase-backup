-- Id: 8708
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32945

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
    indicator:name("Trading Channel Index");
    indicator:description("Trading Channel Index");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("CP", "Channel Period", "Channel Period", 10);
    indicator.parameters:addInteger("AP", "Average Period", "Average Period", 21);
	indicator.parameters:addDouble("Coefficient", "Coefficient", "Coefficient", 0.015);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("TPI_color", "Color of TPI", "Color of TPI", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local CP;
local AP;
local source = nil;
local MA1, MA2, M3;
local Buff1,Buff2;
local Coefficient;
-- Streams block
local TPI = nil;

-- Routine
function Prepare(nameOnly)
    CP = instance.parameters.CP;
    AP = instance.parameters.AP;
	Coefficient = instance.parameters.Coefficient;
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(CP) .. ", " .. tostring(AP) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        MA1 = core.indicators:create("EMA", source, CP);
        Buff1 = instance:addInternalStream(0, 0);
        MA2 = core.indicators:create("EMA", Buff1, CP);
        Buff2 = instance:addInternalStream(0, 0);
        MA3 = core.indicators:create("EMA", Buff2, AP);
       
        TPI = instance:addStream("TPI", core.Line, name, "TPI", instance.parameters.TPI_color, MA3.DATA:first());
    TPI:setPrecision(math.max(2, instance.source:getPrecision()));
		TPI:setWidth(instance.parameters.width);
        TPI:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

MA1:update(mode);
if period < MA1.DATA:first() then
return;
end

Buff1[period]= math.abs( source[period] -  MA1.DATA[period]);

MA2:update(mode);
if period < MA2.DATA:first() then
return;
end

Buff2[period] = (source[period] -  MA1.DATA[period]) / (Coefficient * MA2.DATA[period]);

MA3:update(mode);
if period < MA3.DATA:first() then
return;
end
 	
        TPI[period] = MA3.DATA[period];
   
end

