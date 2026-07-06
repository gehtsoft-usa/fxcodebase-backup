-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72158

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
    indicator:name("Ultimate Moving Average");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");

	
    indicator.parameters:addInteger("fastperiod", "Fast MA", "", 5, 1, 2000);
    indicator.parameters:addInteger("middleperiod", "Middle Period", "", 34, 1, 2000);
    indicator.parameters:addInteger("slowperiod", "Slow MA", "", 55, 1, 2000);	
	
    indicator.parameters:addInteger("fastK", "Fast Multiplier", "", 4, 1, 2000);
    indicator.parameters:addInteger("middleK", "Middle Multiplier", "", 2, 1, 2000);
    indicator.parameters:addInteger("slowK", "Slow Multiplier", "", 1, 1, 2000);		
 
	
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
local fastperiod, middleperiod,slowperiod ; 
local fastperiod, middleperiod,slowperiod ; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	fastperiod=instance.parameters.fastperiod;
	middleperiod=instance.parameters.middleperiod;
	slowperiod=instance.parameters.slowperiod;	
	fastK=instance.parameters.fastK;
	middleK=instance.parameters.middleK;
	slowK=instance.parameters.slowK;	
	Method=instance.parameters.Method;
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Method.. "," ..  fastperiod.. "," ..  middleperiod.. "," ..  slowperiod .. "," ..  fastK.. "," ..  middleK.. "," ..  slowK  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
	BPBuffer = instance:addInternalStream(0, 0);
	
	ATR1= core.indicators:create("ATR", source, fastperiod);
	ATR2= core.indicators:create("ATR", source, middleperiod);
	ATR3= core.indicators:create("ATR", source, slowperiod);	
	
	MA1= core.indicators:create(Method, BPBuffer, fastperiod);
	MA2= core.indicators:create(Method, BPBuffer, middleperiod);
	MA3= core.indicators:create(Method, BPBuffer, slowperiod);	
	first=math.max(ATR1.DATA:first(), ATR2.DATA:first(), ATR3.DATA:first()) ; 
	
	

 
	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
end


function Update(period, mode)

 

    BPBuffer[period]=(2*((source.open[period]+source.close[period])/2)+( (source.high[period]+source.low[period])/2))/3;
	
	ATR1:update(mode); 
	ATR2:update(mode); 
	ATR3:update(mode); 	
	
	MA1:update(mode); 
	MA2:update(mode); 
	MA3:update(mode); 	
 
	 if period <= first then
	 return;
	 end
	
		
	
	
	local RawUO=(fastK+3*ATR1.DATA[period])*MA1.DATA[period]
            +(middleK+3*ATR2.DATA[period])*MA2.DATA[period]
            +(slowK+3*ATR3.DATA[period])*MA3.DATA[period]
            
    local  divider=(fastK+3*ATR1.DATA[period])+(middleK+3*ATR2.DATA[period])+(slowK+3*ATR3.DATA[period]);
	  
	   
	Line[period]=   RawUO/divider; 
	
end