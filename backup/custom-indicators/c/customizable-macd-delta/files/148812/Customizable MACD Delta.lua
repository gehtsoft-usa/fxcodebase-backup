-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73079

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
    indicator:name("Customizable MACD Delta");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("MACD Calculation");	 
	
    indicator.parameters:addString("Price1", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "WEIGHTED", "", "weighted");	

	
    indicator.parameters:addString("Method1", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method1", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method1", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method1", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method1", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method1", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method1", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method1", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method1", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method1", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method1", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method1", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method1", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method1", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method1", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method1", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method1", "JSmooth", "", "JSmooth");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method1", "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "HPF", "", "HPF");
    indicator.parameters:addStringAlternative("Method1", "VAMA", "", "VAMA");
	
    indicator.parameters:addInteger("Period1", "Fast MA", "", 20, 1, 2000);
    indicator.parameters:addInteger("Period2", "Slow MA", "", 40, 1, 2000);
    indicator.parameters:addDouble("Sensitive", "Sensitive", "", 50, 1, 2000);
	
	 
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Up Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Down Color", "", core.rgb(255, 0, 0)); 

 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Method, Period1, Period2,Sensitive; 
local Fast, Slow;
	
-- Routine
 function Prepare(nameOnly)   
 
    Method1=instance.parameters.Method1;
	
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Sensitive=instance.parameters.Sensitive;
	
	 
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name() .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Fast= core.indicators:create("AVERAGES", source, Method1,  Period1);
	Slow= core.indicators:create("AVERAGES", source, Method1,  Period2); 
	first=math.max(Fast.DATA:first(),Slow.DATA:first()) ; 
	
	
	MACD = instance:addInternalStream(0, 0);
 
	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color1, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
	
    Bar = instance:addStream("Bar", core.Bar, name, "Bar", instance.parameters.color1, first );
    Bar:setPrecision(math.max(2, instance.source:getPrecision())); 
    Bar:addLevel(0);		
 
end


function Update(period, mode)

	Fast:update(mode); 
	Slow:update(mode); 
	
	if period <= first then
	return;
	end
	
	MACD[period]=Fast.DATA[period]-Slow.DATA[period];
	 
    Line[period] = (MACD[period]-MACD[period-1]) * Sensitive;	 
    Bar[period]= Line[period];
    
   if Line[period] > 0 then
   Bar:setColor(period,  instance.parameters.color1);	
   Line:setColor(period,  instance.parameters.color1);	
   else
   Bar:setColor(period,  instance.parameters.color2);	
   Line:setColor(period,  instance.parameters.color2);	
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