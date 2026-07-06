-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3514

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
    indicator:description("Shows trading history")
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Report");
    
    indicator.parameters:addString("account", "Account", "", "");
    indicator.parameters:setFlag("account", core.FLAG_ACCOUNT);
    indicator.parameters:addGroup("Style");
    createMarkerParam("BuyArrow", " Open marker style", "Empty");
    createMarkerParam("SellArrow", " Close marker style", "Filled");
    indicator.parameters:addString("viewMode", "View mode", "", "AtBar");
    indicator.parameters:addStringAlternative("viewMode", "At price", "", "AtPrice");
    indicator.parameters:addStringAlternative("viewMode", "At bar", "", "AtBar");
    indicator.parameters:addBoolean("connectionLines", "Draw connection lines", "", false);
    
    indicator.parameters:addInteger("S", "Font size in points", "", 10, 6, 20);
    indicator.parameters:addColor("clrP", "Profit positions color", "", core.rgb(128, 255, 128));
    indicator.parameters:addColor("clrL", "Loss positions color", "", core.rgb(255, 128, 128));
    indicator.parameters:addInteger("width", "Line width", "", 1);
end

function createMarkerParam(id, name, def)
    indicator.parameters:addString(id, name, "For the \"At price\" mode", def);
    indicator.parameters:addStringAlternative(id, "Filled arrow", "", "Filled");
    indicator.parameters:addStringAlternative(id, "Empty arrow", "", "Empty");
end

local source;
local buyPos;
local sellPos;
local http;
local loading;
local instr;
local account;
local first;
local openSymbols = {};
local closeSymbols = {};
local profitColor;
local lossColor;
local connectionLines;
local font;
local viewMode;

function fillSumbols(arrowStyle, symbols)
    if arrowStyle == "Filled" then
        symbols.buy = "\112";
        symbols.sell = "\113";
    else -- Empty
        symbols.buy = "\114";
        symbols.sell = "\115";
    end
end

function Prepare(onlyName)
    local name = profile:id();
    instance:name(name);
    if onlyName then
        return ;
    end
    
    require("expat_lua");
    require("http_lua");

    source = instance.source;
    instr = source:instrument();
    account = instance.parameters.account;
    connectionLines = instance.parameters.connectionLines;
    first = source:first();
    fillSumbols(instance.parameters.BuyArrow, openSymbols);
    fillSumbols(instance.parameters.SellArrow, closeSymbols);
    viewMode = instance.parameters.viewMode;
    profitColor = instance.parameters.clrP;
    lossColor = instance.parameters.clrL;
    
    if viewMode == "AtPrice" then
        font = core.host:execute("createFont", "Wingdings 3", instance.parameters.S, false, false);
    else
        buyPos = instance:createTextOutput("P", "P", "Wingdings 3", instance.parameters.S, core.H_Center, core.V_Bottom, profitColor, 0);
        sellPos = instance:createTextOutput("L", "L", "Wingdings 3", instance.parameters.S, core.H_Center, core.V_Top, lossColor, 0);
    end
    loading = false;
    
    core.host:execute("addCommand", 10001, "Refresh", "");
end

local model = {filled = false};
local earliestDate;
local timerId;

-- Loads report for the specified date interval
function loadData(fromDate, toDate)
    if loading == true then 
        return;
    end
    http = http_lua.createRequest();
    local url = getReportURL(instance.parameters.account, source:date(first), source:date(source:size() - 1));
    http:start(url);
    timerId = core.host:execute("setTimer", 1, 1);
    loading = true;
    core.host:execute("setStatus", "loading...");
end

