-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=249

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
    indicator:name("MTF Schaff Trend Cycle Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);	

	
	Parameters (1 , "H1" );
	Parameters (2 , "H4" );
	Parameters (3 , "H8" );
    Parameters (4 , "D1" );
	Parameters (5 , "W1" );
	
	indicator.parameters:addGroup("Common Parameters");		 
	indicator.parameters:addInteger("ArrowSize", "ArrowSize", "", 10);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0 , 10000);
	indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "No Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	
	
end

function Style (id)
    
  	indicator.parameters:addGroup(id.. ".  Time Frame Style Options"); 
    indicator.parameters:addBoolean("Show"..id, "Show Line", "", true);
    indicator.parameters:addInteger("widht"..id, "Line widht", "", 1, 1, 5);
    indicator.parameters:addInteger("style"..id, "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style"..id, core.FLAG_LINE_STYLE);
   
end


function Parameters (id , FRAME )


  	indicator.parameters:addGroup(id..".  Time Frame"); 
    indicator.parameters:addString("B"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("B"..id, core.FLAG_PERIODS);
	
	indicator.parameters:addString("Price"..id, "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price"..id, "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price"..id, "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price"..id, "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price"..id,"CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price"..id, "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price"..id, "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price"..id, "WEIGHTED", "", "weighted");	

	
	indicator.parameters:addInteger("C"..id, "Schaff cycle periods", "", 10, 2, 10000);
    indicator.parameters:addInteger("S"..id, "Short periods", "", 23, 2, 10000);
    indicator.parameters:addInteger("L"..id, "Long periods", "", 50, 2, 10000);
end


local C={};
local S={};
local L={};
local B={};
local Price={};
local widht={};
local style={};

local  ArrowSize;
local source;
local Indicator=nil;
local day_offset, week_offset;
local dummy;
local stream={};
local host;
--local alive;
local first={};
local Up, Down, Neutral, Label;
local Shift;
 local font;
 local font2;
local Show={};
local Temp={};
function Prepare(nameOnly)   
    
    Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
	Label=instance.parameters.Label;
    Shift=instance.parameters.Shift;
    	local i;
    for i= 1, 5, 1 do	
	 
	 C[i]= instance.parameters:getInteger ("C"..i);
	 S[i]= instance.parameters:getInteger ("S"..i);
	 L[i]= instance.parameters:getInteger ("L"..i);
     B[i]= instance.parameters:getString ("B"..i);
	 Price[i]= instance.parameters:getString ("Price"..i);
	end
      
    ArrowSize=instance.parameters.ArrowSize; 
	
    source = instance.source;
	
	 local name =  profile:id() .. ","  .. instance.source:name() ;
	 
	 name = name .. ")";
	instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    host = core.host;

    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");	

	assert(core.indicators:findIndicator("SCHTC") ~= nil, "Please, download and install SCHTC.LUA indicator");
    dummy = instance:addInternalStream(0, 0);

	for i= 1, 5, 1 do
	
    Temp[i]= core.indicators:create("SCHTC", source[Price[i]],C[i],S[i],L[i]);
	first[i]=Temp[i].DATA:first();
 	
	end
	
	
	
	

	--Arial
	  font = core.host:execute("createFont", "Arial", ArrowSize, true, false);
       font2 = core.host:execute("createFont", "Wingdings", ArrowSize, false, false);
	Indicator = nil;
end


function Update(period, mode)

 
 if  period <  source:size() - 1 then	
                            return;
	end
 
	local i;
	
	if Indicator == nil then
	Indicator = {};		
		for i = 1, 5 , 1 do	 
			stream[i] = registerStream(i, B[i],  first[i]);
			Indicator[i] = core.indicators:create("SCHTC", stream[i][Price[i]],C[i],S[i],L[i]);
		end
	end
	
	
	
	
			for i = 1, 5, 1  do
		     
			 
			    local fromLevel= nil;
				local fromDate, toDate;
				local date = source:date(period);
				local color;
						Indicator[i]:update(mode);
						
						
						if  Indicator[i].DATA:hasData( Indicator[i].DATA:size()-1)  then	
                        
                              
                     							--size
							 
							      core.host:execute("drawLabel1", i+ArrowSize*20, -i*ArrowSize*10, core.CR_RIGHT,ArrowSize*3+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
                             font, Label, instance.parameters:getString ("B"..i));
							 
						
											   if Indicator[i].DATA:hasData(Indicator[i].DATA:size()-1)   then
												
												core.host:execute("drawLabel1", i, -i*ArrowSize*10, core.CR_RIGHT, ArrowSize*5+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font2, Up, "\225");
												
													core.host:execute("drawLabel1", i+100, -i*ArrowSize*10, core.CR_RIGHT, ArrowSize*7+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font, Label,  string.format("%." .. 5 .. "f", Indicator[i].DATA[Indicator[i].DATA:size()-1] ));
												--fromLevel=  Indicator[i].DN[Indicator[i].DN:size()-1];
												color=Up;
												
												elseif Indicator[i].DATA:hasData(Indicator[i].DATA:size()-1)  then
												
                                                core.host:execute("drawLabel1", i, -i*ArrowSize*10,core.CR_RIGHT, ArrowSize*5+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font2, Down, "\226");
												
													core.host:execute("drawLabel1", i+100, -i*ArrowSize*10, core.CR_RIGHT, ArrowSize*7+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font, Label,  string.format("%." .. 5 .. "f", Indicator[i].DATA[Indicator[i].DATA:size()-1] ));
												--fromLevel=  Indicator[i].UP[Indicator[i].UP:size()-1];
												color=Down;
												else
													
                                               core.host:execute("drawLabel1", i, -i*ArrowSize*5 ,core.CR_RIGHT, ArrowSize*5+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font2, Neutral, "\223");												
												
												end 		
												
											
												
						end					
					 
				
			end
	 
	  
	end


function ReleaseInstance()
       core.host:execute("deleteFont", font);
       core.host:execute("deleteFont", font2);
   end

local streams = {}


-- register stream
-- @param barSize       Stream's bar size
-- @param extent        The size of the required exten
-- @return the stream reference
function registerStream(id, barSize, extent)
    local stream = {};
    local s1, e1, length;
    local from, to;

    s1, e1 = core.getcandle(barSize, core.now(), 0, 0);
    length = math.floor((e1 - s1) * 86400 + 0.5);

    -- the size of the source
    if barSize == source:barSize() then
        stream.data = source;
        stream.barSize = barSize;
        stream.external = false;
        stream.length = length;
        stream.loading = false;
        stream.extent = extent;
        stream.loading = false;
    else
        stream.data = nil;
        stream.barSize = barSize;
        stream.external = true;
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
        stream.dataFrom = dataFrom;
        stream.data = host:execute("getHistory", id, source:instrument(), barSize, from, to, source:isBid());
        setBookmark(0);
    end
    streams[id] = stream;
    return stream.data;
end

function getPeriod(id, period)
    local stream = streams[id];
    assert(stream ~= nil, "Stream is not registered");
    local candle, from, dataFrom, to;
    if stream.external then
        candle = core.getcandle(stream.barSize, source:date(period), day_offset, week_offset);
        if candle < stream.dataFrom then
            setBookmark(period);
            if stream.loading then
                return -1, true;
            end
            from, dataFrom = getFrom(stream.barSize, stream.length, stream.extent);
            stream.loading = true;
            stream.loadingFrom = from;
            stream.dataFrom = dataFrom;
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
        p = core.findDate (stream.data, candle, true);
        return p, stream.loading;
    else
        return period;
    end
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
    loadFrom = math.floor(from * 86400 - 2 * length * extent + 0.5) / 86400;
    nontrading, nontradingend = core.isnontrading(from, day_offset);
    if nontrading then
        -- if it is non-trading, shift for two days to skip the non-trading periods
        loadFrom = math.floor((loadFrom - 2) * 86400 - 2 * length * extent + 0.5) / 86400;
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