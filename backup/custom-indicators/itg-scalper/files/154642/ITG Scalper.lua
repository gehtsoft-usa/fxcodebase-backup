-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74680

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
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
    indicator:name("ITG Scalper");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  	indicator.parameters:addGroup("Calculation");	 
    indicator.parameters:addBoolean("NoiseFilter", "Noise Filter", "", true);
    indicator.parameters:addBoolean("Signal", "Signal Mode", "", false); 	
	
 
 	indicator.parameters:addGroup("TEMA Calculation");	 
    indicator.parameters:addInteger("Period", "TEMA Period", "", 14, 1, 2000);
	
 	indicator.parameters:addGroup("MACD Calculation");	 
    indicator.parameters:addInteger("Period1", "Short Period", "", 12, 1, 2000);	
    indicator.parameters:addInteger("Period2", "Long Period", "", 26, 1, 2000);
    indicator.parameters:addInteger("Period3", "Signal Period", "", 6, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Up Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Down Line Color", "", core.rgb(255, 0, 0)); 
	 

	
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
 
	
local first;
local source = nil;
local Period; 
local Indicator1, Indicator2, Indicator3,MACD;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period=instance.parameters.Period;
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Period3=instance.parameters.Period3;
    NoiseFilter=instance.parameters.NoiseFilter;	
	Signal=instance.parameters.Signal;	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

	--assert(core.indicators:findIndicator("TSR BIG TREND") ~= nil, "Please, download and install TSR BIG TREND.LUA indicator"); 
	
	Indicator1= core.indicators:create("EMA", source.close, Period);
	Indicator2= core.indicators:create("EMA", Indicator1.DATA, Period);
	Indicator3= core.indicators:create("EMA", Indicator2.DATA, Period);	
	MACD= core.indicators:create("MACD", source.close, Period1, Period2, Period3);	
	ATR= core.indicators:create("ATR", source, Period);	
	first=math.max(Indicator3.DATA:first(), MACD.SIGNAL:first()) ; 
	
	
	
	Last_Transaction = instance:addInternalStream(0, 0);
 
	
	
    TEMA = instance:addStream("TEMA", core.Line, name, "TEMA", instance.parameters.color1, first );
    TEMA:setPrecision(math.max(2, instance.source:getPrecision()));
    TEMA:setWidth(instance.parameters.width);
    TEMA:setStyle(instance.parameters.style); 
	
	if Signal then
    Bar = instance:addStream("Bar", core.Bar, name, "Bar", instance.parameters.color, first );
    Bar:setPrecision(math.max(2, instance.source:getPrecision())); 
    Bar:addLevel(0);	
	else
    Bar = instance:addInternalStream(0, 0);	
	end
	
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top , instance.parameters.clrDN, 0);	
 
end


function Update(period, mode)

	Indicator1:update(mode); 
	Indicator2:update(mode); 
	Indicator3:update(mode);
	MACD:update(mode);
	ATR:update(mode);	
	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end

   --Triple EMA trend calculation
    TEMA[period] = 3 * (Indicator1.DATA[period] - Indicator2.DATA[period]) + Indicator3.DATA[period]
	  
	  	
    if TEMA[period] > TEMA[period-1]then
    TEMA:setColor(period, instance.parameters.color1);
    else
    TEMA:setColor(period, instance.parameters.color2)	
    end	
	
    local FilterBuy = (MACD.MACD[period] >= MACD.SIGNAL[period]) or not NoiseFilter
    local FilterSell = (MACD.MACD[period] < MACD.SIGNAL[period]) or not NoiseFilter
	
	--Entry & exit conditions
	local long = TEMA[period] > TEMA[period-1] and Last_Transaction[period-1]~=1  and FilterBuy
	local short = TEMA[period] < TEMA[period-1] and Last_Transaction[period-1]~=-1  and FilterSell
	
	if long then
	Last_Transaction[period]=1;
	elseif short then
	Last_Transaction[period]=-1;
    else	
	Last_Transaction[period]=Last_Transaction[period-1];	
	end
	
	
    up:setNoData(period);
    down:setNoData(period);
	
	if long
	then
	    Bar[period]= 1;
		if Bar[period-1]~= 1 then
		up:set(period, source.low[period]-ATR.DATA[period], "\217");	
		end
	elseif short	
    then	
	    Bar[period]= -1;
		if Bar[period-1]~= -1 then	
        down:set(period, source.high[period]+ATR.DATA[period], "\218");	
		end
		
	Bar[period]= -1;
    else
	Bar[period]= 0;	
	end	

	
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
