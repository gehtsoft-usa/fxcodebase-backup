-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73786

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
    indicator:name("Darvas Boxes");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;  
	
-- Routine
 function Prepare(nameOnly)   
  
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

 
	first=source:first() ; 
	
	
	box = instance:addInternalStream(0, 0);
    flag = instance:addInternalStream(0, 0);
    th = instance:addInternalStream(0, 0);	
	
    Up = instance:addStream("Up", core.Line, name, "Up", instance.parameters.color1, first );
    Up:setPrecision(math.max(2, instance.source:getPrecision()));
    Up:setWidth(instance.parameters.width);
    Up:setStyle(instance.parameters.style);
    Up:addLevel(0);	
	
    Down = instance:addStream("Down", core.Line, name, "Down", instance.parameters.color2, first );
    Down:setPrecision(math.max(2, instance.source:getPrecision()));
    Down:setWidth(instance.parameters.width);
    Down:setStyle(instance.parameters.style);
    Down:addLevel(0);	
	
 
end


function Update(period, mode)

 
    box[period]=box[period-1];
    flag[period]=flag[period-1];
	th[period]=th[period-1];
    Up[period]=Up[period-1];
	Down[period]=Down[period-1];
	
	Up:setBreak (period, false) 
	Down:setBreak (period, false)
	
	
	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	
	
	
	if box[period]==1 and (source.high[period]>Down[period] or source.low[period]<Up[period]) then
	 box[period]=0
	 flag[period]=0
	end
	if box[period]==0 and flag[period]==0 and source.low[period]>source.low[period-3] and source.low[period-1]>source.low[period-3] and source.low[period-2]>source.low[period-3] then
	 th[period]=source.low[period-3]
	 flag[period]=1
	end
	if flag[period]==1 and box[period]==0 and source.low[period]<th[period] then
	 flag[period]=0
	end
	if flag[period]==1 and box[period]==0 and source.high[period]<source.high[period-3] and source.high[period-1]<source.high[period-3] and source.high[period-2]<source.high[period-3] then
	 Down[period]=source.high[period-3]
	 Up[period]=th[period]
	 box[period]=1
	end
	
	if Up[period]~=Up[period-1] then
	Up:setBreak (period, true)
	end
	if Down[period]~=Down[period-1] then	
	Down:setBreak (period, true)
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