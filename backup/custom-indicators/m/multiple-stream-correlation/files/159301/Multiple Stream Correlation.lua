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
    indicator:name("Multiple Stream Correlation");
    indicator:description("Plots correlation between Multiple instruments or two price series.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Correlation Settings");
    indicator.parameters:addInteger("Period", "Correlation Period", "", 20, 2, 500); 
 
	indicator.parameters:addString("BaseInstrument", "Base Instrument", "", "EUR/USD");
    indicator.parameters:setFlag("BaseInstrument", core.FLAG_INSTRUMENTS);
    
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color1", "Chart In Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Color2", "Line Color", "", core.rgb(128, 128, 128));	
	
    indicator.parameters:addInteger("Width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style", core.FLAG_LINE_STYLE);
end

local Period, source;
local Source={};
local loading={};
local Instrument, Count, Point;
local corrStream={};
local BaseInstrument;
function getInstrumentList()
    local list={};
	local point={};
	
    local count = 0;	
    local row, enum;	
	
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();--will position us on the first instrument of the offers table
    while row ~= nil do	   
        count = count + 1;
        list[count] = row.Instrument;
		point[count] = row.PointSize;
        row = enum:next();--will position us on the next instrument of the offers table	
    end
	
	 
    return list, count,point;
end

function Prepare(nameOnly)
    Period = instance.parameters.Period; 
	BaseInstrument = instance.parameters.BaseInstrument;
	source = instance.source ;
	 
	Instrument, Count,Point = getInstrumentList();
	

 
 

    local name = profile:id() .. "(" .. source:name()  .. ", " .. Period  .. ")";
    instance:name(name);
    if nameOnly then return; end
	
	
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");	
	
	
	
	for i = 1, Count, 1 do	
	Source[i] = core.host:execute("getSyncHistory", Instrument[i], source:barSize(), source:isBid(), Period, 100+i, 200+i);
	loading[i]=true;	 
	end
	


 
	
    local first = source:first() + Period - 1;
	
	for i = 1, Count, 1 do			
		if Instrument[i] == source:instrument() or Instrument[i] ==  BaseInstrument then
		corrStream[i] = instance:addStream(Instrument[i] , core.Line, Instrument[i],  Instrument[i], instance.parameters.Color1, first);
		else
		corrStream[i] = instance:addStream(Instrument[i] , core.Line, Instrument[i],  Instrument[i], instance.parameters.Color2, first);		
		end
    corrStream[i]:setWidth(instance.parameters.Width);
    corrStream[i]:setStyle(instance.parameters.Style);
    corrStream[i]:setPrecision(math.max(2, instance.source:getPrecision()));	
	end
end

function Update(period, mode)
    if period < Period  then return; end
	
	local Flag=false;
	local p={};
	for i = 1, Count, 1 do		
    p[i] =  Initialization(i, period)
		if p[i]== false or p[i]< Period then
		Flag=true;
		end
    end	
 
		
		
		
	if Flag
	then
	return;
	end	

	for i = 1, Count, 1 do
    corrStream[i][period]=mathex.correl (source, Source[i].close, period-Period+1, period,  p[i]-Period+1, p[i])
	end
	
	
end


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)


	local Flag=false;

	for i = 1, Count, 1 do
		if cookie == 100+i then
			loading [i]= false;
		elseif cookie == 200+i then
			loading[i] = true;
			Flag=true;
		end
    end

	
	
	if not Flag  then
	   core.host:execute ("setStatus", " Loaded "); 
	   instance:updateFrom(0);
	else
		core.host:execute ("setStatus", " Loading "); 	
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