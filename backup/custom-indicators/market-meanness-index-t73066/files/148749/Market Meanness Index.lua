-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73066

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
    indicator:name("Market Meanness Index");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Length", "Length", "", 100, 1, 2000);
	
    indicator.parameters:addString("Method", "Method", "Method" , "S");
    indicator.parameters:addStringAlternative("Method", "Sort function", "Calculates the median value using sort function." , "S");
    indicator.parameters:addStringAlternative("Method", "Wirth's Kth-minimum function", "Calculates the median value using Wirth's Kth-minimum function." , "W");	
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("U", "Up Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("UD", "Down in Up Trend Line Color", "", core.rgb(0, 200, 0)); 
	indicator.parameters:addColor("DU", "Up in Down Trend Line Color", "", core.rgb(255, 0, 0)); 
	indicator.parameters:addColor("D", "Down Line Color", "", core.rgb(200, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Length, Method; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Length=instance.parameters.Length;
	Method=instance.parameters.Method;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Length  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
 
	first=source:first() +Length; 
	
	
	mmi = instance:addInternalStream(0, 0);
	slo = instance:addInternalStream(0, 0);
	
	
    filt = instance:addStream("Line", core.Line, name, "Line", instance.parameters.U, first );
    filt:setPrecision(math.max(2, instance.source:getPrecision()));
    filt:setWidth(instance.parameters.width);
    filt:setStyle(instance.parameters.style);
    filt:addLevel(50);	
 
end


function Update(period, mode)

	 -- Indicator:update(mode); 
 
	 if period <= first then
	 return;
	 end
	 
	local median;
	
     if Method== "S" then
	 median = mathex.median_s(source, period - Length + 1, period);
	 else
	 median = mathex.median_w(source, period - Length + 1, period);
	 end	 
	 
	 
	nh = 0
	nl = 0
	for i = 1 , Length - 1, 1 do 

		if (source[period-i] > median and source[period-i] > source[period-i-1]) then
			nl=nl+1
		elseif (source[period-i] < median and source[period-i] < source[period-i-1]) then
			nh=nh+1
		end	
	end		
	
	mmi[period] = 100 * (nl + nh) / (Length - 1)	 
	  
	  	
	filt[period] = 0.0
	coef = 0.0
	for  i = 1 , Length, 1 do 
		cosine = 1 - math.cos(2 * math.pi * i / (Length + 1))
		filt[period] = filt[period] + cosine *mmi[period- i - 1]
		coef=coef+ cosine
	end	
	
	if coef ~= 0 then
	filt[period]=filt[period] / coef 
	else
	filt[period] =0 
	end

    slo[period] = filt[period-1]  - filt[period]
   
	if slo[period]> 0 then
		if slo[period] > slo[period-1] then
        filt:setColor(period,  instance.parameters.U);			
		else
        filt:setColor(period,  instance.parameters.UD);			
		end	
	else
		if slo[period] > slo[period-1] then
        filt:setColor(period,  instance.parameters.DU);			
		else
        filt:setColor(period,  instance.parameters.D);			
		end		
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