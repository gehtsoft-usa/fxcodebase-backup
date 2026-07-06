-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72876

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
    indicator:name("Smoothed Filter");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addDouble("percentage", "Percentage", "", 10, 0, 100);  
	indicator.parameters:addBoolean("candles", "Paint the candles", "Paint the candles", true);

	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Up Trend Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Down Trend Line Color", "", core.rgb(255, 0, 0)); 
	 
	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local percentage, candles;  
	
-- Routine
 function Prepare(nameOnly)   
 
    
	percentage=instance.parameters.percentage;
	candles=instance.parameters.candles;
	source = instance.source
	
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  percentage  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	percentage = percentage/100	
	
	 
	first=source:first() ;  
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color1, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
	
	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
	if candles then
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);	
    end
end


function Update(period, mode)

    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	

	 if period <= first then
	 Line[period]=source.median[period];
	 open:setColor(period, core.rgb(128, 128, 128));		 
	 return;
	 end
	 
    local MyHigh = source.close[period] + source.close[period] * percentage
	local MyLow = source.close[period] - source.close[period] * percentage	 
	  
	Line[period]=Line[period-1]; 
	
	if MyLow > Line[period] then
	Line[period] = MyLow
	end
	 
	if MyHigh < Line[period] then
	Line[period] = MyHigh
    end
	
	
	if source.close[period] > Line[period] then
    Line:setColor(period, instance.parameters.color1);	
	open:setColor(period,instance.parameters.color1);	
	else
    Line:setColor(period, instance.parameters.color2);	
	open:setColor(period,instance.parameters.color2);	
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
