-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73710

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
    indicator:name("Momentum Linear Regression");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("Period1", "Momentum Period", "", 10, 1, 2000);
    indicator.parameters:addInteger("Period2", "Linear Regression Period", "", 14, 1, 2000);
    indicator.parameters:addInteger("Period3", "Shift", "", 1, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Up Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Down Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period1, Period2,Period3; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Period3=instance.parameters.Period3;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Period2 .. "," ..  Period3 .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 
	first=source:first() ; 
	
	
	Momentum = instance:addInternalStream(0, 0);
 
	
	
    LinearRegression = instance:addStream("LinearRegression", core.Line, name, "LinearRegression", instance.parameters.color1, first );
    LinearRegression:setPrecision(math.max(2, instance.source:getPrecision()));
    LinearRegression:setWidth(instance.parameters.width);
    LinearRegression:setStyle(instance.parameters.style);
    LinearRegression:addLevel(0);	
	
    Decay = instance:addStream("Decay", core.Line, name, "Decay", instance.parameters.color1, first );
    Decay:setPrecision(math.max(2, instance.source:getPrecision()));
    Decay:setWidth(instance.parameters.width);
    Decay:setStyle(instance.parameters.style);
    Decay:addLevel(0);		
 
end


function Update(period, mode)
 

	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	 
	Momentum[period]=source[period]-source[period-Period1+1]
	
	if period <= first + Period2
	or  not source:hasData(period) 
	then
	return;
	end	
	  	
	LinearRegression[period]= mathex.lreg(Momentum, period-Period2+1, period);

	
	if period <= first + Period2+ Period3
	or  not source:hasData(period) 
	then
	return;
	end		
	
	Decay[period]=LinearRegression[period-Period3]
	
	if LinearRegression[period] > Decay[period] then
    LinearRegression:setColor(period, instance.parameters.color1);
    Decay:setColor(period, instance.parameters.color1);		
	else
    LinearRegression:setColor(period, instance.parameters.color2);	
    Decay:setColor(period, instance.parameters.color2);		
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