-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72709

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
    indicator:name("Fibonacci auto channel");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "", 50, 1, 2000);
    indicator.parameters:addDouble("Level1", "1. Level", "", 0.764  );
    indicator.parameters:addDouble("Level2", "2. Level", "", 0.618  );
    indicator.parameters:addDouble("Level3", "3. Level", "", 0.500  );
    indicator.parameters:addDouble("Level4", "4. Level", "", 0.382  );
    indicator.parameters:addDouble("Level5", "5. Level", "", 0.236  );
	
	indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(255, 0, 0)); 
	indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(255, 0, 0)); 
	indicator.parameters:addColor("color3", "3. Line Color", "", core.rgb(0, 0, 255)); 
	indicator.parameters:addColor("color4", "4. Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color5", "5. Line Color", "", core.rgb(0, 255, 0)); 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period; 
local Fibo={};
local Level={};
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period=instance.parameters.Period;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
 
	first=source:first()+Period ; 
 
 
	
    for i= 1, 5, 1 do	
	Level[i]= instance.parameters:getDouble("Level" .. i)
    Fibo[i] = instance:addStream("Line".. i, core.Line, name, i ..". Line", instance.parameters:getColor("color" .. i), first );
    Fibo[i]:setPrecision(math.max(2, instance.source:getPrecision()));
    Fibo[i]:setWidth(instance.parameters.width);
    Fibo[i]:setStyle(instance.parameters.style);
    Fibo[i]:addLevel(0);	
    end
	
end


function Update(period, mode)

 

	 if period <= first then
	 return;
	 end
	 
    local ll, hh = mathex.minmax(source, period-Period+1, period)
 
 
    for i= 1, 5, 1 do
	Fibo[i][period] = (hh-ll)*Level[i]+ll
    end
	
 
	
end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

