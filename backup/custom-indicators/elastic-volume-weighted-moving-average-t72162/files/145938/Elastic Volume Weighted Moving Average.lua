-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72162

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
    indicator:name("Elastic Volume Weighted Moving Average");
    indicator:description("Elastic Volume Weighted Moving Average");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
 
 	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addBoolean("LowVolume", "Low Volume CutOff", "", true);
	indicator.parameters:addInteger("CutOff", "CutOff as Percantage", "", 10, 1, 100);	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("EVWMA_color", "Color of EVWMA", "Color of EVWMA", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local CutOff,LowVolume;

local first;
local source = nil;

-- Streams block
local EVWMA = nil;

-- Routine
function Prepare(nameOnly)  
    source = instance.source;
    first = source:first() ;
	
	CutOff=instance.parameters.CutOff;
	LowVolume=instance.parameters.LowVolume;

    local name = profile:id() .. "(" .. source:name()   .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
 
 
 
        EVWMA = instance:addStream("EVWMA", core.Line, name, "EVWMA", instance.parameters.EVWMA_color, first);
		EVWMA:setWidth(instance.parameters.width);
        EVWMA:setStyle(instance.parameters.style);
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period <= first then 
	return;
	end
	
	  
	  
    if LowVolume and  (source.volume[period]/(source.volume[period-1]/ 100)) < CutOff then
	EVWMA[period]=EVWMA[period-1];
	else
	EVWMA[period]= (source.volume[period-1]*EVWMA[period-1]+(source.volume[period])*source.close[period])/(source.volume[period]+source.volume[period-1]);
	end
 
 
    
end

