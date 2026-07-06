-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73323

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
    indicator:name("Sidus tunnel width");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

 
    indicator.parameters:addGroup("Trend Caclculation");
	
	indicator.parameters:addBoolean("Absolute", "Absolute", "", false);
	indicator.parameters:addInteger("Period1", "1. Period", "", 18);  
    indicator.parameters:addInteger("Period2", "2. Period", "", 28);
 
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");	

    indicator.parameters:addGroup("Signal Caclculation");
    indicator.parameters:addInteger("Period3", "1. Period", "", 5);  
    indicator.parameters:addInteger("Period4", "2. Period", "", 8); 
	
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");	 	
 
	
	indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "Trend Line Color", "", core.rgb(0, 255, 0)); 
     indicator.parameters:addColor("color2", "Signal Line Color", "", core.rgb(255, 0, 0)); 
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
	Period2=instance.parameters.Period2;
	Period3=instance.parameters.Period3;
	Period4=instance.parameters.Period4;	
	Method1=instance.parameters.Method1;		
	Method2=instance.parameters.Method2;
    Absolute=instance.parameters.Absolute;	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Period2 .. "," ..  Method1 .. "," ..  Period3.. "," ..  Period4 .. "," ..  Method2.. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	MA1= core.indicators:create(Method1, source, Period1);
	MA2= core.indicators:create(Method1, source, Period2);	
	MA3= core.indicators:create(Method2, source, Period3);
	MA4= core.indicators:create(Method2, source, Period4)	
	first=math.max(MA1.DATA:first(),MA2.DATA:first(),MA3.DATA:first(),MA4.DATA:first()) ; 
	
	
	--Stream = instance:addInternalStream(0, 0);
	
    Trend = instance:addStream("Trend", core.Line, name, "Trend", instance.parameters.color1, first );
    Trend:setPrecision(math.max(2, instance.source:getPrecision()));
    Trend:setWidth(instance.parameters.width);
    Trend:setStyle(instance.parameters.style);
    Trend:addLevel(0);
	
    Signal = instance:addStream("Signal", core.Line, name, "Signal", instance.parameters.color2, first );
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
    Signal:setWidth(instance.parameters.width);
    Signal:setStyle(instance.parameters.style);
    Signal:addLevel(0);		
 
end


function Update(period, mode)

	MA1:update(mode); 
	MA2:update(mode); 
	MA3:update(mode); 
	MA4:update(mode); 
	
	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	  
	  	
	if Absolute then
	Trend[period]= math.abs(MA1.DATA[period]-MA2.DATA[period]);
	Signal[period]= math.abs(MA3.DATA[period]-MA4.DATA[period]);		
    else	
	Trend[period]= MA1.DATA[period]-MA2.DATA[period];
	Signal[period]= MA3.DATA[period]-MA4.DATA[period];	
	end
	
    --Line:setColor(period, instance.parameters.color);		
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