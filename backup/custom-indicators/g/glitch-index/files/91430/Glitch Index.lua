-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60078
-- Id: 10686

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
    indicator:name("Glitch Index");
    indicator:description("Glitch Index");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("MaPeriod", "MA Period", "MA Period", 30);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
    indicator.parameters:addInteger("ROCPeriod", "ROC Period", "ROC Period", 1);
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Up", "Color of Positiv GlitchIndex", "Color of GlitchIndex", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Color of Negativ GlitchIndex", "Color of GlitchIndex", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local MaPeriod;
local ROCPeriod;
local Method;
local first;
local source = nil;
local MA;
-- Streams block
local GlitchIndex = nil;

-- Routine
function Prepare(nameOnly)
    MaPeriod = instance.parameters.MaPeriod;
    ROCPeriod = instance.parameters.ROCPeriod;
	Method = instance.parameters.Method;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(MaPeriod)  .. ", " .. tostring(Method).. ", " .. tostring(ROCPeriod) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
        MA = core.indicators:create(Method, source, MaPeriod);
        first = MA.DATA:first();
        GlitchIndex = instance:addStream("GlitchIndex", core.Bar, name, "GlitchIndex", instance.parameters.Up, first+ROCPeriod);
    GlitchIndex:setPrecision(math.max(2, instance.source:getPrecision()));
	 
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

       MA:update(mode);  
    if period < first + ROCPeriod then
	return;
	end
	
	
	local rocsma=((MA.DATA[period]-MA.DATA[period-ROCPeriod])*0.1)+1;
	local smamult=MA.DATA[period]*rocsma;
    local diff=source[period]-smamult;
    GlitchIndex[period] = (diff/source[period])*100;
	
	if  GlitchIndex[period] > 0 then
	GlitchIndex:setColor(period,  instance.parameters.Up);
	else
	GlitchIndex:setColor(period,  instance.parameters.Down);
	end
 
end

--rocsma:=(ROC(sma,1,$)*0.1)+1;
--smamult:=sma*rocsma;
--diff:=C-smamult;
--gi:=(diff/C)*100;

