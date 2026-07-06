-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72670

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
    indicator:name("Recursive Moving Average");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("N", "RMA Periods", "", 10, 1, 2000);
    indicator.parameters:addInteger("P", "Smoothing Periods", "", 6, 1, 2000);
 

	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "RMA Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Signal Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local N, P; 
local Indicator;
local RMA;	
-- Routine
 function Prepare(nameOnly)   
 
    
	N=instance.parameters.N;
	P=instance.parameters.P;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  N.. "," ..  P  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end 
	

	first=source:first()+N ;  
	
    RMA = instance:addStream("RMA", core.Line, name, "RMA", instance.parameters.color1, first   );
    RMA:setPrecision(math.max(2, instance.source:getPrecision()));
    RMA:setWidth(instance.parameters.width);
    RMA:setStyle(instance.parameters.style);
   -- RMA:addLevel(0);	
	
	Indicator= core.indicators:create("MVA", RMA, P);	
	
    SIGNAL = instance:addStream("SIGNAL", core.Line, name, "SIGNAL", instance.parameters.color2, first +P );
    SIGNAL:setPrecision(math.max(2, instance.source:getPrecision()));
    SIGNAL:setWidth(instance.parameters.width);
    SIGNAL:setStyle(instance.parameters.style);
 
 
end


function Update(period, mode)



	 if period <= first then
	 return;
	 end
	 
   
	
	
	RMA[period]= source[period];
	
	for i= 1, N-1,  1 do
	RMA[period]=RMA[period]+ mathex.avg(source, period-i, period);
	end
	
	RMA[period]= RMA[period]/N;
	
	
	Indicator:update(mode); 

	if period <= source:first()+N+P then
    return;
    end
	SIGNAL[period]=Indicator.DATA[period];
	
end

 




