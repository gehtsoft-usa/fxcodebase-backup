-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73047

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
    indicator:name("Volume efficiency");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	 indicator.parameters:addGroup("Calculation");	 
    indicator.parameters:addInteger("Period", "Period", "", 14, 1, 1000);	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Up Volume Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Down Volume Line Color", "", core.rgb(255, 0, 0)); 
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
 
     
	source = instance.source
	Period=instance.parameters.Period;
 
    local name = profile:id() .. "(" ..  instance.source:name()   .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Up = instance:addInternalStream(0, 0);
	Down = instance:addInternalStream(0, 0);	  
	first=source:first()+1 ;  
 
	
	
    UpVolume = instance:addStream("UpVolume", core.Line, name, "Up Volume", instance.parameters.color1, first +Period );
    UpVolume:setPrecision(math.max(2, instance.source:getPrecision()));
    UpVolume:setWidth(instance.parameters.width);
    UpVolume:setStyle(instance.parameters.style);
    UpVolume:addLevel(0);	
	
    DownVolume = instance:addStream("DownVolume", core.Line, name, "Down Volume", instance.parameters.color2, first +Period );
    DownVolume:setPrecision(math.max(2, instance.source:getPrecision()));
    DownVolume:setWidth(instance.parameters.width);
    DownVolume:setStyle(instance.parameters.style);
    DownVolume:addLevel(0);		
 
end


function Update(period, mode)

	  

	 if period <= first then
	 return;
	 end
	 
	 
 
	if source.close[period] > source.close[period-1] then
	Up[period]=source.volume[period]
	Down[period]=0;
    elseif source.close[period] < source.close[period-1] then
	Down[period]=source.volume[period]
	Up[period]=0;
	else
	Up[period]=0;
	Down[period]=0;	
	end
	
	 if period <= first +Period then
	 return;
	 end
	 
	local Total =  mathex.sum(source.volume,period-Period+1, period); 

 
	UpVolume[period]= mathex.sum(Up,period-Period+1, period) / Total;
	DownVolume[period]= mathex.sum(Down,period-Period+1, period) / Total;
	
 
	
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