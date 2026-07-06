-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72661

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--Your donations will allow the service to continue onward.
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
    indicator:name("Force Indicator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("p", "Period", "", 20, 1, 2000);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
    indicator.parameters:addDouble("STDstart", "STDstart", "", 0.1, 0, 2000);
    indicator.parameters:addDouble("STDmax", "STDmax", "", 10, 0, 2000);
    indicator.parameters:addDouble("STDstep", "STDstep", "", 0.1, 0, 2000);	
 	
	
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
local p,Method;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	p=instance.parameters.p;
	Method=instance.parameters.Method;
	STDstart=instance.parameters.STDstart;
	STDmax=instance.parameters.STDmax;
	STDstep=instance.parameters.STDstep;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  p.. "," ..  Method .. "," ..  STDstart.. "," ..  STDmax .. "," ..  STDstep  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Average= core.indicators:create(Method, source, p);
	first=Average.DATA:first() ; 
	
	
	--Stream = instance:addInternalStream(0, 0);
 
	
	
    Force = instance:addStream("Force", core.Line, name, "Force", instance.parameters.color1, first );
    Force:setPrecision(math.max(2, instance.source:getPrecision()));
    Force:setWidth(instance.parameters.width);
    Force:setStyle(instance.parameters.style);
    Force:addLevel(0);	
 
end


function Update(period, mode)

	Average:update(mode); 



	 if period <= first then
	 return;
	 end
	 
    local stdev=mathex.stdev(source, period-p+1, period);  
		
	Force[period]= 0;
	
	
	if source[period] > Average.DATA[period] then 
	a = STDstart
	     while a <= STDmax do

			 if source[period] > Average.DATA[period] + a*stdev then
			   Force[period] = Force[period] + 1
			   a = a + STDstep
			  else
			   break
			  end 		  
	      end
	
	else 
	  	 
	a = -STDstart
		 while a >= -STDmax do   
			 if source[period] < Average.DATA[period] + a*stdev then
			   Force[period] = Force[period] - 1
			   a = a - STDstep
			  else
			   break
			  end 	
		 end  
	
	
	end
	
	
	
	if Force[period]> Force[period-1] then 
	Force:setColor(period,  instance.parameters.color1);	
	else
	Force:setColor(period,  instance.parameters.color2);		
	end
	
end

--[[


 
if close > Average[p, AveType](close) then
 a = STDstart
 force = 0
		 while a <= STDmax
		  if close > Average[p, AveType](close) + a*stdev then
		   force = force + 1
		   a = a + STDstep
		  else
		   break
		  endif
		 wend
endif
 
if close < Average[p, AveType](close) then
 a = -STDstart
 force = 0
		 while a >= -STDmax
		  if close < Average[p, AveType](close) + a*stdev then
		   force = force - 1
		   a = a - STDstep
		  else
		   break
		  endif
		 wend
endif
 
 
]]

