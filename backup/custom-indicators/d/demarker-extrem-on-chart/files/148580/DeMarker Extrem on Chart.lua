-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73011

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
    indicator:name("DeMarker Extrem on Chart");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addBoolean("Signal", "Signal Mode", "", false); 
    indicator.parameters:addInteger("Period", "Period", "", 6);	
	
	indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("Level1", "1. Level","", 5);
	indicator.parameters:addDouble("Level2", "2. Level","", 95);	
 
	
	indicator.parameters:addGroup("Line Style");	
	indicator.parameters:addInteger("Size", "Arrow Size", "", 20); 
   indicator.parameters:addColor("clrUP", "Up Arrow", "" ,  core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN",  "Down Arrow", "" , core.COLOR_DOWNCANDLE);	
	indicator.parameters:addColor("color", "Bar Color", "", core.rgb(0, 0, 255)); 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local Signal,Period;	
local first;
local source = nil;  
local Bar;	
local up, down;
-- Routine
 function Prepare(nameOnly)   
  
	source = instance.source
	
	Signal=instance.parameters.Signal;
	Period=instance.parameters.Period;
	Level1=instance.parameters.Level1;
	Level2=instance.parameters.Level2;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
 
	first=source:first()+Period+1;  
	
	if Signal then
    Bar = instance:addStream("Bar", core.Line, name, "Bar", instance.parameters.color, first );
    Bar:setPrecision(math.max(2, instance.source:getPrecision())); 
    Bar:addLevel(0);	
	else
    Bar = instance:addInternalStream(0, 0);	
	end
	
    Up = instance:addInternalStream(0, 0);	
    Down = instance:addInternalStream(0, 0);
    DeMark= instance:addInternalStream(0, 0);	
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top, instance.parameters.clrDN, 0);
 
end


function Update(period, mode)

 

	 if period < source:first()+1 then
	 return;
	 end
	  
	  
    up:setNoData(period);
    down:setNoData(period);	
	
	
 
    Up[period]=math.max(0,source.high[period]-source.high[period-1])
    Down[period]=math.max(0,source.low[period-1]-source.low[period])
	
	if period <= first  then
	return;
	end	
	
	local AverageUp=mathex.avg(Up, period-Period+1, period);
	local AverageDown=mathex.avg(Down, period-Period+1, period);
	
    DeMark[period] =100*AverageUp/(AverageUp+AverageDown)

	 
	 
 
	if DeMark[period] < Level1 
	then
	Bar[period]= 1;
    up:set(period, source.low[period], "\217", source.low[period]);	
	end
	if  DeMark[period] > Level2 
    then	
    down:set(period, source.high[period], "\218", source.high[period]);	
	Bar[period]= -1;	
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
 