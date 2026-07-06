-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72726

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
    indicator:name("M-Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "", 14, 1, 2000); 
    indicator.parameters:addInteger("Period1", "1. Period", "", 5, 1, 2000); 
    indicator.parameters:addInteger("Period2", "2. Period", "", 3, 1, 2000); 
    indicator.parameters:addInteger("Period3", "3. Period", "", 3, 1, 2000); 	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "Histogram Color", "", core.rgb(0, 0, 255)); 
	indicator.parameters:addColor("color2", "Oscillator Line Color", "", core.rgb(255, 0, 0)); 
	indicator.parameters:addColor("color3", "Signal Line Color", "", core.rgb(0, 255, 0)); 
	
	
    indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("Level1", "1. Level","", -5);
	indicator.parameters:addDouble("Level2", "2. Level","", 5);
	indicator.parameters:addDouble("Level3", "3. Level","", -10); 
	indicator.parameters:addDouble("Level4", "4. Level","", 10); 	
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);		
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period,Period1, Period2, Period3; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period=instance.parameters.Period;
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Period3=instance.parameters.Period3;	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period .. "," .. Period1 .. "," .. Period2 .. "," .. Period3.. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	

	first=source:first()+Period ; 
	
	
	S = instance:addInternalStream(0, 0);
 
    Indicator1= core.indicators:create("EMA", S, Period1);	
    Indicator2= core.indicators:create("EMA", Indicator1.DATA, Period2);	
    Indicator3= core.indicators:create("EMA", Indicator2.DATA, Period3);		
	
    Histogram = instance:addStream("Histogram", core.Bar, name, "Histogram", instance.parameters.color1, first  + Period1+ Period2+Period3);
    Histogram:setPrecision(math.max(2, instance.source:getPrecision())); 
    Histogram:addLevel(0);	
	Histogram:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Histogram:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Histogram:addLevel(instance.parameters.Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Histogram:addLevel(instance.parameters.Level4, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
 
	
    Oscillator = instance:addStream("Oscillator", core.Line, name, "Oscillator", instance.parameters.color2, first );
    Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
    Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    Oscillator:addLevel(0);	
	
    Signal = instance:addStream("Signal", core.Line, name, "Signal", instance.parameters.color3, first );
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
    Signal:setWidth(instance.parameters.width);
    Signal:setStyle(instance.parameters.style);
    Signal:addLevel(0);	 
end


function Update(period, mode)

 
	 if period <= first then
	 return;
	 end
	 
	S[period]      = 0
	for i  = 1 , Period , 1 do
 
	    if (source[period] - source[period-i]) > 0 then
        S[period] = S[period] + 1; 
        else
        S[period] = S[period] - 1; 
        end 
  
	end 
	
	
	Indicator1:update(mode); 
	Indicator2:update(mode); 
	Indicator3:update(mode); 	
	
    if period < first  + Period1+ Period2+Period3	then 
	return;
	end
	Histogram[period]= Indicator1.DATA[period];
	Oscillator[period]= Indicator2.DATA[period];
	Signal[period]= Indicator3.DATA[period];	
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