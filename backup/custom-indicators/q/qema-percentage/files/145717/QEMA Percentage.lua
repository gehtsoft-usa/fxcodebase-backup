-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72094

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
    indicator:name("QEMA Percentage");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

 
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("ema_per", "period", "", 50, 1, 2000);
    indicator.parameters:addInteger("correction", "correction", "", 100, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255)); 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local ema_per, correction; 
local Indicator;
local k_ema_per, k1, k2, k3, k4, k5;	
-- Routine
 function Prepare(nameOnly)    
 
	ema_per=instance.parameters.ema_per;
	correction=instance.parameters.correction;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  ema_per.. "," ..  correction  .. ")";
    instance:name(name); 

	   k1=(1.0+4.0*correction*0.01);
	   k2=-10.0*correction*0.01;
	   k3=10.0*correction*0.01;
	   k4=-5.0*correction*0.01;
	   k5=correction*0.01;
	   k_ema_per=(ema_per+1.0)/2.0;
   

    if   (nameOnly) then
        return;
    end
	
	--Indicator= core.indicators:create("AO", source, Period1, Period2);
	first=source:first() ; 
	
	
	ema1 = instance:addInternalStream(0, 0);
 	ema2 = instance:addInternalStream(0, 0);
	ema3 = instance:addInternalStream(0, 0);
	ema4 = instance:addInternalStream(0, 0);
	ema5 = instance:addInternalStream(0, 0);	
	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
end


function Update(period, mode)

	--  Indicator:update(mode); 

	 if period <= first then
	 
      ema1[period]=source[period];
      ema2[period]=source[period];
      ema3[period]=source[period];
      ema4[period]=source[period];
      ema5[period]=source[period];  
	 return;
	 end
	 
      ema1[period]=ema1[period-1]+(source[period]-ema1[period-1])/k_ema_per;
      ema2[period]=ema2[period-1]+(ema1[period]-ema2[period-1])/k_ema_per;
      ema3[period]=ema3[period-1]+(ema2[period]-ema3[period-1])/k_ema_per;
      ema4[period]=ema4[period-1]+(ema3[period]-ema4[period-1])/k_ema_per;
      ema5[period]=ema5[period-1]+(ema4[period]-ema5[period-1])/k_ema_per;
      Line[period]=k1*ema1[period]+k2*ema2[period]+k3*ema3[period]+k4*ema4[period]+k5*ema5[period];
	  
	
 
end