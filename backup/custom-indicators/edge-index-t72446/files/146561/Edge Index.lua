-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72446

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
    indicator:name("Edge Index");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 	indicator.parameters:addGroup("Calculation");
     indicator.parameters:addInteger("PeriodA", "1. Signal Period", "", 10, 1, 2000); 	
     indicator.parameters:addInteger("PeriodB", "2. Signal Period", "", 14, 1, 2000); 
 	indicator.parameters:addGroup("Stochastic Calculation");	
    indicator.parameters:addInteger("Period1", "Fast Period", "", 5, 1, 2000);
    indicator.parameters:addInteger("Period2", "Mid Period", "", 21, 1, 2000);
    indicator.parameters:addInteger("Period3", "Slow Period", "", 50, 1, 2000);	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", 	core.LINE_NONE );
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	 indicator.parameters:addColor("color1", "EDGE INDEX Color", "", core.rgb(0, 0, 255)); 
	 
	 
	 indicator.parameters:addGroup("1. Signal Line Style");	
    indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);	
	 indicator.parameters:addColor("color2", "1. Signal Line Color", "", core.rgb(0, 255, 0));


	 indicator.parameters:addGroup("2. Signal Line Style");	
    indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);	 
	 indicator.parameters:addColor("color3", "2. Signal Line Color", "", core.rgb(255, 0, 0)); 	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local PeriodA, PeriodB,Period1, Period2, Period3; 
 
	
-- Routine
 function Prepare(nameOnly)   
 
    PeriodA=instance.parameters.PeriodA;
    PeriodB=instance.parameters.PeriodB;	
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Period3=instance.parameters.Period3;	
	source = instance.source
    first=source:first()+math.max(Period1,Period2,Period3) ; 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  PeriodA.. "," ..  PeriodB.. "," ..  Period1.. "," ..  Period2.. "," ..  Period3  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
 
    EDGEINDEX = instance:addStream("EDGEINDEX", core.Line, name, "EDGEINDEX", instance.parameters.color1, first );
    EDGEINDEX:setPrecision(math.max(2, instance.source:getPrecision()));
    EDGEINDEX:setWidth(instance.parameters.width1);
    EDGEINDEX:setStyle(instance.parameters.style1);
    EDGEINDEX:addLevel(0);	
 	
	
	Indicator1= core.indicators:create("MVA", EDGEINDEX, PeriodA );
	Indicator2= core.indicators:create("MVA", Indicator1.DATA, PeriodB );
	
	

	
	
    Signal1 = instance:addStream("SIGNAL1", core.Line, name, "Signal1", instance.parameters.color2, first+PeriodA );
    Signal1:setPrecision(math.max(2, instance.source:getPrecision()));
    Signal1:setWidth(instance.parameters.width2);
    Signal1:setStyle(instance.parameters.style2);
    Signal1:addLevel(0);	
	
    Signal2 = instance:addStream("SIGNAL2", core.Line, name, "Signal2", instance.parameters.color3, first+PeriodA+PeriodB );
    Signal2:setPrecision(math.max(2, instance.source:getPrecision()));
    Signal2:setWidth(instance.parameters.width3);
    Signal2:setStyle(instance.parameters.style3);
    Signal2:addLevel(0);	
 
end


function Update(period, mode)



	 if period <= first then
	 return;
	 end
	 
	local Slo,Shi=mathex.minmax(source, period-Period1, period);
	local Mlo,Mhi=mathex.minmax(source, period-Period2, period);
	local Llo,Lhi=mathex.minmax(source, period-Period3, period);   	
	
    local StochS = (source.close[period] - Slo) / (Shi - Slo) * 100
    local StochM = (source.close[period] - Mlo) / (Mhi - Mlo) * 100
    local StochL = (source.close[period] - Llo) / (Lhi - Llo) * 100
   
     EDGEINDEX[period]= ( StochS  +  StochM  + StochL)/3
	 
	 
	Indicator1:update(mode); 	 
	
	
	 if period <= first +PeriodA then
	 return;
	 end

	 
	Signal1[period]= Indicator1.DATA[period];
	
	Indicator2:update(mode); 	 
	
	
	 if period <= first +PeriodA + PeriodB then
	 return;
	 end

	Signal2[period]= Indicator2.DATA[period];	 
	
end