-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75950

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
    indicator:name("Correlation");
    indicator:description("Plots correlation between two instruments or two price series.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Correlation Settings");
    indicator.parameters:addInteger("Period", "Correlation Period", "", 20, 2, 500); 
	
	
	indicator.parameters:addString("InstrumentB", "Second Instrument", "", "EUR/USD");
    indicator.parameters:setFlag("InstrumentB", core.FLAG_INSTRUMENTS);

    
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color", "Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("Width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style", core.FLAG_LINE_STYLE);
end

local Period, source

function Prepare(nameOnly)
    Period = instance.parameters.Period;
    InstrumentB = instance.parameters.InstrumentB;
	source = instance.source ;
	

 
 

    local name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ", " ..  InstrumentB .. ")";
    instance:name(name);
    if nameOnly then return; end
	
	
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");	
	
	
	Source = core.host:execute("getSyncHistory", InstrumentB, source:barSize(), source:isBid(), first, 100, 101);
	loading=true;	

    local first = source:first() + Period - 1;
    corrStream = instance:addStream("Correlation", core.Line, name, "Correlation", instance.parameters.Color, first);
    corrStream:setWidth(instance.parameters.Width);
    corrStream:setStyle(instance.parameters.Style);
    corrStream:setPrecision(math.max(2, instance.source:getPrecision()));	
end

function Update(period, mode)
    if period < Period or loading  then return; end
	
        local p =  Initialization(period) 
     
	    if not p
		or p < Period
		then
		return;
		end	

    corrStream[period]=mathex.correl (source.close, Source.close, period-Period+1, period, p-Period+1, p)
 
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

function   Initialization(  period )

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset);

  
    if loading or Source:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(Source, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75950

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