-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72982

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
    indicator:name("Period High Low");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("ZZPeriod", "Period", "", 54, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Up Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Down Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("color", "Neutral Color", "", core.rgb(128, 128, 128)); 	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local ZZPeriod;  
	
-- Routine
 function Prepare(nameOnly)   
 
    
	ZZPeriod=instance.parameters.ZZPeriod;
	source = instance.source
	first=source:first()+ZZPeriod;
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  ZZPeriod  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	 
 
	
	
	--li_16 = instance:addInternalStream(0, 0);
 	--li_20 = instance:addInternalStream(0, 0);
 	 
	
    Bar = instance:addStream("Bar", core.Bar, name, "Bar", instance.parameters.color, first );
    Bar:setPrecision(math.max(2, instance.source:getPrecision())); 
	Bar:addLevel(0);	 
end


function Update(period, mode)
 
    --li_16[period]= li_16[period-1];
    --li_20[period]= li_20[period-1];
	
	if period < first then
	return;
	end
	  
	
	local low_44, high_52 = mathex.minmax(source, period-ZZPeriod, period-1)
 
     
       if (source.low[period] < low_44 and source.high[period] > high_52)  then
			 gi_104 = false;
			 gi_108 = false;	
       else  
			 if (source.low[period] < low_44) then 
			 gi_104 = true;
			 gi_108 = false;	 
			 end
			 if (source.high[period] > high_52) then 
			 gi_104 = false;
			 gi_108 = true; 
			 end
        end 
		
 
	  	
		
	if gi_104 then
    Bar:setColor(period, instance.parameters.color2);		
	elseif gi_108 then
    Bar:setColor(period, instance.parameters.color1);		
	end
	
	Bar[period]= 1;
	
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