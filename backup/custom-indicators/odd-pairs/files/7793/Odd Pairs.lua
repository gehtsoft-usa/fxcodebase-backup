-- Id: 2986
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3282

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
    indicator:name("Odd Pairs");
    indicator:description("Odd Pairs");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	
   
   
    indicator.parameters:addString("Symbol", "Instrumet", "", "");
    indicator.parameters:setFlag("Symbol", core.FLAG_INSTRUMENTS);
	
	indicator.parameters:addString("Pair" , "First/Second", "" , "Second");	
    indicator.parameters:addStringAlternative("Pair", "First", "ZONE" , "Second");
    indicator.parameters:addStringAlternative("Pair", "Second", "" ,"First");
	
	
	indicator.parameters:addString("Abbreviations" , "Abbreviations", "" , "HRK");	
	
	indicator.parameters:addDouble("Value1" , "First Rate", "" , 1);	
	indicator.parameters:addDouble("Value2" , "Seconde Rate", "" , 1);	
	
	
	indicator.parameters:addGroup( "Style");	 
	indicator.parameters:addColor("color", "Color of Label", "", core.rgb(0, 128, 192));
	
	
end


local Abbreviations;
local color;
local Pair;
local Value1;
local Value2;

local first;
local source = nil;

local day_offset, week_offset;

local font1;
local font2;

local dummy;
local host;

local init= true;
local streams = {};
local stream;

local Symbol;

local open=nil;
local close=nil;
local high=nil;
local low=nil;

local pauto =  "(%a%a%a)/(%a%a%a)";

-- Routine
function Prepare(nameOnly)	 
    Abbreviations=instance.parameters.Abbreviations;
    Pair=instance.parameters.Pair;
    color=instance.parameters.color;   
	Symbol=instance.parameters.Symbol;
	Value1=instance.parameters.Value1;	
	Value2=instance.parameters.Value2;
     
	host=   core.host;
    source = instance.source;
    first = source:first();
	
	
     local crncy1, crncy2 = string.match(Symbol, pauto);
	
    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");
	
	local name;

	 if Value ~= 1 then
			 if Pair == "First" then	
			 name = profile:id() .. "("..crncy1 .."/".. Abbreviations .. ")" ;
			 else
			  name = profile:id() .. "("..crncy2 .."/".. Abbreviations .. ")" ;
			  end
	 
	 end
    instance:name(name);
    if nameOnly then
        return;
    end
	
	font1 = core.host:execute("createFont", "Courier", 15, false, false);
    font2 = core.host:execute("createFont", "Courier", 15, false, true);
	
	dummy = instance:addInternalStream (first, 0);
	
	init= true;
	
		
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    open:setPrecision(math.max(2, instance.source:getPrecision()));
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    high:setPrecision(math.max(2, instance.source:getPrecision()));
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    low:setPrecision(math.max(2, instance.source:getPrecision()));
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    close:setPrecision(math.max(2, instance.source:getPrecision()));
    instance:createCandleGroup("candle", "", open, high, low, close);
					   
end

local Last;

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

	if not source:hasData(period) or period < first  or period >  source:size()-1  then
	return;
	end
	
	if Last ~= source:size()-1 then
	Last = source:size()-1;
	init= true;
	end
	
	if init then
	init= false;
	stream = registerStream(1, source:barSize(), 0, Symbol );
	end
	
	
	local X=period;

	
	if stream:hasData(X)  then	
				if Pair == "First" then		
                      	
						open[X] = stream.open[X] *  Value2;
						close[X] = stream.close[X]*  Value2;
						high[X] = stream.high[X]*  Value2;
						low[X] = stream.low[X]*  Value2;
						
				else
						
						open[X] =  Value1/stream.open[X] ;
						close[X] = Value1/stream.close[X];
						high[X] = Value1/stream.high[X];
						low[X] = Value1/stream.low[X];
						
				end
	end	
end

  function ReleaseInstance()
       core.host:execute("deleteFont", font1);   
	    core.host:execute("deleteFont", font2); 
   end  
   
   

-- register stream
-- @param barSize       Stream's bar size
-- @param extent        The size of the required extent (number of periods to look the back)
-- @return the stream reference
function registerStream(id, barSize, extent, instrument )
    local stream = {};
    local s1, e1, length;
    local from, to;

    s1, e1 = core.getcandle(barSize, 0, 0, 0);
    length = math.floor((e1 - s1) * 86400 + 0.5);

    stream.data = nil;
    stream.barSize = barSize;
    stream.length = length;
    stream.loading = false;
    stream.extent = extent;
    local from, dataFrom
    from, dataFrom = getFrom(barSize, length, extent);
    if (source:isAlive()) then
        to = 0;
    else
        t, to = core.getcandle(barSize, source:date(source:size() - 1), day_offset, week_offset);
    end
    stream.loading = true;
    stream.loadingFrom = from;
    stream.dataFrom = from;
    stream.data = host:execute("getHistory", id, instrument, barSize, from, to, source:isBid());
    setBookmark(0);

    streams[id] = stream;
    return stream.data;
end


function setBookmark(period)
    local bm;
    bm = dummy:getBookmark(1);
    if bm < 0 then
        bm = period;
    else
        bm = math.min(period, bm);
    end
    dummy:setBookmark(1, bm);
end

-- get the from date for the stream using bar size and extent and taking the non-trading periods
-- into account
function getFrom(barSize, length, extent)
    local from, loadFrom;
    local nontrading, nontradingend;

    from = core.getcandle(barSize, source:date(source:first()), day_offset, week_offset);
    loadFrom = math.floor(from * 86400 - length * extent + 0.5) / 86400;
    nontrading, nontradingend = core.isnontrading(from, day_offset);
    if nontrading then
        -- if it is non-trading, shift for two days to skip the non-trading periods
        loadFrom = math.floor((loadFrom - 2) * 86400 - length * extent + 0.5) / 86400;
    end
    return loadFrom, from;
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    local period;
    local stream = streams[cookie];
    if stream == nil then
        return ;
    end
    stream.loading = false;
    period = dummy:getBookmark(1);
    if (period < 0) then
        period = 0;
    end
    loading = false;
    instance:updateFrom(period);
end   
   