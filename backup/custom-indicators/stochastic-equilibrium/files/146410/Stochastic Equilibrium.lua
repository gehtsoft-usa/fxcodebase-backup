-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72396

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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Stochastic Equilibrium");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "", 20, 1, 2000);
    indicator.parameters:addInteger("N", "N", "", 10, 1, 2000);
    indicator.parameters:addInteger("K", "K", "", 5, 1, 2000);	
	
 

	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "K Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "D Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period, N,K; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period=instance.parameters.Period;
	N=instance.parameters.N;
	K=instance.parameters.K;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period.. "," ..  N .. "," ..  K .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Indicator= core.indicators:create("SSD", source, Period1, Period2);
	first=source:first()+Period ; 
	
	
	mid = instance:addInternalStream(0, 0); 
	
	
    K_Line = instance:addStream("K_Line", core.Line, name, "K_Line", instance.parameters.color1, first + N );
    K_Line:setPrecision(math.max(2, instance.source:getPrecision()));
    K_Line:setWidth(instance.parameters.width);
    K_Line:setStyle(instance.parameters.style);
    K_Line:addLevel(0);	
	
    D_Line = instance:addStream("D_Line", core.Line, name, "D_Line", instance.parameters.color2, first + N + K  );
    D_Line:setPrecision(math.max(2, instance.source:getPrecision()));
    D_Line:setWidth(instance.parameters.width);
    D_Line:setStyle(instance.parameters.style);
    D_Line:addLevel(0);		
 
end


function Update(period, mode)

	Indicator:update(mode); 

	 if period <= first then
	 return;
	 end
	 
	local min1,max1=mathex.minmax(source, period-Period+1, period);

    mid[period] =(source.close[period]- min1) /((max1-min1)/100);


	 if period <= first + N then
	 return;
	 end
	 
	local min2,max2=mathex.minmax(mid, period-N+1, period); 	

	
        if max2 ~= min2 then
            K_Line[period] = (mid[period] - min2) / (max2 - min2) * 100;
        else
            K_Line[period] = 50;
        end
	 if period <= first + N + K then
	 return;
	 end
    
	
        D_Line[period] = mathex.avg(K_Line, period - K + 1, period);
	
 
	
end

--[[
period = 50
N = 10
K = 20
 
if barindex>period then
 ll = lowest[period](low)
 hh = highest[period](high)
 mid = (ll+hh)/2
 
 sto = SmoothedStochastic[N,K](mid)
 avg = exponentialaverage[1000](sto)
 sig = exponentialaverage[N](sto)
endif
 
RETURN -sto coloured(200,20,3), -avg as "mean", -sig as "signal line"
 
]]
 