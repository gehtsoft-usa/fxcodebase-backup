-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66100

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
    indicator:name("Risk Reward Positions Overview")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("Placement")
    indicator.parameters:addBoolean("PositionCapInstrument", "Use Position Instrument", "", true)

    indicator.parameters:addGroup("Placement")
    indicator.parameters:addString("Y", " Y Placement", "", "Top")
    indicator.parameters:addStringAlternative("Y", "Top", "Top", "Top")
    indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom", "Bottom")

    indicator.parameters:addString("X", " X Placement", "", "Left")
    indicator.parameters:addStringAlternative("X", "Right", "Right", "Right")
    indicator.parameters:addStringAlternative("X", "Left", "Left", "Left")
    indicator.parameters:addInteger("ShiftY", "Shift", "", 3)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0))
    indicator.parameters:addInteger("Size", "Font Size", "", 10)
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0))
end

local first
local source = nil
local X, Y
local font
local Label
local Size
local ShiftY
local PositionCapInstrument
local Offer
local ask
local bid

-- Routine
function Prepare(nameOnly)
    Y = instance.parameters.Y
    X = instance.parameters.X
    ShiftY = instance.parameters.ShiftY
    Label = instance.parameters.Label

    Size = instance.parameters.Size
    source = instance.source
    first = source:first()

    PositionCapInstrument = instance.parameters.PositionCapInstrument

    local name = profile:id() .. "(" .. source:name() .. ")"
    instance:name(name)
    if nameOnly then
        return
    end
    Offer = core.host:findTable("offers"):find("Instrument", source:instrument()).OfferID
    instance:ownerDrawn(true)

    if source:isBid() then
        bid = source
        ask = core.host:execute("getAskPrice")
    else
        ask = source
        bid = core.host:execute("getBidPrice")
    end
end

function Update(period)
end

local init = false

function Draw(stage, context)
    if stage ~= 2 then
        return
    end

    if not init then
        context:createFont(1, "Arial", 0, context:pointsToPixels(Size), 0)
        init = true
    end

    local Number1 = 0
    local Number2 = 0
    local Risk = "-"
    local Reward = "-"
    local PointSize
    local Bid, Ask

    enum = core.host:findTable("trades"):enumerator()
    row = enum:next()
    local totalPL = 0;
    local totalGrossPL = 0;
    while (row ~= nil) do
        -- for every trade for this instance.
        if (not PositionCapInstrument or (row.OfferID == Offer and PositionCapInstrument)) then
            if row.Stop == 0 or row.Limit == 0 then
                Risk = "-"
                Reward = "-"
            else
                Risk = "1"
                Reward = math.abs(row.Open - row.Limit) / math.abs(row.Close - row.Stop)
            end

            Number1 = Number1 + 1
            Text = ""
            PointSize = core.host:findTable("offers"):find("Instrument", row.Instrument).PointSize

            local isDigit = tonumber(Reward)
            if isDigit then
                Reward = math.floor(Reward + 0.5)
            end
            local distance;
            Text = row.TradeID .. "  " .. row.Instrument .. "   " .. row.BS .. "   " .. Risk .. ":" ..
                Reward .. "   " .. win32.formatNumber(row.PL, false, 2) .. "   " .. win32.formatNumber(row.GrossPL, false, 2)
            totalPL = totalPL + row.PL;
            totalGrossPL = totalGrossPL + row.GrossPL;

            width, height = context:measureText(1, Text, 0)
            context:drawText(1, Text, Label, -1, iX(context, width, 0, 1), iY(context, height, Number1 + 1, 0),
                iX(context, width, 0, 2), iY(context, height, Number1 + 1, 1), 0)
        end

        row = enum:next()
    end
    local Text = "Total PL: " .. win32.formatNumber(totalPL, false, 2) .. "; Total grossPL: " .. win32.formatNumber(totalGrossPL, false, 2)
    width, height = context:measureText(1, Text, 0)
    Number1 = Number1 + 1;
    context:drawText(1, Text, Label, -1, iX(context, width, 0, 1), iY(context, height, Number1 + 1, 0),
        iX(context, width, 0, 2), iY(context, height, Number1 + 1, 1), 0)

    if Number1 ~= 0 then
        Text = "Active Trader: " .. Number1
        width, height = context:measureText(1, Text, 0)
        context:drawText(1, Text, Label, -1, iX(context, width, 0, 1), iY(context, height, 0, 0), 
            iX(context, width, 0, 2), iY(context, height, 0, 1), 0)
    end

    enum = core.host:findTable("orders"):enumerator()
    row = enum:next()
    while (row ~= nil) do
        if row.Type == "SE" or row.Type == "LE" then
            if (not PositionCapInstrument or (row.OfferID == Offer and PositionCapInstrument)) then
                --Rate
                --Stop
                --Limit;
                --Distance
                --PointSize
                if row.Risk == 0 or row.Limit == 0 then
                    Risk = "-"
                    Reward = "-"
                else
                    Risk = "1"
                    local spread = ask[NOW] - bid[NOW]
                    local limitPips = 0
                    if row.TypeLimit == 3 or row.TypeLimit == 2 then
                        limitPips = math.abs(row.Limit)
                    else
                        limitPips = math.abs(row.Rate - row.Limit)
                    end

                    local stopPips = 0
                    if row.TypeStop == 3 or row.TypeStop == 2 then
                        stopPips = math.abs(row.Stop)
                    else
                        stopPips = (math.abs(row.Rate - row.Stop) - spread)
                    end

                    Reward = limitPips / stopPips
                end

                Number2 = Number2 + 1
                Text = ""
                local isDigit = tonumber(Reward)
                if isDigit then
                    Reward = math.floor(Reward * 10 + 0.5) / 10
                end
                local distance = 0;
                if row.BS == "B" then
                    distance = math.abs(row.Rate - ask:tick(NOW)) / ask:pipSize();
                else
                    distance = math.abs(row.Rate - bid:tick(NOW)) / bid:pipSize();
                end
                Text = row.TradeID .. "  " .. row.Instrument .. "   " .. row.BS .. "   " .. Risk .. ":" 
                    .. Reward .. "   " .. win32.formatNumber(distance, false, 2)

                width, height = context:measureText(1, Text, 0)
                context:drawText(1, Text, Label, -1, iX(context, width, 0, 1), iY(context, height, Number1 + Number2 + 4, 0),
                    iX(context, width, 0, 2), iY(context, height, Number1 + Number2 + 4, 1), 0)
            end
        end
        row = enum:next()
    end

    if Number2 ~= 0 then
        Text = "Entry Orders: " .. Number2
        width, height = context:measureText(1, Text, 0)
        context:drawText(1, Text, Label, -1, iX(context, width, 0, 1), iY(context, height, Number1 + 3, 0),
            iX(context, width, 0, 2), iY(context, height, Number1 + 3, 1), 0)
    end
end

function iX(context, width, Shift, x)
    if X == "Left" then
        return context:left() + Shift * width + width * (x - 1)
    else
        return context:right() - width * Shift - width * (1 - (x - 1))
    end
end

function iY(context, height, Index, Line)
    if Y == "Top" then
        return context:top() + Index * height + ShiftY * height + Line * height
    else
        if Line == 1 then
            return context:bottom() - (Index + 1) * height - ShiftY * height + height
        else
            return context:bottom() - (Index + 1) * height - ShiftY * height
        end
    end
end
