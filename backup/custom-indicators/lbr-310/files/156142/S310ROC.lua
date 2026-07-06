-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75066

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
    indicator:name("S310ROC");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("Period1", "Fast Period", "", 3, 1, 2000);
    indicator.parameters:addInteger("Period2", "Slow Period", "", 10, 1, 2000);
    indicator.parameters:addInteger("Period3", "Smoothing Period", "", 16, 1, 2000);
    indicator.parameters:addInteger("Period4", "ROC Length", "", 2, 1, 2000);
 
    indicator.parameters:addBoolean("Chart", "Chart Signals", "", true);	
    indicator.parameters:addBoolean("Oscillator", "Oscillator Signals", "", true);	
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "MACD Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "SIGNAL Line Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("color3", "ROC Line Color", "", core.rgb(0, 0, 255)); 
	 
 	indicator.parameters:addGroup("Signal Style");	
	indicator.parameters:addInteger("Size", "Signal Size", "", 20); 
   indicator.parameters:addColor("clrUP", "Up Signal", "" ,  core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN",  "Down Signal", "" , core.COLOR_DOWNCANDLE);	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period1, Period2,Period3,Period4; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Period3=instance.parameters.Period3;
	Period4=instance.parameters.Period4;
	Chart=instance.parameters.Chart;
	Oscillator=instance.parameters.Oscillator;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Period2 .. "," ..  Period3 .. "," ..  Period4 .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 
	
	Indicator1= core.indicators:create("MVA", source.close, Period1 );
	Indicator2= core.indicators:create("MVA", source.close, Period2 );	  
	first=math.max(Indicator1.DATA:first(),Indicator2.DATA:first())
	
    MACD = instance:addStream("MACD", core.Line, name, "MACD", instance.parameters.color1, first +  Period3 );
    MACD:setPrecision(math.max(2, instance.source:getPrecision()));
    MACD:setWidth(instance.parameters.width);
    MACD:setStyle(instance.parameters.style);
    MACD:addLevel(0);
	
 	Indicator3= core.indicators:create("MVA", MACD, Period3 );
	
	
    SIGNAL = instance:addStream("SIGNAL", core.Line, name, "SIGNAL", instance.parameters.color2, first +Period3 );
    SIGNAL:setPrecision(math.max(2, instance.source:getPrecision()));
    SIGNAL:setWidth(instance.parameters.width);
    SIGNAL:setStyle(instance.parameters.style);
    SIGNAL:addLevel(0);	
	
    ROC = instance:addStream("ROC", core.Line, name, "ROC", instance.parameters.color3, source:first() +Period4 );
    ROC:setPrecision(math.max(2, instance.source:getPrecision()));
    ROC:setWidth(instance.parameters.width);
    ROC:setStyle(instance.parameters.style);
    ROC:addLevel(0);		
   		
	up = instance:createTextOutput ("up", "up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("dn", "dn", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top , instance.parameters.clrDN, 0);
 	
	UP = instance:createTextOutput ("UP", "UP", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.clrUP, 0);
    DOWN = instance:createTextOutput ("DOWN", "DOWN", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top , instance.parameters.clrDN, 0); 
	
    core.host:execute ("attachTextToChart", "UP")
    core.host:execute ("attachTextToChart", "DOWN")	
end


function Update(period, mode)

	Indicator1:update(mode); 
	Indicator2:update(mode);
	
	if period <= source:first() +Period4
	or  not source:hasData(period) 
	then
	return;
	end
	
	ROC[period]= source.close[period]-source.close[period-Period4+1]
	
	
	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	
	MACD[period]=Indicator1.DATA[period]-Indicator2.DATA[period];
	  
	if period <= first + Period3
	or  not source:hasData(period) 
	then
	return;
	end
	
	Indicator3:update(mode);	
    SIGNAL[period]=Indicator3.DATA[period];
	
	
 
    local slope_net_change = ROC[period] -  ROC[period-1];
    local slope_macd = MACD[period] - MACD[period-1];
    local slope_signal = SIGNAL[period] - SIGNAL[period-1];

    up:setNoData(period);
    down:setNoData(period);
    UP:setNoData(period);
    DOWN:setNoData(period);	
	
	 if Chart then 
 	  if slope_net_change > 0 and slope_macd > 0 and slope_signal > 0 then
	  UP:set(period, source.low[period]- ROC[period]*1.6 , "\108");
	  end
	  if   slope_net_change < 0 and slope_macd < 0 and slope_signal < 0 then 
	  DOWN:set(period, source.high[period]+ ROC[period]*1.6 , "\108"); 
	  end 
	 end
	 
	 if Oscillator then
	  if slope_net_change > 0 and slope_macd > 0 and slope_signal > 0 then
	  up:set(period, ROC[period]*1.6 , "\108");
	  end
	  if   slope_net_change < 0 and slope_macd < 0 and slope_signal < 0 then 
	  down:set(period, ROC[period]*1.6 , "\108"); 
	  end
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