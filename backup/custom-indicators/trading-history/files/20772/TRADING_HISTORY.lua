-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=9754

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
    indicator:name("Trading History");
    indicator:description("Shows account trading history");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addString("account", "Account", "", "");
    indicator.parameters:setFlag("account", core.FLAG_ACCOUNT);

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("P_color", "Color of positive labels", "Color of Surge labels", core.rgb(0, 255, 0));
    indicator.parameters:addColor("N_color", "Color of negative labels", "Color of Plunge labels", core.rgb(255, 0, 0));
end

local timerId;
local account
local source
local day_offset
local week_offset
local request_start_day = 0

function Prepare(onlyName)
    source = instance.source;
    host = core.host;

    account = instance.parameters.account

    instance:name(profile:id());
    if onlyName then
        return ;
    end

    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");

    require("LuaLib/commons");
    require("LuaLib/reportapi");
    require("LuaLib/reportcache")

    reportcache.initialize(account)
    last_index = 1

    timerId = core.host:execute("setTimer", 1, 1);

    B = instance:createTextOutput("B", "B", "Wingdings 3", 12, core.H_Center, core.V_Bottom, instance.parameters.P_color, 0);
    BB = instance:createTextOutput("BB", "BB", "Wingdings 3", 16, core.H_Center, core.V_Bottom, instance.parameters.P_color, 0);
    S = instance:createTextOutput("S", "S", "Wingdings 3", 12, core.H_Center, core.V_Top, instance.parameters.N_color, 0);
    BS = instance:createTextOutput("BS", "BS", "Wingdings 3", 16, core.H_Center, core.V_Top, instance.parameters.N_color, 0);
end

local sent = false;

local waiting_trades = {}
--local last_index = 1

local REDRAW = false

function Update(period, mode)
    -- Check if there are closed trades in source:date(period) and draw arrow
    if mode == core.UpdateAll then
        last_index = 1
    end
    local closed_trades = reportcache.get_closed_trades();

    local up, dn = 0, 0
    local uppnl, dnpnl = 0, 0
    local label = ''
    local start, finish = core.getcandle(source:barSize(), source:date(period), day_offset, week_offset);        

    for i = last_index, #closed_trades do
        if closed_trades[i].symbol == source:instrument() then
            -- Open
            if closed_trades[i].open_date >= start and closed_trades[i].open_date < finish then
                if closed_trades[i].quantity > 0 then 
                    up = up + 1
                    uppnl = uppnl + closed_trades[i].net_pl
                    upprice = closed_trades[i].open_rate
                    
                    label = label .. '\nOpen #' .. closed_trades[i].ticket_id .. " Buy " .. tostring(closed_trades[i].volume)
                else
                    dn =dn + 1
                    dnpnl = dnpnl + closed_trades[i].net_pl
                    dnprice = closed_trades[i].open_rate
                    label = label .. '\nOpen #' .. closed_trades[i].ticket_id .. " Sell " .. tostring(closed_trades[i].volume)
                end
            end
            -- Close
            if closed_trades[i].close_date >= start and closed_trades[i].close_date < finish then
                if closed_trades[i].quantity < 0 then 
                    up = up + 1
                    uppnl = uppnl + closed_trades[i].net_pl
                    upprice = closed_trades[i].close_rate
                    label = label .. '\nClosed #' .. closed_trades[i].ticket_id .. " Buy " .. tostring(closed_trades[i].volume)
                else
                    dn = dn + 1
                    dnpnl = dnpnl + closed_trades[i].net_pl
                    dnprice = closed_trades[i].close_rate
                    label = label .. '\nClosed #' .. closed_trades[i].ticket_id .. " Sell " .. tostring(closed_trades[i].volume)
                end
            end

        end

        if closed_trades[i].close_date < start then
            last_index = i + 1
            --break
        end
    end

    if up  > 0 then 
        local color = instance.parameters.P_color

        if uppnl < 0 then color = instance.parameters.N_color end

        if up == 1 then
            B:set(period, upprice, '\199', 'PNL = ' .. tostring(uppnl) .. label, color)
        else
            BB:set(period, source.low[period], '\199', 'PNL = ' .. tostring(uppnl) .. label, color)
        end
    end
    if dn  > 0 then 
        local color = instance.parameters.P_color

        if dnpnl < 0 then color = instance.parameters.N_color end

        if dn == 1 then
            S:set(period, dnprice, '\200', 'PNL = ' .. tostring(dnpnl) .. label, color)
        else
            BS:set(period, source.high[period], '\200', 'PNL = ' .. tostring(dnpnl) .. label, color)
        end
    end
    
end


function AsyncOperationFinished(cookie, success, message)
    if cookie == 1 then 
        reportapi.onTimer();
        if reportcache.onTimer() then
            last_index = 1
            instance:updateFrom(0)
        end            
    end
    return 0
end

function ReleaseInstance()
    reportapi.cancelAll();
end

