-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76377
--
-- ── Author ─────────────────────────────────────────────────────────────────────
-- Developed by: Mario Jemic
-- Email:        mario.jemic@gmail.com
-- Website:      https://mario-jemic.com
--
-- ── Support & Donations ────────────────────────────────────────────────────────
-- PayPal:        https://goo.gl/9Rj74e
-- Patreon:       https://tiny.cc/1ybwxz
-- BuyMeACoffee:  https://tiny.cc/bj7vxz
--
-- Crypto:
--  BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
--  SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
--  ETH/BNB/USDT/XRP (ERC20 & BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
--
-- ── Copyright ──────────────────────────────────────────────────────────────────
-- © 2025 Gehtsoft USA LLC — https://fxcodebase.com

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- <https://www.gnu.org/licenses/>.
----------------------------------------------------
-- PARAMETERS
----------------------------------------------------
function Init()
    indicator:name("News Scalper (addCommand + OCO)");
    indicator:description("Context-menu trading helper with OCO straddle, HUD, and safe order execution.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Event & Straddle");
    indicator.parameters:addInteger("OffsetPips", "Straddle distance (pips)", "", 10, 0, 5000);
    indicator.parameters:addBoolean("ShowLines", "Show helper lines", "", true);

    indicator.parameters:addGroup("Trading");
    indicator.parameters:addBoolean("AllowTrade", "Allow trading", "", true);
    indicator.parameters:addString("Account", "Account", "", "");
    indicator.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    indicator.parameters:addString("CustomID", "Custom ID (tag)", "", "NEWS-SCALP");
    indicator.parameters:addString("AmtType", "Amount Type", "", "lots");
    indicator.parameters:addStringAlternative("AmtType", "Lots", "", "lots");
    indicator.parameters:addStringAlternative("AmtType", "% Equity (k-units)", "", "k");
    indicator.parameters:addInteger("Amount", "Amount (lots or %)", "", 1, 1, 1000);
    indicator.parameters:addBoolean("UseStop", "Attach Stop", "", false);
    indicator.parameters:addInteger("StopP", "Stop (pips)", "", 15, 1, 10000);
    indicator.parameters:addBoolean("UseLimit", "Attach Limit", "", false);
    indicator.parameters:addInteger("LimitP", "Limit (pips)", "", 15, 1, 10000);
    indicator.parameters:addBoolean("UseTrail", "Trailing Stop", "", false);
    indicator.parameters:addInteger("TrailStep", "Trail step (pips)", "", 1, 1, 1000);

    indicator.parameters:addGroup("HUD/Style");
    indicator.parameters:addColor("LongColor", "Long color", "", core.rgb(0, 200, 0));
    indicator.parameters:addColor("ShortColor", "Short color", "", core.rgb(220, 0, 0));
    indicator.parameters:addColor("MidColor", "Mid color", "", core.rgb(200, 200, 200));
    indicator.parameters:addInteger("LineW", "Line width", "", 2, 1, 5);
    indicator.parameters:addInteger("LineStyle", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("LineStyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addBoolean("HUD", "Show HUD", "", true);
    indicator.parameters:addInteger("HUDAlpha", "HUD alpha (0-100)", "", 30, 0, 100);
    indicator.parameters:addColor("HUDColor", "HUD color", "", core.rgb(40, 40, 40));
    indicator.parameters:addColor("HUDText", "HUD text color", "", core.rgb(255, 255, 255));
    indicator.parameters:addInteger("FontPct", "Font %", "", 80, 50, 150);
end

----------------------------------------------------
-- STATE
----------------------------------------------------
local S = {
    src=nil, sym=nil, pt=0.0001,
    dist=10,
    allow=true, account="", custom="NEWS-SCALP",
    amtType="lots", amount=1,
    useStop=false, stopP=15, useLimit=false, limitP=15, useTrail=false, trailStep=1,
    refPrice=nil, longLevel=nil, shortLevel=nil,
    CMD_OPEN_LONG=1001, CMD_OPEN_SHORT=1002, CMD_ARM_NOW=1003, CMD_CLOSE_ALL=1004, CMD_OCO=1005,
    timer_id=7777,
}

----------------------------------------------------
-- HELPERS
----------------------------------------------------
local function N(v, d) local n=tonumber(v); return (n==nil) and d or n end

local function getOffer(sym)
    local t=core.host:findTable("offers"); if not t then return nil end
    return t:find("Instrument", sym)
end

local function lastPrice(sym, useBid)
    local r=getOffer(sym); if not r then return nil end
    return useBid and r.Bid or r.Ask
end

local function pip2px(p) return N(p,0)*S.pt end

local function ensureRefFromPrice()
    local p=lastPrice(S.sym, true); if not p then return false end
    S.refPrice=p
    S.longLevel=p+pip2px(S.dist)
    S.shortLevel=p-pip2px(S.dist)
    return true
end

----------------------------------------------------
-- TRADING CORE
----------------------------------------------------
 
function CloseTrade(trade)
    local valuemap = core.valuemap();
    valuemap.BuySell = trade.BS == "B" and "S" or "B";
    valuemap.OrderType = "CM";
    valuemap.OfferID = trade.OfferID;
    valuemap.AcctID = trade.AccountID;
    valuemap.TradeID = trade.TradeID;
    valuemap.Quantity = trade.Lot;
    local success, msg = terminal:execute(2, valuemap);
end

function CloseTrades()
    local count = 0;
    local enum = core.host:findTable("trades"):enumerator();
    local row = enum:next();
    while row ~= nil do
        if row.QTXT == S.custom   then
            CloseTrade(row);
            count = count + 1;
        end
        row = enum:next();
    end
    return count;
end


-- Market order (safe, with status)
local function openMarket(sym, side, account, amountType, amount, customId,
                          useStop, stopP, useLimit, limitP, trailing, trailStep)
    base_size = core.host:execute("getTradingProperty", "baseUnitSize", sym, account);
    offer_id = core.host:findTable("offers"):find("Instrument", sym).OfferID;
 

    local vm=core.valuemap()
    vm.OrderType="OM"           -- Market
    vm.AcctID=account; vm.OfferID=offer_id
    vm.BuySell=(side=="BUY") and "B" or "S"	
	
	
     if amountType == "lots" then
        vm.Quantity = amount * base_size;
    else
        local equity = core.host:findTable("accounts"):find("AccountID", vm.account).Equity;
        local used_equity = equity * instance.parameters.Amount / 100.0;
        local emr = core.host:getTradingProperty("EMR", instance.bid:instrument(), vm.account);
        vm.Quantity = math.floor(used_equity / emr) * base_size;
    end
	

    vm.GTC="IOC"; vm.CustomID=customId or "NEWS"
    if useStop then
        vm.PegTypeStop="M"; vm.PegPriceOffsetPipsStop=(vm.BuySell=="B") and -stopP or stopP
        if trailing then vm.TrlMinMove=1; vm.Distance=trailStep end
    end
    if useLimit then
        vm.PegTypeLimit="M"; vm.PegPriceOffsetPipsLimit=(vm.BuySell=="B") and  limitP or -limitP
    end

    local ok,msg=terminal:execute(3, vm)
    if not ok then
        core.host:execute("setStatus","ORDER FAILED: "..tostring(msg))
        return false
    else
        core.host:execute("setStatus","ORDER SENT: "..tostring(msg)) -- RequestID
        return true
    end
end

-- Build Stop Entry (SE) valuemap at fixed rate
local function buildEntrySE(side, rate)
    local off=getOffer(S.sym); if not off then return nil end
    local base=core.host:execute("getTradingProperty","baseUnitSize", S.sym, S.account)
    if not base or base<=0 then base=1 end

    local vm=core.valuemap()
    vm.OrderType="SE"
    vm.AcctID=S.account
    vm.OfferID=off.OfferID
    vm.BuySell=(side=="LONG") and "B" or "S"
    vm.Rate=rate
    vm.GTC="GTC"
    vm.QTXT=S.custom

    local qty
    if S.amtType=="lots" then
        qty=N(S.amount,1)*base
    else
        local acc=core.host:findTable("accounts"):find("AccountID", S.account)
        local equity=acc and acc.Equity or 0
        local emr=core.host:execute("getTradingProperty","EMR", S.sym, S.account) or 0
        local units=(emr>0) and math.floor((equity*N(S.amount,1)/100.0)/emr) or 0
        if units<1 then units=1 end
        qty=units*base
    end
    vm.Quantity=qty

    -- Attach SL/TP relative to entry
    if S.useStop then
        vm.PegTypeStop="M"; vm.PegPriceOffsetPipsStop=(vm.BuySell=="B") and -S.stopP or S.stopP
        if S.useTrail then vm.TrlMinMove=1; vm.Distance=S.trailStep end
    end
    if S.useLimit then
        vm.PegTypeLimit="M"; vm.PegPriceOffsetPipsLimit=(vm.BuySell=="B") and  S.limitP or -S.limitP
    end

    return vm
end

-- OCO creation (CreateOCO + append(entry1, entry2))
local function placeOCO_AtLevels()
    if not S.allow or (S.account=="" or S.account==nil) then
        core.host:execute("setStatus","Trading disabled or no account."); return false
    end
    if (not S.longLevel) or (not S.shortLevel) then
        if not ensureRefFromPrice() then
            core.host:execute("setStatus","No price/ref."); return false
        end
    end

    local eBuy = buildEntrySE("LONG",  S.longLevel)
    local eSell= buildEntrySE("SHORT", S.shortLevel)
    if not eBuy or not eSell then
        core.host:execute("setStatus","Cannot build entries."); return false
    end

    local vm=core.valuemap()
    vm.Command="CreateOCO"
    vm:append(eBuy)
    vm:append(eSell)

    local ok,msg=terminal:execute(5001, vm)
    if not ok then
        core.host:execute("setStatus","OCO FAILED: "..tostring(msg))
        return false
    else
        core.host:execute("setStatus","OCO SENT: "..tostring(msg)) -- possibly list of RequestIDs
        return true
    end
end

----------------------------------------------------
-- PREPARE
----------------------------------------------------
local openS,highS,lowS,closeS
local outL,outS,outM

function Prepare(nameOnly)
    S.src=instance.source
    S.sym=S.src:instrument()
    local off=getOffer(S.sym); assert(off,"Instrument not subscribed: "..tostring(S.sym))
    S.pt=off.PointSize

    S.dist      = N(instance.parameters.OffsetPips,10)
    S.allow     = instance.parameters.AllowTrade and true or false
    S.account   = instance.parameters.Account or ""
    S.custom    = instance.parameters.CustomID or "NEWS-SCALP"
    S.amtType   = instance.parameters.AmtType or "lots"
    S.amount    = N(instance.parameters.Amount,1)
    S.useStop   = instance.parameters.UseStop and true or false
    S.stopP     = N(instance.parameters.StopP,15)
    S.useLimit  = instance.parameters.UseLimit and true or false
    S.limitP    = N(instance.parameters.LimitP,15)
    S.useTrail  = instance.parameters.UseTrail and true or false
    S.trailStep = N(instance.parameters.TrailStep,1)

    instance:name(profile:id().." ("..S.sym..")")
    if nameOnly then return end

    -- streams for CandleGroup (first stream controls color)
    openS = instance:addStream("open", core.Line, "open","open", core.rgb(0,0,0), 0)
    highS = instance:addStream("high", core.Line, "high","high", core.rgb(0,0,0), 0)
    lowS  = instance:addStream("low",  core.Line, "low","low",   core.rgb(0,0,0), 0)
    closeS= instance:addStream("close",core.Line, "close","close",core.rgb(0,0,0), 0)
    instance:createCandleGroup("Candles","Candles", openS, highS, lowS, closeS)
    openS:setVisible(false)

    outL = instance:addStream("L", core.Line, "LongLvl","L", instance.parameters.LongColor, 0)
    outS = instance:addStream("S", core.Line, "ShortLvl","S", instance.parameters.ShortColor, 0)
    outM = instance:addStream("M", core.Line, "Mid","M", instance.parameters.MidColor, 0)
    outL:setVisible(false); outS:setVisible(false); outM:setVisible(false)

    instance:ownerDrawn(true)

    -- context menu commands
    core.host:execute("addCommand", S.CMD_OPEN_LONG,  "Open LONG now",  "Buy market")
    core.host:execute("addCommand", S.CMD_OPEN_SHORT, "Open SHORT now", "Sell market")
    core.host:execute("addCommand", S.CMD_ARM_NOW,    "Arm now (ref ± X pips)", "Create ref from current price")
    core.host:execute("addCommand", S.CMD_OCO,        "Place OCO Straddle",     "BuyStop@ref+X / SellStop@ref-X")
    core.host:execute("addCommand", S.CMD_CLOSE_ALL,  "Close all (CustomID)",   "Close all tagged trades")

    core.host:execute("setTimer", S.timer_id, 1)
end

function ReleaseInstance()
    core.host:execute("killTimer", S.timer_id)
end

----------------------------------------------------
-- UPDATE
----------------------------------------------------
function Update(i, mode)
    if i < S.src:first() then return end
    openS[i]=S.src.open[i]; highS[i]=S.src.high[i]; lowS[i]=S.src.low[i]; closeS[i]=S.src.close[i]

    if S.refPrice then
        outM[i]=S.refPrice; outL[i]=S.longLevel; outS[i]=S.shortLevel
    else
        outM[i]=nil; outL[i]=nil; outS[i]=nil
    end
end

----------------------------------------------------
-- DRAW (HUD + lines)
----------------------------------------------------
local initG=false
local PEN_L, PEN_S, PEN_M = 1,2,3
local BRUSH_HUD=10
local FONT=20

local function ensureG(context)
    if initG then return end
    context:createPen(PEN_L, context.SOLID, N(instance.parameters.LineW,2), instance.parameters.LongColor)
    context:createPen(PEN_S, context.SOLID, N(instance.parameters.LineW,2), instance.parameters.ShortColor)
    context:createPen(PEN_M, N(instance.parameters.LineStyle,core.LINE_SOLID), math.max(1, math.floor(N(instance.parameters.LineW,2)/2)), instance.parameters.MidColor)
    context:createSolidBrush(BRUSH_HUD, instance.parameters.HUDColor)
    local px=math.max(8, math.floor((N(instance.parameters.FontPct,80)/100.0)*12))
    -- IMPORTANT: last arg must be 0 (not boolean)
    context:createFont(FONT, "Arial", px, px, 0)
    initG=true
end

local function drawLineY(context, pen, y)
    local l,r=context:left(),context:right()
    context:drawLine(pen, l, y, r, y)
end

local function pointOfPriceSafe(context, price)
    if not price then return false, 0 end
    local vis, y = context:pointOfPrice(price)
    return vis, y
end

local function drawHUD(context)
    if not instance.parameters.HUD then return end
    local l,t,r,b = context:left(), context:top(), context:right(), context:bottom()
    local w = math.floor((r-l)*0.32)
    local h = math.floor((b-t)*0.16)
    local x1,y1 = l+8, t+8
    local x2,y2 = x1+w, y1+h
    local alpha = math.max(0, math.min(255, math.floor(N(instance.parameters.HUDAlpha,30)/100*255)))
    context:drawRectangle(-1, BRUSH_HUD, x1,y1,x2,y2, alpha)

    local style = context.LEFT + context.TOP
    local y = y1 + 6
    local pad = 18
    local function row(txt)
        context:drawText(FONT, txt, instance.parameters.HUDText, -1, x1+8, y, x2-8, y+pad, style, 0)
        y = y + pad
    end

    row("Symbol: "..tostring(S.sym))
    row("Dist: "..tostring(S.dist).." pips")
    if S.refPrice then
        row(string.format("Ref=%.5f  L=%.5f  S=%.5f", S.refPrice, S.longLevel or 0, S.shortLevel or 0))
    else
        row("Ref: (not armed)")
    end
end

function Draw(stage, context)
    if stage ~= 0 then return end
    ensureG(context)

    if S.refPrice and instance.parameters.ShowLines then
        local vM,yM = pointOfPriceSafe(context, S.refPrice); if vM then drawLineY(context, PEN_M, yM) end
        if S.longLevel  then local vL,yL = pointOfPriceSafe(context, S.longLevel ); if vL then drawLineY(context, PEN_L, yL) end end
        if S.shortLevel then local vS,yS = pointOfPriceSafe(context, S.shortLevel); if vS then drawLineY(context, PEN_S, yS) end end
    end

    drawHUD(context)
end

----------------------------------------------------
-- COMMANDS / TIMER
----------------------------------------------------
function AsyncOperationFinished(cookie, success, message)
    if cookie == S.timer_id then
        -- (reserve for future timed logic)
        return
    end

    if cookie == S.CMD_OPEN_LONG  then
        if not S.allow or S.account=="" then core.host:execute("setStatus","Trading disabled or no account.") return end
        openMarket(S.sym, "BUY", S.account, S.amtType, S.amount, S.custom, S.useStop, S.stopP, S.useLimit, S.limitP, S.useTrail, S.trailStep)
        return
    elseif cookie == S.CMD_OPEN_SHORT then
        if not S.allow or S.account=="" then core.host:execute("setStatus","Trading disabled or no account.") return end
        openMarket(S.sym, "SELL", S.account, S.amtType, S.amount, S.custom, S.useStop, S.stopP, S.useLimit, S.limitP, S.useTrail, S.trailStep)
        return
    elseif cookie == S.CMD_ARM_NOW then
        if ensureRefFromPrice() then
            core.host:execute("setStatus", string.format("ARMED: ref=%.5f  L=%.5f  S=%.5f", S.refPrice, S.longLevel, S.shortLevel))
        else
            core.host:execute("setStatus", "ARM FAIL: no price")
        end
        return
    elseif cookie == S.CMD_OCO then
        if not S.refPrice then ensureRefFromPrice() end
        placeOCO_AtLevels()
        return
    elseif cookie == S.CMD_CLOSE_ALL then
        if S.account=="" then core.host:execute("setStatus","No account") return end
        local n=CloseTrades()
        core.host:execute("setStatus","Closed: "..tostring(n))
        return
    end
end
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76377
--
-- ── Author ─────────────────────────────────────────────────────────────────────
-- Developed by: Mario Jemic
-- Email:        mario.jemic@gmail.com
-- Website:      https://mario-jemic.com
--
-- ── Support & Donations ────────────────────────────────────────────────────────
-- PayPal:        https://goo.gl/9Rj74e
-- Patreon:       https://tiny.cc/1ybwxz
-- BuyMeACoffee:  https://tiny.cc/bj7vxz
--
-- Crypto:
--  BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
--  SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
--  ETH/BNB/USDT/XRP (ERC20 & BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
--
-- ── Copyright ──────────────────────────────────────────────────────────────────
-- © 2025 Gehtsoft USA LLC — https://fxcodebase.com

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- <https://www.gnu.org/licenses/>.