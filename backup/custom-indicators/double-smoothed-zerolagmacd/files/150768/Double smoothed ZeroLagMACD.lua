-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=73700

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Double smoothed Zero Lag MACD");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("1. Calculation");		
	indicator.parameters:addString("Method1", "MA Method (first segment)", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");	
	
    indicator.parameters:addInteger("FMA1", "Fast MA periods (first segment)", "", 12, 1, 5000);
    indicator.parameters:addInteger("SMA1", "Slow MA Periods (first segment)", "", 24, 1, 5000);
	
	
    indicator.parameters:addGroup("2. Calculation");		
	indicator.parameters:addString("Method2", "MA Method (second segment)", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");	
	
    indicator.parameters:addInteger("FMA2", "Fast MA periods (second segment)", "", 12, 1, 5000);
    indicator.parameters:addInteger("SMA2", "Slow MA Periods (second segment) ", "", 24, 1, 5000);
	
    indicator.parameters:addGroup("3. Calculation");		
	indicator.parameters:addString("Method3", "Double smoothed MA Method (second segment)", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");	
	
	
    indicator.parameters:addInteger("FMA3", "Double smoothed Fast MA periods (second segment)", "", 12, 1, 5000);
    indicator.parameters:addInteger("SMA3", "Double smoothed Slow MA Periods (second segment)", "", 24, 1, 5000);
	
	indicator.parameters:addString("Method4", "Signal Line MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method4", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method4", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method4", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method4", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method4", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method4", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method4", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method4", "WMA", "WMA" , "WMA");		
	
	indicator.parameters:addString("Method5", "Signal Line MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method5", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method5", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method5", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method5", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method5", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method5", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method5", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method5", "WMA", "WMA" , "WMA");		

	indicator.parameters:addString("Method6", "Signal Line MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method6", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method6", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method6", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method6", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method6", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method6", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method6", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method6", "WMA", "WMA" , "WMA");		

	
    indicator.parameters:addInteger("SigMA1", "Signal MA periods  (first segment) ", "", 9, 1, 5000);
    indicator.parameters:addInteger("SigMA2", "Signal MA periods  (second segment)", "", 18, 1, 5000);	
    indicator.parameters:addInteger("SigMA3", "Double smoothed Signal MA periods  (second segment)", "", 18, 1, 5000);	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MACD_color", "Color of MACD", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("SIG_color", "Color of Signal", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("HIS_color_Up", "Color of Historgram Up", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("HIS_color_Down", "Color of Historgram Down", "", core.rgb(255,0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local FMA;
local SMA;
local SigMA;

local FMA_I;
local SMA_I;
local FMA_I2;
local SMA_I2;
local SigMA_I;
local SigMA_I2;
local FMA_I3;
local SMA_I4;
local firstMACD, firstSIG;
local source = nil;

-- Streams block
local MACD = nil;
local SIG = nil;
local HIS = nil;

-- Routine
function Prepare(nameOnly)
    Method1 = instance.parameters.Method1;
    FMA1 = instance.parameters.FMA1;
    SMA1 = instance.parameters.SMA1;
	Method2 = instance.parameters.Method2;
    FMA2 = instance.parameters.FMA2;
    SMA2 = instance.parameters.SMA2;
	Method3 = instance.parameters.Method3;	
    FMA3 = instance.parameters.FMA3;
    SMA3 = instance.parameters.SMA3;	
	Method4 = instance.parameters.Method4;
	Method5 = instance.parameters.Method5;
	Method6 = instance.parameters.Method6;	
    SigMA1 = instance.parameters.SigMA1;
    SigMA2 = instance.parameters.SigMA2;
    SigMA3 = instance.parameters.SigMA3;	
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. Method1 .. ", " .. FMA1 .. ", " .. SMA1 .. ", " .. Method2 .. ", " .. FMA2 .. ", " .. SMA2  .. ", " .. Method3.. ", " .. FMA3 .. ", " .. SMA3 .. ", " .. Method4 .. ", " .. Method5.. ", " .. Method5.. ", " .. SigMA1.. ", " .. SigMA2.. ", " .. SigMA3 .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    FMA_I = core.indicators:create(Method1, source, FMA1);
    SMA_I = core.indicators:create(Method1, source, SMA1);
    FMA_I2 = core.indicators:create(Method2, FMA_I.DATA, FMA2);
    SMA_I2 = core.indicators:create(Method2, SMA_I.DATA, SMA2);
	
    FMA_I3 = core.indicators:create(Method3, FMA_I2.DATA, FMA3);
    SMA_I3 = core.indicators:create(Method3, SMA_I2.DATA, SMA3);
	

    firstMACD = math.max(FMA_I3.DATA:first(), SMA_I3.DATA:first());

    MACD = instance:addStream("MACD", core.Line, name .. ".MACD", "MACD", instance.parameters.MACD_color, firstMACD);
	
    MACD:setWidth(instance.parameters.width1);
    MACD:setStyle(instance.parameters.style1);
    SigMA_I = core.indicators:create(Method4, MACD, SigMA1);
    SigMA_I2 = core.indicators:create(Method5, SigMA_I.DATA, SigMA2);
    SigMA_I3 = core.indicators:create(Method6, SigMA_I2.DATA, SigMA3);
    firstSIG = SigMA_I3.DATA:first();
    SIG = instance:addStream("SIG", core.Line, name .. ".SIG", "SIG", instance.parameters.SIG_color, firstSIG);
	SIG:setWidth(instance.parameters.width2);
    SIG:setStyle(instance.parameters.style2);
    HIS = instance:addStream("HISTOGRAM", core.Bar, name .. ".HIS", "HIS", instance.parameters.HIS_color_Up, firstSIG);
	
	
	MACD:setPrecision(math.max(2, source:getPrecision()));
	SIG:setPrecision(math.max(2, source:getPrecision()));
	HIS:setPrecision(math.max(2, source:getPrecision()));

end

-- Indicator calculation routine
function Update(period, mode)
    FMA_I:update(mode);
    SMA_I:update(mode);	
    FMA_I2:update(mode);
    SMA_I2:update(mode);
    FMA_I3:update(mode);
    SMA_I3:update(mode);	

    if period < firstMACD then
	return;
	end
        MACD[period] = (2 * FMA_I.DATA[period] - FMA_I3.DATA[period]) -
                       (2 * SMA_I.DATA[period] - SMA_I3.DATA[period]);
   

    SigMA_I:update(mode);
    SigMA_I2:update(mode);
    SigMA_I3:update(mode);
	
    if period < firstSIG then 
	return;
	end
	
        SIG[period] = 2 * SigMA_I.DATA[period] - SigMA_I3.DATA[period];
        HIS[period] = MACD[period] - SIG[period];
		
		if HIS[period] > 0 then
		HIS:setColor(period,  instance.parameters.HIS_color_Up);
		else		
		HIS:setColor(period,  instance.parameters.HIS_color_Down);
		end
    
end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+
