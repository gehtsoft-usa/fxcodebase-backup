-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=58939

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
    indicator:name("Elastic Volume Weighted Moving Average HiLo Bands");
    indicator:description("Elastic Volume Weighted Moving Average");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period1", "Period", "Period", 20);
    indicator.parameters:addInteger("Period2", "Lookback", "Lookback", 10);	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("EVWMA_color", "Color of EVWMA", "Color of EVWMA", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Trend_color", "Color of Trend", "Color of Trend", core.rgb(255, 0, 0));	
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;

-- Streams block
local EVWMA = nil;

-- Routine
function Prepare(nameOnly)
    Period1 = instance.parameters.Period1;
    Period2 = instance.parameters.Period2;	
	
   Transparency= instance.parameters.Transparency;
   Transparency= 100-Transparency;

   
    source = instance.source;
    first = source:first()+1+Period1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period1) .. ", " .. tostring(Period2)  .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
  
	
	Top = instance:addInternalStream(0, 0);
	Bottom = instance:addInternalStream(0, 0);
	Color = instance:addInternalStream(0, 0);
	
    EVWMA = instance:addStream("EVWMA", core.Line, name, "EVWMA", instance.parameters.EVWMA_color, first );
	EVWMA:setWidth(instance.parameters.width);
    EVWMA:setStyle(instance.parameters.style);
    EVWMA:setPrecision(math.max(2, instance.source:getPrecision()));	
	
    Trend = instance:addStream("Trend", core.Line, name, "Trend", instance.parameters.Trend_color, first+math.max(Period1, Period2));
	Trend:setWidth(instance.parameters.width);
    Trend:setStyle(instance.parameters.style);	
    Trend:setPrecision(math.max(2, instance.source:getPrecision()));	    
	
	
	instance:createChannelGroup("Group","Group" , EVWMA, Trend, instance.parameters.EVWMA_color, Transparency);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)


    if period <= first then
	return;
	end
	
	local Total = mathex.sum(source.volume, period-Period1+1, period);	
	
    EVWMA[period] = ((Total-source.volume[period])*EVWMA[period-1]+ source.volume[period]*source.close[period])/Total;
		
    if period <= first + Period1 then
	return;
	end	
    local min, max = mathex.minmax(EVWMA, period-Period1+1, period);	
	
    Top[period] = max;	
    Bottom[period] = min;
 
    if period <= first +math.max(Period1, Period2) then
	return;
	end	
 
	if EVWMA[period]>Top[period-Period2+1] then
	Trend[period] = Bottom[period]
	Color[period]=1;
	elseif EVWMA[period]<Bottom[period-Period2+1] then
	Trend[period] = Top[period]
	Color[period]=-1;
	else
	Trend[period]=Trend[period-1];
	Color[period]=Color[period-1];	
	end 
	 

    if Color[period]== 1 then
	EVWMA:setColor(period,  instance.parameters.EVWMA_color);
	else
	EVWMA:setColor(period,  instance.parameters.Trend_color);
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

