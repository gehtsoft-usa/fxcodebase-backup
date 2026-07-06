-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73208

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
    indicator:name("Trend Following Moving Averages");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("Period", "Range Period", "", 300, 1, 2000);
    indicator.parameters:addDouble("Rate", "Trend Channel Rate", "", 1, 0.1, 2000);
    indicator.parameters:addInteger("TrendPeriod", "Trend Period", "", 20, 1, 2000);
	
    indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addBoolean("LinearRegression", "Linear Regression", "", true);	

    indicator.parameters:addInteger("Min", "Min Period", "", 5, 1, 2000);
    indicator.parameters:addInteger("Max", "Max Period", "", 100, 1, 2000);
    indicator.parameters:addInteger("Step", "Step Period", "", 5, 1, 2000);	
	
    indicator.parameters:addInteger("LRP", "Linear Regression Period", "", 10, 1, 2000);		
	
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "Up Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color2", "Down  Line Color", "", core.rgb(255, 0, 0)); 
	indicator.parameters:addColor("color3", "Neutral Line Color", "", core.rgb(128, 128, 128)); 
		
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Line={};
local Indicator={}; 
local Source={};
local Trend={};
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period=instance.parameters.Period;
	TrendPeriod=instance.parameters.TrendPeriod;
	Rate=instance.parameters.Rate/ 100;
	Method=instance.parameters.Method;
	Min=instance.parameters.Min;
	Max=instance.parameters.Max;
	Step=instance.parameters.Step;
	LRP=instance.parameters.LRP;
	
	LinearRegression=instance.parameters.LinearRegression;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period.. "," ..  Rate .. "," ..  TrendPeriod.. "," ..  Method.. "," ..  Min.. "," ..  Max .. "," ..  Step .. "," ..  LRP .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	

	first=source:first()+Period; 
 
 
	
	for i= Min, Max, Step do 
	Indicator[i]= core.indicators:create(Method, source, i);
	Source[i]= instance:addInternalStream(0, 0);
	Trend[i]= instance:addInternalStream(0, 0);
	
    Line[i] = instance:addStream("Line"..i , core.Line, name, i.. ". Line", instance.parameters.color1, first+Max+LRP );
    Line[i]:setPrecision(math.max(2, instance.source:getPrecision()));
    Line[i]:setWidth(instance.parameters.width);
    Line[i]:setStyle(instance.parameters.style);
    Line[i]:addLevel(0);	
    end
	
	
end


function Update(period, mode)



	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	
	local min, max=mathex.minmax(source, period-Period+1, period); 
	local Change = (max - min) * Rate
 
 
    if period <= first+Max then
	return;
	end
	
	for i= Min, Max, Step do	  
	Indicator[i]:update(mode);   		
	Source[i][period]=Indicator[i].DATA[period];
	end
	

    if period <= first+Max+LRP then
	return;
	end	
 
	
	for i= Min, Max, Step do	 

	
		if LinearRegression then 
		Line[i][period]=mathex.lreg(Source[i], period-LRP+1, period);
		else
		Line[i][period]= Source[i][period];
		end
		
		 
	end	

    if period <= first+Max+LRP+TrendPeriod then
	return;
	end		
 
	for i= Min, Max, Step do	
    	min,max=mathex.minmax(Line[i], period-TrendPeriod+1, period );
		diff=math.abs(max-min);
		  if diff>Change then 
			 if Line[i][period]>min+Change then 
				   Trend[i][period]=1
				  elseif Line[i][period] <max-Change then 
				   Trend[i][period]=-1
				  else
				   Trend[i][period]=0
				  end
			 else
				   Trend[i][period]=0
			 end
			 
			if Trend[i][period]> 0 then
			Line[i]:setColor(period,  instance.parameters.color1);
			elseif Trend[i][period]< 0 then
			Line[i]:setColor(period,  instance.parameters.color2);	
			else
			Line[i]:setColor(period,  instance.parameters.color3);
			end	
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