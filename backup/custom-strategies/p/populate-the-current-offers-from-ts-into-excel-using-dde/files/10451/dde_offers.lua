function Init()
    strategy:name("DDE Offer")
    strategy:description("Publishes Offers via DDE")

    strategy.parameters:addString("SRV", "Service Name", "The service name must be unique amoung all running instances of the strategy", "TS2OFFERS");
end

require("ddeserver_lua");

local dde_server;
local ids = {};
local timeid;

function Prepare(onlyName)
    instance:name(profile:id() .. "(" .. instance.parameters.SRV .. ")");
    if onlyName then
        return ;
    end

    -- start dde server
    dde_server = ddeserver_lua.new(instance.parameters.SRV);
    
    local enum = core.host:findTable("offers"):enumerator();
    local row, topic;
    local offers, offer;
    -- create topics
    offers = "";
    local ofr, val;
    while true do
        row = enum:next();
        if row == nil then
            break ;
        end
        topic = {};
        offer = string.gsub(row.Instrument, "([^A-Za-z0-9])", "_");
        offers = offers .. offer .. ";";

        topic.id = dde_server:addTopic(offer);

        topic.bid = dde_server:addValue(topic.id, "Bid");
        topic.ask = dde_server:addValue(topic.id, "Ask");
        topic.time = dde_server:addValue(topic.id, "Time");

        val = dde_server:addValue(topic.id, "Digits");
        dde_server:set(topic.id, val, row.Digits);
        ids[row.Instrument] = topic;
    end

    ofr = dde_server:addTopic("OFFERS");
    val = dde_server:addValue(ofr, "LIST");
    dde_server:set(ofr, val, offers);

    timerid = core.host:execute("setTimer", 1, 1);

end

function Update()
end

function AsyncOperationFinished(cookie, success, msg)
    if cookie == 1 then
        local enum = core.host:findTable("offers"):enumerator();
        local row, topic;
        -- create topics
        while true do
            row = enum:next();
            if row == nil then
                return ;
            end
            topic = ids[row.Instrument];
            if topic ~= nil then
                dde_server:set(topic.id, topic.bid, row.Bid);
                dde_server:set(topic.id, topic.ask, row.Ask);
                dde_server:set(topic.id, topic.time, row.Time);
            end
        end
    end
end

function ReleaseInstance()
    core.host:execute("killTimer", timerid);
    dde_server:close();
end

