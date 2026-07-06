-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72569

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

function Init()
    indicator:name("Linear AFR");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 14, 1, 2000); 
    indicator.parameters:addDouble("Percentage", "Percentage", "", 1, 0, 2000); 	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Up Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("color2", "Down Line Color", "", core.rgb(255, 0, 0));	
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

  
local first;
local source = nil;
 
local Period, Percentage;

-- Routine
 function Prepare(nameOnly)    
 
    Period= instance.parameters.Period; 
	Percentage= instance.parameters.Percentage;
	
	local Parameters= Period  .. ", " .. Percentage;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first()+1;
	
	 
   
 
	AFR =  instance:addInternalStream(0, 0);
	
	Average = instance:addStream("Average" , core.Line, " Average"," Average",instance.parameters.color2, first+Period);
	Average:setWidth(instance.parameters.width);
    Average:setStyle(instance.parameters.style);
    Average:setPrecision(math.max(2, source:getPrecision()));	
end

-- Indicator calculation routine
function Update(period, mode)
 
	
	
    if period < first then
	AFR[period]=source.median[period];
	return;
	end
	
	local p = Percentage* math.floor(source.close[period])/100	
	
	if source.close[period] > AFR[period-1] then
	AFR[period] = AFR[period-1] + p
	else
	AFR[period] = AFR[period-1] - p
	end 
	

    if period < first +Period then 
	return;
	end
	
    Average[period]=mathex.avg(AFR, period-Period+1 ,period);
	
	
	if source.close[period] > Average[period] then 
	Average:setColor(period,  instance.parameters.color1);
	else 
	Average:setColor(period,  instance.parameters.color2);	
	end
end
