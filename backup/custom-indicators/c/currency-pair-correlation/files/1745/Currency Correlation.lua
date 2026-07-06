-- Id: 2545
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=951

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
    indicator:name("Currency  Correlation");
    indicator:description("Currency  Correlation");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addColor("color1", "Dollar color", "Dollar color", core.rgb(0, 255, 0));
	indicator.parameters:addBoolean("Dollar", "Dollar On", "Dollar On", true);
	indicator.parameters:addColor("color2", "Euro color", "Euro color", core.rgb(255, 0, 0));
	indicator.parameters:addBoolean("Euro", "Euro On", "Euro On", true);
	indicator.parameters:addColor("color3", "Jen color", "Jen color", core.rgb(0, 0, 255));
	indicator.parameters:addBoolean("Jen", "Jen On", "Jen On", true);
	indicator.parameters:addColor("color4", "Pound color", "Pound color", core.rgb(128, 0, 128));
	indicator.parameters:addBoolean("Pound", "Pound On", "Pound On", true);
	indicator.parameters:addColor("color5", "Franc color", "Franc color", core.rgb(0, 128, 128));
	indicator.parameters:addBoolean("Franc", "Franc On", "Franc On", true);
	indicator.parameters:addColor("color6", "Kiwi color", "Kiwi color", core.rgb(128, 0, 0));
	indicator.parameters:addBoolean("Kiwi", "Kiwi On", "Kiwi On", true);
	indicator.parameters:addColor("color7", "Aussi color", "Aussi color", core.rgb(255, 255, 255));
	indicator.parameters:addBoolean("Aussi", "Aussi On", "Aussi On", true);
	indicator.parameters:addColor("color8", "Loonie color", "Loonie color", core.rgb(128, 128, 128));
	indicator.parameters:addBoolean("Loonie", "Loonie On", "Loonie On", true);
	

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local first;
local source = nil;
local host;

local last;
local data;
local instrument;
local dummy = nil;
local day_offset, week_offset;

local N;
local SCALEFACTOR1,SCALEFACTOR2, SCALEFACTOR3, SCALEFACTOR4, SCALEFACTOR5, SCALEFACTOR6, SCALEFACTOR7, SCALEFACTOR8;
local Dollar, Euro, Jen, Pound, Franc, Kiwi, Aussi, Loonie;

local out1=nil,tmp11,stream11;
local tmp12,stream12;
local tmp13,stream13;
local tmp14,stream14;

local out2=nil,tmp21,stream21;
local tmp22,stream22;
local tmp23,stream23;
local tmp24,stream24;

local out3=nil,tmp31,stream31;
local tmp32,stream32;
local tmp33,stream33;
local tmp34,stream34;

local out4=nil,tmp41,stream41;
local tmp42,stream42;
local tmp43,stream43;
local tmp44,stream44;

local out5=nil,tmp51,stream51;
local tmp52,stream52;
local tmp53,stream53;
local tmp54,stream54;

local out6=nil,tmp61,stream61;
local tmp62,stream62;
local tmp63,stream63;
local tmp64,stream64;

local out7=nil,tmp71,stream71;
local tmp72,stream72;
local tmp73,stream73;
local tmp74,stream74;

local out8=nil,tmp81,stream81;
local tmp82,stream82;
local tmp83,stream83;
local tmp84,stream84;



