-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73778

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
    indicator:name("MESA Phase");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("DomCycle", "Dom Cycle", "", 15, 1, 2000); 
	
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
local DomCycle;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	DomCycle=instance.parameters.DomCycle;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  DomCycle  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

 
	 
	first=source:first() ;  
	
    Phase = instance:addStream("Phase", core.Line, name, "Phase", instance.parameters.color, first );
    Phase:setPrecision(math.max(2, instance.source:getPrecision()));
    Phase:setWidth(instance.parameters.width);
    Phase:setStyle(instance.parameters.style);
    Phase:addLevel(0);	
 
end


function Update(period, mode)
 

	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	  
	local RealPart = 0
	local ImagPart = 0	  	
	local Weight;
	
	
	for J = 0,DomCycle - 1, 1 do
	Weight = (source.close[period-J] + source.close[period-J] + source.high[period-J] + source.low[period-J]) * 1
	RealPart = RealPart + math.cos(90 * J / DomCycle) * Weight * 2
	ImagPart = ((ImagPart + math.sin(90 * J / DomCycle) * Weight) + (ImagPart + math.sin(180 * J / DomCycle) * Weight)) / 2
	end
	 
	
	Phase[period]= ((math.atan(ImagPart / RealPart)) - 0.685) * 100; 
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