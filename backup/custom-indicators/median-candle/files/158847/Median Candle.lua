-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75783

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
function Init()
    indicator:name("Median Candle");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("replaceSource", "t");      
	indicator.parameters:addGroup("Calculation");
   indicator.parameters:addInteger("Repetitions", "Number of Repetitions", "", 1,0,100);
   
	indicator.parameters:addGroup("Style");

   indicator.parameters:addColor("Up", "Up Bar Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Bar Color", "", core.rgb(255, 0, 0));
	 
  
end

local source = nil;
 local open = nil;
local high = nil;
local low = nil;
local close=nil;
local Up, Down;
local first = 0; 
local Repetitions;

local o={};
local h={};
local l={};
local c={};
-- Routine
function Prepare(nameOnly)
 
    source = instance.source;
 
	
	Up = instance.parameters.Up;    
	Down = instance.parameters.Down;
	
	Repetitions = instance.parameters.Repetitions;
	
    first = source:first();

    local name = profile:id() .. "(" ..  Repetitions  .. ", " ..   source:name() .. ")";
    instance:name(name);
	
    instance:name(name)
    if nameOnly then
        return;
    end		
	
	if Repetitions~=0 then
		for i= 1, Repetitions, 1 do
		o[i]=instance:addInternalStream(0, 0); 
		h[i]=instance:addInternalStream(0, 0); 
		l[i]=instance:addInternalStream(0, 0); 
		c[i]=instance:addInternalStream(0, 0); 
		end
	end
    
    open = instance:addStream("open", core.Line, name .. ".open", "open", Up, first)	
    high = instance:addStream("high", core.Line, name .. ".high", "high", Up , first)	
    low = instance:addStream("low", core.Line, name .. ".low", "low", Up, first)	
    close = instance:addStream("close", core.Line, name .. ".close", "close", Up, first)
    instance:createCandleGroup("Candles", "Candles", open, high, low, close);	
	
	 
end

-- Indicator calculation routine
function Update(period, mode)
    if period <= first then
	return;
	end
        
		
		if Repetitions==0 then
		
				open[period] =  source.open[period];
				close[period] =   source.close[period];
				high[period] =   source.high[period];
				low[period] =   source.low[period] ; 		
		
		
		else 		
		
				for i= 1, Repetitions, 1 do		
						if i==  1 then				
						o[i][period] =  (source.open[period]+ source.open[period-1])/2 ;
						c[i][period] =  (source.close[period] +source.close[period-1])/2;
						h[i][period] =   (source.high[period] + source.high[period-1])/2;
						l[i][period] =   (source.low[period] + source.low[period-1])/2 ; 
						else
						o[i][period] =  (o[i-1][period]+ o[i-1][period-1])/2 ;
						c[i][period] =   (c[i-1][period] +c[i-1][period-1])/2;
						h[i][period] =   (h[i-1][period] + h[i-1][period-1])/2;
						l[i][period] =   (l[i-1][period] + l[i-1][period-1])/2 ; 					
						end
				end
				
				
				open[period]  =   o[Repetitions][period] ;
				close[period] =   c[Repetitions][period];
				high[period]  =   h[Repetitions][period];
				low[period]   =   l[Repetitions][period]; 		
		
        end



	
		if close[period] > open[period] then
		open:setColor(period, Up);	
		else
		open:setColor(period, Down);			
		end
		
    
end
 
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75783

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