-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
    host = core.host;
    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");
	
	Dollar=instance.parameters.Dollar;
	Euro=instance.parameters.Euro;
	Jen=instance.parameters.Jen;
	Pound=instance.parameters.Pound;
	Franc=instance.parameters.Franc;
	Kiwi=instance.parameters.Kiwi;
	Aussi=instance.parameters.Aussi;
	Loonie=instance.parameters.Loonie;
 
    local name = profile:id();
	instance:name(name);
	if (nameOnly) then
		return;
	end
   
    instrument=source:instrument();
	if Dollar then
	out1 = instance:addStream("out1", core.Line, "Dollar", "Dollar", instance.parameters.color1, first);
    out1:setPrecision(math.max(2, instance.source:getPrecision()));
	else
	out1=instance:addInternalStream(first, 0);
	end
	if Euro then 
	out2 = instance:addStream("out2", core.Line, "Euro", "Euro", instance.parameters.color2, first);
    out2:setPrecision(math.max(2, instance.source:getPrecision()));
	else
	out2=instance:addInternalStream(first, 0);
	end
	if Jen then
	out3 = instance:addStream("out3", core.Line, "Jen", "Jen", instance.parameters.color3, first);
    out3:setPrecision(math.max(2, instance.source:getPrecision()));
    else
	out3=instance:addInternalStream(first, 0);
	end
	if  Pound then
	out4 = instance:addStream("out4", core.Line, "Pound", "Pound", instance.parameters.color4, first);
    out4:setPrecision(math.max(2, instance.source:getPrecision()));
	else
	out4=instance:addInternalStream(first, 0);
	end
	if Franc then  
	out5 = instance:addStream("out5", core.Line, "Franc", "Franc", instance.parameters.color5, first);
    out5:setPrecision(math.max(2, instance.source:getPrecision()));
	else
	out5=instance:addInternalStream(first, 0);
	end
	if Kiwi then 
	out6 = instance:addStream("out6", core.Line, "Kiwi", "Kiwi", instance.parameters.color6, first);
    out6:setPrecision(math.max(2, instance.source:getPrecision()));
	else
	out6=instance:addInternalStream(first, 0);
	end
	if Aussi then 
	out7 = instance:addStream("out7", core.Line, "Aussi", "Aussi", instance.parameters.color7, first);
    out7:setPrecision(math.max(2, instance.source:getPrecision()));
	else
	out7= instance:addInternalStream(first, 0);
	end
	if Loonie then 
	out8 = instance:addStream("out8", core.Line, "Loonie", "Loonie", instance.parameters.color8, first);
    out8:setPrecision(math.max(2, instance.source:getPrecision()));
    else
	out8 = instance:addInternalStream(first, 0);
    end	
	
    dummy = instance:addInternalStream(first, 0);   -- the stream for bookmarking
end

-- Indicator calculation routine

local init = false;
local streams = {}