-- ----------------------------------------------------------------
-- Get XML report url
-- ----------------------------------------------------------------
function getReportURL(account, fromDate, toDate)
    local url = core.host:execute("getTradingProperty", "ReportURL", nil, account);
    url = url .. "&report_name=REPORT_NAME_CUSTOMER_ACCOUNT_STATEMENT";
    url = url .. "&outFormat=xml";
    local from = core.dateToTable(core.host:execute("convertTime", core.TZ_EST, core.TZ_FINANCIAL, fromDate));
    url = url .. "&from=" .. string.format("%02i/%02i/%04i", from.month, from.day, from.year);
    local to = core.dateToTable(core.host:execute("convertTime", core.TZ_EST, core.TZ_FINANCIAL, toDate));
    url = url .. "&till=" .. string.format("%02i/%02i/%04i", to.month, to.day, to.year);
    return url;
end

-- Gets date ID in the model
function getDateId(date)
    return math.floor(math.floor((date - 32874) * 86400 + 0.5) / 60);
end

-- Formates the date
function formatDate(date)
    local t = core.dateToTable(core.host:execute("convertTime", 1, 4, date));
    return string.format("%02i-%02i-%04i %02i:%02i:%02i", t.month, t.day, t.year, t.hour, t.min, t.sec);
end

-- Formattes tooltip for the closed position
function formatTooltip(closedTrade, isOpen)
    local side;
    if closedTrade.isBuy then
        side = "Long";
    else
        side = "Short";
    end
    if isOpen then
        --return string.format("Ticket ID: %s\nAmount: %s\n%s\nOpened\t%s at %s\nGross P/L: %s",
        --    closedTrade.ticket_id, closedTrade.volume, side, formatDate(closedTrade.open_date), closedTrade.open_rate,
         --   closedTrade.gross_pl);
		return string.format("%s(Open)\nOpen: %s @ %s\nClose: %s @ %s\nAmount: %s\nGross P/L: %s\nTicket ID: %s",
			side, closedTrade.open_rate, formatDate(closedTrade.open_date), closedTrade.close_rate, formatDate(closedTrade.close_date),
			closedTrade.volume, closedTrade.gross_pl, closedTrade.ticket_id);
    else
         --return string.format("Ticket ID: %s\nAmount: %s\n%s\nClosed\t%s at %s\nGross P/L: %s",
         --   closedTrade.ticket_id, closedTrade.volume, side, 
         --   formatDate(closedTrade.close_date), closedTrade.close_rate, closedTrade.gross_pl);
		return string.format("%s(Close)\nOpen: %s @ %s\nClose: %s @ %s\nAmount: %s\nGross P/L: %s\nTicket ID: %s",
			side, closedTrade.open_rate, formatDate(closedTrade.open_date), closedTrade.close_rate, formatDate(closedTrade.close_date),
			closedTrade.volume, closedTrade.gross_pl, closedTrade.ticket_id);
    end
end

-- Formattes tooltip for the closed position
function formatFullTooltip(closedTrade)
    local side;
    if closedTrade.isBuy then
        side = "Long";
    else
        side = "Short";
    end
    --return string.format("Ticket ID: %s\nAmount: %s\n%s\nOpened\t%s at %s\nClosed\t%s at %s\nGross P/L: %s",
    --    closedTrade.ticket_id, closedTrade.volume, side, formatDate(closedTrade.open_date), closedTrade.open_rate,
    --    formatDate(closedTrade.close_date), closedTrade.close_rate, closedTrade.gross_pl);
	return string.format("%s\nOpen: %s @ %s\nClose: %s @ %s\nAmount: %s\nGross P/L: %s\nTicket ID: %s",
			side, closedTrade.open_rate, formatDate(closedTrade.open_date), closedTrade.close_rate, formatDate(closedTrade.close_date),
			closedTrade.volume, closedTrade.gross_pl, closedTrade.ticket_id);
end

-- Gets color for a label according to P/L
function getColorForPL(pl)
    if pl >= 0 then
        return profitColor;
    else
        return lossColor;
    end
end

-- Gets label char for according to positions coudt
function getLabelChar(positionsCount, isBuy)
    if positionsCount > 1 then
        if isBuy then
            return "\112";
        else
            return "\113";
        end
    else
        if isBuy then
            return "\129";
        else
            return "\130";
        end
    end
end

