-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72392

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
    indicator:name("Volatility Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("length", "Length", "", 100, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255)); 
	indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source,spike;
local length; 
 
	
-- Routine
 function Prepare(nameOnly)   
 
    
	length=instance.parameters.length;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  length  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
 
	first=source:first()+length ; 
 
	
	
    spike = instance:addStream("Spike", core.Line, name, "Spike", instance.parameters.color, first );
    spike:setPrecision(math.max(2, instance.source:getPrecision()));
    spike:setWidth(instance.parameters.width);
    spike:setStyle(instance.parameters.style);
    spike:addLevel(0);	
	
	
    Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.color1, first + length );
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
    Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style);
    Top:addLevel(0);		
 
    Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.color2, first + length );
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style);
    Bottom:addLevel(0);		
end


function Update(period, mode)

 

	 if period <= first then
	 return;
	 end
	 
     
    spike[period]=source.close[period]-source.open[period];
	
	if period <= first + length then
	 return;
	 end
	Top[period]= mathex.stdev(spike, period-length+1, period);
	Bottom[period]= -1*Top[period];	
end


 