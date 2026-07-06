-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73204

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
    indicator:name("Vegas tunnel");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

 
	
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
	
    indicator.parameters:addInteger("Period1", "1. MA", "", 144, 1, 2000);
    indicator.parameters:addInteger("Period2", "2. MA", "", 169, 1, 2000);
    indicator.parameters:addInteger("Period3", "3. MA", "", 12, 1, 2000); 
	
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "1. Tunnel Line Color", "", core.rgb(0, 0, 255)); 
	 indicator.parameters:addColor("color2", "2. Tunnel Line Color", "", core.rgb(0, 0, 255)); 
	 indicator.parameters:addColor("color3", "3. Tunnel Line Color", "", core.rgb(0, 255, 0)); 	 
	 indicator.parameters:addColor("color4", "Lines Color", "", core.rgb(128, 128, 128)); 	 	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Method, Period1, Period2, Period3;
local T1, T2, T3;
local R={};
local S={}; 
local Level={.0055,.0089,.0144,.0233 , .0377,.0610,.0987,.1597,.2584  };
	
-- Routine
 function Prepare(nameOnly)   
 


    Method=instance.parameters.Method;
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Period3=instance.parameters.Period3;
	
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Method .. "," .. Period1.. "," ..  Period2 .. "," ..  Period3.. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	Indicator1= core.indicators:create(Method, source, Period1);
	Indicator2= core.indicators:create(Method, source, Period2);
	Indicator3= core.indicators:create(Method, source, Period3);
	
	first=math.max(Indicator1.DATA:first() , Indicator2.DATA:first(), Indicator3.DATA:first()); 
	

 
	
	
    Tunnel1 = instance:addStream("Tunnel1", core.Line, name, "1. Tunnel", instance.parameters.color1, first );
    Tunnel1:setPrecision(math.max(2, instance.source:getPrecision()));
    Tunnel1:setWidth(instance.parameters.width);
    Tunnel1:setStyle(instance.parameters.style);
 	
 
    Tunnel2 = instance:addStream("Tunnel2", core.Line, name, "2. Tunnel", instance.parameters.color2, first );
    Tunnel2:setPrecision(math.max(2, instance.source:getPrecision()));
    Tunnel2:setWidth(instance.parameters.width);
    Tunnel2:setStyle(instance.parameters.style);
 


    Tunnel3 = instance:addStream("Tunnel3", core.Line, name, "3. Tunnel1", instance.parameters.color3, first );
    Tunnel3:setPrecision(math.max(2, instance.source:getPrecision()));
    Tunnel3:setWidth(instance.parameters.width);
    Tunnel3:setStyle(instance.parameters.style);
 
	
	for i = 1, 9, 1 do
	R[i] = instance:addStream("R"..i, core.Line, name, i ..". R", instance.parameters.color4, first );
    R[i]:setPrecision(math.max(2, instance.source:getPrecision()));
    R[i]:setWidth(instance.parameters.width);
    R[i]:setStyle(instance.parameters.style);
	
	S[i] = instance:addStream("S"..i, core.Line, name, i ..". S", instance.parameters.color4, first );
    S[i]:setPrecision(math.max(2, instance.source:getPrecision()));
    S[i]:setWidth(instance.parameters.width);
    S[i]:setStyle(instance.parameters.style);	
	end
	
end


function Update(period, mode)

	Indicator1:update(mode); 
	Indicator2:update(mode); 
	Indicator3:update(mode); 
	
	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	  
	  	
	Tunnel1[period]= Indicator1.DATA[period];
	Tunnel2[period]= Indicator2.DATA[period];
	Tunnel3[period]= Indicator3.DATA[period];
	
	
    local min = math.min(Tunnel1[period], Tunnel2[period]);
    local max = math.max(Tunnel1[period], Tunnel2[period]);
	
	
	for i =1, 9, 1 do
	R[i][period]= max+Level[i]
	S[i][period]= min-Level[i]	
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