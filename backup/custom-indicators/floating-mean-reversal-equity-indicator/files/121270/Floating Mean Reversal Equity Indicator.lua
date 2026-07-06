-- Id: 22338
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66672

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

function Init()
    indicator:name("Floating Mean Reversal Equity Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("MA Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 20, 1, 2000);
 
 
	indicator.parameters:addString("Method", "MA Method", "Method" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	
     indicator.parameters:addBoolean("ShowSource", "Show Source", "", true);	
 
	indicator.parameters:addGroup("Style"); 	
	
    indicator.parameters:addColor("color3", "Long Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_DOT);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 1, 1, 5);
	
	
	indicator.parameters:addColor("color4", "Short Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style4", "Line Style", "", core.LINE_DOT);
    indicator.parameters:setFlag("style4", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width4", "Line Width", "", 1, 1, 5);
	
	
    indicator.parameters:addColor("color1", "Long Average Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addColor("color2", "Short Average Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Method,ShowSource;
 
local first;
local source = nil;
local LongIndicator,ShortIndicator;
local LongData, ShortData; 
local LongDataSum, ShortDataSum; 
local ShortOscillator;  
local LongOscillator;  
 

-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    Period= instance.parameters.Period;
    Method= instance.parameters.Method;
	ShowSource= instance.parameters.ShowSource;
			
    source = instance.source;
    first= source:first()+1;	
    
    LongData = instance:addInternalStream(0, 0);
	ShortData = instance:addInternalStream(0, 0);
	
	if ShowSource then
	LongDataSum = instance:addStream("Long" , core.Line, "Long","Long",instance.parameters.color3, first +Period);
	LongDataSum:setWidth(instance.parameters.width3);
    LongDataSum:setStyle(instance.parameters.style3);
	
	
	ShortDataSum = instance:addStream("Short" , core.Line, "Short","Short",instance.parameters.color4, first +Period);
	ShortDataSum:setWidth(instance.parameters.width4);
    ShortDataSum:setStyle(instance.parameters.style4);	
	else
	LongDataSum = instance:addInternalStream(0, 0);
	ShortDataSum = instance:addInternalStream(0, 0);
	end
	
	LongDataSum:setPrecision(math.max(2, source:getPrecision()));
	ShortDataSum:setPrecision(math.max(2, source:getPrecision()));	
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
    LongIndicator = core.indicators:create(Method, LongDataSum, Period);
	ShortIndicator = core.indicators:create(Method, ShortDataSum, Period);
    

	
	 
   
 
	LongOscillator = instance:addStream("LongAverage" , core.Line, "Long Average","Long Average",instance.parameters.color1, LongIndicator.DATA:first() );
	LongOscillator:setWidth(instance.parameters.width1);
    LongOscillator:setStyle(instance.parameters.style1);
	
	
	ShortOscillator = instance:addStream("ShortAverage" , core.Line, "Short Average","Short Average",instance.parameters.color2, LongIndicator.DATA:first() );
	ShortOscillator:setWidth(instance.parameters.width2);
    ShortOscillator:setStyle(instance.parameters.style2);
    
	LongOscillator:setPrecision(math.max(2, source:getPrecision()));
	ShortOscillator:setPrecision(math.max(2, source:getPrecision()));
	
end

-- Indicator calculation routine
function Update(period, mode)


    LongData[period]=0;
	ShortData[period]=0;
	
	if period<=  first  then
    return;
    end
	
    if source.close[period-1] < source.open[period-1] then	
	LongData[period]=(source.close[period] - source.open[period]);
	elseif source.close[period-1] > source.open[period-1] then	
	ShortData[period]=(source.open[period] - source.close[period]);
    end  
				  
				  
				  
	if  period <= first +Period  then
    return;
    end
	
	
	LongDataSum[period]= mathex.sum(LongData, period-1-Period+1, period-1);
	ShortDataSum[period]= mathex.sum(ShortData, period-1-Period+1, period-1);
	
 
    LongIndicator:update(mode);
	ShortIndicator:update(mode);
	
	 
    if period <= LongIndicator.DATA:first() then
	return;
	end
	
	
	LongOscillator[period]= LongIndicator.DATA[period];
	ShortOscillator[period]= ShortIndicator.DATA[period];
	 
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



 