function Update(period, mode)
    if loading or not(source:hasData(period)) then
        return;
    end
    if not(model.filled) then
        if period == source:size() - 1 and not loading then
            earliestDate = source:date(first);
            loadData(earliestDate, source:date(source:size() - 1));
        end
        return ;
    end
    local firstDate = source:date(first);
    if firstDate < earliestDate then
        if not loading then
            -- request more data
            loadData(firstDate, source:date(source:size() - 1));
            earliestDate = firstDate;
        end
        return ;
    end
    
    if viewMode == "AtBar" then
        local dateId = getDateId(source:date(period));
        local positions = model[dateId];
        if positions ~= nil then
            if positions.buyTotalPL ~= nil then
                local color = getColorForPL(positions.buyTotalPL);
                buyPos:set(period, source.low[period], getLabelChar(positions.buyPosCount, true), positions.buyTooltip, color);
            else
                buyPos:setNoData(period);
            end
            if positions.sellTotalPL ~= nil then
                local color = getColorForPL(positions.sellTotalPL);
                sellPos:set(period, source.high[period], getLabelChar(positions.sellPosCount, false), positions.sellTooltip, color);
            else
                sellPos:setNoData(period);
            end
        end
    end
end

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1 then
        if loading then
            if not(http:loading()) then
                loading = false;
                if http:success() then
                    if http:httpStatus() == 200 then
                        local err = http:responseHeader("X-FXPA_Error");
                        if err ~= nil and err ~= "" then
                            core.host:execute("setStatus", "Execution report error..." .. err);
                            model.error = true;
                        else
                            parseXmlReport(http:response());
                            core.host:execute("setStatus", "");
                            model.filled = true;
                            instance:updateFrom(0);
                        end
                    elseif http:httpStatus() == 302 then
                        local url = http:responseHeader("Location");
                        local cookies;
                        if url ~= nil then
                            local cookie = "";
                            local headers = http:responseHeaders();
                            local i, c;
                            c = headers.count - 1;
                            for i = 0, c, 1 do
                                if headers[i].name == "Set-Cookie" then
                                    local name, value = string.match(headers[i].value, "%s([^=]+)=([^;]+)");
                                    if name ~= nil and value ~= nil then
                                        cookie = cookie .. name .. "=" .. value .. ";";
                                    end
                                end
                            end

                            http = http_lua.createRequest();
                            if cookie ~= "" then
                                http:setRequestHeader("Cookie", cookie);
                            end
                            http:start(url);
                            loading = true;
                        end
                    end
                else
                    model.filled = false;
                    model.error = true;
                    core.host:execute("setStatus", "Loading connecting to the server...");
                end
                return core.ASYNC_REDRAW;
            end
        end
        return 0;
    elseif cookie == 10001 then
        model = {filled = false};
        instance:updateFrom(0);
        return core.ASYNC_REDRAW;
    end
    return 0;
end

function ReleaseInstance()
    core.host:execute("killTimer", timerId);
    core.host:execute("deleteFont", font);
end

-- Utility: Adds closed position makter for the specified date.
function addClosedPositionMarkerAtBar(dateId, closedPosition, symbols, tooltip, isOpen)
    local rowsCollection = model[dateId];
    if rowsCollection == nil then
        rowsCollection = {};
    end
    local gross_pl = tonumber(closedPosition.gross_pl);
    if (closedPosition.isBuy and isOpen) or (not closedPosition.isBuy and not isOpen) then
        if rowsCollection.buyTotalPL == nil then
            rowsCollection.buyTotalPL = gross_pl;
            rowsCollection.buyTooltip = tooltip;
            rowsCollection.buyPosCount = 1;
        else
            rowsCollection.buyTotalPL = rowsCollection.buyTotalPL + gross_pl;
            rowsCollection.buyTooltip = rowsCollection.buyTooltip .. "\n===========\n" .. tooltip;
            rowsCollection.buyPosCount = rowsCollection.buyPosCount + 1;
        end
    else
        if rowsCollection.sellTotalPL == nil then
            rowsCollection.sellTotalPL = gross_pl;
            rowsCollection.sellTooltip = tooltip;
            rowsCollection.sellPosCount = 1;
        else
            rowsCollection.sellTotalPL = rowsCollection.sellTotalPL + gross_pl;
            rowsCollection.sellTooltip = rowsCollection.sellTooltip .. "\n===========\n" .. tooltip;
            rowsCollection.sellPosCount = rowsCollection.sellPosCount + 1;
        end
    end
    model[dateId] = rowsCollection;
