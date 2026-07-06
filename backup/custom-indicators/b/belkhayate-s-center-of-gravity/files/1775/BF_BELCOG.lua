-- Id: 619

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=706

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
    indicator:name("Bigger timeframe Stochastic RSI");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addString("BS", "Time frame ", "", "D1");
    indicator.parameters:setFlag("BS", core.FLAG_PERIODS);
    indicator.parameters:addInteger("N", "Number of bars", "", 180);
    indicator.parameters:addInteger("O", "Order", "", 3);
    indicator.parameters:addDouble("E", "Eccart value", "", 1.61803399);
    indicator.parameters:addColor("L1_color_Up", "Color of L1 Up", "Color of L1",core.rgb(0, 0, 255));
 
	
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("L2_color_Up", "Color of L2 Up", "Color of L2",  core.rgb(127, 127, 127));
 
	
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("L3_color_Up", "Color of L3 Up", "Color of L3", core.rgb(255, 0, 0));
 
	
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("L4_color_Up", "Color of L4 Up", "Color of L4", core.rgb(255, 0, 0));
 
	
	indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("L5_color_Up", "Color of L5 Up", "Color of L5",core.rgb(127, 127, 127));
 
	
	indicator.parameters:addInteger("width5", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style5", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style5", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("L6_color_Up", "Color of L6 Up", "Color of L6", core.rgb(0, 192, 0));
 
	
	indicator.parameters:addInteger("width6", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style6", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style6", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("L7_color_Up", "Color of L7 Up", "Color of L7",   core.rgb(0, 192, 0));
 
	
	indicator.parameters:addInteger("width7", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style7", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style7", core.FLAG_LINE_STYLE);

end

local source;                 -- the source
local bf_data = nil;          -- the high/low data
local N;
local O;
local E;
local BS;
local bf_length;                -- length of the bigger frame in seconds
local dates;                    -- candle dates
local host;
local BELCOG;
local day_offset;
local week_offset;
local backstep;

local L1 = nil;
local L2 = nil;
local L3 = nil;
local L4 = nil;
local L5 = nil;
local L6 = nil;
local L7 = nil;

function Prepare(nameOnly)  
    source = instance.source;
    host = core.host;

    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");

    BS = instance.parameters.BS;
    N = instance.parameters.N;
    O = instance.parameters.O;
    E = instance.parameters.E;

    extent = N;

    local s, e, s1, e1;
    s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
    s1, e1 = core.getcandle(BS, core.now(), 0, 0);
    assert ((e - s) < (e1 - s1), "The chosen time frame must be bigger than the chart time frame!");
    bf_length = math.floor((e1 - s1) * 86400 + 0.5);
    backstep = math.floor(N * (e1 - s1) / (e - s));

    local name = profile:id() .. "(" .. source:name() .. ", " .. BS .. ", " .. N .. ", " .. O .. ", " .. E .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	

    L1 = instance:addStream("L1", core.Line, name .. ".L1", "L1", instance.parameters.L1_color_Up, 0);
	L1:setWidth(instance.parameters.width1);
    L1:setStyle(instance.parameters.style1);
	
    L2 = instance:addStream("L2", core.Line, name .. ".L2", "L2", instance.parameters.L2_color_Up, 0);
	L2:setWidth(instance.parameters.width2);
    L2:setStyle(instance.parameters.style2);
	
    L3 = instance:addStream("L3", core.Line, name .. ".L3", "L3", instance.parameters.L3_color_Up, 0);
	L3:setWidth(instance.parameters.width3);
    L3:setStyle(instance.parameters.style3);
	
    L4 = instance:addStream("L4", core.Line, name .. ".L4", "L4", instance.parameters.L4_color_Up, 0);
	L4:setWidth(instance.parameters.width4);
    L4:setStyle(instance.parameters.style4);
	
    L5 = instance:addStream("L5", core.Line, name .. ".L5", "L5", instance.parameters.L5_color_Up, 0);
	L5:setWidth(instance.parameters.width5);
    L5:setStyle(instance.parameters.style5);
	
    L6 = instance:addStream("L6", core.Line, name .. ".L6", "L6", instance.parameters.L6_color_Up, 0);
	L6:setWidth(instance.parameters.width6);
    L6:setStyle(instance.parameters.style6);
	
    L7 = instance:addStream("L7", core.Line, name .. ".L7", "L7", instance.parameters.L7_color_Up, 0);
	L7:setWidth(instance.parameters.width7);
    L7:setStyle(instance.parameters.style7);
end


local loading = false;
local prevCandle = nil;


-- the function which is called to calculate the period
function Update(period, mode)
    -- get date and time of the hi/lo candle in the reference data
    if period == source:size() - 1 then
        -- if data for the specific candle are still loading
        -- then do nothing
        if loading then
            return ;
        end

        -- if the period is before the source start
        -- the do nothing
        if period < source:first() then
            return ;
        end

        -- if data is not loaded yet at all
        -- load the data
        if bf_data == nil then
            -- there is no data at all, load initial data
            local to, t;
            local from;

            if (source:isAlive()) then
                -- if the source is subscribed for updates
                -- then subscribe the current collection as well
                to = 0;
            else
                -- else load up to the last currently available date
                t, to = core.getcandle(BS, source:date(period), day_offset, week_offset);
            end
            from = 0;
            L1:setBookmark(1, period);
            -- shift so the bigger frame data is able to provide us with the stoch data at the first period
            loading = true;
            bf_data = host:execute("getHistory", 1, source:instrument(), BS, from, to, source:isBid());
    assert(core.indicators:findIndicator("BELCOG") ~= nil, "BELCOG" .. " indicator must be installed");
            BELCOG = core.indicators:create("BELCOG", bf_data, N, O, E);
            return ;
        end

        if prevCandle ~= nil and source:serial(period) == prevCandle then
            return ;
        else
            prevCandle = source:serial(period);
        end

        BELCOG:update(mode);

        local t = math.max(period - backstep, source:first());
        local i, bf_candle, bf_candle_p, p, p_p;
        bf_candle_p = -1;
        p_p = -1;
        for i = period, t, -1 do
            bf_candle = core.getcandle(BS, source:date(i), day_offset, week_offset);
            if bf_candle ~= bf_candle_p then
                p = findDateFast(bf_data, bf_candle, true);
                bf_candle_p = bf_candle;
                p_p = p;
            else
                p = p_p;
            end
            if p ~= -1 then
                L1[i] = BELCOG:getStream(0)[p];
                L2[i] = BELCOG:getStream(1)[p];
                L3[i] = BELCOG:getStream(2)[p];
                L4[i] = BELCOG:getStream(3)[p];
                L5[i] = BELCOG:getStream(4)[p];
                L6[i] = BELCOG:getStream(5)[p];
                L7[i] = BELCOG:getStream(6)[p];
            else
                L1[i] = nil;
                L2[i] = nil;
                L3[i] = nil;
                L4[i] = nil;
                L5[i] = nil;
                L6[i] = nil;
                L7[i] = nil;
            end
        end
    else
        prevCandle = nil;
    end
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    local period;

    period = L1:getBookmark(1);
    if (period < 0) then
        period = 0;
    end
    loading = false;
    instance:updateFrom(period);
end

function findDateFast(stream, date, precise)
    local datesec = nil;
    local periodsec = nil;
    local min, max, mid;

    datesec = math.floor(date * 86400 + 0.5)

    min = 0;
    max = stream:size() - 1;

    while true do
        mid = math.floor((min + max) / 2);
        periodsec = math.floor(stream:date(mid) * 86400 + 0.5);
        if datesec == periodsec then
            return mid;
        elseif datesec > periodsec then
            min = mid + 1;
        else
            max = mid - 1;
        end
        if min > max then
            if precise then
                return -1;
            else
                return min - 1;
            end
        end
    end
end
