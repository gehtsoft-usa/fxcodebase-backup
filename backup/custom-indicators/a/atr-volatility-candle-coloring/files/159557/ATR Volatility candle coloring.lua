-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76021

-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
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
    indicator:name("ATR Volatility candle coloring");
    indicator:description("EMA Template");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
    indicator.parameters:addGroup("Calculation"); 	 
    indicator.parameters:addInteger("Period", "ATR Period", "ATR Period", 14);
	indicator.parameters:addString("TF", "Bar Size to display High/Low", "", "D1");
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	
    indicator.parameters:addDouble("L1", "Strong Level", "Level", 20);	
    indicator.parameters:addDouble("L2", "Weak Level", "Level", 10);		
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
	local Period;
	local first;
	local source = nil;
	local TF; 
	local dayoffset;
	local weekoffset;
	local SourceData;
	local loading = false;   
	local Indicator;
-- Streams block
    local MA = nil;

-- Routine

function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

	L1= instance.parameters.L1;
	L2= instance.parameters.L2; 
	
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first();	
	 
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
    TF = instance.parameters.TF;
	
	
	 local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle(TF, 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");
	
 	
	
	SourceData = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), Period, 100, 101);
	loading=true;
	
 

     
	    Indicator = core.indicators:create("ATR", SourceData, Period);

     
    open = instance:addStream("open", core.Line, name .. ".open", "open", core.rgb(128, 128, 128), first)	
    high = instance:addStream("high", core.Line, name .. ".high", "high", core.rgb(128, 128, 128) , first)	
    low = instance:addStream("low", core.Line, name .. ".low", "low", core.rgb(128, 128, 128), first)	
    close = instance:addStream("close", core.Line, name .. ".close", "close", core.rgb(128, 128, 128), first)
    instance:createCandleGroup("Candles", "Candles", open, high, low, close);	  
end


function   Initialization(period)

    local Candle;
    Candle = core.getcandle(TF, source:date(period), dayoffset, weekoffset);

  
    if loading or SourceData:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(SourceData, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)


        open[period] =  source.open[period] ;
        close[period] =   source.close[period] ;
        high[period] =   source.high[period] ;
        low[period] =   source.low[period] ; 

        local p =  Initialization(period) 
     
	    if not p then
		return;
		end
		
	
	   Indicator:update(mode); 	
    
	    if Indicator.DATA:hasData(p) then  
				if math.abs(close[period] - open[period])  > (Indicator.DATA[p]/100) * L1  then
					if close[period] > open[period] then
					open:setColor(period, core.rgb(0, 255, 0));	
					else				
					open:setColor(period, core.rgb(0, 200, 0));		
					end				
				elseif math.abs(close[period] - open[period])  < (Indicator.DATA[p]/100) * L2  then
					if close[period] > open[period] then
					open:setColor(period, core.rgb( 255, 0, 0));	
					else				
					open:setColor(period, core.rgb(200, 0, 0));		
					end			
				else
					if close[period] > open[period] then
					open:setColor(period, core.rgb( 128, 128, 128));	
					else				
					open:setColor(period, core.rgb(100, 100, 100));		
					end				
				end
		end
  
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
	
		return core.ASYNC_REDRAW ;	
end


-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76021

-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
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