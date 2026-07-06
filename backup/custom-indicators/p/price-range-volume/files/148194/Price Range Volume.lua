-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72908

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
    indicator:name("Price Range Volume");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "", 14);	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 0, 255)); 
	 indicator.parameters:addColor("color2", "Up Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color3", "Down Line Color", "", core.rgb(255, 0, 0)); 	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Previous;  
	
-- Routine
 function Prepare(nameOnly)   
 
	Period=instance.parameters.Period;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name() .. ", " ..  Period  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end 
	
    up= instance:addInternalStream(0, 0);
    down= instance:addInternalStream(0, 0);
	trend= instance:addInternalStream(0, 0);
	
	
	first=source:first() ; 
	 
    Trend = instance:addStream("Trend", core.Line, name, "Trend", instance.parameters.color1, first+Period );
    Trend:setPrecision(math.max(2, instance.source:getPrecision()));
    Trend:setWidth(instance.parameters.width);
    Trend:setStyle(instance.parameters.style);
    Trend:addLevel(0);	
 
 
 
    Up = instance:addStream("Up", core.Line, name, "Up", instance.parameters.color2, first+Period );
    Up:setPrecision(math.max(2, instance.source:getPrecision()));
    Up:setWidth(instance.parameters.width);
    Up:setStyle(instance.parameters.style);
    Up:addLevel(0);
	
	Down = instance:addStream("Down", core.Line, name, "Down", instance.parameters.color3, first+Period );
    Down:setPrecision(math.max(2, instance.source:getPrecision()));
    Down:setWidth(instance.parameters.width);
    Down:setStyle(instance.parameters.style);
    Down:addLevel(0);
end


function Update(period, mode)

 
	
	 	

	 if period <= first  then
	 return;
	 end
	 
	 
	  
	local Range=source.high[period]- source.low[period];
 	local Close=  ((source.close[period] - source.low[period] ) / (Range/100))    
	local Open=	 ((source.open[period] - source.low[period] ) / (Range/100))
	
	if Close > Open then
	Value= (source.volume[period]/100) * (Close - Open);
	trend[period]=   Value;	
	up[period]=  Value;
	down[period]= (source.volume[period]- Value);
	elseif Close < Open then
	Value=(source.volume[period]/100) * (Open - Close);
	trend[period]= Value ;
	up[period]= (source.volume[period]- Value);
	down[period]= Value;	
	else	 
	trend[period]= trend[period-1] ;
	up[period]= up[period-1];
	down[period]= down[period-1];		
	end
	
	
	 if period <= first	+Period  then
	 return;
	 end	
	
	Trend[period]= mathex.sum(trend, period-Period+1,period);
	Up[period]= mathex.sum(up, period-Period+1,period);
	Down[period]= mathex.sum(down, period-Period+1,period);
	
	
	
	
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
