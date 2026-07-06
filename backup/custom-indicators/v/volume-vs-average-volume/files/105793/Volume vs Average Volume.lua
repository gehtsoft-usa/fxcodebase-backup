-- Id: 15869
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63377

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
function Init()
    indicator:name("Volume vs Average Volume");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period1", "Period", "", 14, 2, 1000);
    indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Secondary Smoothing");
	indicator.parameters:addBoolean("Use" , "Use Secondary Smoothing", "", false);	
    indicator.parameters:addInteger("Period2", "Period", "", 14, 2, 1000);
    indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	 	
end

-- Indicator instance initialization routine

-- Parameters block
local MA;
local source = nil;
local first;
local Method1;
local Period1;
local Method2;
local Period2;
local Delta;
local Use;
local Raw;
-- Routine
function Prepare(nameOnly) 
    Method1 = instance.parameters.Method1;
    Period1 = instance.parameters.Period1;
	Method2 = instance.parameters.Method2;
    Period2 = instance.parameters.Period2;
	Use= instance.parameters.Use;
    source = instance.source;
	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. Method1 .. ", " .. Period1.. ", " .. Method2 .. ", " .. Period2 .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
    MA1 = core.indicators:create(Method1, source.volume, Period1); 
    Raw = instance:addInternalStream(MA1.DATA:first(), 0);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
    MA2 = core.indicators:create(Method2,Raw, Period2);    	
    first = math.max(MA1.DATA:first(), MA2.DATA:first());
	
    
    Delta = instance:addStream("Delta", core.Bar, name .. ".Delta", "Delta", instance.parameters.Up, first); 
	Delta:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
function Update(period, mode)
     
    MA1:update(mode);
    MA2:update(mode);

    if (period < first) then
    return;
    end

	 Raw[period]=source.volume[period]-MA1.DATA[period];
    
	 if Use then
	 Delta[period]= MA2.DATA[period];
	 else
     Delta[period]= Raw[period];
	 end
	 
	 
     if Delta[period]> Delta[period-1] then
	 Delta:setColor(period, instance.parameters.Up);
	 else
	 Delta:setColor(period, instance.parameters.Down);
	 end
	 
end


