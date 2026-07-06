-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=74314

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |
--|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
--+------------------------------------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Velocity And Acceleration");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("Period1", "Sample Period", "", 26, 1, 2000);
    indicator.parameters:addInteger("Period2", "MA Smoothing", "", 9, 1, 2000);
    indicator.parameters:addDouble("scale_factor", "Scale Factor", "",0.5);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 3, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Avg. Acceleration Up Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Avg. Acceleration Down Color", "", core.rgb(255, 0, 0)); 	 
	 indicator.parameters:addColor("color3", "Avg. Velocity Color", "", core.rgb(0, 0, 255)); 
	 indicator.parameters:addColor("color4", "Upper Color", "", core.rgb(128, 128, 128));
	 indicator.parameters:addColor("color5", "Lower Color", "", core.rgb(128, 128, 128));  
end
 

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period1, Period2,scale_factor; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	scale_factor=instance.parameters.scale_factor;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Period2 .. "," .. scale_factor  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
  
	
	Source = instance:addInternalStream(0, 0);
	MA= core.indicators:create("EMA", Source, Period2);	 
	first=source:first() + Period1 ; 
	
	

 
	
	
    AV = instance:addStream("AV", core.Line, name, "Avg. Velocity", instance.parameters.color3, first+ Period2 );
    AV:setPrecision(math.max(2, instance.source:getPrecision()));
    AV:setWidth(instance.parameters.width);
    AV:setStyle(instance.parameters.style);
    AV:addLevel(0);	
	
    ACC = instance:addStream("ACC", core.Bar, name, "Avg. Acceleration", instance.parameters.color1, first+ Period2 );
    ACC:setPrecision(math.max(2, instance.source:getPrecision())); 
    ACC:addLevel(0);	
	
	
	upper = instance:addInternalStream(0, 0);
	lower = instance:addInternalStream(0, 0);
	
	
	MA1= core.indicators:create("EMA", upper, Period2);	 
	MA2= core.indicators:create("EMA", lower, Period2);	 	
	
	
    upperband= instance:addStream("upper", core.Line, name, "Upper", instance.parameters.color4, MA1.DATA:first() + Period1 );
    upperband:setPrecision(math.max(2, instance.source:getPrecision()));
    upperband:setWidth(instance.parameters.width);
    upperband:setStyle(instance.parameters.style);
	
    lowerband = instance:addStream("lower", core.Line, name, "Lower", instance.parameters.color5, MA1.DATA:first() + Period1 );
    lowerband:setPrecision(math.max(2, instance.source:getPrecision()));
    lowerband:setWidth(instance.parameters.width);
    lowerband:setStyle(instance.parameters.style);
	
 
end

function weighted_avg (source, period)


    local  sum = 0.0
    for i = 1 , Period1, 1 do
        diff = (source[period] - source[period-i]) / i
        sum  = sum + diff
	end
	
    return sum /Period1
	
	
end

function Update(period, mode)


	
	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	
	
	Source[period]= weighted_avg (source, period);
	
	
    MA:update(mode); 

	if period <= first + Period2
	or  not source:hasData(period) 
	then
	return;
	end
	
 
 
	  	
	AV[period]=  (100.0 * MA.DATA[period] ) /  (Period1 * scale_factor); 	
	ACC[period]= 100.0 * weighted_avg (MA.DATA, period);		
	
	if ACC[period] > 0 then
	ACC:setColor(period,  instance.parameters.color1); 
	else
	ACC:setColor(period,  instance.parameters.color2); 	
	end
	
	
	
	 if AV[period] > 0 then
	 upper[period]=  AV[period]+(upper[period-1] - AV[period]) * 0.5;
	 else
	 upper[period]=upper[period-1];
	 end
	 
	 if AV[period] < 0 then
	 lower[period]=  AV[period]+(lower[period-1] - AV[period]) * 0.5;
	 else
	 lower[period]=lower[period-1];
	 end	 
	 
    MA1:update(mode); 
    MA2:update(mode); 

    if period < MA1.DATA:first() + Period1 then
    return;
    end	
	
	upperband[period]=mathex.max(MA1.DATA, period-Period1+1, period);
	lowerband[period]=mathex.min(MA2.DATA, period-Period1+1, period);
end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
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