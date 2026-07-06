-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73220

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
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("VQ bars");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period", "Period", "", 5, 1, 1000);
	indicator.parameters:addInteger("Smoothing", "Smoothing", "", 1, 0, 1000);	
	indicator.parameters:addInteger("Filter", "Filter", "", 5, 0, 1000);
	
	indicator.parameters:addBoolean("Steady", "Steady", "", false); 
 
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
	indicator.parameters:addColor("Neutral", "Neutral color", "", core.rgb(0, 0, 255));
	
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Up,Down, Neutral;
local first;
local source = nil;
 

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;
 

 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end


    Up = instance.parameters.Up;
    Down= instance.parameters.Down;
    Neutral= instance.parameters.Neutral;
   
    Period = instance.parameters.Period;
	Method= instance.parameters.Method;
	Smoothing= instance.parameters.Smoothing;
	Filter= instance.parameters.Filter; 
	Steady= instance.parameters.Steady;

	source = instance.source;
	
	
	
		Open=core.indicators:create(Method,  source.open, Period);
		High=core.indicators:create(Method,  source.high, Period);
		Low=core.indicators:create(Method,  source.low, Period);
		
		if Steady then
		Close=core.indicators:create(Method,  source.median, Period); 
		else
		Close=core.indicators:create(Method,  source.close, Period); 
		end
   
    Signal = instance:addInternalStream(0, 0);	
	VQ = instance:addInternalStream(0, 0);	
	
	first= source:first()+Period+Smoothing;

    	
	open = instance:addStream("openup", core.Line, name, "", Up, first);
    high = instance:addStream("highup", core.Line, name, "", Up, first);
    low = instance:addStream("lowup", core.Line, name, "", Up, first);
    close = instance:addStream("closeup", core.Line, name, "", Up, first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
		
end

-- Indicator calculation routine
function Update(period, mode)
	
    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
	
	
			Open:update(mode);
			High:update(mode);
			Low:update(mode);
			Close:update(mode);		
	
			if period <= first
			or not source:hasData(period)
			then
			open:setColor(period, Neutral);	
			return;
			end
	
 
	VQ[period]=VQ[period-1] + math.abs(((Close.DATA[period] - Close.DATA[period-Smoothing])/
	          math.max(High.DATA[period] - Low.DATA[period], math.max(High.DATA[period] -  Close.DATA[period-Smoothing],  Close.DATA[period-Smoothing] - Low.DATA[period])) +
			  (Close.DATA[period] - Open.DATA[period])/(High.DATA[period] - Low.DATA[period])) * 0.5) * 
			  ((Close.DATA[period] -  Close.DATA[period-Smoothing] + (Close.DATA[period] - Open.DATA[period])) * 0.5);
			  
 
      if (Filter > 0) then
	                  if (math.abs(VQ[period] - VQ[period- 1]) < Filter * source:pipSize()) then VQ[period]=VQ[period-1]; end
	  end
	  
			  
		   
 
      if (VQ[period] > VQ[period-1]) then Signal[period]=1; end
	  if (VQ[period] < VQ[period-1]) then Signal[period]=-1; end 
	  if (VQ[period] == VQ[period-1]) then Signal[period]=Signal[period-1]; end 
 
		
    if Signal[period]== 1 then
    open:setColor(period, Up);			
    elseif Signal[period]== -1 then
    open:setColor(period, Down);	
    else
    open:setColor(period, Neutral);		
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