-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=34513


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

function Init()
    indicator:name("Intraday Intensity Index");
    indicator:description("Intraday Intensity Index");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 21); 
	
	indicator.parameters:addGroup("Style");		
    indicator.parameters:addColor("III_color1", "Color of INT", "Color of INT", core.rgb(0, 255, 0));	
    indicator.parameters:addColor("III_color2", "Color of SUM", "Color of SUM", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
  
local first;
local source = nil;
local Period;
local Normalized;
-- Streams block
local III = nil;
local Raw;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Normalized = instance.parameters.Normalized;
    source = instance.source;
    first = source:first()+Period;
	
	 assert(source:supportsVolume(), "The source must have volume");

    local name = profile:id() .. "(" .. source:name() .. ", " .. Period  .. ")";
    instance:name(name);
	
    if   (nameOnly) then
        return;
    end
 
 
        INT = instance:addStream("INT", core.Bar, name, "INT", instance.parameters.III_color1, source:first());
        INT:setPrecision(math.max(2, instance.source:getPrecision()));

		
        SUM = instance:addStream("SUM", core.Line, name, "SUM", instance.parameters.III_color2, first);
        SUM:setPrecision(math.max(2, instance.source:getPrecision()));
		SUM:setWidth(instance.parameters.width);
        SUM:setStyle(instance.parameters.style);
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)



    if period <= source:first()   then
	return;	
	end
	

    local K1 =  (2*source.close[period]-source.high[period]-source.low[period])*source.volume[period];

	if source.high[period] ~= source.low[period] then
	 K2= source.high[period]-source.low[period]
	else
	 K2=1
	end 
	
	INT[period]= K1/K2;
	
    if period <= first   then
	return;	
	end
	
	 
	SUM[period]=  mathex.sum(INT, period-Period+1, period) 
 
	 
        
    
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

