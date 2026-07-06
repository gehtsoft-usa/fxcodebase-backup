-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73933

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
    indicator:name("Relative Trend Index");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("StddevLength", "Stddev Length", "", 20, 1, 2000); 
    indicator.parameters:addInteger("TrendLength", "Trend Length", "", 200, 1, 2000);
    indicator.parameters:addInteger("SignalLength", "Signal Length ", "", 20, 1, 2000);
	
	indicator.parameters:addString("Method", "Signal MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");	
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Relative Trend Index  Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Signal Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local StddevLength, TrendLength  , SignalLength ;  
	
-- Routine
 function Prepare(nameOnly)   
 
    
	TrendLength  =instance.parameters.TrendLength  ;
	SignalLength =instance.parameters.SignalLength ;
	Method =instance.parameters.Method;
	StddevLength=instance.parameters.StddevLength;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," .. StddevLength .. "," ..  TrendLength  .. "," ..  SignalLength .. "," ..   Method   .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 

	first=source:first()+StddevLength ; 
	
	uppertrend = instance:addInternalStream(0, 0);
	lowertrend = instance:addInternalStream(0, 0); 		
	
    RelativeTrendIndex = instance:addStream("RelativeTrendIndex", core.Line, name, "RelativeTrendIndex", instance.parameters.color1, first+TrendLength );
    RelativeTrendIndex:setPrecision(math.max(2, instance.source:getPrecision()));
    RelativeTrendIndex:setWidth(instance.parameters.width);
    RelativeTrendIndex:setStyle(instance.parameters.style);
    RelativeTrendIndex:addLevel(0);	
	
	Signal= core.indicators:create(Method, RelativeTrendIndex, SignalLength);
	
 
    RelativeTrendIndexSignal = instance:addStream("RelativeTrendIndexSignal", core.Line, name, "RelativeTrendIndexSignal", instance.parameters.color2, first+TrendLength+SignalLength );
    RelativeTrendIndexSignal:setPrecision(math.max(2, instance.source:getPrecision()));
    RelativeTrendIndexSignal:setWidth(instance.parameters.width);
    RelativeTrendIndexSignal:setStyle(instance.parameters.style);
    RelativeTrendIndexSignal:addLevel(0);	
	
end


function Update(period, mode)



	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	  
    local StdDev= mathex.stdev(source, period-StddevLength+1, period);
	
	uppertrend[period]  = source[period]+StdDev;
	lowertrend[period]   = source[period]-StdDev;
	
	if period <= first + TrendLength
	or  not source:hasData(period) 
	then
	return;
	end	
	
	
	local UpperTrendHigh = mathex.max(uppertrend, period-TrendLength+1, period)
	local LowerTrendLow =  mathex.min(lowertrend, period-TrendLength+1, period)

	
	RelativeTrendIndex[period]=  ((source[period] - LowerTrendLow) / (UpperTrendHigh - LowerTrendLow)) * 100;
	
	Signal:update(mode); 

	if period <= first + TrendLength + SignalLength
	or  not source:hasData(period) 
	then
	return;
	end		
	
    RelativeTrendIndexSignal[period]=Signal.DATA[period];	
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