 -- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75644

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

function Init()
    indicator:name("Dynamic Trend Oscillator")
    indicator:description("Dynamic Trend Oscillator")
    indicator:requiredSource(core.Tick)
    indicator:type(core.Oscillator)
    
    indicator.parameters:addGroup("Calculation"); 
 
    indicator.parameters:addInteger("RSI_Period", "RSI Period", "Period", 13);	
    indicator.parameters:addInteger("Stoch_Period", "Stoch Period", "Period", 8);	
    indicator.parameters:addInteger("SK_Period", "SK Period", "Period", 5);	
    indicator.parameters:addInteger("SD_Period", "SD Period", "Period", 3);	
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");	
 


    indicator.parameters:addGroup("SK Style");
    indicator.parameters:addColor("color1", "Line Color", "Color of the line", core.rgb(0, 255, 0))
    indicator.parameters:addInteger("width1", "Line Width", "Width of the line", 2, 1, 5)
    indicator.parameters:addInteger("style1", "Style", "Style of the oscillator line", core.LINE_SOLID)
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);	
	
    indicator.parameters:addGroup("SD Style");
    indicator.parameters:addColor("color2", "Line Color", "Color of the line", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("width2", "Line Width", "Width of the line", 2, 1, 5)
    indicator.parameters:addInteger("style2", "Style", "Style of the oscillator line", core.LINE_SOLID)
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);	
	
	
 
    indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("Level1", "1. Level","", 30);
	indicator.parameters:addDouble("Level2", "2. Level","", 50);
	indicator.parameters:addDouble("Level3", "3. Level","", 70); 
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);		
	
	

end
local first;
local Period, Method;

function Prepare(nameOnly)
    -- Get input parameters
    RSI_Period = instance.parameters.RSI_Period
	Stoch_Period = instance.parameters.Stoch_Period;
	SK_Period= instance.parameters.SK_Period;
	SD_Period= instance.parameters.SD_Period;
    Method = instance.parameters.Method 
    source = instance.source;
    
    -- Indicator name
    local name = "Indicator Template (".. RSI_Period ..  ", " .. Stoch_Period .. ", " .. Method .. ")"
    instance:name(name)
    if nameOnly then
        return;
    end	
	 
	
	RSI = core.indicators:create("RSI", source, RSI_Period);		
	first=RSI.DATA:first()+Stoch_Period;
	
	
	StoRSI = instance:addInternalStream(0, 0);
	
	
    ma1= core.indicators:create(Method, StoRSI, SK_Period);	
    ma2= core.indicators:create(Method, ma1.DATA, SD_Period);		
	
    
    -- Create a stream to hold the dominant period as an oscillator
    SK = instance:addStream("SK", core.Line, name, "SK", instance.parameters.color1, first)
    SK:setWidth(instance.parameters.width1)
    SK:setStyle(instance.parameters.style1)
	
	SK:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);		
	SK:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);	
	SK:addLevel(instance.parameters.Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);		
    -- Create a stream to hold the dominant period as an oscillator
    SD = instance:addStream("SD", core.Line, name, "SD", instance.parameters.color2, first)
    SD:setWidth(instance.parameters.width2)
    SD:setStyle(instance.parameters.style2)	
end

function Update(period)

    RSI:update(mode);
    -- Make sure there is enough data to calculate all required moving averages
    if period < first then
        return
    end
	
	
	local min, max=mathex.minmax(RSI.DATA, period-Stoch_Period+1, period);
  	if ((max-min)~=0) then
            StoRSI[period] = 100.0*((RSI.DATA[period] - min)/(max - min));
    else 
	        StoRSI[period] = 0;
    end 
   
    ma1:update(mode);
    ma2:update(mode);
	
   if period < ma2.DATA:first() then
        return
    end	
	
    -- Store the dominant moving average period
    SK[period] = ma1.DATA[period];
    SD[period] = ma2.DATA[period];	
end
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75644

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