-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76085&p=159742#p159742

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
    -- Ime i opis indikatora
    indicator:name("Previous day Bounce with MA Confirmation ");
    indicator:description(" ");

    -- Indikator zahteva OHLC podatke
    indicator:requiredSource(core.Bar);

    -- Tip izlaza
    indicator:type(core.Indicator);
	
	
	indicator.parameters:addGroup("Selector"); 	
    indicator.parameters:addBoolean("PDHL", "Close > PDH Close < PDL", "", true);
    indicator.parameters:addBoolean("PDC", "Close > PDC Close < PDC", "", true);
    indicator.parameters:addBoolean("PDR", "Previous candle Reversal", "", true);	
    indicator.parameters:addBoolean("MA", "Close > MA  Close < MA", "", true);	
    indicator.parameters:addBoolean("Range", "PDHL Filter", "", true);		
    indicator.parameters:addDouble("Multiplier", "Multiplier", "", 0.25, 0, 1 );		
	
	
	
	indicator.parameters:addGroup("Calculation"); 	
	indicator.parameters:addString("TF", "Bar Size to display High/Low", "", "D1");
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS);	
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
	
    indicator.parameters:addInteger("Period", "MA Period", "Period", 14);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Size", "Size", "", 10);	
end

-- Globalne promenljive
local source = nil;
 

function Prepare(nameOnly)
    -- Inicijalizacija izvora
    source = instance.source;

    TF = instance.parameters.TF;
	Price = instance.parameters.Price;
	Period = instance.parameters.Period;
	Method = instance.parameters.Method;
	PDHL = instance.parameters.PDHL;
	PDC = instance.parameters.PDC;
	PDR = instance.parameters.PDR;
	MA = instance.parameters.MA;
	Range = instance.parameters.Range;
	Multiplier= instance.parameters.Multiplier;
	ma = core.indicators:create(Method, source[Price], Period);		
	first=ma.DATA:first();	 
 
    local name =  profile:id() .. " (".. Price ..  ", " .. Period .. ", " .. Method .. ")"
    instance:name(name);
	
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");

	SourceData = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), first, 100, 101);
	loading=true;	

    if not nameOnly then 
        up = instance:createTextOutput("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top, instance.parameters.Up, first);
        down = instance:createTextOutput("Down", "Down", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.Down, first);
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

function Update(period, mode)
 
    ma:update(mode);
	
    if period < first then
        return;
    end
	
	
        up:setNoData(period);
        down:setNoData(period);
		
        local p =  Initialization(period) 
     
	    if not p  
		or p < 1
		then
		return;
		end
		
	local range= math.max( SourceData.high[p-1]-SourceData.low[p-1])
		
		
		if (source.close[period]> ma.DATA[period]  and MA or not MA)
		and (source.open[period]< (ma.DATA[period] + range* Multiplier)  and Range or not Range)
		and (source.close[period]> source.open[period]
		and source.close[period-1]< source.open[period-1] and PDR or not PDR)
		and (source.close[period] > SourceData.high[p-1] and PDHL or not PDHL)
		and (source.close[period] > SourceData.close[p-1] and PDC or not PDC)		
		then
        up:set(period, source.high[period], "\217"); 
		elseif (source.close[period]< ma.DATA[period]  and MA or not MA)
		and (source.open[period]> (ma.DATA[period] - range* Multiplier)  and Range or not Range)		
		and (source.close[period]< source.open[period]
		and source.close[period-1]> source.open[period-1]  and PDR or not PDR)	
		and (source.close[period] < SourceData.low[p-1] and PDHL or not PDHL)
		and (source.close[period] < SourceData.close[p-1] and PDC or not PDC)			
		then
        down:set(period, source.low[period], "\218");
		end
    

   
end
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76085&p=159742#p159742

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