-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73903

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
    indicator:name("Stable Fx");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "", 4, 1, 2000); 
    indicator.parameters:addInteger("CCI_Period", "CCI Period", "", 34, 1, 2000); 

    indicator.parameters:addDouble("c1", "c1", "", 0.5, 0, 2000); 
    indicator.parameters:addDouble("c2", "c2", "", 0.5, 0, 2000);

    indicator.parameters:addInteger("K_Period", "K Period", "", 2, 2, 2000); 
    indicator.parameters:addInteger("D_Period", "D Period", "", 3, 2, 2000); 
    indicator.parameters:addInteger("Signal_Period", "Signal Period", "", 11, 1, 2000); 


    indicator.parameters:addInteger("MA_Period", "MA Period", "", 61, 1, 2000);
	
	indicator.parameters:addString("MA_Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("MA_Method", "LWMA", "LWMA" , "LWMA"); 
    indicator.parameters:addStringAlternative("MA_Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("MA_Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("MA_Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("MA_Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("MA_Method", "WMA", "WMA" , "WMA");	
	
	
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("color3", "3. Line Color", "", core.rgb(0, 0, 255)); 	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil; 
	
-- Routine
 function Prepare(nameOnly)   
 
    Period=instance.parameters.Period;
	CCI_Period=instance.parameters.CCI_Period;
	K_Period=instance.parameters.K_Period;
	D_Period=instance.parameters.D_Period;
	Signal_Period=instance.parameters.Signal_Period;
    MA_Method=instance.parameters.MA_Method;
    MA_Period=instance.parameters.MA_Period;	
	
	c1=instance.parameters.c1;
	c2=instance.parameters.c2;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name()   .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 
	
	CCI= core.indicators:create("CCI", source, CCI_Period);
	Stochastic= core.indicators:create("STOCHASTIC", source, K_Period, D_Period, Signal_Period, "MVA", "MVA");	
	first=math.max(Stochastic.K:first(), CCI.DATA:first())+Period ; 
	
	
	Delta = instance:addInternalStream(0, 0);
	Sum = instance:addInternalStream(0, 0);
	
	
    Line1 = instance:addStream("Line1", core.Line, name, "1. Line", instance.parameters.color1, first+Period );
    Line1:setPrecision(math.max(2, instance.source:getPrecision()));
    Line1:setWidth(instance.parameters.width);
    Line1:setStyle(instance.parameters.style);
    Line1:addLevel(0);	
	
	MA= core.indicators:create(MA_Method, Line1, MA_Period);
	
    Line2 = instance:addStream("Line2", core.Line, name, "2. Line", instance.parameters.color2, first+Period+MA_Period );
    Line2:setPrecision(math.max(2, instance.source:getPrecision()));
    Line2:setWidth(instance.parameters.width);
    Line2:setStyle(instance.parameters.style);
    Line2:addLevel(0);		
	
    Line3 = instance:addStream("Line3", core.Line, name, "3. Line", instance.parameters.color3, first );
    Line3:setPrecision(math.max(2, instance.source:getPrecision()));
    Line3:setWidth(instance.parameters.width);
    Line3:setStyle(instance.parameters.style);
    Line3:addLevel(0); 
end


function Update(period, mode)

	CCI:update(mode); 
	Stochastic:update(mode); 

	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	
	
	Line3[period]= Stochastic.K[period]; 		
   
    Delta[period] = CCI.DATA[period-1 ] * c1 - CCI.DATA[period] * c2
	
	Sum[period]=mathex.sum(Delta, period-Period+1, period);
	
	if period <= first +Period
	then
	return;
	end
	
	local min, max =mathex.minmax(Sum, period-Period+1, period);	
	
 	 
 			
	Line1[period]= min+max; 

	MA:update(mode); 

	if period <= first +Period + MA_Period
	then
	return;
	end	
	
	Line2[period]= MA.DATA[period]; 	
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