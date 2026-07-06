-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4504

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
 



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams

--13 Time Frame 
local Period = { 
    {code = "m1", default = false}, 
    {code = "m5" , default = false}, 
    {code = "m15", default = true}, 
    {code = "m30", default = true}, 
    {code = "H1", default = true}, 
    {code = "H2", default = true}, 
    {code = "H3", default = false}, 
    {code = "H4", default = true}, 
    {code = "H6", default = false}, 
    {code = "H8", default = false}, 
    {code = "D1", default = true}, 
    {code = "W1", default = true}, 
    {code = "M1", default = false}
}; 

local Instrument = {
{id = 1; name = "EUR/USD"}, {id = 2; name = "USD/JPY"}, {id = 3; name = "GBP/USD"}, {id = 4; name = "USD/CHF"},
{id = 5; name = "EUR/CHF"}, {id = 6; name = "AUD/USD"}, {id = 7; name = "USD/CAD"}, {id = 8; name = "NZD/USD"},
{id = 9; name = "EUR/GBP"}, {id = 10; name = "EUR/JPY"}, {id = 11; name = "GBP/JPY"}, {id = 12; name = "CHF/JPY"},
{id = 13; name = "GBP/CHF"}, {id = 14; name = "EUR/AUD"}, {id = 15; name = "EUR/CAD"}, {id = 16; name = "AUD/CAD"},
{id = 17; name = "AUD/JPY"}, {id = 18; name = "CAD/JPY"}, {id = 19; name = "NZD/JPY"}, {id = 20; name = "GBP/CAD"},
{id = 21; name = "GBP/NZD"}, {id = 22; name = "GBP/AUD"}, {id = 28; name = "AUD/NZD"}, {id = 30; name = "USD/SEK"},
{id = 31; name = "USD/DKK"}, {id = 32; name = "EUR/SEK"}, {id = 36; name = "EUR/NOK"}, {id = 37; name = "USD/NOK"},
{id = 38; name = "USD/MXN"}, {id = 39; name = "AUD/CHF"}, {id = 40; name = "EUR/NZD"}, {id = 47; name = "USD/ZAR"},
{id = 48; name = "USD/SGD"}, {id = 50; name = "USD/HKD"}, {id = 51; name = "EUR/DKK"}, {id = 60; name = "GBP/SEK"},
{id = 66; name = "NOK/JPY"}, {id = 67; name = "SEK/JPY"}, {id = 69; name = "SGD/JPY"}, {id = 70; name = "HKD/JPY"},
{id = 71; name = "ZAR/JPY"}, {id = 83; name = "USD/TRY"}, {id = 87; name = "EUR/TRY"}, {id = 89; name = "NZD/CHF"},
{id = 90; name = "CAD/CHF"}, {id = 91; name = "NZD/CAD"}, {id = 93; name = "CHF/SEK"}, {id = 94; name = "CHF/NOK"},
{id = 98; name = "TRY/JPY"}
};


local Time, Offer = {}, {}

--local Period ={  "H1", "H4", "H8", "D1", "W1" , "M1"  }; 

