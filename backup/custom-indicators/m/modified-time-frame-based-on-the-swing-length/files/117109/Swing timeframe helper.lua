-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65645

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Swing timeframe helper");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

local db;
local Line;

-- Routine
function Prepare()
    source = instance.source;
    first = source:first();
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    
    require("storagedb");
    db = storagedb.get_db(source:instrument());
    
    Line=instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first);
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);

    core.host:execute("addCommand", 1001, "Set swing start", "");
    core.host:execute("addCommand", 1002, "Set swing end", "");
end

function Update(period)
    local date1 = db:get("Date1", 0);
    local level1 = tonumber(db:get("Level1", 0));
    local date2 = db:get("Date2", 0);
    local level2 = tonumber(db:get("Level2", 0));
    core.host:trace(date1);
    core.host:trace(date2);
    core.host:trace(level1);
    core.host:trace(level2);
    if date1 ~= 0 and date2 ~= 0 and level1 ~= 0 and level2 ~= 0 then
        local First = core.findDate(source, date1, false)
        local Second = core.findDate(source, date2, false)
        if First >= first and Second >= first then
            core.drawLine(Line, core.range(First, Second), level1, First, level2, Second); 
        end
    end
end

local pattern = "([^;]*);([^;]*)";

function Parse(message)
    local level, date;
    level, date = string.match(message, pattern, 0);
    
    if level == nil or date == nil then
        return nil, nil;
    end
    
    return tonumber(date), tonumber(level);
end

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1001 then
        local date, level = Parse(message);
        db:put("Date1", tostring(date));
        db:put("Level1", tostring(level));
    elseif cookie == 1002 then
        local date, level = Parse(message);
        db:put("Date2", tostring(date));
        db:put("Level2", tostring(level));
    end
end
