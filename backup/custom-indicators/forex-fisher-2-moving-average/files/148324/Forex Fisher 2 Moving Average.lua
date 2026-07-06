-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72690

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
    indicator:name("Forex Fisher 2 Moving Average");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "", 10, 1, 2000);
    indicator.parameters:addInteger("Period1", "1. MA Period", "", 9, 1, 2000);
    indicator.parameters:addInteger("Period2", "2. MA Period", "", 45, 1, 2000);	

 	indicator.parameters:addGroup("RSI Calculation");	 
    indicator.parameters:addInteger("RSI_Period", "Period", "", 14, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Fisher Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Fast MA Line Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("color3", "Slow MA Line Color", "", core.rgb(0, 0, 255)); 	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period1, Period2; 
local Indicator;
local RSI_Period, RSI;	
-- Routine
 function Prepare(nameOnly)   
 
 	Period=instance.parameters.Period;   
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	RSI_Period=instance.parameters.RSI_Period;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period .. "," ..  Period1.. "," ..  Period2 .. "," ..  RSI_Period .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
    RSI= core.indicators:create("RSI", source.close, RSI_Period);
	first=source:first() + Period; 
	
	
	Value = instance:addInternalStream(0, 0);
 
	
	
    Fisher = instance:addStream("Fisher", core.Line, name, "Fisher", instance.parameters.color1, first );
    Fisher:setPrecision(math.max(2, instance.source:getPrecision()));
    Fisher:setWidth(instance.parameters.width);
    Fisher:setStyle(instance.parameters.style);
    Fisher:addLevel(0);	
 
	MA1= core.indicators:create("MVA", Fisher, Period1);
	
    Fast = instance:addStream("Fast", core.Line, name, "Fast", instance.parameters.color2,  MA1.DATA:first()  );
    Fast:setPrecision(math.max(2, instance.source:getPrecision()));
    Fast:setWidth(instance.parameters.width);
    Fast:setStyle(instance.parameters.style);
    Fast:addLevel(0);	

	MA2= core.indicators:create("LWMA", Fast, Period2);
	
    Slow = instance:addStream("Slow", core.Line, name, "Slow", instance.parameters.color3,  MA2.DATA:first()  );
    Slow:setPrecision(math.max(2, instance.source:getPrecision()));
    Slow:setWidth(instance.parameters.width);
    Slow:setStyle(instance.parameters.style);
    Slow:addLevel(0);	
end


function Update(period, mode)

	RSI:update(mode); 
	
	if period <= first then
	return;
	end
	
	
	if period>RSI.DATA:first() then
	local  Text = " RSI:" .. string.format("%." .. 2 .. "f", RSI.DATA[period]); 
    core.host:execute("setStatus", Text); 
    end
 
	 
	 
	local MinL, MaxH= mathex.minmax(source, period-Period+1, period); 
 
 
 	if period <= source:first()+2 then
	return;
	end
 
    Value[period] = 0.33*2*((source.close[period]-MinL)/(MaxH-MinL)-0.5) + 0.67*Value[period-1] 
    Fisher[period] = 0.5*math.log((1+Value[period])/(1-Value[period]))+0.5*Fisher[period-1]
 
 
	MA1:update(mode); 

	
 	if period <=  MA1.DATA:first()  then
	return;
	end	
 
    Fast[period]= MA1.DATA[period];
	
	
	MA2:update(mode); 	
 	if period <=  MA2.DATA:first()  then
	return;
	end	
	
    Slow[period]= MA2.DATA[period];
 
 
	
end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
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


