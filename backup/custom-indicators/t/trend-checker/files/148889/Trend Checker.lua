-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73102

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
    indicator:name("Trend Checker");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("Row1", "1. Period", "", 1, 1, 2000);
    indicator.parameters:addInteger("Row2", "2. Period", "", 2, 1, 2000);
    indicator.parameters:addInteger("Row3", "3. Period", "", 4, 1, 2000);
    indicator.parameters:addInteger("Row4", "4. Period", "", 8, 1, 2000);
    indicator.parameters:addInteger("Row5", "5. Period", "", 12, 1, 2000);
    indicator.parameters:addInteger("Row6", "6. Period", "", 24, 1, 2000);
    indicator.parameters:addInteger("Row7", "7. Period", "", 48, 1, 2000);
    indicator.parameters:addInteger("Row8", "8. Period", "", 96, 1, 2000);
	
	
    indicator.parameters:addInteger("Smoothing", "Smoothing Period", "", 12, 1, 2000);	
	
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
local Factor, Max;
local Row={};	
-- Routine
 function Prepare(nameOnly)   
 
    
	
    local Sum=0; 
	local Max=0;
	for i= 1 , 8, 1 do
    Row[i]=instance.parameters:getInteger("Row" .. i);
	Sum=Sum+Row[i];
	
	if Row[i] > Max then
	Max=Row[i];
	end
	
	end

	Factor = 100/Sum;
		
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name()..  ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	

	first=source:first()+Max ; 
	
	
	trend = instance:addInternalStream(0, 0);
 	Smoothing= core.indicators:create("MVA", trend,  instance.parameters.Smoothing);
	
	
    Trend = instance:addStream("Trend", core.Line, name, "Trend", instance.parameters.color, first );
    Trend:setPrecision(math.max(2, instance.source:getPrecision()));
    Trend:setWidth(instance.parameters.width);
    Trend:setStyle(instance.parameters.style);
    Trend:addLevel(0);	
 
end


function Update(period, mode)

	

	 if period <= first then
	 return;
	 end
	 
	 
	trend[period] = 0

	
    for i= 1 , 8,  1 do	
			  
			 if source[period] > source[period-Row[i]] then
			  trend[period] = trend[period] + (Row[i]*Factor)
			 elseif  source[period] < source[period-Row[i]] then
			   trend[period] = trend[period] - (Row[i]*Factor)
			  end
			 
			 
	end
	  
    Smoothing:update(mode); 
	
	if period < Smoothing.DATA:first() then
	return;
	end
	
	
	Trend[period]=Smoothing.DATA[period];
	
	
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