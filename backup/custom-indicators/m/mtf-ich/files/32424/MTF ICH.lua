-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=17908
-- Id: 6486

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("MTF ICH");
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
	indicator.parameters:addColor("SL", "SL Line  Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("TL", "TL Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("CS", "CS Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("SA", "SA Line Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addColor("SB", "SB Line Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	
	Style (1 );
	Style (2 );
	Style (3 );
	Style (4 );
	Style (5 );
	
	
end

function Style (id)
    
  	indicator.parameters:addGroup(id.. ".  Time Frame Style Options"); 
    indicator.parameters:addBoolean("Show"..id, "Show Line", "", true);
    indicator.parameters:addInteger("widht"..id, "Line widht", "", 1, 1, 5);
    indicator.parameters:addInteger("style"..id, "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style"..id, core.FLAG_LINE_STYLE);
--	indicator.parameters:addColor("color"..id, "Color", "", core.rgb(0, 255, 0));
end


function Parameters (id , FRAME )


  	indicator.parameters:addGroup(id..".  Time Frame");    
  
    indicator.parameters:addString("B"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("B"..id, core.FLAG_PERIODS);
	

	indicator.parameters:addInteger("TS"..id, "Tenkan-sen period", "Tenkan-sen period", 9, 1, 1000);
    indicator.parameters:addInteger("KS"..id, "Kijun-sen period", "Kijun-sen period", 26, 1, 1000);
    indicator.parameters:addInteger("SS"..id, "Senkou Span B period", "Senkou Span B period", 52, 1, 1000);
end


local TS={};
local KS={};
local SS={};
local B={};
--local color={};
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
local first;
local Up, Down, Neutral, Label;
local Shift;
 local font;
 local font2;
local List;
local Old={};
local Final={};
local Note={"TL", "SL", "CS", "SA", "SB"};
function Prepare(nameOnly)   
    
	Label=instance.parameters.Label;
    Shift=instance.parameters.Shift;
    	local i;
    for i= 1, 5, 1 do		
	 style[i]= instance.parameters:getDouble ("style"..i);
	 widht[i]= instance.parameters:getDouble ("widht"..i);
	 TS[i]= instance.parameters:getDouble ("TS"..i);
	 KS[i]= instance.parameters:getDouble ("KS"..i);
	 SS[i]= instance.parameters:getDouble ("SS"..i);
     B[i]= instance.parameters:getString ("B"..i);
	end
      
    ArrowSize=instance.parameters.ArrowSize; 
	
    local name =  profile:id() .. ","  .. instance.source:name() ;
	
    source = instance.source;
	first= source:first();
    host = core.host;

    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");	

	for i= 1, 5, 1 do
	name = name..", (" .. B[i]..", " ..KS[i]..", ".. TS[i]..", ".. SS[i] ..  ")";      
	end
	name = name .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    dummy = instance:addInternalStream(0, 0);
	
	--Arial
	  font = core.host:execute("createFont", "Arial", ArrowSize, true, false);
       font2 = core.host:execute("createFont", "Wingdings", ArrowSize, false, false);
	Indicator = nil;
end


function Update(period, mode)

 if not source:hasData(period) or   period < first then 
 return;
 end
 
 
 if  period <  source:size() - 1 then	
                            return;
	end
 
	local i;
	
	if Indicator == nil then
	Indicator = {};		
		for i = 1, 5 , 1 do	 
			stream[i] = registerStream(i, B[i],  math.max(KS[i],  TS[i],  SS[i])+1);
			Indicator[i] = core.indicators:create("ICH", stream[i], KS[i],  TS[i],  SS[i], instance.parameters.SL,0,0,  instance.parameters.TL, 0,0,instance.parameters.CS, 0,0,instance.parameters.SA,0,0, instance.parameters.SB);
		end
	end
	
	
	
	
			for i = 1, 5, 1  do		     
	
				
						Indicator[i]:update(mode);
					
						
						
						if  Indicator[i].DATA:hasData( Indicator[i].DATA:size()-1)  or   Indicator[i].DATA:hasData(Indicator[i].DATA:size()-1)then	
                        
                              
                     							
							 
							      core.host:execute("drawLabel1", i+200, -i*100, core.CR_RIGHT,35+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
                             font, Label, instance.parameters:getString ("B"..i));
							 
						
								SORT(i);								
							
                                			
								Final[1] = Find( 1);
								Final[2]= Find( 2);
								Final[3] = Find( 3);
								Final[4] = Find( 4);
								Final[5] = Find( 5);
												
							
								
								local j;
								
								
							
								
								for j=  1, 5, 1 do
									if List[j]~= nil and  Final[j]~= nil then									
								     
									 	
						           local Temp=  Indicator[i]:getStream (Final[j]-1 );								  
								   local color= Temp:colorI(Temp:size()-1) ;
						 			
									core.host:execute("drawLabel1", i+100 + j*10, -i*100, core.CR_RIGHT, ((j+1)*35)+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
									 font, color, tostring( Note [Final[j]] .." "..string.format("%." .. 5 .. "f", List[j])));
									 end
									 
									 -- )
								end 
						
												
												
													
                                             
												
											
												
						end					
					 
				
			end
	 
	  
	end
	
function Find ( Number)	

local j;
	for j = 1, 5, 1 do
		  if  Old[j]==List[Number]  
		  then
				return j,0;
		  end
	end

end

function SORT (i)

List =nil;

local A= Indicator[i]:getStream (0);
local B= Indicator[i]:getStream (1);
local C= Indicator[i]:getStream (2);
local D= Indicator[i]:getStream (3);
local E= Indicator[i]:getStream (4);

local a=A[ A:size()-1];
local b=B[ B:size()-1];
local c=C[ C:size()-1];
local d=D[ D:size()-1];
local e=E[ E:size()-1];

if  b== a then
b = b+0.0001;
end

if c==b then
c = c+0.0001;
end

if  d==b then
d = d+0.0001;
end

if  e== d then
e = e+0.0001;
end


List= {   a,b,c,d,e  };
Old= {   a,b,c,d,e   };

table.sort(List, compare)
--table.sort(List);
end	

function compare(a,b)
  return a > b;
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