-- Id: 13030
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=61480

--+------------------------------------------------------------------+
--|                                            http://fxcodebase.com |
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
    strategy:name("Delete Duplicate Orders");
    strategy:description("Deletes duplicate orders.");
    strategy:setTag("Version", "2");
    strategy:setTag("group", "Other");
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:type(core.Signal);

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false)
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)
    strategy.parameters:addGroup("Configuration");
    strategy.parameters:addInteger("Frequency", "Frequency", "The number of seconds that define the frequency to check for duplicates.", 10, 1, 14400);
end

local Frequency;
local timerId = -1;

function Prepare(onlyName)
    local name = profile:id();
    instance:name(name);
    if onlyName then
        return;
    end

    Frequency = instance.parameters.Frequency;
    timerId = core.host:execute("setTimer", 999, Frequency);
end

-- when tick source is updated
function Update()

end

function CheckForDuplicate()
    enum = core.host:findTable("orders"):enumerator();
    row = enum:next();
    local PRICES = {};
    while (row ~= nil) do
        if row.Type == "LE" or row.Type == "SE" then 
            -- have we seen this price before.
            if (row.Rate ~= 0 and PRICES[row.Rate * 10000] == nil) then
                PRICES[row.Rate * 10000] = row.OrderID;
            else
                -- found a duplicate.
                DeleteOrder(row.OrderID);
            end
        end

        row = enum:next();
    end
end

function DeleteOrder(id)
    core.host:trace("Duplicate order detected, deleting order: " .. id);
    local valuemap = core.valuemap();
    valuemap.Command = "DeleteOrder";
    valuemap.OrderID = id;
    success, msg = terminal:execute(301, valuemap);
    if not(success) then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Failed to delete order: " .. id .. ": " .. msg, instance.bid:date(NOW));
    end
end

function ReleaseInstance()
    if (timerId ~= -1) then
        core.host:execute("killTimer", timerId);
    end
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == 999 then
        if instance.parameters.AllowTrade then
            CheckForDuplicate();
        end
    end
end
