-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73508

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
    indicator:name("Undersampled Double MA");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("samplePeriod", "Sampling period", "", 5, 1, 2000);
    indicator.parameters:addInteger("fastLength", "Fast period", "", 6, 1, 2000);
    indicator.parameters:addInteger("slowLength", "Slow period", "", 12, 1, 2000);
  
	indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local samplePeriod, fastLength,slowLength; 
local sample={};
local PIx2;	
-- Routine
 function Prepare(nameOnly)   
 
    
	samplePeriod=instance.parameters.samplePeriod;
	fastLength=instance.parameters.fastLength;
	slowLength=instance.parameters.slowLength;
	source = instance.source
    PIx2 = math.pi * 2.0
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  samplePeriod.. "," ..  fastLength .. "," .. slowLength .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	 
	first=source:first() +math.max(fastLength,slowLength ); 
	
	
	sample[1] = instance:addInternalStream(0, 0);
 	sample[2] = instance:addInternalStream(0, 0);
	
	
    Line1= instance:addStream("Line1", core.Line, name, "1. Line", instance.parameters.color1, first );
    Line1:setPrecision(math.max(2, instance.source:getPrecision()));
    Line1:setWidth(instance.parameters.width);
    Line1:setStyle(instance.parameters.style);
 
    Line2 = instance:addStream("Line2", core.Line, name, "2. Line", instance.parameters.color2, first );
    Line2:setPrecision(math.max(2, instance.source:getPrecision()));
    Line2:setWidth(instance.parameters.width);
    Line2:setStyle(instance.parameters.style); 
end


function Update(period, mode) 

	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	  
	  	
	Line1[period]= hann(1, fastLength, samplePeriod,period)
 	Line2[period]= hann(2, slowLength, samplePeriod,period)	
end

 


function hann (id, length, samplePeriod,  period) 

    sample[id][period] = sampledSource(id, samplePeriod, period )
 
	local filt = 0.0
	local  coef = 0.0
    
	for count = 1 ,  length, 1 do
        w = 1.0 - math.cos(PIx2 * count / (length + 1.0))
        filt =filt+ w * sample[id][period-count + 1]
        coef =coef+ w
	end

	
    if coef ~= 0.0 then
 	return filt / coef 
	end
end


function sampledSource ( id, samplePeriod, period )  
 
    
    if period % samplePeriod == 0 then
    return source[period]
	else
	return sample[id][period-1] 
	end;

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