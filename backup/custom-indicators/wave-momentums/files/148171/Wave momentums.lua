-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72901

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
    indicator:name("Wave momentums");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

 	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addBoolean("Selector1", "1. Line", "1. Line", true);
	indicator.parameters:addBoolean("Selector2", "2. Line", "2. Line", true);
	indicator.parameters:addBoolean("Selector3", "3. Line", "3. Line", true);	
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
  
 	indicator.parameters:addGroup("1. Wave Calculation");	
    indicator.parameters:addInteger("PeriodA1", "1. Period", "", 8, 1, 2000);
    indicator.parameters:addInteger("PeriodA2", "2. Period", "", 34, 1, 2000);
    indicator.parameters:addInteger("PeriodA3", "3. Period", "", 55, 1, 2000);	
	

 	indicator.parameters:addGroup("2. Wave Calculation");	
    indicator.parameters:addInteger("PeriodB1", "1. Period", "", 8, 1, 2000);
    indicator.parameters:addInteger("PeriodB2", "2. Period", "", 89, 1, 2000);
    indicator.parameters:addInteger("PeriodB3", "3. Period", "", 144, 1, 2000);	


 	indicator.parameters:addGroup("3. Wave Calculation");	
    indicator.parameters:addInteger("PeriodC1", "1. Period", "", 8, 1, 2000);
    indicator.parameters:addInteger("PeriodC2", "2. Period", "", 233, 1, 2000);
    indicator.parameters:addInteger("PeriodC3", "3. Period", "", 377, 1, 2000);	

	
	 indicator.parameters:addGroup("1. Line Style");	 	
	indicator.parameters:addColor("colorA1", "1. Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("colorA2", "2. Line Color", "", core.rgb(0, 100, 0)); 
	
	 indicator.parameters:addGroup("2. Line Style");	 	
	indicator.parameters:addColor("colorB1", "1. Line Color", "", core.rgb(255, 0, 0)); 
	indicator.parameters:addColor("colorB2", "2. Line Color", "", core.rgb(100, 0, 0)); 	
	
	 indicator.parameters:addGroup("3. Line Style");	 	
	indicator.parameters:addColor("colorC1", "1. Line Color", "", core.rgb(0, 0, 255)); 
	indicator.parameters:addColor("colorC2", "2. Line Color", "", core.rgb(0, 0, 100)); 	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil; 
local Selector1, Selector2, Selector3, Method; 
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Selector1=instance.parameters.Selector1;
	Selector2=instance.parameters.Selector2;
	Selector3=instance.parameters.Selector3;	
	
	PeriodA1=instance.parameters.PeriodA1;
	PeriodA2=instance.parameters.PeriodA2;
	PeriodA3=instance.parameters.PeriodA3;
	
	PeriodB1=instance.parameters.PeriodB1;
	PeriodB2=instance.parameters.PeriodB2;
	PeriodB3=instance.parameters.PeriodB3;

	PeriodC1=instance.parameters.PeriodC1;
	PeriodC2=instance.parameters.PeriodC2;
	PeriodC3=instance.parameters.PeriodC3;	
	
	Method=instance.parameters.Method;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. "," ..  Method .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	first=source:first() ; 
	
	if Selector1 then
	IndicatorA1= core.indicators:create(Method, source, PeriodA1);
	IndicatorA2= core.indicators:create(Method, source, PeriodA2);
	IndicatorA3= core.indicators:create(Method, source, PeriodA3);	
	first1=math.max(first, IndicatorA1.DATA:first(), IndicatorA2.DATA:first(), IndicatorA3.DATA:first() )
	
	DeltaA1 = instance:addInternalStream(0, 0);
	DeltaA2 = instance:addInternalStream(0, 0);
	
	IndicatorA11= core.indicators:create(Method, DeltaA1, PeriodA3);	
	IndicatorA12= core.indicators:create(Method, DeltaA2, PeriodA3);	
    end
	
	if Selector2  then	
	IndicatorB1= core.indicators:create(Method, source, PeriodB1);
	IndicatorB2= core.indicators:create(Method, source, PeriodB2);
	IndicatorB3= core.indicators:create(Method, source, PeriodB3);	
	first2=math.max(first, IndicatorB1.DATA:first(), IndicatorB2.DATA:first(), IndicatorB3.DATA:first() )	
	
	DeltaB1 = instance:addInternalStream(0, 0);
	DeltaB2 = instance:addInternalStream(0, 0);
	
	IndicatorB11= core.indicators:create(Method, DeltaB1, PeriodB3);	
	IndicatorB12= core.indicators:create(Method, DeltaB2, PeriodB3);	
    end
	
	if Selector3  then
	IndicatorC1= core.indicators:create(Method, source, PeriodC1);
	IndicatorC2= core.indicators:create(Method, source, PeriodC2);
	IndicatorC3= core.indicators:create(Method, source, PeriodC3);	
	first3=math.max(first, IndicatorC1.DATA:first(), IndicatorC2.DATA:first(), IndicatorC3.DATA:first() )	

	DeltaC1 = instance:addInternalStream(0, 0);
	DeltaC2 = instance:addInternalStream(0, 0);

	IndicatorC11= core.indicators:create(Method, DeltaC1, PeriodC3);	
	IndicatorC12= core.indicators:create(Method, DeltaC2, PeriodC3);	
	end
	 
	
	if Selector1 then	
    LineA1 = instance:addStream("LineA1", core.Line, name, "A1. Line", instance.parameters.colorA1, first1 + math.max(PeriodA3,PeriodB3,PeriodC3) );
    LineA1:setPrecision(math.max(2, instance.source:getPrecision())); 
    LineA1:setStyle(core.LINE_SOLID);
    LineA1:addLevel(0);	
	
    LineA2 = instance:addStream("LineA2", core.Line, name, "A2. Line", instance.parameters.colorA2, first1+ math.max(PeriodA3,PeriodB3,PeriodC3) );
    LineA2:setPrecision(math.max(2, instance.source:getPrecision())); 
    LineA2:setStyle(core.LINE_DASH);
    LineA2:addLevel(0);		
	end
	
	if Selector2 then	
    LineB1 = instance:addStream("LineB1", core.Line, name, "B1. Line", instance.parameters.colorB1, first2 + math.max(PeriodA3,PeriodB3,PeriodC3) );
    LineB1:setPrecision(math.max(2, instance.source:getPrecision())); 
    LineB1:setStyle(core.LINE_SOLID);
    LineB1:addLevel(0);	
	
    LineB2 = instance:addStream("LineB2", core.Line, name, "B2. Line", instance.parameters.colorB2, first2+ math.max(PeriodA3,PeriodB3,PeriodC3) );
    LineB2:setPrecision(math.max(2, instance.source:getPrecision())); 
    LineB2:setStyle(core.LINE_DASH);
    LineB2:addLevel(0);		
	end


	if Selector3 then	
    LineC1 = instance:addStream("LineC1", core.Line, name, "C1. Line", instance.parameters.colorC1, first3 + math.max(PeriodA3,PeriodB3,PeriodC3) );
    LineC1:setPrecision(math.max(2, instance.source:getPrecision())); 
    LineC1:setStyle(core.LINE_SOLID);
    LineC1:addLevel(0);	
	
    LineC2 = instance:addStream("LineC2", core.Line, name, "C2. Line", instance.parameters.colorC2, first3+ math.max(PeriodA3,PeriodB3,PeriodC3) );
    LineC2:setPrecision(math.max(2, instance.source:getPrecision())); 
    LineC2:setStyle(core.LINE_DASH);
    LineC2:addLevel(0);	
	end
	
 
end


function Update(period, mode)


     
      if Selector1 then	
	  IndicatorA1:update(mode); 
	  IndicatorA2:update(mode); 
	  IndicatorA3:update(mode); 	
	  end

      if Selector2 then	
	  IndicatorB1:update(mode); 
	  IndicatorB2:update(mode); 
	  IndicatorB3:update(mode); 
	  end
	  
      if Selector3 then	
	  IndicatorC1:update(mode); 
	  IndicatorC2:update(mode); 
	  IndicatorC3:update(mode); 	  
      end
	  
	  
 
	 
	if Selector1 and period  > first1  then	 
	DeltaA1[period]=IndicatorA1.DATA[period]-IndicatorA2.DATA[period];
	DeltaA2[period]=IndicatorA1.DATA[period]-IndicatorA3.DATA[period];
	end
	
	if Selector2 and period  > first2   then	
	DeltaB1[period]=IndicatorB1.DATA[period]-IndicatorB2.DATA[period];  	
	DeltaB2[period]=IndicatorB1.DATA[period]-IndicatorB3.DATA[period];
	end

	if Selector3 and period  > first3   then		
	DeltaC1[period]=IndicatorC1.DATA[period]-IndicatorC2.DATA[period];
	DeltaC2[period]=IndicatorC1.DATA[period]-IndicatorC3.DATA[period];
	end
	
	
	
    if Selector1 then	 
	IndicatorA11:update(mode); 
	IndicatorA12:update(mode);
    end

    if Selector2 then	
	IndicatorB11:update(mode); 
	IndicatorB12:update(mode);
	end
	
	
    if Selector3 then	
	IndicatorC11:update(mode); 
	IndicatorC12:update(mode);
    end
 
	 
 

	  
    if Selector1 and period > first1 + math.max(PeriodA3,PeriodB3,PeriodC3)  then	 
	LineA1[period]=DeltaA1[period]-IndicatorA11.DATA[period];
	LineA2[period]=DeltaA2[period]-IndicatorA12.DATA[period];
	end

    if Selector2 and period > first2 + math.max(PeriodA3,PeriodB3,PeriodC3) then		
	LineB1[period]=DeltaB1[period]-IndicatorB11.DATA[period]; 
	LineB2[period]=DeltaB2[period]-IndicatorB12.DATA[period];  
	end

    if Selector3 and period > first3 + math.max(PeriodA3,PeriodB3,PeriodC3) then	
	LineC1[period]=DeltaC1[period]-IndicatorC11.DATA[period]; 
	LineC2[period]=DeltaC2[period]-IndicatorC12.DATA[period]; 
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
