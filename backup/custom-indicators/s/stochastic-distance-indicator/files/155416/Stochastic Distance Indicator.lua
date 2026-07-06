-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74886

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                               https://appliedmachinelearning.systems/contact/  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
--+------------------------------------------------------------------------------------------------+


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Stochastic Distance Indicator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("Period1", "Lookback Length", "", 200, 1, 2000);
    indicator.parameters:addInteger("Period2", "1. Period", "", 12, 1, 2000);
    indicator.parameters:addInteger("Period3", "2. Period", "", 3, 1, 2000);	

	
	indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("color2", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("color3", "Neutral Color", "", core.rgb(0, 0, 255));	
	 
    indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("Level1", "OB Level","", 40); 
	indicator.parameters:addDouble("Level2", "OS Level","", -40); 
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);		
	
	
	 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period1, Period2,Period3; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Period3=instance.parameters.Period3;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Period2 .. "," ..  Period3 .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

	 
	

	first=source:first() + math.max(Period1, Period2); 
	
	
	Distance = instance:addInternalStream(0, 0);
	DistanceStochastic = instance:addInternalStream(0, 0);
 	DistanceD = instance:addInternalStream(0, 0);
	EMA= core.indicators:create("EMA", DistanceD, Period3);	
	
	
	
    SDO = instance:addStream("SDO", core.Line, name, "SDO", instance.parameters.color3, first  + Period1 );
    SDO:setPrecision(math.max(2, instance.source:getPrecision()));
    SDO:setWidth(instance.parameters.width);
    SDO:setStyle(instance.parameters.style);
	SDO:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	SDO:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 

	
 
end


function Update(period, mode)



	if period <= first
	or  not source:hasData(period) 
	then
	return;	
	end
	
    local min, max= mathex.minmax(Distance, period-Period1+1, period);	
	Distance[period]=source[period]- source[period-Period2+2]
	
	 
	if  max - min ~= 0 then	
	DistanceStochastic[period] = (Distance[period] - min) / (max - min) * 100
	else
	DistanceStochastic[period]=0;
	end
	
	if source[period]>source[period-Period2+2] then
	DistanceD[period]= DistanceStochastic[period];
	elseif source[period]<source[period-Period2+2] then 
	DistanceD[period]= -DistanceStochastic[period];
	else
	DistanceD[period]=0;
	end
	
	EMA:update(mode);	
	
	if period <= first + Period3
	or  not source:hasData(period) 
	then
	return;	
	end		
	
 	SDO[period]=EMA.DATA[period];
 
  
 
    if DistanceD[period] > SDO[period] or SDO[period-1] < instance.parameters.Level2 and SDO[period] > instance.parameters.Level2 then
	SDO:setColor(period, instance.parameters.color1);	
	elseif DistanceD[period] < SDO[period] or SDO[period-11] > instance.parameters.Level1 and SDO[period] < instance.parameters.Level1  then
	SDO:setColor(period, instance.parameters.color2);		
	else
	SDO:setColor(period, instance.parameters.color3);		
	end 
	
end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+