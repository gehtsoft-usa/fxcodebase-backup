-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72650

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
    indicator:name("KDJ");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("nPeriod", "Period", "", 9, 1, 2000);
    indicator.parameters:addDouble("factor1", "factor1", "", 0.6666666 , 0, 1);
    indicator.parameters:addDouble("factor2", "factor2", "", 0.3333333 , 0, 1);
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "K Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color2", "D Line Color", "", core.rgb(255, 0, 0)); 
	indicator.parameters:addColor("color3", "J Line Color", "", core.rgb(0, 0, 255)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local nPeriod, factor1,factor2; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	nPeriod=instance.parameters.nPeriod;
	factor1=instance.parameters.factor1;
	factor2=instance.parameters.factor2;	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  nPeriod.. "," ..  factor1.. "," ..  factor2  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	--Indicator= core.indicators:create("AO", source, Period1, Period2);
	first=source:first()+nPeriod ; 
	
	
	RSV = instance:addInternalStream(0, 0);
 
	
	
    percentK = instance:addStream("percentK", core.Line, name, "percentK", instance.parameters.color1, first );
    percentK:setPrecision(math.max(2, instance.source:getPrecision()));
    percentK:setWidth(instance.parameters.width);
    percentK:setStyle(instance.parameters.style);
    percentK:addLevel(0);	
	
    percentD = instance:addStream("percentD", core.Line, name, "percentD", instance.parameters.color2, first );
    percentD:setPrecision(math.max(2, instance.source:getPrecision()));
    percentD:setWidth(instance.parameters.width);
    percentD:setStyle(instance.parameters.style);
    percentD:addLevel(0);	


    percentJ = instance:addStream("percentJ", core.Line, name, "percentJ", instance.parameters.color3, first );
    percentJ:setPrecision(math.max(2, instance.source:getPrecision()));
    percentJ:setWidth(instance.parameters.width);
    percentJ:setStyle(instance.parameters.style);
    percentJ:addLevel(0);		
end


function Update(period, mode)

	--  Indicator:update(mode); 

	 if period <= first then
	 return;
	 end
	 
    local min, max= mathex.minmax(source, period-nPeriod+1, period);
	
	
	if min~= max then
	RSV[period]=(source.close[period]-min)/(max-min)*100
	else
	RSV[period] = 50
	end 
 
	percentK[period] = factor1 * 50 + factor2 * RSV[period]
	percentD[period] = factor1 * 50 + factor2 * percentK[period]
	percentJ[period]= 3 * percentD[period] - 2 * percentK[period]
	 
 end
	
 
	
	
	
	
	
	
	
	
	