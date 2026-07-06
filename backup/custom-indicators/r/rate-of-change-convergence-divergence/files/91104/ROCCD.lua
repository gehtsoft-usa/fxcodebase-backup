-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59969
-- Id: 10508

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
    indicator:name("Rate of Change Convergence-Divergence");
    indicator:description("Rate of Change Convergence-Divergence");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("RocPeriod", "ROC Period", "ROC Period", 14);
    indicator.parameters:addInteger("MaPeriod", "MA Period", "MA Period", 14);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Selector");
	indicator.parameters:addBoolean("S1", "Show ROC Line", "", true);
    indicator.parameters:addBoolean("S2", "Show Signal Line", "", true);
	indicator.parameters:addBoolean("S3", "Show Histogram", "", true);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("ROC_color", "Color of ROC", "Color of ROC", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("MA_color", "Color of MA", "Color of MA", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
    indicator.parameters:addColor("Up", "Color of Up Histogram", "Color of Histogram", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Down", "Color of Down Histogram", "Color of Histogram", core.rgb(128, 128, 128));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local RocPeriod;
local MaPeriod;
local Method;
local first;
local source = nil;
local S1, S2, S3;
-- Streams block
local ROC = nil;
local MA = nil;
local Histogram = nil;
local roc, ma;
-- Routine
function Prepare(nameOnly)
    RocPeriod = instance.parameters.RocPeriod;
	Method = instance.parameters.Method;
    MaPeriod = instance.parameters.MaPeriod;
	S1= instance.parameters.S1;
	S2= instance.parameters.S2;
	S3= instance.parameters.S3;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(RocPeriod) .. ", " .. tostring(MaPeriod) .. ", " .. tostring(Method) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
		roc = core.indicators:create("ROC", source, RocPeriod);
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
		ma = core.indicators:create(Method, roc.DATA, MaPeriod);
		
		first = ma.DATA:first();
	    if S1 then
        ROC = instance:addStream("ROC", core.Line, name .. ".ROC", "ROC", instance.parameters.ROC_color, roc.DATA:first());
    ROC:setPrecision(math.max(2, instance.source:getPrecision()));
		ROC:setWidth(instance.parameters.width1);
        ROC:setStyle(instance.parameters.style1);
		else
		ROC = instance:addInternalStream(0, 0);
		end
		if S2 then
        MA = instance:addStream("MA", core.Line, name .. ".MA", "MA", instance.parameters.MA_color, ma.DATA:first());
    MA:setPrecision(math.max(2, instance.source:getPrecision()));
		MA:setWidth(instance.parameters.width2);
        MA:setStyle(instance.parameters.style2);
		else
		MA = instance:addInternalStream(0, 0);
		end
		if S3 then
        Histogram = instance:addStream("Histogram", core.Bar, name .. ".Histogram", "Histogram", instance.parameters.Up, first);
    Histogram:setPrecision(math.max(2, instance.source:getPrecision()));
		else
		Histogram = instance:addInternalStream(0, 0);
		end
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    roc:update(mode);
		
	if period < roc.DATA:first()  then
	return;
	end
	
	ROC[period] = roc.DATA[period];
	
	ma:update(mode);
	
	if period < ma.DATA:first()  then
	return;
	end
	
    MA[period] = ma.DATA[period];
	
    if period < first  then
	return;
	end
       
     Histogram[period] = roc.DATA[period]-ma.DATA[period];
	 
	 if Histogram[period] > 0 then
	 
	 Histogram:setColor(period, instance.parameters.Up);
     else
	  Histogram:setColor(period, instance.parameters.Down);
	 end
    
end

