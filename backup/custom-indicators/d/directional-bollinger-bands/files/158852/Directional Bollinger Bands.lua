-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75786

-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright � 2025, Gehtsoft USA LLC  | 
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
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Directional Bollinger Bands");
    indicator:description("Directional Bollinger Bands");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator); 

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods" , "", 20); 
	indicator.parameters:addDouble("Dev", "Number of standard deviations", "", 2);
 
 
	
    indicator.parameters:addGroup("Style");
	
	
    --[[indicator.parameters:addColor("clrBBA", "Central Line Color", "", core.rgb(0, 0, 255));	
    indicator.parameters:addBoolean("HideAve", "Hide average line",  "Defines whether the BB average line is hidden.", false);   
	indicator.parameters:addInteger("widthBBA", "Central Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleBBA", "Central Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleBBA", core.FLAG_LINE_STYLE);]]
	
	
    indicator.parameters:addColor("clrBBP", "Outer Line Color", "", core.rgb(0, 255, 0));		
	indicator.parameters:addInteger("widthBBB", "Outer Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleBBB", "Outer Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleBBB", core.FLAG_LINE_STYLE);
 
	
 end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;
local D;
 

local firstPeriod;
local source = nil;
 

 

-- Routine
function Prepare(nameOnly) 
    N = instance.parameters.N;
    D = instance.parameters.Dev;
    source = instance.source;
    firstPeriod = source:first() + N - 1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ", " .. D .. ")";
    instance:name(name);
	
	if nameOnly then
	return;
	end
	
	
	ml = instance:addInternalStream(firstPeriod, 0);
	d = instance:addInternalStream(firstPeriod, 0);	 
	 
	
	
    TL = instance:addStream("TL", core.Line, name .. ".TL", "TL", instance.parameters.clrBBP, firstPeriod)
    TL:setWidth(instance.parameters.widthBBB);
    TL:setStyle(instance.parameters.styleBBB);
    BL = instance:addStream("BL", core.Line, name .. ".BL", "BL", instance.parameters.clrBBP, firstPeriod)
    BL:setWidth(instance.parameters.widthBBB);
    BL:setStyle(instance.parameters.styleBBB);
 
end
 
function Update(period)
    if period < firstPeriod then
	return;
	end
	
	
    TL:setBreak (period, false);
    BL:setBreak (period, false);
	
    ml[period] = mathex.avg(source, period - N + 1, period);
    d[period] = mathex.stdev(source, period - N + 1, period); 
       
		
		if source[period]> ml[period] then		
		    TL[period]= ml[period] + D * d[period];
			if source[period-1]< ml[period-1] then
			BL[period]=ml[period]
            TL:setBreak (period, true);
            BL:setBreak (period, true);			
			else
		    BL[period]=BL[period-1]+math.abs(TL[period]-TL[period-1]);	
			end
		else
		    BL[period]=ml[period] - D * d[period];
			if source[period-1]> ml[period-1] then
			TL[period]=ml[period]
            TL:setBreak (period, true);
            BL:setBreak (period, true);				
			else
		    TL[period]=TL[period-1]-math.abs(BL[period]-BL[period-1]);	
			end	
		end
        
    
end

-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75786

-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright � 2025, Gehtsoft USA LLC  | 
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