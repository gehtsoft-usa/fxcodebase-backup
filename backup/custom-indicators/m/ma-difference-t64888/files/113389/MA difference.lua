-- Id: 18621
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64888

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
    indicator:name("MA difference");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	indicator.parameters:addGroup("Selector");	
	indicator.parameters:addBoolean("S1", "Show Difference Line", "", true);
	indicator.parameters:addBoolean("S2", "Show Signal Line", "", true);
	
	indicator.parameters:addBoolean("S3", "Show Second Line", "", true);
 
	
    indicator.parameters:addGroup("1. Difference Calculation");	
    indicator.parameters:addInteger("length11", "1. MA Period", "Period", 10, 1, 2000);
	indicator.parameters:addString("Method11", "1. MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method11", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method11", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method11", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method11", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method11", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method11", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method11", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method11", "WMA", "WMA" , "WMA");
	
    indicator.parameters:addInteger("length12", "2. MA Period", "Period", 10, 1, 2000);
	
	indicator.parameters:addString("Method12", "2. MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method12", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method12", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method12", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method12", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method12", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method12", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method12", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method12", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("length1", "1. Difference Smoothing Period", "Period", 10, 1, 2000);
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	
	
    indicator.parameters:addGroup("2. Difference Calculation");	
    indicator.parameters:addInteger("length21", "1. MA Period", "Period", 34, 1, 2000);
	
	indicator.parameters:addString("Method21", "1. MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method21", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method21", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method21", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method21", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method21", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method21", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method21", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method21", "WMA", "WMA" , "WMA");
	
	
    indicator.parameters:addInteger("length22", "2. MA Period", "Period", 34, 1, 2000);
	indicator.parameters:addString("Method22", "2. MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method22", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method22", "EMA", "EMA" , "EMA");
   indicator.parameters:addStringAlternative("Method22", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method22", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method22", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method22", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method22", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method22", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addInteger("length2", "2. Difference Smoothing Period", "Period", 10, 1, 2000);
	
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addColor("color1", "1. Line Color", "Line Color", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	
 
    indicator.parameters:addColor("color2", "2. Line Color", "Line Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("Signal Line Style");	
    indicator.parameters:addColor("color3", "1. Signal Line Color", "Line Color", core.rgb(0, 255, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
	
 
    indicator.parameters:addColor("color4", "2. Signal Line Color", "Line Color", core.rgb(255, 0, 255));
	indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);
	

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local MA11;
local MA12;
local MA21;
local MA22;
local source = nil;
local first;

local MA1, MA2;

local difference1;
local difference2;
local signal1;
local signal2;

local S1, S2, S3;
-- Routine
function Prepare(nameOnly)
    length = instance.parameters.length;
	S1 = instance.parameters.S1;
	S2 = instance.parameters.S2;
	S3 = instance.parameters.S3;
	 
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(instance.parameters.length11).. ", " .. tostring(instance.parameters.length12) 
	.. ", " .. tostring(instance.parameters.length21) .. ", " .. tostring(instance.parameters.length22) .. ")";
    instance:name(name);

    if (not (nameOnly)) then

    assert(core.indicators:findIndicator(instance.parameters.Method11) ~= nil, instance.parameters.Method11 .. " indicator must be installed");
        MA11 = core.indicators:create(instance.parameters.Method11, source,instance.parameters.length11 );
    assert(core.indicators:findIndicator(instance.parameters.Method12) ~= nil, instance.parameters.Method12 .. " indicator must be installed");
        MA12 = core.indicators:create(instance.parameters.Method12, source,instance.parameters.length12 );
    assert(core.indicators:findIndicator(instance.parameters.Method21) ~= nil, instance.parameters.Method21 .. " indicator must be installed");
        MA21 = core.indicators:create(instance.parameters.Method21, source,instance.parameters.length21 );
    assert(core.indicators:findIndicator(instance.parameters.Method22) ~= nil, instance.parameters.Method22 .. " indicator must be installed");
        MA22 = core.indicators:create(instance.parameters.Method22, source,instance.parameters.length22 );
        first = math.max(MA11.DATA:first(),MA12.DATA:first(),MA21.DATA:first(),MA22.DATA:first());
        
	
	    if S1 then
        difference1 = instance:addStream("difference1", core.Line, name .. ".difference1", "difference1", instance.parameters.color1, first);
    difference1:setPrecision(math.max(2, instance.source:getPrecision()));
		difference1:setWidth(instance.parameters.width1);
        difference1:setStyle(instance.parameters.style1);
		
			if S3 then
			difference2 = instance:addStream("difference2", core.Line, name .. ".difference2", "difference2", instance.parameters.color2, first);
    difference2:setPrecision(math.max(2, instance.source:getPrecision()));
			difference2:setWidth(instance.parameters.width2);
			difference2:setStyle(instance.parameters.style2);
			else
			difference2 = instance:addInternalStream(0, 0);
			end
		
		else
		difference1 = instance:addInternalStream(0, 0);
		difference2 = instance:addInternalStream(0, 0);
		end
		
		
    assert(core.indicators:findIndicator(instance.parameters.Method1) ~= nil, instance.parameters.Method1 .. " indicator must be installed");
		MA1 = core.indicators:create(instance.parameters.Method1, difference1,instance.parameters.length1 );
    assert(core.indicators:findIndicator(instance.parameters.Method2) ~= nil, instance.parameters.Method2 .. " indicator must be installed");
	    MA2 = core.indicators:create(instance.parameters.Method2, difference2,instance.parameters.length2 );
		
		if  S2 then
		
		signal1 = instance:addStream("signal1", core.Line, name .. ".signa11", "signal1", instance.parameters.color2, MA1.DATA:first());
    signal1:setPrecision(math.max(2, instance.source:getPrecision()));
		signal1:setWidth(instance.parameters.width3);
        signal1:setStyle(instance.parameters.style3);
		
		
				if S3 then
				
				signal2 = instance:addStream("signal2", core.Line, name .. ".signal2", "signal2", instance.parameters.color4, MA2.DATA:first());
    signal2:setPrecision(math.max(2, instance.source:getPrecision()));
				signal2:setWidth(instance.parameters.width4);
				signal2:setStyle(instance.parameters.style4);
				
				else
				signal2 = instance:addInternalStream(0, 0);
				end
				
		
		else
		
		signal1 = instance:addInternalStream(0, 0);
		signal2 = instance:addInternalStream(0, 0);
		end
		
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)


       MA11:update(mode);
	   MA12:update(mode);
	   MA21:update(mode);
	   MA22:update(mode);
	
	
    if period < first then
	return;
	end
	
	difference1[period]=MA11.DATA[period]-MA12.DATA[period];
	difference2[period]=MA21.DATA[period]-MA22.DATA[period];
	
	MA1:update(mode);
	MA2:update(mode);
	
	if period > MA1.DATA:first() then
	signal1[period]= MA1.DATA[period]
	end
	
	if period > MA2.DATA:first() then
	signal2[period]= MA2.DATA[period]
	end
end

