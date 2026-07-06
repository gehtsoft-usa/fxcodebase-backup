-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74925

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
    indicator:name("MA Angles - JD.");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  	indicator.parameters:addGroup("1. JMA  Calculation");
    indicator.parameters:addInteger("Length1", "JMA length", "", 10, 1, 2000);
    indicator.parameters:addInteger("Phase1", "JMA Phase", "", 50, 1, 2000);
    indicator.parameters:addInteger("Power1", "JMA Power", "", 1, 1, 2000);
	
  	indicator.parameters:addGroup("2. JMA  Calculation");
    indicator.parameters:addInteger("Length2", "JMA length", "", 10, 1, 2000);
    indicator.parameters:addInteger("Phase2", "JMA Phase", "", 50, 1, 2000);
    indicator.parameters:addInteger("Power2", "JMA Power", "", 1, 1, 2000);	
	
 	indicator.parameters:addGroup("MA Calculation");	
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");	
 
    indicator.parameters:addInteger("Period1", "1. MA", "", 27, 1, 2000);
    indicator.parameters:addInteger("Period2", "2. MA", "", 83, 1, 2000);
    indicator.parameters:addInteger("Period3", "3. MA", "", 278, 1, 2000);
	
 	indicator.parameters:addGroup("ATR Calculation");		
	indicator.parameters:addInteger("Period4", "Period", "", 14, 1, 2000);	
	
  	indicator.parameters:addGroup("Calculation");	
	
    indicator.parameters:addInteger("th", "threshold for -no trade zones- in degrees", "", 2, 1, 2000);	
	indicator.parameters:addBoolean("no_trade", "black out bars in no trade zones?", "", false);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "JMA Fast Color Up", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "JMA Fast Color Down", "", core.rgb(255, 0, 0)); 
	 
	 indicator.parameters:addColor("color3", "JMA Slow Color Up", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color4", "JMA Slow Color Down", "", core.rgb(255, 0, 0));  
	 
	 indicator.parameters:addColor("color5", "1. MA Color Up", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color6", "1. MA Color Down", "", core.rgb(255, 0, 0)); 
  
	 
 	 indicator.parameters:addColor("color7", "2. MA Color Up", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color8", "2. MA Color Down", "", core.rgb(255, 0, 0)); 

	 indicator.parameters:addColor("color9", "3. MA Color Up", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color10", "3. MA Color Down", "", core.rgb(255, 0, 0)); 	 
	 
	 
	indicator.parameters:addGroup("Candle Style");
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral color", "", core.rgb(128, 128, 128));	 
	
	
	indicator.parameters:addGroup("Arrow Style");	
	indicator.parameters:addInteger("Size", "Arrow Size", "", 20); 
   indicator.parameters:addColor("clrUP", "Up Arrow", "" ,  core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN",  "Down Arrow", "" , core.COLOR_DOWNCANDLE);		
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
 
 
    Length1=instance.parameters.Length1;
	Phase1=instance.parameters.Phase1;
	Power1=instance.parameters.Power1;
	
    Length2=instance.parameters.Length2;
	Phase2=instance.parameters.Phase2;
	Power2=instance.parameters.Power2;	
 
    Method=instance.parameters.Method;
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Period3=instance.parameters.Period3;
	Period4=instance.parameters.Period4;	
	

    Up = instance.parameters.Up;
    Down= instance.parameters.Down;
    Neutral= instance.parameters.Neutral;	
	

    th=instance.parameters.th;
	no_trade=instance.parameters.no_trade;
 
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name() .. "," .. Length1  .. "," ..  Phase1  .. "," ..    Power1.. "," .. Length2  .. "," ..  Phase2  .. "," ..    Power2 .. "," ..    Method  .. "," .. Period1.. "," ..  Period2  .. "," ..  Period3 .. "," ..  Period4.. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 
	assert(core.indicators:findIndicator("JURIK MOVING AVERAGE") ~= nil, "Please, download and install JURIK MOVING AVERAGE.LUA indicator"); 
	
	MA1= core.indicators:create(Method, source.close, Period1 );
	MA2= core.indicators:create(Method, source.close, Period2 );
	MA3= core.indicators:create(Method, source.close, Period3 );	
	
	ATR= core.indicators:create("ATR", source, Period4 );		
	
	JMA1= core.indicators:create("JURIK MOVING AVERAGE", source.close, Length1, Phase1, Power1 );
	JMA2= core.indicators:create("JURIK MOVING AVERAGE", source.close, Length2, Phase2, Power2 );	
	first=math.max(MA1.DATA:first(),MA2.DATA:first() ,MA3.DATA:first() ,JMA1.DATA:first(), JMA2.DATA:first() , ATR.DATA:first()) ; 
	
	
	--Stream = instance:addInternalStream(0, 0);
 
	
	
    jma_fast = instance:addStream("jma_fast", core.Line, name, "jma_fast", instance.parameters.color1, first );
    jma_fast:setPrecision(math.max(2, instance.source:getPrecision()));
    jma_fast:setWidth(instance.parameters.width);
    jma_fast:setStyle(instance.parameters.style);
    jma_fast:addLevel(0);	
	
    jma_slow = instance:addStream("jma_slow", core.Line, name, "jma_slow", instance.parameters.color3, first );
    jma_slow:setPrecision(math.max(2, instance.source:getPrecision()));
    jma_slow:setWidth(instance.parameters.width);
    jma_slow:setStyle(instance.parameters.style); 


    ma1 = instance:addStream("ma1", core.Line, name, "ma1", instance.parameters.color5, first );
    ma1:setPrecision(math.max(2, instance.source:getPrecision()));
    ma1:setWidth(instance.parameters.width);
    ma1:setStyle(instance.parameters.style); 
	
    ma2 = instance:addStream("ma2", core.Line, name, "ma2", instance.parameters.color7, first );
    ma2:setPrecision(math.max(2, instance.source:getPrecision()));
    ma2:setWidth(instance.parameters.width);
    ma2:setStyle(instance.parameters.style);
	
    ma3 = instance:addStream("ma3", core.Line, name, "ma3", instance.parameters.color9, first );
    ma3:setPrecision(math.max(2, instance.source:getPrecision()));
    ma3:setWidth(instance.parameters.width);
    ma3:setStyle(instance.parameters.style); 
	
	open = instance:addStream("openup", core.Line, name, "", core.COLOR_LABEL, first);
    high = instance:addStream("highup", core.Line, name, "", core.COLOR_LABEL, first);
    low = instance:addStream("lowup", core.Line, name, "", core.COLOR_LABEL, first);
    close = instance:addStream("closeup", core.Line, name, "", core.COLOR_LABEL, first);
    instance:createCandleGroup("CandleGroup", "CandleGroup", open, high, low, close);


    core.host:execute ("attachOuputToChart", "CandleGroup")	
	
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Center, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Center , instance.parameters.clrDN, 0);
end


function angle(Source, period) 
    local rad2degree = 180 / math.pi   
    return rad2degree * math.atan((Source[period] - Source[period-1]) / ATR.DATA[period])
end

function Update(period, mode)

	MA1:update(mode); 
	MA2:update(mode); 
	MA3:update(mode); 
	
	JMA1:update(mode); 
	JMA2:update(mode); 


	ATR:update(mode);  	
	
	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	
    up:setNoData(period);
    down:setNoData(period);
	
    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
 

 	jma_slow[period]= angle(JMA1.DATA, period);
	jma_fast[period]= angle(JMA2.DATA, period);

 	ma1[period]= angle(MA1.DATA, period);
	ma2[period]= angle(MA2.DATA, period);
	ma3[period]= angle(MA3.DATA, period);	
	
	if  jma_slow[period]>  jma_slow[period-1] then
    jma_slow:setColor(period, instance.parameters.color1);			
    else 
    jma_slow:setColor(period, instance.parameters.color2);	
    end	


	if  jma_fast[period]>  jma_fast[period-1] then
    jma_fast:setColor(period, instance.parameters.color3);			
    else 
    jma_fast:setColor(period, instance.parameters.color4);	
    end		
	
	if  ma1[period]>  ma1[period-1] then
    ma1:setColor(period, instance.parameters.color5);			
    else 
    ma1:setColor(period, instance.parameters.color6);	
    end	

	if  ma2[period]>  ma2[period-1] then
    ma2:setColor(period, instance.parameters.color7);			
    else 
    ma2:setColor(period, instance.parameters.color8);	
    end	

	if  ma3[period]>  ma3[period-1] then
    ma3:setColor(period, instance.parameters.color9);			
    else 
    ma3:setColor(period, instance.parameters.color10);	
    end		
	
	
	
	if no_trade and math.abs(ma1[period]) <= th then
	open:setColor(period, Neutral);
	elseif source.close[period] > source.open[period] then
	open:setColor(period,  Up); 
    elseif source.close[period] < source.open[period] then	
	open:setColor(period,  Down); 	
    end
	
	
	if  ma1[period] > 0 then
    up:set(period, 45, "\217");	
	else
	down:set(period, 45, "\218");	  	
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