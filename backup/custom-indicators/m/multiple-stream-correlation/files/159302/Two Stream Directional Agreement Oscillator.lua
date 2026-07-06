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
    indicator:name("Two Stream Directional Agreement Oscillator");
    indicator:description("Percentage of candles in the same direction between two instruments or two price series.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Correlation Settings");
    indicator.parameters:addInteger("Period", "Correlation Period", "", 20, 2, 500); 
	
	indicator.parameters:addString("InstrumentA", "Second Instrument", "", "EUR/USD");
    indicator.parameters:setFlag("InstrumentA", core.FLAG_INSTRUMENTS);
	
	
	indicator.parameters:addString("InstrumentB", "Second Instrument", "", "AUD/USD");
    indicator.parameters:setFlag("InstrumentB", core.FLAG_INSTRUMENTS);

    
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color", "Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("Width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style", core.FLAG_LINE_STYLE);
end

local Period, source;
local Source={};
local loading={};

function Prepare(nameOnly)
    Period = instance.parameters.Period;
	InstrumentA = instance.parameters.InstrumentA;
    InstrumentB = instance.parameters.InstrumentB;
	source = instance.source ;
	

 
 

    local name = profile:id() .. "(" .. source:name()   .. ", " ..  InstrumentA .. ", " .. Period .. ", " ..  InstrumentB .. ")";
    instance:name(name);
    if nameOnly then return; end
	
	
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");	
	
	
	Source[1] = core.host:execute("getSyncHistory", InstrumentA, source:barSize(), source:isBid(), Period, 100, 200);
	loading[1]=true;	

 	Source[2] = core.host:execute("getSyncHistory", InstrumentB, source:barSize(), source:isBid(), Period, 101, 201);
	loading[2]=true;
	
    local first = source:first() + Period - 1;
    corrStream = instance:addStream("Correlation", core.Line, name, "Correlation", instance.parameters.Color, first);
    corrStream:setWidth(instance.parameters.Width);
    corrStream:setStyle(instance.parameters.Style);
    corrStream:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
    if period < Period or loading[1]  or loading[2] then return; end
	
        local p1 =  Initialization(1, period) 
        local p2 =  Initialization(2, period)      
		
	    if not p1
		or not p2
		or p1 < Period
		or p2 < Period		
		then
		return;
		end	
 
		local Number=0;
		for i= 1, Period, 1 do
		if (Source[1].close[p1-i+1] > Source[1].open[p1-i+1]
		and Source[2].close[p2-i+1] > Source[2].open[p2-i+1] )
		or (Source[1].close[p1-i+1] < Source[1].open[p1-i+1]
		and Source[2].close[p2-i+1] < Source[2].open[p2-i+1] )
		
		then
		Number=Number+1;
		end
	end
	
	
	corrStream[period]=(Number/Period)*100
end


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading [1]= false;
    elseif cookie == 200 then
        loading[1] = true;
    end

    if cookie == 101 then
        loading [2]= false; 
    elseif cookie == 201 then
        loading[2] = true;
    end
	
	
	if not loading [1] and not loading [2] then
	   instance:updateFrom(0);
    end	

	return core.ASYNC_REDRAW ;	
end

function   Initialization(id,   period )

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset);

  
    if loading[id] or Source[id]:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(Source[id] , Candle, false);

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