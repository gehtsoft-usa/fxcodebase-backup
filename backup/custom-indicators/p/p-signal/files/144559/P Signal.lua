-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71742

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
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
    indicator:name("P Signal");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 9, 1, 2000);
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period; 
local first;
local source = nil;
 
local Oscillator;   
 
-- Routine
 function Prepare(nameOnly)   
 
 
    Period= instance.parameters.Period;
	
	
	local Parameters= Period;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first()+Period;
	Source= instance:addInternalStream(0, 0);	
	Change= instance:addInternalStream(0, 0);	
	Raw= instance:addInternalStream(0, 0);
   
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first+Period*2);
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
end

function fErf(period)  

    local stdev = mathex.stdev(Change, period-Period+1, period);
    local sma = mathex.avg(Change, period-Period+1, period);	
    local x= sma/stdev/math.sqrt(2);
	
    local nT = 1.0/(1.0 + 0.5*math.abs(x));
    local nAns = 1.0 - nT*math.exp(-x*x - 1.26551223 + 
     nT*( 1.00002368 + nT*( 0.37409196 + nT*( 0.09678418 + 
     nT*(-0.18628806 + nT*( 0.27886807 + nT*(-1.13520398 + 
     nT*( 1.48851587 + nT*(-0.82215223 + nT*( 0.17087277 ))))))))));
	 
	if x >= 0  then
	Raw[period]=nAns; 
	else 
	Raw[period]=-nAns;
	end 
end	
 

-- Indicator calculation routine
function Update(period, mode)

    Source[period]=(source.high[period]+source.low[period]+source.open[period]+source.close[period])/4;

	if period < first+Period 
	then
	return;
	end


 	Change[period]=Source[period]-Source[period-Period+1];
	

	fErf(period );
	 

	if period < first+Period*2
	then
	return;
	end
	
	Oscillator[period]=mathex.avg(Raw, period-Period+1, period)
end

