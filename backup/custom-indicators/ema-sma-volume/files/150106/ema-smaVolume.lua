-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73516

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
    indicator:name("ema-sma + Volume");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("length", "Fast MA", "", 9, 1, 2000);
    indicator.parameters:addInteger("Shift", "Shift", "", 4, 1, 2000);	
	
    indicator.parameters:addInteger("Period", "Averaging Period", "", 3, 1, 2000);		
    indicator.parameters:addInteger("lensma", "Slow MA", "", 17, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Oscillator Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Signal Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)
	length =instance.parameters.length;
	Shift =instance.parameters.Shift;
	Period =instance.parameters.Period;
	lensma =instance.parameters.lensma;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name()   .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Fast= core.indicators:create("MVA", source.volume, length);
	first=source:first()+math.max(length, lensma)+Shift ; 
	
	fast= core.indicators:create("EMA", source.close, length);
	slow= core.indicators:create("MVA", source.close, lensma);	
	
	vm = instance:addInternalStream(0, 0);
    Delta = instance:addInternalStream(0, 0);
    PriceDelta = instance:addInternalStream(0, 0);	
	vvm = instance:addInternalStream(0, 0);
	
    Oscillator = instance:addStream("Oscillator", core.Line, name, "Oscillator", instance.parameters.color1, first+Period );
    Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
    Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    Oscillator:addLevel(0);	
 

    Signal = instance:addStream("Signal", core.Line, name, "Signal", instance.parameters.color1, first+Period );
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
    Signal:setWidth(instance.parameters.width);
    Signal:setStyle(instance.parameters.style);
    Signal:addLevel(0);	
	
    Cut = instance:addStream("Cut", core.Bar, name, "Cut", instance.parameters.color1, first+Period+5 );
    Cut:setPrecision(math.max(2, instance.source:getPrecision())); 
    Cut:addLevel(0);		
end
 
function Update(period, mode)

	Fast:update(mode); 
	fast:update(mode); 
	slow:update(mode); 	

	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	
	vm[period]=100* ((Fast.DATA[period] - Fast.DATA[period-Shift]) / Fast.DATA[period-Shift]) 
	
	Delta[period]=(vm[period] - vm[period-1]) / vm[period-1]	
	PriceDelta[period]=fast.DATA[period]-slow.DATA[period];	
	
 
    vvm[period] = 100 * mathex.avg(Delta, period-Period+1, period);	  

	if period <= first+Period
	or  not source:hasData(period) 
	then
	return;
	end
	
    Oscillator[period] = mathex.avg(PriceDelta, period-Period+1, period) 
	Signal[period] = (Oscillator[period] + 2 * Oscillator[period-1] + 2 * Oscillator[period-2] + Oscillator[period-3]) / 6
	
	
	if Oscillator[period] > 0 then
    Oscillator:setColor(period, instance.parameters.color1);
    Signal:setColor(period, instance.parameters.color1);	
	else
    Oscillator:setColor(period, instance.parameters.color2);	
    Signal:setColor(period, instance.parameters.color2);	
	end	
	
	
	if period <= first+Period+5
	or  not source:hasData(period) 
	then
	return;
	end
	
	if math.abs(vvm[period] / 8) > math.abs(mathex.avg(vvm, period-5+1, period)) then
	 Cut[period]=Oscillator[period]/.7
	else
	  Cut[period]=0
	end 	
		
	if Cut[period]>0 then
	    Cut:setColor(period, instance.parameters.color1);
	else 
	    Cut:setColor(period, instance.parameters.color2);
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