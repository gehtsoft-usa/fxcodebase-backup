-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73572

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
    indicator:name("Simplified supertrend");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addDouble("factor", "Factor", "", 0.005);
	
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
local factor;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	factor=instance.parameters.factor;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  factor  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Indicator= core.indicators:create("AO", source, Period1, Period2);
	first=Indicator.DATA:first() ; 
	
	
	STlong = instance:addInternalStream(0, 0);
	STshort = instance:addInternalStream(0, 0); 
	direction = instance:addInternalStream(0, 0); 
	
    Line = instance:addStream("Line", core.Line, name, "Simplified Supertrend", instance.parameters.color, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
end


function Update(period, mode)

	Indicator:update(mode); 

	if period <= first
	or  not source:hasData(period) 
	then
	direction[period]=1;
	STlong[period] = 0
	STshort[period] = math.huge	
	return;
	end

	STlong[period] = source.median[period] - source.close[period] * factor;	 
	STshort[period] = source.median[period] + source.close[period] * factor;
  
  
    direction[period]=direction[period-1];
  
	if direction[period-1] == 1 and STlong[period] < STlong[period-1] then
	 STlong[period] = STlong[period-1]
	end
	 
	if direction[period-1] == -1 and STshort[period] > STshort[period-1] then
	 STshort[period] = STshort[period-1]
	end
	 
	if direction[period-1] == 1 and source.close[period] < STlong[period] then
	 direction[period] = -1
	end
	 
	if direction[period-1] == -1 and source.close[period] > STshort[period] then
	 direction[period] = 1
	end
   
    
  
	if direction[period] == 1 then
	 Line[period] = STlong[period]
	else
	 Line[period] = STshort[period]
	end 
end

 --[[
 
 ONCE direction = 1
ONCE STlongold = 0
ONCE STshortold = 1000000000000

factor = 0.005

indicator1 = medianprice

indicator3 = close

indicator2 = indicator3 * factor

STlong = indicator1 - indicator2

STshort = indicator1 + indicator2

If direction = 1 and STlong < STlongold then
 STlong = STlongold
endif

If direction = -1 and STshort > STshortold then
 STshort = STshortold
endif

If direction = 1 and indicator3 < STlong then
 direction = -1
endif

If direction = -1 and indicator3 > STshort then
 direction = 1
endif

STlongold = STlong

STshortold = STshort

If direction = 1 then
 ST = STlong
else
 ST = STshort
endif

Return ST as "simplified Supertrend"
 ]]

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