function Update(period)
local i,j;

    if period >= first then
       
	   if period == source:size()-1 then
	       
		    if last ~= source:size()-1  then
            last=source:size()-1;
	
	        local size=source:barSize();
	          
            if not(init) then			  
			stream11=registerStream(0, size, 0,"EUR/USD");  
			stream12=registerStream(1, size, 0,"USD/JPY");  
			stream13=registerStream(2, size, 0,"GBP/USD");  
			stream14=registerStream(3, size, 0,"USD/CHF");  
			
			stream21=registerStream(4, size, 0,"EUR/USD");  
			stream22=registerStream(5, size, 0,"EUR/JPY");  
			stream23=registerStream(6, size, 0,"EUR/GBP");  
			stream24=registerStream(7, size, 0,"EUR/CHF"); 
			
			stream31=registerStream(8, size, 0,"USD/JPY");  
			stream32=registerStream(9, size, 0,"EUR/JPY");  
			stream33=registerStream(10, size, 0,"GBP/JPY");  
			stream34=registerStream(11, size, 0,"CHF/JPY");  
			
			stream41=registerStream(12, size, 0,"GBP/USD");  
			stream42=registerStream(13, size, 0,"EUR/GBP");  
			stream43=registerStream(14, size, 0,"GBP/JPY");  
			stream44=registerStream(15, size, 0,"GBP/CHF"); 
			
			stream51=registerStream(16, size, 0,"USD/CHF");  
			stream52=registerStream(17, size, 0,"EUR/CHF");  
			stream53=registerStream(18, size, 0,"CHF/JPY");  
			stream54=registerStream(19, size, 0,"GBP/CHF");  
			
			
			stream61=registerStream(20, size, 0,"NZD/USD");  
					
			stream71=registerStream(21, size, 0,"AUD/USD");  
						
			stream81=registerStream(22, size, 0,"USD/CAD");  
			
						
			end
			
		
			
		end
            for i = 0, #streams do
                period = math.min(period, streams[i].data:size() - 1)
            end
        
        
					for j=1, period,1 do
						  
						  if j== 1 then
						  out1[j]=100; tmp11=stream11.close[j];
						  tmp12=stream12.close[j];
						  tmp13=stream13.close[j];
						  tmp14=stream14.close[j];
						  
						  out2[j]=100; tmp21=stream21.close[j];
						  tmp22=stream22.close[j];
						  tmp23=stream23.close[j];
						  tmp24=stream24.close[j];
						  
						  out3[j]=100; tmp31=stream31.close[j];
						  tmp32=stream32.close[j];
						  tmp33=stream33.close[j];
						  tmp34=stream34.close[j];
						  
						  out4[j]=100; tmp41=stream41.close[j];
						  tmp42=stream42.close[j];
						  tmp43=stream43.close[j];
						  tmp44=stream44.close[j];
						
						
						  out5[j]=100; tmp51=stream51.close[j];
						  tmp52=stream52.close[j];
						  tmp53=stream53.close[j];
						  tmp54=stream54.close[j];
						  
						  out5[j]=100; tmp51=stream51.close[j];
						  tmp52=stream52.close[j];
						  tmp53=stream53.close[j];
						  tmp54=stream54.close[j];
						  
						  out6[j]=100; tmp61=stream61.close[j];
						  out7[j]=100; tmp71=stream71.close[j];
						  out8[j]=100; tmp81=stream81.close[j];
						  
						
						
						
						  N=4;
						  
						  SCALEFACTOR1=100/((stream11.close[j]/tmp11)^(-1/N) *(stream12.close[j]/tmp12)^(1/N)*(stream13.close[j]/tmp13)^(-1/N)*(stream14.close[j]/tmp14)^(1/N));
						  SCALEFACTOR2=100/((stream21.close[j]/tmp21)^(1/N) *(stream22.close[j]/tmp22)^(1/N)*(stream23.close[j]/tmp23)^(1/N)*(stream24.close[j]/tmp24)^(1/N));
						  SCALEFACTOR3=100/((stream31.close[j]/tmp31)^(-1/N) *(stream32.close[j]/tmp32)^(-1/N)*(stream33.close[j]/tmp33)^(-1/N)*(stream34.close[j]/tmp34)^(-1/N));
						  SCALEFACTOR4=100/((stream41.close[j]/tmp41)^(1/N) *(stream42.close[j]/tmp42)^(-1/N)*(stream43.close[j]/tmp43)^(1/N)*(stream44.close[j]/tmp44)^(1/N));
						  SCALEFACTOR5=100/((stream51.close[j]/tmp51)^(-1/N) *(stream52.close[j]/tmp52)^(-1/N)*(stream53.close[j]/tmp53)^(1/N)*(stream54.close[j]/tmp54)^(-1/N));
			
						  
						  else
						  out1[j]=((stream11.close[j]/tmp11)^(-1/N) *(stream12.close[j]/tmp12)^(1/N)*(stream13.close[j]/tmp13)^(-1/N)*(stream14.close[j]/tmp14)^(1/N))*SCALEFACTOR1;
						  out2[j]=((stream21.close[j]/tmp21)^(1/N) *(stream22.close[j]/tmp22)^(1/N)*(stream23.close[j]/tmp23)^(1/N)*(stream24.close[j]/tmp24)^(1/N))*SCALEFACTOR2;
						  out3[j]=((stream31.close[j]/tmp31)^(-1/N) *(stream32.close[j]/tmp32)^(-1/N)*(stream33.close[j]/tmp33)^(-1/N)*(stream34.close[j]/tmp34)^(-1/N))*SCALEFACTOR3;
						  out4[j]=((stream41.close[j]/tmp41)^(1/N) *(stream42.close[j]/tmp42)^(-1/N)*(stream43.close[j]/tmp43)^(1/N)*(stream44.close[j]/tmp44)^(1/N))*SCALEFACTOR4;
						  out5[j]=((stream51.close[j]/tmp51)^(-1/N) *(stream52.close[j]/tmp52)^(-1/N)*(stream53.close[j]/tmp53)^(1/N)*(stream54.close[j]/tmp54)^(-1/N))*SCALEFACTOR5;
						  out6[j]=100*(stream61.close[j]/tmp61);
						  out7[j]=100*(stream71.close[j]/tmp71);
						  out8[j]=100* (stream81.close[j]/tmp81)^(-1);
						  end
						 
					end
			
			
        end
    end
	   
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

function getDate(id, candle, precise, period)
    local stream = streams[id];
    assert(stream ~= nil, "Stream is not registered");
    local from, dataFrom, to;
    if candle < stream.dataFrom then
        setBookmark(period);
        if stream.loading then
            return -1, true;
        end
        from, dataFrom = getFrom(stream.barSize, stream.length, stream.extent);
        stream.loading = true;
        stream.loadingFrom = from;
        stream.dataFrom = from;
        host:execute("extendHistory", id, stream.data, from, stream.data:date(0));
        return -1, true;
    end

    if (not(source:isAlive()) and candle > stream.data:date(stream.data:size() - 1)) then
        setBookmark(period);
        if stream.loading then
            return -1, true;
        end
        stream.loading = true;
        from = bf_data:date(bf_data:size() - 1);
        to = candle;
        host:execute("extendHistory", id, stream.data, from, to);
    end

    local p;
    p = core.findDate(stream.data, candle, precise);
    return p, stream.loading;
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
 
