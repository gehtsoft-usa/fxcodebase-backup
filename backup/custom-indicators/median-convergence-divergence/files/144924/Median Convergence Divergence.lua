-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71846

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
    indicator:name("Median Convergence Divergence");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period1", "Fast MA Period", "", 5, 1, 2000);
    indicator.parameters:addInteger("Period2", "Slow MA Period", "", 20, 1, 2000);
    indicator.parameters:addInteger("Period3", "Signal MA Period", "", 10, 1, 2000);	
	 indicator.parameters:addGroup("MACD Line Style");	
    indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);	
	indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0)); 
	 
	indicator.parameters:addGroup("Signal Line Style");	
    indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 0, 0));  

	indicator.parameters:addGroup("Histogram Style");	 
	indicator.parameters:addColor("color3", "Bar Color", "", core.rgb(0, 0, 255)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period1, Period2, Period3; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Period3=instance.parameters.Period3;	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Period2.. "," ..  Period3  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
 
	first=source:first()+math.max(Period1, Period2) ; 
	
 
	
	
    MACD = instance:addStream("MACD", core.Line, name, "MACD", instance.parameters.color1, first  );
    MACD:setPrecision(math.max(2, instance.source:getPrecision()));
    MACD:setWidth(instance.parameters.width1);
    MACD:setStyle(instance.parameters.style1);
    MACD:addLevel(0);	

    SIGNAL = instance:addStream("SIGNAL", core.Line, name, "SIGNAL", instance.parameters.color2, first );
    SIGNAL:setPrecision(math.max(2, instance.source:getPrecision()));
    SIGNAL:setWidth(instance.parameters.width2);
    SIGNAL:setStyle(instance.parameters.style2);
    SIGNAL:addLevel(0);	 
	
	
    BAR = instance:addStream("BAR", core.Bar, name, "BAR", instance.parameters.color3, first );
    BAR:setPrecision(math.max(2, instance.source:getPrecision())); 
    BAR:addLevel(0);	 
end


function Update(period, mode)

	 
	 if period < first then
	 return;
	 end
	 
	MACD[period]= mathex.median_s (source, period-Period1+1, period)-mathex.median_s (source, period-Period2+1, period); 
	
	if period < first+Period3 then
	return;
	end 
	
	SIGNAL[period]=mathex.median_s (MACD, period-Period3+1, period);
	
	BAR[period]= MACD[period]-SIGNAL[period];
	
	
	
end
 