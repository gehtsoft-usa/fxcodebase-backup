-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73934

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
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
    indicator:name("MACD-V Volatility normalised Momentum");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("Period1", "Fast MA Period", "", 26, 1, 2000);
    indicator.parameters:addInteger("Period2", "Slow MA Period", "", 12, 1, 2000);
    indicator.parameters:addInteger("Period3", "Signal MA Period", "", 9, 1, 2000);	
	indicator.parameters:addString("Method", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	
    indicator.parameters:addInteger("Period4", "ATR Period", "", 26, 1, 2000);	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "MACD Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Signal Line Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("color3", "Histogram Line Color", "", core.rgb(0, 0, 255)); 	 
	 
    indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("Level1", "1. Level","", 40);
	indicator.parameters:addDouble("Level2", "2. Level","", 50);
	indicator.parameters:addDouble("Level3", "3. Level","", 150); 
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
local Period1, Period2,Method, Period3; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Method=instance.parameters.Method;
	Period3=instance.parameters.Period3;
	Period4=instance.parameters.Period4;	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Period2.. "," ..  Period3  .. "," ..  Method.. "," ..   Period4 .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

	--assert(core.indicators:findIndicator("TSR BIG TREND") ~= nil, "Please, download and install TSR BIG TREND.LUA indicator"); 
	MA1= core.indicators:create(Method, source.close, Period1);
	MA2= core.indicators:create(Method, source.close, Period2);	
	ATR= core.indicators:create("ATR", source, Period4);
	first=source:first()+ math.max(Period1, Period2, Period4); 
	
	
	--Stream = instance:addInternalStream(0, 0);
 
	
	
    MACD = instance:addStream("MACD", core.Line, name, "MACD", instance.parameters.color1, first );
    MACD:setPrecision(math.max(2, instance.source:getPrecision()));
    MACD:setWidth(instance.parameters.width);
    MACD:setStyle(instance.parameters.style);
    MACD:addLevel(0);	
	MACD:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	MACD:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	MACD:addLevel(instance.parameters.Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	MACD:addLevel(-instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	MACD:addLevel(-instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	MACD:addLevel(-instance.parameters.Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);

	MA3= core.indicators:create(Method, MACD, Period3);	
	
    Signal = instance:addStream("Signal", core.Line, name, "Signal", instance.parameters.color2, first+Period3 );
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
    Signal:setWidth(instance.parameters.width);
    Signal:setStyle(instance.parameters.style);
 

    Histogram = instance:addStream("Histogram", core.Bar, name, "Histogram", instance.parameters.color3, first +Period3);
    Histogram:setPrecision(math.max(2, instance.source:getPrecision())); 
 
end


function Update(period, mode)

	ATR:update(mode); 
	MA1:update(mode); 
	MA2:update(mode); 
	
	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	  
	  	
	MACD[period]= ((MA2.DATA[period]-MA1.DATA[period])/ATR.DATA[period])*100; 

	MA3:update(mode); 		
	
	if period <= first + Period3
	or  not source:hasData(period) 
	then
	return;
	end
	

   Signal[period]=MA3.DATA[period];
   Histogram[period]=MACD[period]-Signal[period];
   
	
	
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