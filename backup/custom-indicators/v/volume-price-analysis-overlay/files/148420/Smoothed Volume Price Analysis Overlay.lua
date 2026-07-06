-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72959

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Smoothed Volume Price Analysis Overlay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calcation");	
 	indicator.parameters:addInteger("Period1", "1. Volume Period", "", 1, 1, 1000);
 	indicator.parameters:addInteger("Period2", "2. Volume Period", "", 14, 1, 1000);	 
	 
	indicator.parameters:addInteger("Period3", "1. Price Period", "", 1, 1, 1000);
 	indicator.parameters:addInteger("Period4", "2. Price Period", "", 14, 1, 1000);	 
    indicator.parameters:addBoolean("CurrentCandle", "Current candle", "", true);	 
	 
    indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	

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
 	 indicator.parameters:addColor("U", "Strong Up Color", "", core.rgb(0, 255, 0)); 
 	 indicator.parameters:addColor("WU", "Weak Up Color", "", core.rgb(0, 100, 0))
 	 indicator.parameters:addColor("D", "Strong Down Color", "", core.rgb(255, 0, 0)); 
 	 indicator.parameters:addColor("WD", "Weak Down Color", "", core.rgb(255, 0, 0))	 

 
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

 
local first;
local source = nil;
local CurrentCandle,Period1,Period2,Period3,Period4, Shift,Price, Method; 
 

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;
  
 function Prepare(nameOnly)   
 
 
 
    Period1=instance.parameters.Period1;
    Period2=instance.parameters.Period2;	
    Period3=instance.parameters.Period3;
    Period4=instance.parameters.Period4;		
	Price=instance.parameters.Price;
	Method=instance.parameters.Method;
 
    local name = profile:id() .. "(" ..  instance.source:name() .. ", " .. Period1.. ", " .. Period2.. ", " .. Period3.. ", " .. Period4   .. ", " .. Price.. ", " .. Method .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
	source = instance.source;	
	
	Volume1 = core.indicators:create(Method, source.volume, Period1);
	Volume2 = core.indicators:create(Method, source.volume, Period2);

	Price1 = core.indicators:create(Method, source[Price], Period3);
	Price2 = core.indicators:create(Method, source[Price], Period4);
	
	if CurrentCandle then
	first=math.max(Volume1.DATA:first(),Volume2.DATA:first(),Price1.DATA:first(),Price2.DATA:first());		
	Shift=0;
	else
	first=math.max(Volume1.DATA:first(),Volume2.DATA:first())+1;
	Shift=1;
	end
	

    	
	open = instance:addStream("openup", core.Line, name, "",  instance.parameters.U, first);
    high = instance:addStream("highup", core.Line, name, "",  instance.parameters.U, first);
    low = instance:addStream("lowup", core.Line, name, "",  instance.parameters.U, first);
    close = instance:addStream("closeup", core.Line, name, "" ,instance.parameters.U, first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
		
end

-- Indicator calculation routine
function Update(period, mode)
	
    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
	Volume1:update(mode);
	Volume2:update(mode);
	
	Price1:update(mode);
	Price2:update(mode);	
	
	        if period <= first then
			open:setColor(period, core.rgb(128, 128, 128));	
			return;
			end
	
 
 
		
		
 
		if Price1.DATA[period]> Price2.DATA[period-1-Shift] then	 
			if Volume1.DATA[period]>= Volume2.DATA[period-1-Shift] then
			open:setColor(period,instance.parameters.U);	   
			else
			open:setColor(period,instance.parameters.WU);
			end		
		else	
			if Volume1.DATA[period]>= Volume2.DATA[period-1-Shift] then
			open:setColor(period,instance.parameters.D);	   
			else
			open:setColor(period,instance.parameters.WD);
			end		
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