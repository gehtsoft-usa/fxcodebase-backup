-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72714

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
    indicator:name("Moving Averages Proximity Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("min", "Minimum Length", "", 10, 1, 2000);
    indicator.parameters:addInteger("max", "Maximum Length", "", 100, 1, 2000);
    indicator.parameters:addInteger("smooth", "Smooth Length", "", 9, 1, 2000);  
 
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("colorA", "Proximity Index Line Color", "", core.rgb(125, 125, 125)); 
	 indicator.parameters:addColor("colorB1", "Price Above MA'sLine Color Up", "", core.rgb(0, 0, 255)); 	 
	 indicator.parameters:addColor("colorB2", "Price Above MA'sLine Color Down", "", core.rgb(0, 0, 200)); 	 
	 indicator.parameters:addColor("color1", "OB Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "OS Line Color", "", core.rgb(255, 0, 0)); 	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local min, max,smooth ; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	min=instance.parameters.min;
	max=instance.parameters.max;
	smooth=instance.parameters.smooth; 
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  min.. "," ..  max.. "," ..  smooth  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 
	first=source:first() ;  
	csum = instance:addInternalStream(0, 0);  
	per = instance:addInternalStream(0, 0);  	
	len = instance:addInternalStream(0, 0);  	
	
    Len = instance:addStream("ProximityIndex", core.Line, name, "Proximity Index", instance.parameters.colorA, first );
    Len:setPrecision(math.max(2, instance.source:getPrecision()));
    Len:setWidth(instance.parameters.width);
    Len:setStyle(instance.parameters.style);
    Len:addLevel(0);	
	
    Per = instance:addStream("PriceAboveMA", core.Line, name, "Price Above MA's", instance.parameters.colorB1, first );
    Per:setPrecision(math.max(2, instance.source:getPrecision()));
    Per:setWidth(instance.parameters.width);
    Per:setStyle(instance.parameters.style);
    Per:addLevel(0);		
	
    OB = instance:addStream("OB", core.Line, name, "OB", instance.parameters.color1, first );
    OB:setPrecision(math.max(2, instance.source:getPrecision()));
    OB:setWidth(instance.parameters.width);
    OB:setStyle(instance.parameters.style);
    OB:addLevel(0);

    OS = instance:addStream("OS", core.Line, name, "OS", instance.parameters.color2, first );
    OS:setPrecision(math.max(2, instance.source:getPrecision()));
    OS:setWidth(instance.parameters.width);
    OS:setStyle(instance.parameters.style);
    OS:addLevel(0);	
 
end


function Update(period, mode) 

	 if period <= first then
	 return;
	 end
	 
	csum[period]=csum[period-1] +source[period]
	 
	 if period <= first +math.max(max, min) then
	 return;
	 end
	 
    len[period] = 0.
    per[period] = 0.
    local max_min = math.abs(source[period] - (csum[period] - csum[period-min]) / min)
    local ae;
   
    local ma;
    for i = min, max, 1 do
		ma = (csum[period] - csum[period-i])/i;
		
		if source[period] > ma then
		per[period]  =per[period]+1  
		else
		per[period]  =per[period]+0  		
		end
		
    
		ae = math.abs(source[period] - ma)
		
		max_min = math.min(ae, max_min)
		if ae == max_min then
		len[period] = i  
		else
		len[period]=len[period];		
		end
    end

    if period <=smooth then
	return;
	end
	
    len[period] = mathex.avg(len, period-smooth, period)
    per[period] = mathex.avg(per,  period-smooth, period)

	 
	    Len[period]= (len[period] - min)  / (max - min +1 )*100 ; 
		Per[period] = (per[period]-min)  / (max - min +1 )*100 ; 
    
 
 
	OB[period]=80;
	OS[period]=20
 


 
    if Per[period] > 50  then
    Per:setColor(period,  instance.parameters.colorB1);	
	else
    Per:setColor(period,  instance.parameters.colorB2);	
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

