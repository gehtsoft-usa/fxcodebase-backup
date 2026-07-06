-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&p=157623

-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 



-- Indicator profile initialization routine
function Init()
    indicator:name("Signal Strength Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Selector");	
	indicator.parameters:addBoolean("rsi", "Use RSI", "", true);
	indicator.parameters:addBoolean("cci", "Use CCI", "", true);	
	indicator.parameters:addBoolean("ma", "Use MA", "", true);
	indicator.parameters:addBoolean("cross", "Use MA", "", true);
	indicator.parameters:addBoolean("stochastic", "Use Stochastic", "", true);	
	
	indicator.parameters:addBoolean("macd_signal", "Use MACD Signal Line", "", true);		
	indicator.parameters:addBoolean("macd_zero", "Use MACD Zero Line", "", true);	
	indicator.parameters:addBoolean("macd_histogram", "Use MACD Histogram Line", "", true);		
	indicator.parameters:addBoolean("macd_slope", "Use MACD Line Slope", "", true);		
	indicator.parameters:addBoolean("macd_histogram_slope", "Use MACD Histogram Line Slope", "", true);	
	
	indicator.parameters:addGroup("RSI Calculation");
	

    indicator.parameters:addInteger("RSI_Period", "RSI Period", "", 14 );
	indicator.parameters:addDouble("RSI_OB", "RSI OB Level", "", 70 );
	indicator.parameters:addDouble("RSI_OS", "RSI OS Level", "", 30 );
	
	
	indicator.parameters:addGroup("CCI Calculation");
	

    indicator.parameters:addInteger("CCI_Period", "RSI Period", "", 14 );
	indicator.parameters:addDouble("CCI_OB", "CCI OB Level", "", 100 );
	indicator.parameters:addDouble("CCI_OS", "CCI OS Level", "", -100 );
	
	
	indicator.parameters:addGroup("MA Calculation");
	

	 indicator.parameters:addInteger("Period", "MA Period", "", 14 );
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
	indicator.parameters:addStringAlternative("Method", "DEMA", "DEMA" , "DEMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addGroup("MA Cross Calculation");
	

	 indicator.parameters:addInteger("Period1", "1. MA Period", "", 1 );
	
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
	indicator.parameters:addStringAlternative("Method1", "DEMA", "DEMA" , "DEMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");

 
	 indicator.parameters:addInteger("Period2", "2. MA Period", "", 28 );
	
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
	indicator.parameters:addStringAlternative("Method2", "DEMA", "DEMA" , "DEMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");

	

	indicator.parameters:addGroup("Stochastic Calculation");

 
    indicator.parameters:addInteger("K", "K period", "", 5, 2, 1000);
    indicator.parameters:addInteger("SD", "SD Period", "", 3, 2, 1000);
    indicator.parameters:addInteger("D", "D Period", "", 3, 2, 1000);

    indicator.parameters:addString("MVAT_K", "K Method","", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K", "MVA","", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K", "EMA","", "EMA");
    indicator.parameters:addStringAlternative("MVAT_K", "FS","", "FS");

    indicator.parameters:addString("MVAT_D", "D Method","", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D", "MVA","", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D", "EMA","", "EMA");
	
	indicator.parameters:addDouble("Stochastic_OB", "Stochastic OB Level", "", 80 );
	indicator.parameters:addDouble("Stochastic_OS", "Stochastic OS Level", "", 20 );
	
	
	indicator.parameters:addGroup("MACD Calculation");	
    indicator.parameters:addInteger("P1", "K period", "", 12, 2, 1000);
    indicator.parameters:addInteger("P2", "SD Period", "", 26, 2, 1000);
    indicator.parameters:addInteger("P3", "D Period", "", 9, 2, 1000);

	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Neutral", "Neutral", "", core.rgb(127, 127, 127)); 
	
 	
end

-- Indicator instance initialization routine

-- Parameters block
local Signal;
local source;
local first;
local Up,Down,Neutral;
local RSI,rsi, RSI_OB, RSI_OS, RSI_Period;
local CCI,cci, CCI_OB, CCi_OS, CCI_Period;
local MA,ma,Method ,Period;
local stochastic, STOCHASTIC, K, SD, D, MVAT_K, MVAT_D, Stochastic_OB, Stochastic_OS;
-- Routine
function Prepare(nameOnly)
  --  SN = instance.parameters.SN;
 
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	Neutral= instance.parameters.Neutral;
	RSI_OB= instance.parameters.RSI_OB;
	RSI_OS= instance.parameters.RSI_OS;
	rsi= instance.parameters.rsi;
	RSI_Period= instance.parameters.RSI_Period;
    ma= instance.parameters.ma;
	Period= instance.parameters.Period;
	Method= instance.parameters.Method;	
	stochastic= instance.parameters.stochastic;
	K= instance.parameters.K;
	SD= instance.parameters.SD;
	D= instance.parameters.D;
	MVAT_K= instance.parameters.MVAT_K;
	MVAT_D= instance.parameters.MVAT_D;	
	Stochastic_OB= instance.parameters.Stochastic_OB;
	Stochastic_OS= instance.parameters.Stochastic_OS;
	
	cross= instance.parameters.cross;	
	Period1= instance.parameters.Period1;
	Method1= instance.parameters.Method1;	
	Period1= instance.parameters.Period1;
	Method2= instance.parameters.Method2;		
	
	
	macd_signal= instance.parameters.macd_signal;
	macd_zero= instance.parameters.macd_zero;
	macd_histogram= instance.parameters.macd_histogram;
	P1= instance.parameters.P1;
	P2= instance.parameters.P2;
	P3= instance.parameters.P3;
	
    macd_slope= instance.parameters.macd_slope;
    macd_histogram_slope= instance.parameters.macd_histogram_slope;
	
	
	
    source = instance.source;
	first=source:first();
	
	
    if rsi then
    RSI = core.indicators:create("RSI", source.close, RSI_Period);
	first=math.max(first,RSI.DATA:first() );
    end
	
	
	if cci then
    CCI = core.indicators:create("CCI", source, CCI_Period);
	first=math.max(first,CCI.DATA:first() );
    end
	
	
	if ma then
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
    MA = core.indicators:create(Method, source.close, Period);
	first=math.max(first,MA.DATA:first() );
    end
	
	if cross then
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");	
    MA1 = core.indicators:create(Method1, source.close, Period1);
    MA2 = core.indicators:create(Method2, source.close, Period2);	
	first=math.max(first,MA1.DATA:first(),MA2.DATA:first() );
    end
	
	if stochastic then
    STOCHASTIC = core.indicators:create("STOCHASTIC", source, K, SD, D, MVAT_K, MVAT_D);
	first=math.max(first,STOCHASTIC.D:first() );
    end
	
	
	if macd_signa or macd_zero or macd_histogram or macd_histogram_slope or macd_slope then
    MACD = core.indicators:create("MACD", source.close, P1, P2, P3);	
	first=math.max(first,MACD.SIGNAL:first() );	
	end
	

    -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
 
	 
	
    Signal = instance:addStream("Signal", core.Bar, name .. ".Signal", "Signal", Neutral, first);
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
 
end

-- Indicator calculation routine
function Update(period, mode)
    
    
	if period < first then
	return;
	end
	
 
 


   Signal[period]=0;
 
   if rsi then
	   RSI:update(mode);
	   if RSI.DATA[period]> RSI_OB then
	   Signal[period]=Signal[period]-1;
	   elseif RSI.DATA[period]< RSI_OS then
	   Signal[period]=Signal[period]+1;
	   end
   end
   
   if cci then
	   CCI:update(mode);
	   if CCI.DATA[period]> CCI_OB then
	   Signal[period]=Signal[period]-1;
	   elseif  CCI.DATA[period]< CCI_OS then
	   Signal[period]=Signal[period]+1;
	   end
   end

   if ma then
	   MA:update(mode);
	   if source.close[period ]> MA.DATA[period] then
	   Signal[period]=Signal[period]-1;
	   elseif source.close[period ] < MA.DATA[period] then
	   Signal[period]=Signal[period]+1;
	   end
   end
   
   
    if stochastic then
	   STOCHASTIC:update(mode);
	   if STOCHASTIC.K[period] > Stochastic_OB then
	   Signal[period]=Signal[period]-1;
	   elseif STOCHASTIC.K[period] < Stochastic_OS  then
	   Signal[period]=Signal[period]+1;
	   end
   end
   
     if cross then
	   MA1:update(mode);
	   MA2:update(mode);	  
	   
	   if MA1.DATA[period] > MA2.DATA[period] then
	   Signal[period]=Signal[period]+1;
	   elseif MA1.DATA[period] < MA2.DATA[period]  then
	   Signal[period]=Signal[period]-1;
	   end
   end
   
   
   if macd_signa or macd_zero or macd_histogram or macd_histogram_slope or macd_slope  then
	   MACD:update(mode);	  
	   
	   if macd_signa then
		   if MACD.MACD[period] > MACD.SIGNAL[period] then
		   Signal[period]=Signal[period]+1;
		   elseif MACD.MACD[period] < MACD.SIGNAL[period]  then
		   Signal[period]=Signal[period]-1;
		   end
	   end
	   
	   if macd_zero then
		   if MACD.MACD[period] > 0 then
		   Signal[period]=Signal[period]+1;
		   elseif MACD.MACD[period] < 0  then
		   Signal[period]=Signal[period]-1;
		   end
	   end

	   if macd_histogram then
		   if MACD.HISTOGRAM[period] > 0 then
		   Signal[period]=Signal[period]+1;
		   elseif MACD.HISTOGRAM[period] < 0  then
		   Signal[period]=Signal[period]-1;
		   end
	   end   
 
   
  
	   if macd_slope then
		   if MACD.MACD[period] >    MACD.MACD[period-1] then
		   Signal[period]=Signal[period]+1;
		   elseif MACD.MACD[period] < MACD.MACD[period-1]  then
		   Signal[period]=Signal[period]-1;
		   end
	   end   
	   
	   if macd_histogram_slope then
		   if MACD.HISTOGRAM[period] >    MACD.HISTOGRAM[period-1] then
		   Signal[period]=Signal[period]+1;
		   elseif MACD.HISTOGRAM[period] < MACD.HISTOGRAM[period-1]  then
		   Signal[period]=Signal[period]-1;
		   end
	   end   	   
   
end   

   

   
   if Signal[period]>0 then
   Signal:setColor(period, Up);
   elseif Signal[period]<0 then
   Signal:setColor(period, Down);
   else
   Signal:setColor(period, Neutral);
   end
end


-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&p=157623

-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 