-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72725

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
    indicator:name("Dual Thrust Strategy indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("N", "Period", "", 4, 1, 2000);
    indicator.parameters:addDouble("K1", "Cap factor", "", 0.5, 1, 2000);
    indicator.parameters:addDouble("K2", "Floor factor", "", 0.5, 1, 2000);	
 
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Cap Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Cap Line Color", "", core.rgb(255, 0, 0)); 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local N, K1, K2; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	N=instance.parameters.N;
	K1=instance.parameters.K1;
	K2=instance.parameters.K2;	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  N.. "," ..  K1 .. "," ..  K2  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	--Indicator= core.indicators:create("AO", source, Period1, Period2);
	first=source:first()+N ; 
	
	
	Stream = instance:addInternalStream(0, 0);
 
	
	
    Cap = instance:addStream("Cap", core.Line, name, "Cap", instance.parameters.color1, first );
    Cap:setPrecision(math.max(2, instance.source:getPrecision()));
    Cap:setWidth(instance.parameters.width);
    Cap:setStyle(instance.parameters.style);
    Cap:addLevel(0);	


    Floor = instance:addStream("Floor", core.Line, name, "Floor", instance.parameters.color2, first );
    Floor:setPrecision(math.max(2, instance.source:getPrecision()));
    Floor:setWidth(instance.parameters.width);
    Floor:setStyle(instance.parameters.style);
    Floor:addLevel(0);	 
end


function Update(period, mode)

 

	 if period <= first then
	 return;
	 end
	  
	
	LC, HC =  mathex.minmax(source.close, period-N+1, period);
	LL, HH = mathex.minmax(source, period-N+1, period);
 

 
	local RNG = math.max(HH - LC,HC - LL); 
	Cap[period] = source.open[period] + (RNG * K1);  
	Floor[period] = source.open[period] - (RNG * K2) ; 
 
 
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