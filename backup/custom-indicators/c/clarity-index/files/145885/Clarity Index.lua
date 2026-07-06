-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72144

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Clarity Index");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 
  
 	indicator.parameters:addGroup("Calculation"); 
	
	indicator.parameters:addBoolean("Shift", "Ignore Current Candle", "", false);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
    indicator.parameters:addInteger("Lookback", "Lookback Period", "", 14, 1, 2000);
    indicator.parameters:addInteger("Smoothing", "Smoothing Period", "", 14, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255)); 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Lookback, Smoothing,Method; 
local Indicator;
local Shift;	
-- Routine
 function Prepare(nameOnly)   
 
    
	Lookback=instance.parameters.Lookback;
	Smoothing=instance.parameters.Smoothing;
	Method=instance.parameters.Method;
 
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Method.. "," ..  Lookback.. "," ..  Smoothing  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	

	first=source:first() +1; 
	
	if not  instance.parameters.Shift then
	Shift=1;
	else
	Shift=0;
	end
	
	
	bulls = instance:addInternalStream(0, 0);
 	bears = instance:addInternalStream(0, 0);
	pos = instance:addInternalStream(0, 0);
	neg = instance:addInternalStream(0, 0);	
	vi = instance:addInternalStream(0, 0);		
	Indicator= core.indicators:create(Method, vi, Smoothing);	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first+Lookback );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
end


function Update(period, mode)



	 if period <= first then
	 return;
	 end
	 
 
	if source.close[period]>source.close[period-1] then
	bulls[period]=source.high[period]-source.low[period] 
	else
	bulls[period]=0
	end
	
	
 
	if source.close[period]<source.close[period-1] then
	bears[period]=source.high[period]-source.low[period] 
	else
	bears[period]=0
	end
	
	if bulls[period]==0 then
	pos[period]=0;
	else
	pos[period]=1
	end
	
	if bears[period]==0 then
	neg[period]=0;
	else
	neg[period]=1
	end
	
	
     if period <= first+Lookback then
	 return;
	 end

      local  bullsSum = 1;
      local bearsSum = 1;
      local posSum = 1;
      local negSum = 1;
      local volSum = 1;
      local k = 1;
      
      for  k=1,  Lookback-1 , 1  do   
       volSum   = volSum + source.volume[period-k+Shift];
       bullsSum = bullsSum + bulls[period-k+Shift];
       bearsSum = bearsSum + bears[period-k+Shift];
       posSum   =  posSum + pos[period-k+Shift];
       negSum   = negSum +  neg[period-k+Shift];
      end
	  
	  

    local  gain = (volSum/Lookback)*(bullsSum/Lookback)*posSum;
    local loss = (volSum/Lookback)*(bearsSum/Lookback)*negSum;
	  

    vi[period] = gain-loss;
	  
	Indicator:update(mode); 	
	  
	 if period <= Indicator.DATA:first() then
	 return;
	 end
	 
	Line[period]= Indicator.DATA[period];
	
end