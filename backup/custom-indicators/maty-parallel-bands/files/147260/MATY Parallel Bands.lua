-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72669

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
    indicator:name("MATY Parallel Bands");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "", 20, 1, 2000);
    indicator.parameters:addDouble("Increment", "Increment (In Pips)", "", 10, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255)); 
	 indicator.parameters:addColor("Top", "Top Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("Bottom", "Bottom Line Color", "", core.rgb(255, 0, 0)); 	
 		 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period, Increment; 
local Indicator;
local Line={};	
-- Routine
 function Prepare(nameOnly)   
 
    

	source = instance.source
	
	Period=instance.parameters.Period;
	Increment=instance.parameters.Increment*source:pipSize();	
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period.. "," ..  Increment  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Indicator= core.indicators:create("MVA", source.typical, Period );
	first=Indicator.DATA:first() +1; 
	
	 
	
    Line[0] = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first );
    Line[0]:setPrecision(math.max(2, instance.source:getPrecision()));
    Line[0]:setWidth(instance.parameters.width);
    Line[0]:setStyle(instance.parameters.style);
    Line[0]:addLevel(0);	
 
    for i= 1, 5, 1 do
    Line[10+i] = instance:addStream("Top"..i, core.Line, name, i.. ". Top", instance.parameters.Top, first );
    Line[10+i]:setPrecision(math.max(2, instance.source:getPrecision()));
    Line[10+i]:setWidth(instance.parameters.width);
    Line[10+i]:setStyle(instance.parameters.style);
    Line[10+i]:addLevel(0);
	
    Line[20+i] = instance:addStream("Bottom"..i, core.Line, name, i.. ". Bottom", instance.parameters.Bottom, first );
    Line[20+i]:setPrecision(math.max(2, instance.source:getPrecision()));
    Line[20+i]:setWidth(instance.parameters.width);
    Line[20+i]:setStyle(instance.parameters.style);
    Line[20+i]:addLevel(0);	
	end
end


function Update(period, mode)

	Indicator:update(mode); 

   
	 if period <= first  then
	 return;
	 end
	 
    Line[0][period]=Indicator.DATA[period]
	
    for i= 1, 5 , 1 do
	
		Line[10+i][period]= Indicator.DATA[period-1]+i*Increment;
		Line[20+i][period]= Indicator.DATA[period-1]-i*Increment;	
	end
  
	
end