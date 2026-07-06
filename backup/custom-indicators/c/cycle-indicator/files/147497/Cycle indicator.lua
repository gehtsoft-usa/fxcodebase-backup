-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72728

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
    indicator:name("Cycle indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  	indicator.parameters:addGroup("Smoothing Calculation");
    indicator.parameters:addInteger("Period", "MA Period", "", 9, 1, 2000);	
    indicator.parameters:addDouble("Weight1", "1. Stochastic Weight ", "", 4.1 );	
    indicator.parameters:addDouble("Weight2", "2. Stochastic Weight ", "", 2.5 );	
    indicator.parameters:addDouble("Weight3", "3. Stochastic Weight ", "", 1 );	
    indicator.parameters:addDouble("Weight4", "4. Stochastic Weight ", "", 4 );		
	
 	indicator.parameters:addGroup("1. Stochastic Calculation");	
    indicator.parameters:addInteger("Period11", "Fast MA", "", 5, 1, 2000);
    indicator.parameters:addInteger("Period12", "Slow MA", "", 3, 1, 2000);
	
	
    indicator.parameters:addString("MVAT_K1", "Smoothing type for %K", "", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K1", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K1", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MVAT_K1", "FS", "", "FS");
 
	
	
 	indicator.parameters:addGroup("2. Stochastic Calculation");	
    indicator.parameters:addInteger("Period21", "Fast MA", "", 14, 1, 2000);
    indicator.parameters:addInteger("Period22", "Slow MA", "", 3, 1, 2000);	
	
    indicator.parameters:addString("MVAT_K2", "Smoothing type for %K", "", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K2", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K2", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MVAT_K2", "FS", "", "FS");	
	
 	indicator.parameters:addGroup("3. Stochastic Calculation");	
    indicator.parameters:addInteger("Period31", "Fast MA", "", 45, 1, 2000);
    indicator.parameters:addInteger("Period32", "Slow MA", "", 14, 1, 2000);
    indicator.parameters:addString("MVAT_K3", "Smoothing type for %K", "", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K3", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K3", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MVAT_K3", "FS", "", "FS");	
	

 	indicator.parameters:addGroup("4. Stochastic Calculation");	
    indicator.parameters:addInteger("Period41", "Fast MA", "", 75, 1, 2000);
    indicator.parameters:addInteger("Period42", "Slow MA", "", 20, 1, 2000);	
    indicator.parameters:addString("MVAT_K4", "Smoothing type for %K", "", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K4", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K4", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MVAT_K4", "FS", "", "FS");	
	
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
 
	
-- Routine
 function Prepare(nameOnly)   
 
    
 
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 
	
    Period=instance.parameters.Period;
    Weight1=instance.parameters.Weight1;
    Weight2=instance.parameters.Weight2;
    Weight3=instance.parameters.Weight3;
    Weight4=instance.parameters.Weight4;	

    if   (nameOnly) then
        return;
    end
	
	Indicator1= core.indicators:create("STOCHASTIC", source, instance.parameters.Period11, instance.parameters.Period12,2, instance.parameters.MVAT_K1);
	Indicator2= core.indicators:create("STOCHASTIC", source, instance.parameters.Period21, instance.parameters.Period22,2, instance.parameters.MVAT_K2);
	Indicator3= core.indicators:create("STOCHASTIC", source, instance.parameters.Period31, instance.parameters.Period32,2, instance.parameters.MVAT_K3);
	Indicator4= core.indicators:create("STOCHASTIC", source, instance.parameters.Period41, instance.parameters.Period42,2, instance.parameters.MVAT_K4);	
	first=math.max(Indicator1.DATA:first(),Indicator2.DATA:first(),Indicator2.DATA:first(),Indicator3.DATA:first()) ; 
	
	
	Stream1 = instance:addInternalStream(0, 0);
	Stream2 = instance:addInternalStream(0, 0); 
	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first+Period );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
end


function Update(period, mode)

	  Indicator1:update(mode); 
	  Indicator2:update(mode); 
	  Indicator3:update(mode); 
	  Indicator4:update(mode); 
	  
	 if period <= first then
	 return;
	 end
	 
 
	
	
	Stream1[period]= (Weight1*Indicator1.DATA[period]+Weight2*Indicator2.DATA[period]+Weight3*Indicator3.DATA[period]+Weight4*Indicator4.DATA[period])/(Weight1+Weight2+Weight3+Weight4);
	
	
	 if period <= first+Period then
	 return;
	 end
	 
	Stream2[period]=mathex.avg(Stream1, period-Period+1, period);
 
	
	Line[period]=Stream1[period]-Stream2[period];
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