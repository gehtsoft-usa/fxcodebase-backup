-- Id: 
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67127

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
    indicator:name("Traders in Financial Futures - Options and Futures Combined Positions");
    indicator:description("");
    indicator:requiredSource(core.Tick);

    indicator.parameters:addString("filter", "Filter", "", "")
    indicator.parameters:addColor("text_color", "Text color", "", core.rgb(0, 0, 0));
end

local request;
local data;

function Prepare(nameOnly)
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 
    if nameOnly then
        return;
    end

    require("http_lua");
    request = http_lua.createRequest();
    request:start("https://www.cftc.gov/dea/options/financial_lof.htm", "GET");
    core.host:execute("setTimer", 1, 1);
    core.host:execute("setStatus", "Loading");

    instance:ownerDrawn(true);
end

function Update(period, mode) 
    --shoudn't be called
end

local init = false;
local FONT_TEXT = 2;
function Draw(stage, context)
    if stage ~= 2 or data == nil then
        return;
    end
    if not init then
        context:createFont(FONT_TEXT, "Arial", 0, context:pointsToPixels(8), 0)
        init = true;
    end
    local title_w, title_h = context:measureText(FONT_TEXT, data.Title, 0);
    context:drawText(FONT_TEXT, data.Title, instance.parameters.text_color, -1, context:right() - title_w, context:top(), context:right(), context:top() + title_h, 0);
    local y = context:top() + title_h * 1.2;
    for _, item in ipairs(data.Items) do
        if instance.parameters.filter == "" or item.Title:find(instance.parameters.filter) ~= nil then
            local value = string.format("%s Dealer Intermediary Changes Long: %s; Short: %s", item.Title, item.DealerIntermediary.ChangesLong, item.DealerIntermediary.ChangesShort);
            w, h = context:measureText(FONT_TEXT, value, 0);
            context:drawText(FONT_TEXT, value, instance.parameters.text_color, -1, context:right() - w, y, context:right(), y + h, 0);
            y = y + h * 1.2;
        end
    end
end

function Parse(str)
    local items = {};
    for item in string.gmatch(str, "%S+") do
        items[#items + 1] = item;
    end
    return items;
end

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1 and request ~= nil then
        if request:loading() then
            return;
        end
        if request:httpStatus() == 200 then
            local body = request:response();
            local lines = {};
            local firstLineFound = false;
            for line in string.gmatch(body, "[^\r\n]+") do
                if firstLineFound then
                    if string.find(line, "includeHTML") ~= nil then
                        firstLineFound = false;
                    else
                        lines[#lines + 1] = line;
                    end
                else
                    firstLineFound = string.find(line, "financiallof.txt") ~= nil;
                    if firstLineFound then
                        lines[#lines + 1] = string.match(line, "-->(.+)$")
                    end
                end
            end
            data = 
            {
                Title = lines[1]:gsub(" +$", "");
                Items = {};
            };
            local i = 0;
            while (lines[i * 20 + 7] ~= nil) do
                local item = 
                {
                    DealerIntermediary = {};
                    AssetManager = {};
                    LeveragedFunds = {};
                    OtherReportables = {};
                    NonreportablePositions = {};
                    Title = lines[i * 20 + 7]:gsub(" +$", "");
                };
                local positions = Parse(lines[i * 20 + 10]);
                local changes = Parse(lines[i * 20 + 13]);
                local percent = Parse(lines[i * 20 + 16]);
                core.host:trace(lines[i * 20 + 13]);

                item.DealerIntermediary.PositionsLong = positions[1];
                item.DealerIntermediary.PositionsShort = positions[2];
                item.DealerIntermediary.PositionsSpreading = positions[3];
                item.DealerIntermediary.ChangesLong = changes[1];
                item.DealerIntermediary.ChangesShort = changes[2];
                item.DealerIntermediary.ChangesSpreading = changes[3];
                item.DealerIntermediary.PercentLong = percent[1];
                item.DealerIntermediary.PercentShort = percent[2];
                item.DealerIntermediary.PercentSpreading = percent[3];

                item.AssetManager.PositionsLong = positions[4];
                item.AssetManager.PositionsShort = positions[5];
                item.AssetManager.PositionsSpreading = positions[6];
                item.AssetManager.ChangesLong = changes[4];
                item.AssetManager.ChangesShort = changes[5];
                item.AssetManager.ChangesSpreading = changes[6];
                item.AssetManager.PercentLong = percent[4];
                item.AssetManager.PercentShort = percent[5];
                item.AssetManager.PercentSpreading = percent[6];
                
                item.LeveragedFunds.PositionsLong = positions[7];
                item.LeveragedFunds.PositionsShort = positions[8];
                item.LeveragedFunds.PositionsSpreading = positions[9];
                item.LeveragedFunds.ChangesLong = changes[7];
                item.LeveragedFunds.ChangesShort = changes[8];
                item.LeveragedFunds.ChangesSpreading = changes[9];
                item.LeveragedFunds.PercentLong = percent[7];
                item.LeveragedFunds.PercentShort = percent[8];
                item.LeveragedFunds.PercentSpreading = percent[9];

                item.OtherReportables.PositionsLong = positions[10];
                item.OtherReportables.PositionsShort = positions[11];
                item.OtherReportables.PositionsSpreading = positions[12];
                item.OtherReportables.ChangesLong = changes[10];
                item.OtherReportables.ChangesShort = changes[11];
                item.OtherReportables.ChangesSpreading = changes[12];
                item.OtherReportables.PercentLong = percent[10];
                item.OtherReportables.PercentShort = percent[11];
                item.OtherReportables.PercentSpreading = percent[12];

                item.NonreportablePositions.PositionsLong = positions[13];
                item.NonreportablePositions.PositionsShort = positions[14];
                item.NonreportablePositions.ChangesLong = changes[13];
                item.NonreportablePositions.ChangesShort = changes[14];
                item.NonreportablePositions.PercentLong = percent[13];
                item.NonreportablePositions.PercentShort = percent[14];
                data.Items[#data.Items + 1] = item;

                i = i + 1;
            end
            core.host:execute("setStatus", "");
        else
            data = nil;
            core.host:execute("setStatus", "Load failed");
        end
        request = nil;
    end
    return 0;
end

function ReleaseInstance()
    if request ~= nil then
        while request:loading() do
        end
    end
    core.host:execute("killTimer", 1);
end