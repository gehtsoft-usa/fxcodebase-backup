-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71872

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
    indicator:name("Detrended Ehlers Leading Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Length", "Fast MA", "",14, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Up", "1. Line Up Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("UpDown", "1. Line Down in Up Trend Color", "", core.rgb(0, 200, 0));  
	indicator.parameters:addColor("DownUp", "1. Line Up in Down Trend Color", "", core.rgb(255, 0, 0));  
	indicator.parameters:addColor("Down", "1. Line Down Color", "", core.rgb(200, 0, 0));  	
	indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(0, 0, 255)); 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Length; 
local Indicator;
local alpha;	
-- Routine
 function Prepare(nameOnly)   
 
    
	Length=instance.parameters.Length;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Length  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
    if Length > 2 then
	alpha=2.0 / (Length + 1); 
	else
	alpha = 0.67
	end

    Price = instance:addInternalStream(0, 0);
    ma1 = instance:addInternalStream(0, 0);	
    ma2 = instance:addInternalStream(0, 0);		
    ma3 = instance:addInternalStream(0, 0);		
    slo = instance:addInternalStream(0, 0);			
	first=source:first()+1+Length; 
	
 
	
	
    Line1 = instance:addStream("Line1", core.Line, name, "1. Line", instance.parameters.Up, first );
    Line1:setPrecision(math.max(2, instance.source:getPrecision()));
    Line1:setWidth(instance.parameters.width);
    Line1:setStyle(instance.parameters.style);
    Line1:addLevel(0);	
	
    Line2 = instance:addStream("Line2", core.Line, name, "2. Line", instance.parameters.color2, first );
    Line2:setPrecision(math.max(2, instance.source:getPrecision()));
    Line2:setWidth(instance.parameters.width);
    Line2:setStyle(instance.parameters.style);
    Line2:addLevel(0);		
 
end


function Update(period, mode)

    if first<=source:first()+1 then
	return;
	end
	
    Price[period] = (math.max(source.high[period], source.high[period-1]) + math.min(source.low[period], source.low[period-1])) / 2

	 
  
    ma1[period]= (alpha * Price[period]) + ((1 - alpha) * ma1[period-1]); 
    ma2[period]= ((alpha / 2) * Price[period]) + ((1 - (alpha / 2)) *ma2[period-1]); 
	
	
	
	Line1[period] = ma1[period] - ma2[period];
 
    ma3[period]= (alpha * Line1[period]) + ((1 - alpha) *  ma3[period-1]); 
	
	
	Line2[period] = Line1[period] - ma3[period]

    slo[period] = Line1[period] - Line2[period]
	
    if slo[period]> 0 then
		if  slo[period] >  slo[period-1] then
		Line1:setColor(period, instance.parameters.Up);
		else
		Line1:setColor(period, instance.parameters.UpDown);	
		end
	else
		if  slo[period] >  slo[period-1] then	
	    Line1:setColor(period, instance.parameters.DownUp);	
		else
	    Line1:setColor(period, instance.parameters.Down);
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
