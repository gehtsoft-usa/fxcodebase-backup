-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73601

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
    indicator:name("Cong Adaptive Moving Average");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("lookback", "Lookback Period", "", 10, 1, 2000);
	
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
local lookback;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	lookback=instance.parameters.lookback;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  lookback  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	 
	first=source:first() +lookback; 
	wtr = instance:addInternalStream(0, 0);
	 
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first);
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style); 
 
end


function Update(period, mode)
 

	if period <= first
	or  not source:hasData(period) 
	then
	return;	
	end
	
    local  ll, hh  = mathex.minmax(source, period-lookback+1, period);  
    wtr[period] = WTR(period) 

    Line[period] = source.close[period];
	
	if period <= first+lookback
	or  not source:hasData(period) 
	then
	return;	
	end
	
    local  effort = mathex.sum(wtr, period-lookback+1, period); 
	
    local  result = hh - ll
    local  alpha  = result / effort
    local  d = (1.0 - alpha) * Line[period-1]
    Line[period] = alpha * source.close[period] + d
 
end


function WTR ( period)


    if period==first then
        return source.high[period] - source.low[period]
    else
        return math.max( source.high[period] - source.low[period], source.high[period] - source.close[period-1] ,     source.close[period-1]-source.low[period] )
	end
	
				 
end


function maCongAdaptive ( period )
   

 
end


--[[
 
maCongAdaptive (
 int   length = 10 ,
 float sClose = close ,
 float sHigh  = high  ,
 float sLow   = low   ) =>
    float result_cama = sClose
    float hh  = ta.highest(sHigh, length)
    float ll  = ta.lowest( sLow , length)
    float wTR = wTR(sClose, sHigh, sLow)
    float effort = math.sum(wTR, length)
    float result = hh - ll
    float alpha  = result / effort
    if bar_index > length
        float d = (1.0 - alpha) * result_cama[1]
        result_cama := alpha * sClose + d
    result_cama

 
]] 


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