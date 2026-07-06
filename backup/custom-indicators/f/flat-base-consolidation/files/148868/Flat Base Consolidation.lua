-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73097

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



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Flat Base Consolidation");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period1", "Fast MA", "", 10, 1, 2000);
    indicator.parameters:addInteger("Period2", "Slow MA", "", 40, 1, 2000);
    indicator.parameters:addInteger("Period3", "Range Period", "", 5, 1, 2000);	
    indicator.parameters:addDouble("Level1", "Spread Level", "", 0, 0, 2000);		
    indicator.parameters:addDouble("Level2", "Flatrange Level", "", 15, 0, 2000);			
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
local Period1, Period2,Period3, Level1, Level2; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Period3=instance.parameters.Period3;
	Level1=instance.parameters.Level1;
	Level2=instance.parameters.Level2;
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Period2 .. "," ..  Period3.. "," ..  Level1 .. "," ..  Level2 .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Fast= core.indicators:create("MVA", source.close, Period1);
	Slow= core.indicators:create("MVA", source.close, Period2);	
	first=math.max(Fast.DATA:first(),Slow.DATA:first(), Period3) ; 
	
	 
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style); 
 
end


function Update(period, mode)

	  Fast:update(mode); 
	  Slow:update(mode); 
	  
	 if period <= first then
	 return;
	 end
	 
	 
	local Spread = ((Fast.DATA[period]/Slow.DATA[period])-1)*100
	
	local min, max=mathex.minmax(source, period-Period3+1, period);
	local Flatrange = math.abs((min-max)/source.close[period])*100	 
 
 	
	  	
	if  Fast.DATA[period]>Slow.DATA[period]  and Spread>Level1 and source.close[period] > Fast.DATA[period] and Flatrange<=Level2 then
	Line[period]= 1;
	else
	Line[period]= 0;	
	end
	
 
	
	
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