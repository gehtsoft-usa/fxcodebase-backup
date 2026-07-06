-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73032

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
    indicator:name("Laguerre Filter");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addDouble("Alpha", "Alpha", "", 0.2, 0, 1);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 255, 255)); 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Alpha, Gamma;  
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Alpha=instance.parameters.Alpha;
	Gamma=1-Alpha
	source = instance.source
 
 
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Alpha  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	--Indicator= core.indicators:create("AO", source, Period1, Period2);
	first=source:first() ; 
	
	
	L0 = instance:addInternalStream(0, 0);
	L1 = instance:addInternalStream(0, 0);
	L2 = instance:addInternalStream(0, 0);
	L3 = instance:addInternalStream(0, 0);	
	
	
    LF = instance:addStream("LF", core.Line, name, "LF", instance.parameters.color, first );
    LF:setPrecision(math.max(2, instance.source:getPrecision()));
    LF:setWidth(instance.parameters.width);
    LF:setStyle(instance.parameters.style); 
 
end


function Update(period, mode)

	  --Indicator:update(mode); 

	 if period <= first then
		L0[period] = source[period];
		L1[period] = source[period];
		L2[period] = source[period];
		L3[period] = source[period];
		LF[period] = source[period];
	    return;
	 end
	  

 

	L0[period]= (1-Gamma) * source[period] + Gamma *  L0[period-1]
	 
	L1[period]= -Gamma * L0[period] + L0[period-1]  + Gamma * L1[period-1]   
	L2[period]= -Gamma * L1[period] + L1[period-1]  + Gamma * L2[period-1] 
	L3[period]= -Gamma * L2[period] + L2[period-1]  + Gamma * L3[period-1] 

	LF[period] = (L0[period] + 2 * L1[period] + 2 * L2[period] + L3[period]) / 6
 
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