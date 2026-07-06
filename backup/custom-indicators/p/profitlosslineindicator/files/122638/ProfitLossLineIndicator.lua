
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=67121


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
    indicator:name("ProfitLossLineIndicator");
    indicator:description("The indicator shows the price at which the currently held positions for current profit");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator:setTag("IgnoreBidAskChange", "True");

	indicator.parameters:addInteger("Profit", "Profit/Loss(in pips)", "", 5, -1000, 1000);
    indicator.parameters:addString("Type", "Type", "", "Ask");
    indicator.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    indicator.parameters:addStringAlternative("Type", "Ask", "", "Ask");

    indicator.parameters:addColor("Color", "Line color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("STYLE", "Line style", "", core.LINE_DOT);
    indicator.parameters:setFlag("STYLE", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("WIDTH", "Line width", "", 1, 1, 5);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local style;
local width;

local instrument;
local first;
local source = nil;
local format;
local color;
local profit;
local type;

-- Streams block
local ProfitLine = nil;
local timer;

-- Routine
function Prepare(onlyName)
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end

    profit = instance.parameters.Profit;
    color = instance.parameters.Color;
    style = instance.parameters.STYLE;
    width = instance.parameters.WIDTH;
    instrument = source:instrument();
    format = "%s:%." .. source:getPrecision() .. "f";
    type = instance.parameters.Type;
    
    bid = core.host:execute("getBidPrice");
    ask = core.host:execute("getAskPrice");	

    ProfitLine = instance:addStream("ProfitLine", core.Line, name, "ProfitLine", instance.parameters.Color, 0);
    timer = core.host:execute("setTimer", 1, 1);
end

-- Indicator calculation routine
function Update(period, mode)
    local i, v;
    if period == source:size() - 1 then
        i = ProfitLine:getBookmark(1);
        if i >= 0 and i ~= period then
            v = ProfitLine[i];
            ProfitLine:set(i, nil);
            ProfitLine[period] = v;
            ProfitLine:setBookmark(1, period);
        end
    end
end

local _average= -1;

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1 and source:size() > source:first() then
        local period;
        period = source:size() - 1;

        local table, enum, row;
        local sellA, sellP;
        local buyA, buyB;
        local i;
        table = core.host:findTable("summary");
        if table == nil then
            return ;
        end
        enum = table:enumerator();
        row = enum:next();
        local sellAvgOpen = 0;
        local buyAvgOpen = 0;
        
        local sellAmountK = 0;
        local buyAmountK  = 0;

        local average = 0;
        while row ~= nil do
            if row.Instrument == instrument then
                sellAvgOpen = row.SellAvgOpen;
                buyAvgOpen = row.BuyAvgOpen;               
                sellAmountK = row.SellAmountK;
                buyAmountK = row.BuyAmountK;
            end
            row = enum:next();
        end
        
        local sellAmount = sellAmountK * 1000;
        local buyAmount = buyAmountK * 1000;
        
        local spread = ask[period] - bid[period];
        
        if sellAmountK == buyAmountK then                    
            average = 0; --we can calculate when sellAmountK != buyAmountK
            core.host:trace("Attention: we can calculate when sellAmountK != buyAmountK");
        else
            average =  (sellAvgOpen * sellAmount -  buyAmount * (spread + buyAvgOpen) - profit) / (sellAmount - buyAmount)
            if type == "Bid" then
                average = average - spread;
            end
        end
        
    
        if ProfitLine:getBookmark(1) < 0 and _average > 0 then
            _average = -1;
        end

        if math.abs(average - _average) < 0.000001 then
            return ;
        end

        _average = average;

        i = ProfitLine:getBookmark(1);
        if i >= 0 then
            ProfitLine:set(i, nil);
            ProfitLine:setBookmark(1, -1);
        end

        if average > 0.00001 then
            ProfitLine[period] = average;
            ProfitLine:setBookmark(1, period);
            core.host:execute("drawLine", 1, source:date(source:first()), average, source:date(source:size() - 1) + 5, average, color, style, width, string.format(format, "ProfitLine", average));
        else
            core.host:execute("removeLine", 1);
        end

        return core.ASYNC_REDRAW;
    end
end

function tradesCount(BuySell) 
    local enum, row;
    local count = 0;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while row ~= nil do
        if row.Instrument == instrument and
           (row.BS == BuySell or BuySell == nil) then
           count = count + 1;
        end
        row = enum:next();
    end

    return count
end

function ReleaseInstance()
    core.host:execute("killTimer", timer);
end
