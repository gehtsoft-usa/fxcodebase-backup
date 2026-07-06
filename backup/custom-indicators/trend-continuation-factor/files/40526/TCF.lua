-- Id: 7429
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23551

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

function Init()
    indicator:name("Trend Continuation Factor");
    indicator:description("Trend Continuation Factor");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addInteger("CP", "1. Period", "Period", 1, 1 ,2000);
    indicator.parameters:addInteger("Period", "2. Period", "Period", 35, 2,2000);
    indicator.parameters:addColor("PTCF_color", "Color of Pozitiv TCF", "Color of TCF", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("NTCF_color", "Color of Negativ TCF", "Color of TCF", core.rgb(255, 0, 0));
	 indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local CP;
local first;
local source = nil;

-- Streams block
local TCF,NTCF;
local pc, nc;
local ncf, pcf;  
-- Routine
function Prepare(nameOnly)
    CP = instance.parameters.CP;
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first()+CP;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(CP).. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if  nameOnly  then
	return;
	end
	
        pc=instance:addInternalStream(0, 0);
        nc=instance:addInternalStream(0, 0);	
        ncf=instance:addInternalStream(0, 0);
        pcf=instance:addInternalStream(0, 0);
		
        PTCF = instance:addStream("PTCF", core.Line, name, "PTCF", instance.parameters.PTCF_color, first+Period);
        PTCF:setPrecision(math.max(2, instance.source:getPrecision()));
		PTCF:setWidth(instance.parameters.width);
        PTCF:setStyle(instance.parameters.style);
		NTCF = instance:addStream("NTCF", core.Line, name, "NTCF", instance.parameters.NTCF_color, first+Period);
        NTCF:setPrecision(math.max(2, instance.source:getPrecision()));
		NTCF:setWidth(instance.parameters.width);
        NTCF:setStyle(instance.parameters.style);
  
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)


   if period <=first or  not source:hasData(period)  then
   return;
   end
   
   
 
   local ROC= ((source[period] - source[period-CP ]) / (source[period-CP])) * 100; 
  
   
	 if ROC > 0  then
	 pc[period] = ROC;
	 nc[period] = 0;
	 else
	 pc[period] = 0;
	 nc[period]=-ROC;
	 end
 
	if nc[period] == 0 then
	ncf[period]=0;
	else
	ncf[period]=ncf[period-1]+nc[period]
	end

	if pc[period] == 0 then
	pcf[period]=0;
	else
	pcf[period]=pcf[period-1]+pc[period]
	end

    if period <= first +Period   then
	return;
	end
      

     PTCF[period] = mathex.sum(pc, period-Period+1, period) -  mathex.sum(ncf, period-Period+1, period);
     NTCF[period] =  mathex.sum(nc, period-Period+1, period) -  mathex.sum(pcf, period-Period+1, period);
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