end

-- Utility: Adds closed position makter for the specified date and price.
function addClosedPositionMarkerAtPrice(closedPosition, symbols, tooltip, isOpen)
    local symbol;
    local valign;
    if (closedPosition.isBuy and isOpen) or (not closedPosition.isBuy and not isOpen) then
        symbol = symbols.buy;
        valign = core.V_Bottom;
    else
        symbol = symbols.sell;
        valign = core.V_Top;
    end
    local id;
    local date;
    local rate;
    if isOpen then
        id = tonumber(closedPosition.open_order_id);
        date = closedPosition.open_date;
        rate = tonumber(closedPosition.open_rate);
    else
        id = tonumber(closedPosition.close_order_id);
        date = closedPosition.close_date;
        rate = tonumber(closedPosition.close_rate);
    end
    local color;
    local gross_pl = tonumber(closedPosition.gross_pl);
    if gross_pl >= 0 then
        color = profitColor;
    else
        color = lossColor;
    end
    core.host:execute("drawLabel1", id, date, core.CR_CHART, rate, core.CR_CHART, core.H_Center, valign, font, color, symbol)
end

-- Parses report in XML format
function parseXmlReport(data)
    local callbacks = {
        table = -1,             -- current table being parsed
        value = "",             -- current value being parsed
        row = nil,              -- current row data
        
        -- SAX: ignored events
        comment = function(this, data)
        end,
        endCDATA = function(this)
        end,
        endNamespace = function(this, prefix)
        end,
        processingInstruction = function(this, target, data)
        end,
        startCDATA = function(this)
        end,
        startNamespace = function(this, prefix, uri)
        end,

        -- SAX: text content of the node
        characters = function(this, data)
            local table = this.table;
            local value = this.value;
            
            if table == 1 then              -- "closed_trades"
                if value == "ticket_id" then
                    this.row.ticket_id = data;
                elseif value == "open_date" and data ~= nil then
                    this.row.open_date = this.parseDate(data);
                elseif value == "close_date" and data ~= nil then
                    this.row.close_date = this.parseDate(data);
                elseif value == "precision" then
                    this.row.precision = tonumber(data);
                elseif value == "open_rate" then
                    this.row.open_rate = tonumber(data);
                elseif value == "close_rate" then
                    this.row.close_rate = tonumber(data);
                elseif value == "gross_pl" then
                    this.row.gross_pl = tonumber(data);
                elseif value == "symbol" then
                    this.row.symbol = data;
                elseif value == "volume" then
                    this.row.volume = tonumber(data);
                elseif value == "quantity" then
                    if (tonumber(data) >= 0) then
                        -- this.row.BS = "Long";
						this.row.isBuy = true;
                    else
                        -- this.row.BS = "Short";
						this.row.isBuy = false;
                    end
                elseif value == "created_by" then
                    this.row.created_by = data;
                elseif value == "closed_by" then
                    this.row.closed_by = data;
                elseif value == "open_order_id" then
                    this.row.open_order_id = data;
                elseif value == "close_order_id" then
                    this.row.close_order_id = data;
                elseif value == "grouping_type" then
                    this.row.grouping_type = tonumber(data);
                end
            end
        end,

        -- SAX: element is started
        startElement = function(this, name, attributes)
            local itemName = this:extractName(name);
            if itemName == "table" then
                local ntable = this:getAttribute(attributes, "name");
                if ntable == "closed_trades" then
                    this.table = 1;
                elseif ntable == "account_activity" then
                    this.table = 2;
                elseif ntable == "account_summary" then
                    this.table = 3;
                else
                    this.table = -1;
                end
                if this.table ~= -1 then
                    this.value = "";
                    this.row = {};
                end
            elseif itemName == "row" then
                if table ~= -1 then
                    this.row = {};
                    this.value = "";
                end
            elseif itemName == "cell" then
                if table ~= -1 then
                    this.value = this:getAttribute(attributes, "name");
                end
            end
        end,

        -- SAX: element is ended
        endElement = function(this, name)
            name = this:extractName(name);
            if name == "table" then
                this.table = -1;
            elseif name == "row" then
                if this.table == 1 then
                    this:processClosedTrade();
                end
                row = nil;
            end
        end,

        -- Logic: Process the closed trade table row
        processClosedTrade = function (this)
            if this.row.grouping_type == 2 then
                local closedPosition = this.row;
                if closedPosition.symbol ~= instr then
                    return;
                end
                -- add close marker
                if closedPosition.close_date < source:date(first) then
                    return;
                end
                local dateId = nil;
                if viewMode == "AtBar" then
                    local posPeriod = core.findDate(source, closedPosition.close_date, false);
                    dateId = getDateId(source:date(posPeriod));
                    addClosedPositionMarkerAtBar(dateId, closedPosition, closeSymbols, formatTooltip(closedPosition, false), false);
                else
                    addClosedPositionMarkerAtPrice(closedPosition, closeSymbols, formatTooltip(closedPosition, false), false);
                end

                if connectionLines then
                    -- add line
                    local lineColor;
                    if tonumber(closedPosition.gross_pl) > 0 then
                        lineColor = profitColor;
                    else
                        lineColor = lossColor;
                    end
                    core.host:execute("drawLine", tonumber(closedPosition.ticket_id), closedPosition.open_date, tonumber(closedPosition.open_rate), 
                        closedPosition.close_date, tonumber(closedPosition.close_rate), lineColor, core.LINE_SOLID, instance.parameters.width, formatFullTooltip(closedPosition));
                end

                -- add open marker
                if closedPosition.open_date < source:date(first) then
                    return;
                end
                if viewMode == "AtBar" then
                    local openPosPeriod = core.findDate(source, closedPosition.open_date, false);
                    local openDateId = getDateId(source:date(openPosPeriod));
                    addClosedPositionMarkerAtBar(openDateId, closedPosition, openSymbols, formatTooltip(closedPosition, true), true);
                else
                    addClosedPositionMarkerAtPrice(closedPosition, openSymbols, formatTooltip(closedPosition, true), true);
                end
            end
        end,
        
        -- Utility: Extract the node name from namespace|node notation
        extractName = function(this, name)
            local pos = string.find(name, "|");
            if pos == nil then
                return name;
            end
            return string.sub(name, pos + 1, string.len(name));
        end,

        -- Utility: Parse the date/time string and convert it into EST time zone
        parseDate = function (dateString)
            local pos = 1;
            local year, month, day, hour, minute, second = string.match(dateString, "(%d%d%d%d)-(%d%d)-(%d%d) (%d%d):(%d%d):(%d%d)", pos);
            local reportDate = {};
            reportDate.month = tonumber(month);
            reportDate.day = tonumber(day);
            reportDate.year = tonumber(year);
            reportDate.hour = tonumber(hour);
            reportDate.min = tonumber(minute);
            reportDate.sec = tonumber(second);
            return core.host:execute("convertTime", core.TZ_SERVER, core.TZ_EST, core.tableToDate(reportDate));
        end,

        -- Utility: Find attribute and return its value
        getAttribute = function (this, attributes, name)
            local i;
            for i = 0, attributes.count - 1, 1 do
                if this:extractName(attributes[i].name) == name then
                    return attributes[i].value;
                end
            end
            return nil;
        end,
    }
    
    expat_lua.parseSAX(data, callbacks);
end
