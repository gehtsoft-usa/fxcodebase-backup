-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73026

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
    indicator:name("ATR adaptive Laguerre filter with levels");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period1", "Period", "", 14, 1, 2000);
    indicator.parameters:addInteger("Period2", "Levels Period", "", 14, 0, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 128, 0)); 
	 indicator.parameters:addColor("color1", "Upper Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Lower Line Color", "", core.rgb(255, 0, 0)); 	 
	 indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);
	 
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
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
    Transparency= instance.parameters.Transparency;
    Transparency= 100-Transparency;
   
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Period2  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	ATR= core.indicators:create("ATR", source, Period1  );
	first=ATR.DATA:first()+Period1 ; 
	
	
 
	 l0 = instance:addInternalStream(0, 0);
	 l1 = instance:addInternalStream(0, 0);
	 l2 = instance:addInternalStream(0, 0);
	 l3 = instance:addInternalStream(0, 0);
	
	
    Laguerre = instance:addStream("Laguerre", core.Line, name, "Laguerre", instance.parameters.color, first );
    Laguerre:setPrecision(math.max(2, instance.source:getPrecision()));
    Laguerre:setWidth(instance.parameters.width);
    Laguerre:setStyle(instance.parameters.style);
 
 
    Upper = instance:addStream("Upper", core.Line, name, "Upper", instance.parameters.color1, first );
    Upper:setPrecision(math.max(2, instance.source:getPrecision()));
    Upper:setWidth(instance.parameters.width);
    Upper:setStyle(instance.parameters.style);

    Lower = instance:addStream("Lower", core.Line, name, "Lower", instance.parameters.color2, first );
    Lower:setPrecision(math.max(2, instance.source:getPrecision()));
    Lower:setWidth(instance.parameters.width);
    Lower:setStyle(instance.parameters.style);


	Line = instance:addInternalStream(0, 0); 
	instance:createChannelGroup("Group","Group" , Laguerre, Line,  instance.parameters.color, Transparency);	
end


function Update(period, mode)

	ATR:update(mode); 

	 if period <= first  then	 
	 l0[period] = source.close[period];
	 l1[period] = source.close[period];
	 l2[period] = source.close[period];
	 l3[period] = source.close[period];	 
	 Laguerre[period] = source.close[period];	 
	 return;
	 end
	  
	local min, max=mathex.minmax(ATR.DATA, period-Period1+1, period)  	 
		
	if min~=max then 
	 coeff=1-(ATR.DATA[period]-min)/(max-min)
	else
	 coeff=0.5
	end
	
	coeff = (coeff+1.0)/2.0 
	Period = Period1*coeff 
	gamma = 1.0 - 10.0/(Period+9.0)		
	
 
	 l0[period] = (1 - gamma) * source[period] + gamma * l0[period-1]
	 l1[period] = -gamma * l0[period] + l0[period-1] + gamma * l1[period-1]
	 l2[period] = -gamma * l1[period] + l1[period-1] + gamma * l2[period-1]
	 l3[period] = -gamma * l2[period] + l2[period-1] + gamma * l3[period-1]
	 Laguerre[period] = (l0[period] + 2 * l1[period] + 2 * l2[period] + l3[period]) / 6;
	 
	 
 
	 alpha = 2.0/(1.0+Period2)
	 
	 Upper[period]=Upper[period-1];
	 Lower[period]=Lower[period-1];
	
	 
	 Laguerre:setColor(period, instance.parameters.color);	 
	 
	 if  Laguerre[period]>Lower[period-1] then
	  Upper[period] = Upper[period-1]+alpha*( Laguerre[period]-Upper[period-1]) 
	 end 
	 if  Laguerre[period]<Upper[period-1] then
	  Lower[period] = Lower[period-1]+alpha*( Laguerre[period]-Lower[period-1])   	  
     end
	 
	if Laguerre[period]>Upper[period]  then
	Laguerre:setColor(period, instance.parameters.color1);	 	   
	Line[period]=Upper[period]	
	elseif Laguerre[period]<Lower[period]  then
	Laguerre:setColor(period, instance.parameters.color2);	 	  
	Line[period]=Lower[period]	
	else
     Line[period]=Laguerre[period];	
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