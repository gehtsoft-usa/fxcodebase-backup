-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73005

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
    indicator:name("Displaced Moving Average Channel ");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("1. MA Calculation");	
    indicator.parameters:addInteger("Period1", "Period", "", 6, 1, 2000);
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");	
	
    indicator.parameters:addInteger("Shift1", "Shift", "", 3  );
	
 	indicator.parameters:addGroup("2. MA Calculation");	
    indicator.parameters:addInteger("Period2", "Period", "", 12, 1, 2000);
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");	
	
    indicator.parameters:addInteger("Shift2", "Shift", "", 6  );


 	indicator.parameters:addGroup("3. MA Calculation");	
    indicator.parameters:addInteger("Period3", "Period", "", 24, 1, 2000);
	indicator.parameters:addString("Method3", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");	
	
    indicator.parameters:addInteger("Shift3", "Shift", "", 12  );	
	
	 indicator.parameters:addGroup("1. Line Style");	
    indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0)); 
 
	 indicator.parameters:addGroup("2. Line Style");	
    indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 128, 0)); 


	 indicator.parameters:addGroup("3. Line Style");	
    indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color3", "Line Color", "", core.rgb(255, 0, 0)); 	
	
 
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
 
    
	Period1=instance.parameters.Period1;
	Method1=instance.parameters.Method1;
	Shift1=instance.parameters.Shift1; 
	
	Period2=instance.parameters.Period2;
	Method2=instance.parameters.Method2;
	Shift2=instance.parameters.Shift2; 

	Period3=instance.parameters.Period3;
	Method3=instance.parameters.Method3;
	Shift3=instance.parameters.Shift3; 	
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Method1.. "," ..  Shift1 .. "," ..  Period2.. "," ..  Method2.. "," ..  Shift2.. "," ..  Period3.. "," ..  Method3.. "," ..  Shift3  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	ma1= core.indicators:create(Method1, source, Period1);
	ma2= core.indicators:create(Method2, source, Period2);
	ma3= core.indicators:create(Method3, source, Period3);	
	first=math.max(ma1.DATA:first(), ma2.DATA:first(), ma3.DATA:first()) ; 
	
 
 
	
	
    MA1 = instance:addStream("MA1", core.Line, name, "MA1", instance.parameters.color1, first,Shift1  );
    MA1:setPrecision(math.max(2, instance.source:getPrecision()));
    MA1:setWidth(instance.parameters.width1);
    MA1:setStyle(instance.parameters.style1); 

    MA2 = instance:addStream("MA2", core.Line, name, "MA2", instance.parameters.color2, first,Shift2  );
    MA2:setPrecision(math.max(2, instance.source:getPrecision()));
    MA2:setWidth(instance.parameters.width2);
    MA2:setStyle(instance.parameters.style2); 
	
	MA3 = instance:addStream("MA3", core.Line, name, "MA3", instance.parameters.color3, first,Shift3  );
    MA3:setPrecision(math.max(2, instance.source:getPrecision()));
    MA3:setWidth(instance.parameters.width3);
    MA3:setStyle(instance.parameters.style3); 
 	
end


function Update(period, mode)

	ma1:update(mode); 
	ma2:update(mode); 
	ma3:update(mode); 
	
	 if period <= first
	 or period+ Shift1 < source:first()  
	 or period+ Shift2 < source:first() 
	 or period+ Shift3 < source:first()
	 then	 
	 return;
     end
 
	  	
	MA1[period+Shift1]= ma1.DATA[period];
	MA2[period+Shift2]= ma2.DATA[period];
	MA3[period+Shift3]= ma3.DATA[period];	
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