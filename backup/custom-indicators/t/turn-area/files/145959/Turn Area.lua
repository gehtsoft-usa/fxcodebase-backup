-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72166

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
    indicator:name("Turn Area");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addString("Method", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
    indicator.parameters:addInteger("Period1", "MA Period", "", 12, 1, 2000);
    indicator.parameters:addInteger("Period2", "RSI Period", "", 21, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	 
	
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255)); 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period1, Period2,Method; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Method=instance.parameters.Method;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Period2  .. "," ..    Method .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	MA= core.indicators:create(Method, source, Period1);	
	RSI= core.indicators:create("RSI", source, Period2);
	first=math.max(RSI.DATA:first(),MA.DATA:first()) ; 
	
	
	--Stream = instance:addInternalStream(0, 0);
 
	
	
    Line = instance:addStream("Line", core.Bar, name, "Line", instance.parameters.color, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision())); 
    Line:addLevel(0);	
 
end


function Update(period, mode)

	  MA:update(mode); 
	  RSI:update(mode); 
	  
	 if period <= first then
	 return;
	 end
	 
	
	
	Line[period]=  ((MA.DATA[period]- (50 - RSI.DATA[period])*source:pipSize())- MA.DATA[period] )/source:pipSize() ;
	
	
end