-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72044

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
    indicator:name("OC Momentum");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator); 
 
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("OC_Candles", "OC Candles", "", 3, 1, 2000);
    indicator.parameters:addInteger("Average_Period", "Average_Period", "", 20, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color", "Average Line Color", "", core.rgb(0, 0, 255)); 
	 indicator.parameters:addColor("color1", "Up Bar Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Down Bar Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local OC_Candles, Average_Period; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	OC_Candles=instance.parameters.OC_Candles;
	Average_Period=instance.parameters.Average_Period;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  OC_Candles.. "," ..  Average_Period  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
 
	first=source:first()+OC_Candles;  
	
	Histogram =instance:addStream("Histogram", core.Bar, name, "Histogram", instance.parameters.color1, first  );
    Histogram:setPrecision(math.max(2, instance.source:getPrecision()));
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first +Average_Period );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
end


function Update(period, mode)
 

	 if period <= first then
	 return;
	 end
 
	
	
    Histogram[period] = (source.close[period]-source.open[period-OC_Candles])/source:pipSize() ; 
   
    if Histogram[period]> 0 then
    Histogram:setColor(period,   instance.parameters.color1);	
	else
    Histogram:setColor(period,   instance.parameters.color2);	
	end
	
	
 	 if period <= first +Average_Period  then
	 return;
	 end
	 
   
	Line[period]= mathex.avg(Histogram, period-Average_Period+1, period);
	
end