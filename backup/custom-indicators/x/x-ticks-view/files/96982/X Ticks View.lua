-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61422

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("X Ticks View");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.View);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("instrument", "Instrument","", "EUR/USD");
    indicator.parameters:setFlag("instrument", core.FLAG_INSTRUMENTS);
	
	 indicator.parameters:addString("TF", "Time Frame", "", "t1");
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	
    indicator.parameters:addBoolean("type","Price Type", "", true);
    indicator.parameters:setFlag("type", core.FLAG_BIDASK);

	indicator.parameters:addDouble("Range", "Range", "", 100, 0, 10000);

 

    indicator.parameters:addGroup("Range");
    indicator.parameters:addDate("from", "From","", -1000);
    indicator.parameters:addDate("to", "To", "", 0);
    indicator.parameters:setFlag("to", core.FLAG_DATE_OR_NULL);
	 
end
local source;
local TF;
local loading;
local instrument;
 
local history;
local open, high, low, close;
local offer;
local offset; 
local LastTime;
local Range;
local Flag;
local Last=0;
local Master=1;
local  current = -1;
local volume;
--open:setColor(current, Forward);	
-- initializes the instance of the indicator
function Prepare(onlyName)
    instrument = instance.parameters.instrument;	 
	Range = instance.parameters.Range;	 
	TF = instance.parameters.TF;
	
	
    local name = profile:id() .. "(" .. instrument .. ")";
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

    assert(row ~= nil, "Instrument not found");

    offer = row.OfferID;

    instance:initView(instrument, row.Digits, row.PointSize, false, instance.parameters.to == 0);

    loading = true;
    history = core.host:execute("getHistory", 1000, instrument, TF, instance.parameters.from, instance.parameters.to, instance.parameters.type);
    if instance.parameters.to == 0 then
        core.host:execute("subscribeTradeEvents", 2000, "offers");
    end
		
		
	if TF== "t1" then
	source=history;
	else
	source=history.close;
	end
	
    core.host:execute("setStatus", "Loading");
    open = instance:addStream("open", core.Line, name .. "." .. "open", "open", 0, 0, 0);
    high = instance:addStream("high", core.Line, name .. "." .. "high", "high", 0, 0, 0);
    low = instance:addStream("low", core.Line, name .. "." .. "low", "low", 0, 0, 0);
    close = instance:addStream("close", core.Line, name .. "." .. "close", "close", 0, 0, 0);
	volume = instance:addStream("volume", core.Line, name .. "." .. "volume", "volume", 0, 0, 0);
	instance:createCandleGroup("Range", "Range Bar", open, high, low, close, volume, TF);
 
end

 
function Update(period)
    	
end

function AsyncOperationFinished(cookie, success, message, message1, message2)

    if TF== "t1" then
    Limit = source:size()-1;
	else
	Limit = source:size()-2;
	end
	
	while Last< Limit do
	current= calcValue(current, Last);
	Last=Last+1;
	end
	
	
	
	 core.host:execute("setStatus", tostring(Master).. "/"..tostring(Range) );
end


function calcValue(current, last)



 
	
    if current == -1 then
        Master=1;		
		current=0;
		instance:addViewBar(source:date(0));
		 open[current] = source [last];
		 close[current] = source [last];
		 low[current] = source [last];
		 high[current] = source [last];	
      	  
		return current;
    end
	
	
	 
	 if Master < Range then
	 Master=Master+1;	
		 close[current] =  source [last] ;
	 else
	 current=current+1;	 
	 Master=1;		 
	     instance:addViewBar(source:date(last));
	     open[current] = source [last];
		 close[current] =source [last];
		 low[current] = source [last];
		 high[current] = source [last];
	 end
 
      
     volume[current]=Master;
	 low[current] = math.min(low[current], close[current] );
	 high[current] =math.max(high[current], close[current] );	   	
	 
	 return current ; 
end


