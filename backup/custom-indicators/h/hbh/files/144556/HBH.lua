-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71741

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--Your donations will allow the service to continue onward.
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



-- Indicator profile initialization routine

function Init()
    indicator:name("HBH");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("replaceSource", "t");
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 15, 1, 2000); 
    indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA"); 
	
 
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down color", "", core.rgb(255, 0, 0));	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period,Method; 
local first;
local source = nil;
 
local Oscillator; 
-- Routine
 function Prepare(nameOnly)   
 
 
    Period= instance.parameters.Period;
    Method= instance.parameters.Method;
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	
	local Parameters= Period..", "..Method;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
		
    source = instance.source; 
    first=source:first()+Period;
	Open = core.indicators:create(Method, source.open, Period);
	Close = core.indicators:create(Method, source.close, Period);
	High = core.indicators:create(Method, source.high, Period);
	Low = core.indicators:create(Method, source.low, Period);   
 
	
	open = instance:addStream("Open" , core.Line, " Open"," Open", core.COLOR_LABEL, first);
	high = instance:addStream("High" , core.Line, " High"," High", core.COLOR_LABEL, first);
	low = instance:addStream("Low" , core.Line, " Low"," Low", core.COLOR_LABEL, first);
	close = instance:addStream("Close" , core.Line, " Close"," Close", core.COLOR_LABEL, first);

	open:setPrecision(math.max(2, source:getPrecision()));
	high:setPrecision(math.max(2, source:getPrecision()));
	low:setPrecision(math.max(2, source:getPrecision()));
	close:setPrecision(math.max(2, source:getPrecision()));	


    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);	
end

-- Indicator calculation routine
function Update(period, mode)
    Close:update(mode);
    Open:update(mode);
    High:update(mode);
    Low:update(mode);
	
	if period < first
	then
	return;
	end
 


    open[period]= (open[period-1]+close[period-1])/2;
    close[period]= (Open.DATA[period]+Close.DATA[period]+High.DATA[period]+Low.DATA[period])/4;
	high[period]=math.max(High.DATA[period] , math.max(open[period], close[period]));
	low[period]=math.min(Low.DATA[period], math.min(open[period], close[period]));
	
	
	if close[period]>  open[period] then
	open:setColor(period, Up );			
	else
	open:setColor(period, Down  );			
    end
		
 
				  
end
