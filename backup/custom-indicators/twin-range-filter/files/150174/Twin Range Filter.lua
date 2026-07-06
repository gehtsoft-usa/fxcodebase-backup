-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73533

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
    indicator:name("Twin Range Filter");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("per1", "Fast MA", "", 27, 1, 2000);
    indicator.parameters:addInteger("mult1", "Fast range", "", 1.6, 0, 2000);


    indicator.parameters:addInteger("per2", "Slow MA", "", 55, 1, 2000);
    indicator.parameters:addInteger("mult2", "Slow range", "", 2, 0, 2000);
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", " Up Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", " Down Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local per1, mult1; 
local per2, mult2; 
local wper1, wper2;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	per1=instance.parameters.per1;
	mult1=instance.parameters.mult1;
	per2=instance.parameters.per2;
	mult2=instance.parameters.mult2;
	source = instance.source
	
	wper1 = per1 * 2 - 1
	wper2 = per2 * 2 - 1	
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  per1.. "," ..  mult1 .. "," ..  per2.. "," ..  mult2 .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	

	first=source:first()+1; 
	
	
	Delta = instance:addInternalStream(0, 0);
 
	MA_A= core.indicators:create("MVA", Delta, per1);
	MA_B= core.indicators:create("MVA", Delta, per2);	

	MA_AS= core.indicators:create("MVA", MA_A.DATA, wper1);
	MA_BS= core.indicators:create("MVA", MA_B.DATA, wper2);	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color1, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	

    upward = instance:addInternalStream(0, 0);
	downward = instance:addInternalStream(0, 0);
	
end


function Update(period, mode)



	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	  
	Delta[period]= math.abs(source[period] - source[period-1]);


	MA_A:update(mode); 
	MA_B:update(mode); 
	
 
	
	if period <= first +math.max(per1, per2)  
	then
	return;
	end
	
	MA_AS:update(mode); 
	MA_BS:update(mode);
	

	if period <= first +math.max(per1, per2) + math.max(wper1, wper2) 
	then
	return;
	end


    local Central =  (MA_AS.DATA[period]*mult1 + MA_BS.DATA[period]*mult2) / 2

	if source[period]>Line[period-1] then
		if (source[period]-Central)<Line[period-1] then
		Line[period]=Line[period-1]
		else
		Line[period]=source[period]-Central
		end 
	elseif (source[period]+Central)>Line[period-1] then
	Line[period]=Line[period-1]
	else
	Line[period]=source[period]+Central
	end
	
	
	if Line[period] > Line[period-1] then 
	upward[period]=upward[period]+1
	downward[period]=0
	end  
	if Line[period] < Line[period-1] then
	upward[period]=0
	downward[period]=downward[period]+1
	end 
	
    if (source[period] > Line[period] and source[period] > source[period-1] and upward[period] > 0) or (source[period] > Line[period] and source[period] < source[period-1] and upward[period] > 0) then
    Line:setColor(period, instance.parameters.color1);
    end	
	
    if (source[period] < Line[period] and source[period] < source[period-1] and downward[period] > 0) or (source[period] < Line[period] and source[period] > source[period-1] and downward[period] > 0)	then
    Line:setColor(period, instance.parameters.color2);
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