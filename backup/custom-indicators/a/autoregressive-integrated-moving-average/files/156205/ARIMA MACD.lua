-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75084&p=156197#p156197

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
function Init()
    indicator:name("ARIMA MACD");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period1", "Fast EMA", "", 12, 1, 2000);
    indicator.parameters:addInteger("Period2", "Slow EMA", "", 26, 1, 2000);
    indicator.parameters:addInteger("Period3", "Signal EMA", "", 9, 1, 2000);
	
    indicator.parameters:addInteger("p", "AR Order (p)", "Order of the autoregressive part", 1, 1, 1);
    indicator.parameters:addInteger("d", "Differencing Order (d)", "Order of differencing", 1, 0, 2);
    indicator.parameters:addInteger("q", "MA Order (q)", "Order of the moving average part", 1, 0, 5); 
    indicator.parameters:addInteger("forecast_horizon", "Forecast Horizon", "Number of periods to forecast ahead", 1);	
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "MACD Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color2", "Signal Line Color", "", core.rgb(255, 0, 0)); 
	indicator.parameters:addColor("color3", "Histogram Line Color", "", core.rgb(0, 0, 255)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period1, Period2, Period3;  
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Period3=instance.parameters.Period3;	
	
    p = instance.parameters.p;
    d = instance.parameters.d;
    q = instance.parameters.q; 
	forecast_horizon = instance.parameters.forecast_horizon;
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Period2 .. "," ..  Period3 .. "," ..  p.. "," ..  d .. "," ..  q .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	

	first=source:first() +math.max(Period1,Period2); 
	
	assert(core.indicators:findIndicator("ARIMA OF MA") ~= nil, "Please, download and install ARIMA OF MA.BIN indicator"); 
	
 
 
	Indicator1= core.indicators:create("ARIMA OF MA", source, p, d, q, Period1 , forecast_horizon  ); 
	Indicator2= core.indicators:create("ARIMA OF MA", source, p, d, q , Period2, forecast_horizon  ); 	
	
	 	
	
    MACD_Line = instance:addStream("MACD", core.Line, name, "MACD", instance.parameters.color1, source:first() + math.max(Period1,Period2) );
    MACD_Line:setPrecision(math.max(2, instance.source:getPrecision()));
    MACD_Line:setWidth(instance.parameters.width);
    MACD_Line:setStyle(instance.parameters.style);
    MACD_Line:addLevel(0);	
	
	
 
	Indicator3= core.indicators:create("ARIMA OF MA", MACD_Line, p, d, q, Period3, forecast_horizon  );  
	
    Signal_Line = instance:addStream("Signal", core.Line, name, "Signal", instance.parameters.color2, source:first() + math.max(Period1,Period2)+Period3);
    Signal_Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Signal_Line:setWidth(instance.parameters.width);
    Signal_Line:setStyle(instance.parameters.style);
    Signal_Line:addLevel(0);
	

    Histogram = instance:addStream("Histogram", core.Bar, name, "Histogram", instance.parameters.color3, source:first() + math.max(Period1,Period2)+Period3 );
    Histogram:setPrecision(math.max(2, instance.source:getPrecision())); 
    Histogram:addLevel(0);
	
	

end


function Update(period, mode)


	 if period <= source:first()  then
	 return;
	 end	



  	 Indicator1:update(mode); 
  	 Indicator2:update(mode);  

	 if period <= source:first() + math.max(Period1,Period2)   then
	 return;
	 end	  
	 
 
	MACD_Line[period]=Indicator1.DATA[period]-Indicator2.DATA[period];

	
  	Indicator3:update(mode); 	
	if period <= first+Period3  then
	return;
	end	 	
	 

	Signal_Line[period]=Indicator3.DATA[period];
	Histogram[period]=MACD_Line[period]-Signal_Line[period];
	
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