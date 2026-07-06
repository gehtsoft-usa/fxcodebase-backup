-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71873

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
    indicator:name("Volume Pressure Bars");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	indicator.parameters:addBoolean("Summarize", "Summarize", "Summarize", false);
	indicator.parameters:addBoolean("Cumulative", "Cumulative", "Cumulative", false);
	
	 indicator.parameters:addGroup("Line Style");	 
	
	 indicator.parameters:addColor("buyingPressure", "Buying Pressure Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("sellingPressure", "Selling Pressure Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local buyingPressure, sellingPressure;
local Cumulative,Summarize;	
-- Routine
 function Prepare(nameOnly)   
 
    
 
	source = instance.source
	Cumulative= instance.parameters.Cumulative;
	Summarize= instance.parameters.Summarize;
 
    local name = profile:id() .. "(" ..  instance.source:name() .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end 
	first=source:first() ; 
	
 
	
	if Summarize or Cumulative then
	
	Volume = instance:addStream("Volume", core.Bar, name, "Volume", instance.parameters.buyingPressure, first );
    Volume:setPrecision(math.max(2, instance.source:getPrecision())); 
    Volume:addLevel(0);	
	
	elseif not Summarize and not Cumulative then
    buyingPressure = instance:addStream("buyingPressure", core.Bar, name, "buyingPressure", instance.parameters.buyingPressure, first );
    buyingPressure:setPrecision(math.max(2, instance.source:getPrecision())); 
    buyingPressure:addLevel(0);	
 
    sellingPressure = instance:addStream("sellingPressure", core.Bar, name, "sellingPressure", instance.parameters.sellingPressure, first );
    sellingPressure:setPrecision(math.max(2, instance.source:getPrecision())); 
    sellingPressure:addLevel(0);	 
	end
end


function Update(period, mode)

 

	 if period < first then
	 return;
	 end
    
	if Summarize or Cumulative then 	
	
	local buying = source.volume[period] * (source.close[period] -source.low[period]) / (source.high[period] - source.low[period]);
    local selling = source.volume[period] * (source.high[period] - source.close[period]) / (source.high[period] - source.low[period]);
	
 
	Volume[period]= buying- selling;
	
		if Volume[period] > 0 then
		Volume:setColor(period, instance.parameters.buyingPressure);
		else
		Volume:setColor(period, instance.parameters.sellingPressure);
		end
		
		if Cumulative then
		Volume[period]=Volume[period-1]+Volume[period];
		end
	
	
	else
    buyingPressure[period] = source.volume[period] * (source.close[period] -source.low[period]) / (source.high[period] - source.low[period]);
    sellingPressure[period] = source.volume[period] * (source.high[period] - source.close[period]) / (source.high[period] - source.low[period]);
    end
	 
end