function Init()
    indicator:name("MVA Dashboard");
    indicator:description("MVA Dashboard");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    -- ========================= MVA Periods ============================= --
    indicator.parameters:addGroup("MVA Periods");
    indicator.parameters:addInteger("SMA1P", "Short MVA Period" , "", 30, 0, 1000)
    indicator.parameters:addInteger("SMA2P", "Medium MVA Period" , "", 50, 0, 1000)
    indicator.parameters:addInteger("SMA3P", "Long MVA Period" , "", 100, 0, 1000)
    -- ========================= Time Periods ============================= --
    indicator.parameters:addGroup("Time Periods");
    local i;
    for i= 1, #Period do
        indicator.parameters:addBoolean("Show" .. Period[i].code, "Show " .. Period[i].code, "", Period[i].default);
    end 
	  
	-- =========================    Offers    ============================= --
	indicator.parameters:addGroup("Offers");  
						  
	for i = 1, #Instrument do	  
		indicator.parameters:addBoolean("Show" .. Instrument[i].id,  "Show " .. Instrument[i].name, "" , true);	
    end					  
    
	indicator.parameters:addGroup("Colors");
    indicator.parameters:addColor("labelColor", "Labels color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("upColor", "Color of UP arrow", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("downColor", "Color of DOWN arrow", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("neutralColor", "Color of NEUTRAL bar", "", core.rgb(128, 128, 128));
    
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local firstperiod;
local source = nil;
local day_offset, week_offset;

local SELECT;
local TAG;
local TEMP={};

-- Streams block
local font;
local font2;
local dummy;
local host = core.host;

local init = {false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,false };
local streams = {};
local stream = {};

local TMP=1;

local Type;
local TF;
local jc=0;	
local FLAG=true;

local Digits;
--local INDEX={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20};
local INDEX={};
local BUFFER={};

local SMA1P, SMA2P, SMA3P

function hasInstrument(id)
    for i = 1, #Instrument do	  
        if tostring(Instrument[i].id) == id then
            return true
        end
    end
    return false
end

-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
    source = instance.source;
    firstperiod = source:first();
     day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");

    SMA1P = instance.parameters.SMA1P
    SMA2P = instance.parameters.SMA2P
    SMA3P = instance.parameters.SMA3P
    
    assert(SMA1P < SMA2P, "Short MVA period should be less then Medium")
    assert(SMA2P < SMA3P, "Medium MVA period should be less then Long")
    
   
	
	normal = core.host:execute("createFont", "Courier", 12, false, false);
    arrows   = core.host:execute("createFont", "Wingdings", 12, false, false);
	
	dummy = instance:addInternalStream (firstperiod, 0);
	
    for i =  1, #Period do
        if instance.parameters:getBoolean("Show" .. Period[i].code) then
            table.insert(Time, {
                code = Period[i].code
            })
        end
    end
    
    local enum = core.host:findTable("offers"):enumerator();
    local row;
    local chartOffer = -1;
    while true do
        row = enum:next();	
        if row == nil then
            break;
		end	
        
        if hasInstrument(row.OfferID) and instance.parameters:getBoolean("Show" .. row.OfferID) then
            if row.Instrument == source:instrument() then
                chartOffer = #Offer + 1
            end
            table.insert(Offer, {
                id = row.OfferID, 
                name = row.Instrument, 
                init = false
            })
        end
    end
    
    -- Move main chart offer to first place
    if chartOffer ~= 1 and chartOffer ~= -1 then
        Offer[1], Offer[chartOffer] = Offer[chartOffer], Offer[1]
    end
    
    host:execute ("addCommand", 1, "Refresh", "Refresh")
    TMP=1;
end

function id(i, j)
    return Offer[i].startId + j
end

function labelId(i,j)
 return i * (#Time + 4) + j
end 

local NEXT_STREAM_ID = 1000

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period >= firstperiod and source:hasData(period) then
        if period ~= source:size() - 1 or period == last_updated then 
            return;
        end
       
        last_updated = period;
        dummy[period]= 0;   --???
        local i, j;
	
        --rescanOffers();
        DRAW()
     end
end

function DRAW()   
        -- ============ DRAW LABELS ================= --
        local k = 0
        local width = #Time * 35 + 200
        for j = 1, #Time do		 
            core.host:execute("drawLabel1", 100 + j, 80 + j * 35, core.CR_LEFT, 20, core.CR_TOP, core.H_Center, core.V_Center,
                              normal, instance.parameters.labelColor, Time[j].code);
            core.host:execute("drawLabel1", 200 + j , width + j * 35, core.CR_LEFT, 20, core.CR_TOP, core.H_Center, core.V_Center,
                              normal, instance.parameters.labelColor, Time[j].code);
        end			 
        
        _=[[==
        core.host:execute("drawLabel1", 100 + #Time + 1, 70+ #Time * 35 + 70, core.CR_LEFT, 20, core.CR_TOP, core.H_Center, core.V_Center,
                              normal, instance.parameters.labelColor, "Today");
        core.host:execute("drawLabel1", 100 + #Time + 2, 70 + #Time * 35 + 150, core.CR_LEFT, 20, core.CR_TOP, core.H_Center, core.V_Center,
                              normal, instance.parameters.labelColor, "ADR");
        core.host:execute("drawLabel1", 100 + #Time + 3, 70 + #Time * 35 + 210, core.CR_LEFT, 20, core.CR_TOP, core.H_Center, core.V_Center,
                              normal, instance.parameters.labelColor, "P.High");
        core.host:execute("drawLabel1", 100 + #Time + 4, 70 + #Time * 35 + 280, core.CR_LEFT, 20, core.CR_TOP, core.H_Center, core.V_Center,
                              normal, instance.parameters.labelColor, "P.Low");
        ==]]
        local len = math.floor((#Offer + 1)/ 2)
        for i = 1, len do
               local i2 = i + len
                core.host:execute("drawLabel1", 300 + i, 40, core.CR_LEFT, 40 + i * 17, core.CR_TOP, core.H_Center, core.V_Center,
                                  normal, instance.parameters.labelColor, Offer[i].name);
                if (i2 <= #Offer) then
                core.host:execute("drawLabel1", 300 + i2, width - 35 , core.CR_LEFT, 40 + i * 17, core.CR_TOP, core.H_Center, core.V_Center,
                                    normal, instance.parameters.labelColor, Offer[i2].name);
                end
               if not Offer[i].init then
                    Offer[i].init = true;
                    Offer[i].startId = getNextId();
                    for j = 1, #Time do	
                        stream[id(i, j)] = registerStream(id(i, j), Time[j].code, 160, Offer[i].name);  						
					end	
               end
               
               if i2 <= #Offer and not Offer[i2].init then
                    Offer[i2].init = true;
                    Offer[i2].startId = getNextId();
                    for j = 1, #Time do	
                        stream[id(i2, j)] = registerStream(id(i2, j), Time[j].code, 160, Offer[i2].name);  						
					end	
               end
               
                for j= 1, #Time do				
                    local s = stream[id(i,j)]
                    
                    if  s:hasData(s:size() - 1) and s:size() > 100 then --and ss.MVA1 ~= nil
                        showLabel(s, i, j, j * 35 + 75, i * 17) 
                    end
                  
                    if (i2 <= #Offer) then
                        s = stream[id(i2, j)]
                        if  s:hasData(s:size() - 1) and s:size() > 100 then --and ss.MVA1 ~= nil
                            showLabel(s, i2, j, j * 35 + width, i * 17) 
                        end
                    end
                end
                
                _ = [[== 
                showPlainLabel("1.12345", i, #Time + 1, #Time * 35 + 110, i * 17) 
                showPlainLabel("1.12345", i, #Time + 2, #Time * 35 + 180, i * 17) 
                showPlainLabel("1.12345", i, #Time + 3, #Time * 35 + 250, i * 17) 
                showPlainLabel("1.12345", i, #Time + 4, #Time * 35 + 320, i * 17) 
                ==]]

        end
end

function rescanOffers()
    for i = 1, 50 do
      for j = 1, 15 do 
        core.host:execute("removeLabel", 400 + labelId(i, j))
      end
    end
    
    local enum = core.host:findTable("offers"):enumerator();
    local row = enum:next();	
    local chartOffer = -1;
    local nOffer = {}
    while row ~= nil do
        if instance.parameters:getBoolean("Show" .. row.OfferID) then
            local o = nil;
            --Try to find offer among already registered Offers
            for i = 1, #Offer do
                if Offer[i].id == row.OfferID then
                    o = Offer[i]
                    break
                end
            end
            -- Create new if not found
            if o == nil then
                o = {
                    id = row.OfferID, 
                    name = row.Instrument, 
                    init = false
                }
            end
            
            if row.Instrument == source:instrument() then
              chartOffer = #nOffer + 1
            end
            
            table.insert(nOffer, o);
        end
        row = enum:next();	
    end
    
    if chartOffer ~= 1 and chartOffer ~= -1 then
        nOffer[1], nOffer[chartOffer] = nOffer[chartOffer], nOffer[1]
    end
    
    Offer = nOffer;
    DRAW();
end

function getNextId()
    local nextId = NEXT_STREAM_ID
    NEXT_STREAM_ID = NEXT_STREAM_ID + #Time + 1;
    return nextId
end

function showPlainLabel(label, i, j, xoff, yoff)
        core.host:execute("drawLabel1", 400 + labelId(i,j), xoff, core.CR_LEFT, 40 + yoff, core.CR_TOP, core.H_Right, core.V_Center,
                        normal, instance.parameters.upColor, label); --  "\228\37\113"
end

function showLabel(s, i, j, xoff, yoff)
   local sma30 = mathex.avg(s.close, core.rangeTo(s:size() - 1, instance.parameters.SMA1P))
   local sma50 = mathex.avg(s.close, core.rangeTo(s:size() - 1, instance.parameters.SMA2P))
   local sma100 = mathex.avg(s.close, core.rangeTo(s:size() - 1, instance.parameters.SMA3P))
   local price = s.close[s:size() - 1]
   local alert = ""
   
   if (sma30 > sma50 and sma50 > sma100) then
        if sma30 > price and price > sma50 then alert = "\37" end
        core.host:execute("drawLabel1", 400 + labelId(i,j), xoff, core.CR_LEFT, 40 + yoff, core.CR_TOP, core.H_Right, core.V_Center,
                        arrows, instance.parameters.upColor, "\228" .. alert); --  "\228\37\113"
    elseif (sma30 < sma50 and sma50 < sma100) then
        if sma30 < price and price < sma50 then alert = "\37" end
        core.host:execute("drawLabel1", 400 + labelId(i,j), xoff, core.CR_LEFT, 40 + yoff, core.CR_TOP, core.H_Right, core.V_Center,
                        arrows, instance.parameters.downColor, "\230" .. alert); --  "\228\37\113"
    else
        core.host:execute("drawLabel1", 400 + labelId(i,j), xoff, core.CR_LEFT, 40 + yoff, core.CR_TOP, core.H_Right, core.V_Center,
                        arrows, instance.parameters.neutralColor, "\113"); --  "\228\37\113"
    end
end

function ReleaseInstance()
    core.host:execute("deleteFont", normal);   
	core.host:execute("deleteFont", arrows);  
end
   
   
   
   
-- register stream
-- @param barSize       Stream's bar size
-- @param extent        The size of the required extent (number of periods to look the back)
-- @return the stream reference
function registerStream(id, barSize, extent, instrument)
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
    --stream.data = host:execute("getHistory", id, instrument, barSize, from, to, source:isBid());
    stream.data = host:execute("getHistory", id, instrument, barSize, 0, 0, source:isBid());
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

    --from = core.getcandle(barSize, source:date(source:size() - 1), day_offset, week_offset);
    from = core.host:execute ("convertTime", core.TZ_LOCAL, core.TZ_SERVER, core.now())
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
    if cookie == 1 then
        rescanOffers();
        return;
    end
    
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
    --core.host:trace('Asyncfinished for ' .. cookie .. ',' .. stream.data:size());
    stream.MVA1 = core.indicators:create('MVA', stream.data.close, 30)
    stream.MVA1:update(core.UpdateAll)
    last_updated = 0
    instance:updateFrom(period);
end