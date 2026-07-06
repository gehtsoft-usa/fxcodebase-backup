-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72828

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
    indicator:name("John Ehlers Forward Reverse EMA");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addDouble("AA", "AA", "", 0.1, 0, 1); 
	
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
local AA,CC; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	AA=instance.parameters.AA;
	CC=1-AA;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  AA  .. ")";
    instance:name(name); 

	RE1= instance:addInternalStream(0, 0);
	RE2= instance:addInternalStream(0, 0);
	RE3= instance:addInternalStream(0, 0);
	RE4= instance:addInternalStream(0, 0);
	RE5= instance:addInternalStream(0, 0);
	RE6= instance:addInternalStream(0, 0);
	RE7= instance:addInternalStream(0, 0);
	RE8= instance:addInternalStream(0, 0);
	EMA= instance:addInternalStream(0, 0);
 
    if   (nameOnly) then
        return;
    end
	
 
	first=source:first()+1 ; 
	
 
 
	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
end


function Update(period, mode)

	--  Indicator:update(mode); 

	if period <= first then	 
	RE1[period]=0;
	RE2[period]=0;
	RE3[period]=0;
	RE4[period]=0;
	RE5[period]=0;
	RE6[period]=0;
	RE7[period]=0;
	RE8[period]=0;
	EMA[period]=0; 
	return;
	end
	 
	EMA[period] = AA*source[period] + CC*EMA[period-1]
	 
	RE1[period] = CC*EMA[period] + EMA[period-1]
	RE2[period] = math.exp(2*math.log(CC))*RE1[period] + RE1[period-1]
	RE3[period] = math.exp(4*math.log(CC))*RE2[period] + RE2[period-1]
	RE4[period] = math.exp(8*math.log(CC))*RE3[period] + RE3[period-1]
	RE5[period] = math.exp(16*math.log(CC))*RE4[period] + RE4[period-1]
	RE6[period] = math.exp(32*math.log(CC))*RE5[period] + RE5[period-1]
	RE7[period] = math.exp(64*math.log(CC))*RE6[period] + RE6[period-1]
	RE8[period] = math.exp(128*math.log(CC))*RE7[period] + RE7[period-1]
	Line[period]  = EMA[period] - AA*RE8[period]	 
	
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
