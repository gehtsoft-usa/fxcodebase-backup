-- Id: 6832
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=20388

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("High/Low Bands (Advanced)");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("TF", "Bar Size to display High/Low", "", "D1");
	  indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
    indicator.parameters:addBoolean("YTD", "Show yesterday band", "Choose yes to show yesterday band and no to show today band", false);
  
    indicator.parameters:addGroup("Band");
    indicator.parameters:addBoolean("Extend", "Extend the band till the end of the bar", "", false);
    indicator.parameters:addColor("clrB", "High/Low Band Color", "", core.rgb(192, 192, 192));
    indicator.parameters:addInteger("Width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("A", "High/Low Band transparency (%)", "", 95, 0, 100);
    indicator.parameters:addGroup("Labels");
    indicator.parameters:addBoolean("ShowLabelPip", "Show Size Labels", "", false);
    indicator.parameters:addBoolean("ShowLabelFrame", "Show Frame Labels", "", false);
    indicator.parameters:addColor("LabelC", "Label color", "", core.COLOR_LABEL);
    indicator.parameters:addInteger("LabelI", "Label Size", "", 8, 6, 24);
    indicator.parameters:addInteger("LabelLoc", "Label Location", "", 1);
    indicator.parameters:addIntegerAlternative("LabelLoc", "Above", "", 1);
    indicator.parameters:addIntegerAlternative("LabelLoc", "Below", "", 2);
end

local source;                   -- the source
local hilo_data = nil;          -- the high/low data
local H;                        -- high stream
local L;                        -- low stream
local TF;
local BSLen;
local dates;                    -- candle dates
local CLen;
local host;
local dayoffset;
local weekoffset;
local candles;                  -- stream of the candle's dates
local YTD;
local Extend;
local maxBarsPerBS;
local ShowLabelPip;
local ShowLabelFrame;
local LabelLoc;
local Labels;
local pipSize;
local formatPips;
local hilo_data, loading;
function Prepare(nameOnly)
    source = instance.source;
    host = core.host;
    dayoffset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
    TF = instance.parameters.TF;
    YTD = instance.parameters.YTD;
    Extend = instance.parameters.Extend;
    ShowLabelPip = instance.parameters.ShowLabelPip;
    ShowLabelFrame = instance.parameters.ShowLabelFrame;
    LabelLoc = instance.parameters.LabelLoc;
    local YTDn;

    if YTD then
        YTDn = "prev";
    else
        YTDn = "curr";
    end

    local l1, l2;
    local s, e;

    s, e = core.getcandle(source:barSize(), core.now(), 0);
    l1 = e - s;
    s, e = core.getcandle(TF, core.now(), 0);
    l2 = e - s;
    CLen = l1;
    BSLen = l2; -- remember length of the period
    assert(l1 <= l2, "The chosen time frame must be the same of longer than the chart time frame");
    if Extend then
        maxBarsPerBS = math.floor(l2 / l1 + 0.5);
    else
        maxBarsPerBS = 0;
    end
	
    local name = profile:id() .. "(" .. source:name() .. "," .. TF .. "," .. YTDn .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	hilo_data = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), 0, 100, 101);
	loading=true;

    H = instance:addStream("H", core.Line, name .. ".H", "H", instance.parameters.clrB, 0, maxBarsPerBS);
    H:setStyle(instance.parameters.Style);
    H:setWidth(instance.parameters.Width);
    L = instance:addStream("L", core.Line, name .. ".L", "L", instance.parameters.clrB, 0, maxBarsPerBS);
    L:setStyle(instance.parameters.Style);
    L:setWidth(instance.parameters.Width);
    instance:createChannelGroup("HL", "HL", H, L, instance.parameters.clrB, 100 - instance.parameters.A, true);
    candles = instance:addInternalStream(0, 0);
    if ShowLabelPip or ShowLabelFrame then
        pipSize = source:pipSize();
        formatPips = "%.1f pips";
        local align;
        if LabelLoc == 1 then
            align = core.V_Top;
        else
            align = core.V_Bottom;
        end
        Labels = instance:createTextOutput("Labels", "Lbl", "Arial", instance.parameters.LabelI, core.H_Right, align, instance.parameters.LabelC, 0);
    end
end


local loading = false;

-- the function which is called to calculate the period
function Update(period, mode)

    local hilo_candle;
    hilo_candle = core.getcandle(TF, source:date(period), dayoffset, weekoffset);
 
    if period < source:first() then
        return ;
    end

     local hilo_i =  Initialization(period) 
     
	    if not hilo_i then
		return;
		end
		

    -- candle is not found
    if hilo_i < 0 then
        return ;
    end

    if YTD then
        if hilo_i == 0 then
            return;
        end
        hilo_i = hilo_i - 1;
    end

    H[period] = hilo_data.high[hilo_i];
    L[period] = hilo_data.low[hilo_i];
    candles[period] = hilo_candle;
    if period > 0 and candles[period - 1] ~= candles[period] then
        H:setBreak(period, true);
        L:setBreak(period, true);
    else
        H:setBreak(period, false);
        L:setBreak(period, false);
    end

    if source:isAlive() and period > source:first() and period == source:size() - 1 then
        -- update all today's data in case today's high low is changed
        if candles:hasData(period - 1) and candles[period - 1] == hilo_candle and
           ((H[period - 1] ~= H[period]) or (L[period - 1] ~= L[period]))  then
            local i = period - 1;
            local h = hilo_data.high[hilo_i];
            local l = hilo_data.low[hilo_i];
            while i > 0 and candles:hasData(i) and candles[i] == hilo_candle do
                H[i] = h;
                L[i] = l;
                i = i - 1
            end

            if ShowLabelPip or ShowLabelFrame then
                local text;
                text = "";
                if ShowLabelFrame then
                    text = text .. TF;
                end
                if ShowLabelPip then
                    if ShowLabelFrame then
                        text = text .. ",";
                    end
                    text = text .. string.format(formatPips, (H[i + 1] - L[i + 1]) / pipSize);
                end
                local loc;
                if LabelLoc == 1 then
                    loc = H[i + 1];
                else
                    loc = L[i + 1];
                end
                Labels:set(period, loc, text);
            end
        end
    end

    if Extend and period == source:size() - 1 then
        local i = period + 1;
        local b = source:date(period) + CLen;
        local h = hilo_data.high[hilo_i];
        local l = hilo_data.low[hilo_i];
        while i < H:size() and b < hilo_candle + BSLen do
            if H:hasData(i) and H[i] == h and L[i] == l then
                break;
            end
            H[i] = h;
            L[i] = l;
            i = i + 1;
            b = b + CLen;
        end
    end

    if (ShowLabelPip or ShowLabelFrame) and (period == 0 or candles[period - 1] ~= hilo_candle) then
        local text;
        text = "";
        if ShowLabelFrame then
            text = text .. TF;
        end
        if ShowLabelPip then
            if ShowLabelFrame then
                text = text .. ",";
            end
            text = text .. string.format(formatPips, (H[period] - L[period]) / pipSize);
        end
        local loc;
        if LabelLoc == 1 then
            loc = H[period];
        else
            loc = L[period];
        end
        Labels:set(period, loc, text);
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
end


function   Initialization(period)

    local Candle;
    Candle = core.getcandle(TF, source:date(period), dayoffset, weekoffset);

  
    if loading or hilo_data:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(hilo_data, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	

