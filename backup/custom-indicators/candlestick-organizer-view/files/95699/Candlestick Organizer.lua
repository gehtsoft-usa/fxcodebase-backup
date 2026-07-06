-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61101

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("Candlestick Organizer");
    indicator:description("Candlestick Organizer");
    indicator:requiredSource(core.Tick);
    indicator:type(core.View);

    indicator.parameters:addGroup("Price Parameters");
    indicator.parameters:addString("instrument", "Instrument","", "EUR/USD");
    indicator.parameters:setFlag("instrument", core.FLAG_INSTRUMENTS);
    indicator.parameters:addString("frame", "Time Frame","", "H1");
    indicator.parameters:setFlag("frame", core.FLAG_BARPERIODS);
    indicator.parameters:addBoolean("type", "Price Type","", true);
    indicator.parameters:setFlag("type", core.FLAG_BIDASK);
 

    indicator.parameters:addGroup("Date Range");
    indicator.parameters:addDate("from", "From","", -1000);
    indicator.parameters:addDate("to", "To","", 0);
    indicator.parameters:setFlag("to", core.FLAG_DATE_OR_NULL);
end

local loading;
local instrument;
local frame; 
local history;
local open, high, low, close;
local offer;
local offset;
local OneSecond;
local LastTime;

-- initializes the instance of the indicator
function Prepare(onlyName)
    instrument = instance.parameters.instrument;
    frame = instance.parameters.frame;

    local name = profile:id() .. "(" .. instrument .. "." .. frame .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end

    -- check whether the instrument is available
    local offers = core.host:findTable("offers");
    local enum = offers:enumerator();
    local row;

    row = enum:next();
    while row ~= nil do
        if row.Instrument == instrument then
            break;
        end
        row = enum:next();
    end

    assert(row ~= nil, "Instrument Not Found");

    offer = row.OfferID;

    instance:initView(instrument, row.Digits, row.PointSize, false, instance.parameters.to == 0);

    loading = true;
    history = core.host:execute("getHistory", 1000, instrument, frame, instance.parameters.from, instance.parameters.to, instance.parameters.type);
    if instance.parameters.to == 0 then
        core.host:execute("subscribeTradeEvents", 2000, "offers");
    end
  
    core.host:execute("setStatus", "Loading");

    open = instance:addStream("open", core.Line, name .. "." .. "Open", "open", 0, 0, 0);
    high = instance:addStream("high", core.Line, name .. "." .. "High", "high", 0, 0, 0);
    low = instance:addStream("low", core.Line, name .. "." .. "Low", "low", 0, 0, 0);
    close = instance:addStream("close", core.Line, name .. "." .. "Close", "close", 0, 0, 0);

    instance:createCandleGroup("candle", "candle", open, high, low, close, nil, frame);
    
    OneSecond=1/86400;
end

function Update(period, mode)
    -- shall never be called, ignore the call
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == 1000 then
        handleHistory();
        core.host:execute("setStatus", "");
    elseif cookie == 2000 then
        if message == offer then
            handleUpdate();
        end
    end
end

local lastDirection;

function calcFirstValueValue(current, i)
 
        local source = history.close;
		
	    current = current + 1;
        if current==0 then
            instance:addViewBar(source:date(0));
        else
            instance:addViewBar(open:date(current-1)+OneSecond);
        end
       
        open[current] = history.open[i ];
        close[current] = history.close[i ];
        low[current] = history.low[i ];
        high[current] =history.high[i ];
		
		if close[current]> open[current] then
		lastDirection = 1;
		else
        lastDirection = -1;
		end
    
    
    return current;
end

function calcValue(current, i)
    if current == -1 then
        return calcFirstValueValue(current, i);
    end
	
	 local source = history.close;
	 
	
	    if lastDirection == 1 
		and history.close[i ]>history.open[i ]
		then
	    close[current] = history.close[i ];	
		
		elseif lastDirection ==1 
		and history.close[i ] < history.open[i ]
		then
		 current=current+1;
		 instance:addViewBar(source:date(i));
		 open[current] = history.open[i ];	
         close[current] = history.close[i ];
          low[current] = history.low[i ];
		  high[current] =history.high[i ];		 
         lastDirection=-1;		 
		end
		
		
		 if lastDirection == -1 
		and history.close[i ]< history.open[i ]
		then
		 close[current] = history.close[i ];	
		 
		elseif lastDirection == -1 
		and  history.close[i ] > history.open[i ] 
		then
		 current=current+1;
		 instance:addViewBar(source:date(i));
		  open[current] = history.open[i ];
		  close[current] = history.close[i ];	
		  low[current] = history.low[i ];
		  high[current] =history.high[i ];
		  lastDirection=1;
		end
		
		
		
		
		       if low[current] > history.low[i ] then
				low[current] = history.low[i ];
				end
				
				if  high[current] <history.high[i ]  then
				high[current] =history.high[i ];
				end
	 
	
	   
   
    
    return current;
end

function handleHistory()
    local s = history:size() - 1;
    local i;
    local current = open:size() - 1;
    for i = 1, s, 1 do
        current = calcValue(current, i);
    end
    loading = false;
    LastTime=history:date(history:size()-1);
end

function handleUpdate()
    if not loading and history:size() > 0 then
      if history:date(history:size()-1)~=LastTime then
        calcValue(open:size() - 1, history:size() - 2);
        LastTime=history:date(history:size()-1);
      end  
    end 
end
