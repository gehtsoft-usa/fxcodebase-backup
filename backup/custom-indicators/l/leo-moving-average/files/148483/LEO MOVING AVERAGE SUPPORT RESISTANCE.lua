-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72981

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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
    indicator:name("LEO MOVING AVERAGE + SUPPORT RESISTANCE");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "", 5, 1, 2000);
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255)); 
	 indicator.parameters:addColor("color1", "SupportLine Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Resistance Line Color", "", core.rgb(255, 0, 0)); 	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period;  
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period=instance.parameters.Period;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	WMA= core.indicators:create("WMA", source.close, Period);
	SMA= core.indicators:create("MVA", source.close, Period);	
	first=WMA.DATA:first() ; 
 
	
	
    LMA = instance:addStream("LMA", core.Line, name, "LMA", instance.parameters.color, first );
    LMA:setPrecision(math.max(2, instance.source:getPrecision()));
    LMA:setWidth(instance.parameters.width);
    LMA:setStyle(instance.parameters.style);
    LMA:addLevel(0);	
	
	
	smoothLMA= core.indicators:create("WMA", LMA, Period);
	
	
    support = instance:addStream("Support", core.Line, name, "Support", instance.parameters.color1, first );
    support:setPrecision(math.max(2, instance.source:getPrecision()));
    support:setWidth(instance.parameters.width);
    support:setStyle(instance.parameters.style);
    support:addLevel(0);


    resistance = instance:addStream("Resistance", core.Line, name, "Resistance", instance.parameters.color2, first );
    resistance:setPrecision(math.max(2, instance.source:getPrecision()));
    resistance:setWidth(instance.parameters.width);
    resistance:setStyle(instance.parameters.style);
    resistance:addLevel(0);	
 
end


function Update(period, mode)

	SMA:update(mode); 
	WMA:update(mode); 
	
	 if period <= first then 
	 return;
	 end
	  
	  	
	LMA[period]= 2* WMA.DATA[period] -SMA.DATA[period];
	
	
	
	smoothLMA:update(mode); 

	if period <= first+Period then
	support[period]=source.low[period]
	resistance[period]=source.high[period] 
	return;
	end
	
	support[period]=support[period-1]
	resistance[period]=resistance[period-1] 

    local min, max= mathex.minmax(source, period-Period+1, period);
	
	if LMA[period] > smoothLMA.DATA[period]
	and LMA[period-1] <= smoothLMA.DATA[period-1]
	then
	support[period]=min;
	end

	if LMA[period] < smoothLMA.DATA[period]
	and LMA[period-1] >= smoothLMA.DATA[period-1]	
	then
	 resistance[period]=max;
	end
	
	
	
	support[period]=math.min(source.low[period],support[period])
	resistance[period]=math.max(source.high[period],resistance[period])	 
	
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