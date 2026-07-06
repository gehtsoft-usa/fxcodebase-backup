-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72678

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
--|                                                                       https://mario-jemic.com/ |
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
    indicator:name("Relative Strength Exponential Moving Average");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
 


 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("periods", "EMA Length", "", 20, 14, 2000);
    indicator.parameters:addInteger("pds", "RS Length", "", 20, 4, 2000);
    indicator.parameters:addDouble("mltp", "RS Multiplier", "", 10, 0, 2000);
 
	
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
local periods, pds, mltp; 
local Indicator;
local mltp1, coef1,coef2;	
-- Routine
 function Prepare(nameOnly)   
 
    
	periods=instance.parameters.periods;
	pds=instance.parameters.pds;
	mltp=instance.parameters.mltp;	
	source = instance.source
	
	
    mltp1 = 2.0 / (periods + 1.0)
    coef1 = 2.0 /  (pds + 1.0)
    coef2 = 1.0 - coef1
	
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  periods.. "," ..  pds.. "," ..  mltp  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
	first=source:first()+1 ; 
	
	
	acup = instance:addInternalStream(0, 0);
 	acdn = instance:addInternalStream(0, 0);
	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
 
 
	
end


function Update(period, mode)

	  

	 if period <= first then
	 return;
	 end
	 

    local  diff = source[period] - source[period-1]; 
	
	local cup=0;
	local cdn=0;
	
    if diff > 0 then          cup= diff           end
    if diff < 0 then          cdn= math.abs(diff) end
	
    acup[period] = coef1 * cup + coef2 * acup[period-1]
    acdn[period] = coef1 * cdn + coef2 * acdn[period-1]
    local  rs   = math.abs(acup[period] - acdn[period]) / (acup[period] + acdn[period])
    local rate = mltp1 * (1.0 +  rs  * mltp) 
	
	Line[period]=rate * source[period] + (1.0 - rate) *  Line[period-1]; 
	
end

 

