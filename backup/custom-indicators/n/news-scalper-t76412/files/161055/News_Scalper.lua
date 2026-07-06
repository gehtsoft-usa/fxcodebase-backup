-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76412s
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

--[[
News_Scalper_v4.lua
News Scalper (Overlay) – Time + Fractal + Fast + Free, 100% synchronized with chart time.
Added: Central Trade Log (+ HUD feed) for all trade actions: OPEN/CLOSE/DELETE, with detailed messages.
]]--

-----------------------------------------
-- STATE
-----------------------------------------
local S = {
  timer_id=101,
  CMD_OPEN_LONG=201, CMD_OPEN_SHORT=202, CMD_ARM_NOW=203, CMD_CLOSE_ALL=204, CMD_CREATE_OCO = 96001, CMD_CLOSE_ALL_OCO = 96002,

  entryMode="TIME_LEVEL",

  -- event
  eventTZ="CHART",
  eventOleTS=nil,          -- EVENT time in TS (chart timezone)
  eventOle_LOCAL=nil,      -- HUD info
  eventOle_UTC=nil,        -- HUD info
  eventOle_EST=nil,        -- HUD window shading
  armBefore=10,            -- seconds before the event (window start)
  expireMin=30,            -- minutes after the event (window end)

  -- straddle
  distPips=10, autoOpenMarket=true, entrySim=true,
  armed=false, firedSide=nil, refPrice=nil, longLevel=nil, shortLevel=nil,

  -- runtime
  src=nil, sym=nil, useBid=true, pt=0.0001,

  -- trading
  allow=false, account="", custom="NEWS-SCALP",
  amountType="lots", amount=1,
  useStop=false, stopP=15, useLimit=false, limitP=15,
  useTrailStop=false, trailStep=1,

  -- trailing
  trA=nil, trB=nil, trC=nil,
  lastOpenTimeTS=nil, peakPL=nil, beArmed=false,

  -- fast-move detectors
  fm_dir="AUTO",
  fm1_en=true, fm1_win=5, fm1_delta=8,
  fm2_en=false, fm2_win=3, fm2_speed=3.0, fm2_minMove=5,
  fm3_en=false, fm3_atrN=14, fm3_mult=2.0,
  coolSec=10, coolUntilTS=nil,

  -- fractal + fast
  fractWing=2,
  enableBreakFast=true, breakBufferPips=0.0,
  enableReverseFast=true, revProxPips=3.0,
  lastUpFr=nil, lastDnFr=nil, lastUpIndex=nil, lastDnIndex=nil,

  -- visual: last trigger
  lastTriggerBar=nil, lastTriggerTimeTS=nil,

  -- UI / HUD
  corner="TopRight", hx=10, hy=10, fontPx=14,
  colReady=nil, colWait=nil, colWarn=nil,

  -- labels / zone
  showLabels=true, labelOffset=6,
  showZone=true, zoneAlpha=22, zoneColorRGB=nil,

  -- fm buffer
  buf={}, bufMaxSec=10,

  -- logging
  logEnabled=true, logLinesMax=8, hudLog={}
}

-- UI resources
local _ui = { inited=false, fontHUD=0, penEvent=0, penLong=0, penShort=0,
              brushHUD=0, brushLabelBG=0, brushLabelShadow=0, brushZone=0,
              fontBanner=0, penFrUp=0, penFrDn=0, penTrigger=0 }

-----------------------------------------
-- HELPERS: time & TZ
-----------------------------------------
local function oleDiffSeconds(a,b) return (b - a) * 24 * 3600 end
local function oleDiffMinutes(a,b) return (b - a) * 24 * 60 end
local function secToOle(sec) return sec / 86400.0 end

-- Server time -> TZ_TS
local function nowTS()
  local srv = core.host:execute("getServerTime") -- server (EST)
  return core.host:execute("convertTime", core.TZ_EST, core.TZ_TS, srv)
end

-- Format HUD label
local function fmtTZLabel(ole, tz)
  if not ole then return "—" end
  local sec = math.floor(ole * 86400 - 25569*86400)
  if tz == "UTC" then return os.date("!%Y-%m-%d %H:%M", sec)
  else                return os.date(  "%Y-%m-%d %H:%M", sec) end
end

-----------------------------------------
-- HELPERS: platform
-----------------------------------------
local function colorByName(name)
  local n=(name or "WHITE"):upper()
  if n=="GREEN" then return core.rgb(0,200,0)
  elseif n=="LIME" then return core.rgb(120,220,0)
  elseif n=="RED" then return core.rgb(220,0,0)
  elseif n=="ORANGE" then return core.rgb(220,120,0)
  elseif n=="YELLOW" then return core.rgb(220,220,0)
  elseif n=="BLUE" then return core.rgb(0,120,220)
  elseif n=="CYAN" then return core.rgb(0,200,200)
  elseif n=="MAGENTA" then return core.rgb(200,0,200)
  elseif n=="GRAY" or n=="GREY" then return core.rgb(160,160,160)
  else return core.rgb(230,230,230) end
end

local function getPointSize(sym)
  local offers=core.host:findTable("offers"); if not offers then return 0.0001 end
  local r=offers:find("Instrument", sym)
  return (r and r.PointSize) or 0.0001
end

local function lastPrice(sym,useBid)
  local offers=core.host:findTable("offers"); if not offers then return nil end
  local r=offers:find("Instrument", sym); if not r then return nil end
  return useBid and r.Bid or r.Ask
end

-----------------------------------------
-- LOGGING
-----------------------------------------
local function pushHudLog(line)
  if not S.logEnabled then return end
  table.insert(S.hudLog, 1, line)
  while #S.hudLog > (S.logLinesMax or 8) do table.remove(S.hudLog) end
end

-- SAFE LOG (no instance.bid)
local function log(fmt, ...)
  if not S.logEnabled then return end
  local msg = (select("#", ...) > 0) and string.format(fmt, ...) or tostring(fmt)
  pushHudLog(msg)

  local sym = S.sym or (S.src and S.src:instrument()) or "SYMBOL"
  local px  = lastPrice(sym, S.useBid)
              or (S.src and S.src.close and S.src:hasData(S.src:size()-1) and S.src.close[S.src:size()-1])
              or 0

  terminal:alertMessage(sym, px, "[TRADE LOG] " .. msg, core.now())
end

-----------------------------------------
-- TRADING TABLE HELPERS

-- ==== TRADE HELPERS (Minimal, SDK-compatible; ported from "News Scalper") ====

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

function openMarket(sym, side, account, amountType, amount, customId,
                    useStop, stopP, useLimit, limitP, trailing, trailStep)
    local offers = core.host:findTable("offers"); if not offers then return false end
    local row = offers:find("Instrument", sym);  if not row then return false end
    local base_size = core.host:execute("getTradingProperty", "baseUnitSize", sym, account)
    local vm = core.valuemap()
    vm.OrderType = "OM"
    vm.AcctID    = account
    vm.OfferID   = row.OfferID
    vm.BuySell   = (side == "BUY") and "B" or "S"
    vm.GTC       = "IOC"
    vm.CustomID  = customId or (S and S.custom) or "NEWS"
    
    if amountType == "lots" then
        vm.Quantity = (amount or 1) * base_size
    else
        local acc = core.host:findTable("accounts"):find("AccountID", account)
        local equity = acc and acc.Equity or 0
        local emr = core.host:execute("getTradingProperty", "EMR", sym, account)
        local units = 0
        if emr and emr > 0 then
            units = math.max(1, math.floor((equity * (amount or 0) / 100.0) / emr))
        else
            units = 1
        end
        vm.Quantity = units * base_size
    end

    if useStop then
        vm.PegTypeStop = "M"
        vm.PegPriceOffsetPipsStop = (vm.BuySell=="B") and -stopP or stopP
        if trailing then vm.TrlMinMove = 1; vm.Distance = trailStep or 1 end
    end
    if useLimit then
        vm.PegTypeLimit = "M"
        vm.PegPriceOffsetPipsLimit = (vm.BuySell=="B") and  limitP or -limitP
    end

    local ok, msg = terminal:execute(3, vm)
    return ok and true or false
end
-- ==== END TRADE HELPERS ====

-- TRADING TABLE HELPERS
-----------------------------------------
local function countOurTrades(account, customId)
  local t=core.host:findTable("trades"); if not t then return 0 end
  local e=t:enumerator(); local row=e:next(); local n=0
  while row do
    local q=row.QTXT or row.Comment or ""
    if row.AccountID==account and q and string.find(q, customId or "", 1, true) then n=n+1 end
    row=e:next()
  end
  return n
end

local function closeAllOurTrades(account, customId)
  local t=core.host:findTable("trades"); if not t then log("closeAll: trades table not found"); return 0 end
  local e=t:enumerator(); local row=e:next(); local n=0
  while row do
    local q=row.QTXT or row.Comment or ""
    if row.AccountID==account and q and string.find(q, customId or "", 1, true) then
      local vm=core.valuemap()
      vm.Command="CreateOrder"
      vm.OrderType="C"
      vm.AcctID=row.AccountID
      vm.OfferID=row.OfferID
      vm.TradeID=row.TradeID
      vm.Amount=row.Lot or row.Amount or row.Quantity
      vm.GTC="IOC"
      local ok,err = pcall(function() terminal:execute(2, vm) end)
      if ok then
        n=n+1
        log("CLOSE %s [TradeID=%s] Amount=%.2f", row.Instrument or S.sym, tostring(row.TradeID), vm.Amount or 0)
      else
        log("ERROR CLOSE [TradeID=%s]: %s", tostring(row.TradeID), tostring(err))
      end
    end
    row=e:next()
  end
  log("closeAll finished: %d trades", n)
  return n
end

-----------------------------------------
-- PARAMS
-----------------------------------------
function Init()
  indicator:name("News Scalper")
  indicator:description("A/B/C/D/E modes. Event time aligned with candles (CHART input) + Trade Log (terminal & HUD).")
  indicator:requiredSource(core.Bar)
  indicator:type(core.Indicator)

  indicator.parameters:addGroup("Entry Mode")
  indicator.parameters:addString("EntryMode","Entry mode","", "TIME_LEVEL")
  indicator.parameters:addStringAlternative("EntryMode","A) Time + Level","", "TIME_LEVEL")
  indicator.parameters:addStringAlternative("EntryMode","B) Time + Fast Move","", "TIME_FASTMOVE")
  indicator.parameters:addStringAlternative("EntryMode","C) Fast Move (no time)","", "FASTMOVE_ONLY")
  indicator.parameters:addStringAlternative("EntryMode","D) Time + Fractal + Fast","", "TIME_FRACTALFAST")
  indicator.parameters:addStringAlternative("EntryMode","E) Fractal + Fast (no time)","", "FRACTALFAST_ONLY")

  indicator.parameters:addGroup("Event (parts only)")
  indicator.parameters:addInteger("EventTZ","Event time zone (input)","", 4)
  indicator.parameters:addIntegerAlternative("EventTZ","EST","", 1) 
  indicator.parameters:addIntegerAlternative("EventTZ","UTC","", 2)  
  indicator.parameters:addIntegerAlternative("EventTZ","The user's local time zone","", 3)
  indicator.parameters:addIntegerAlternative("EventTZ","The display time zone","", 4)
  indicator.parameters:addIntegerAlternative("EventTZ","Server time","", 5) 
  indicator.parameters:addIntegerAlternative("EventTZ","Financial time","", 6)

  indicator.parameters:addInteger("EventYear","Year","",2025,2000,2100)
  indicator.parameters:addInteger("EventMonth","Month","",10,1,12)
  indicator.parameters:addInteger("EventDay","Day","",18,1,31)
  indicator.parameters:addInteger("EventHour","Hour","",14,0,23)
  indicator.parameters:addInteger("EventMinute","Minute","",30,0,59)
  indicator.parameters:addInteger("ArmBeforeSec","ARM before event (s)","",10,0,600)
  indicator.parameters:addInteger("ExpireMinutes","Expire after event (min)","",30,1,1440)

  indicator.parameters:addGroup("A) Time + Level")
  indicator.parameters:addDouble("DistancePips","Distance of entry level (pips)","",10,0.1,1000)
  indicator.parameters:addBoolean("AutoOpenMarket","Automatically open Market order on breakout","",true)
  indicator.parameters:addBoolean("EntrySim","Wait for level touch (EntrySim)","",true)

  indicator.parameters:addGroup("B/C/D/E) Fast Move")
  indicator.parameters:addString("FastDir","Fast-move entry direction","", "AUTO")
  indicator.parameters:addStringAlternative("FastDir","AUTO (by direction)","", "AUTO")
  indicator.parameters:addStringAlternative("FastDir","LONG","", "LONG")
  indicator.parameters:addStringAlternative("FastDir","SHORT","", "SHORT")
  indicator.parameters:addStringAlternative("FastDir","BOTH","", "BOTH")
  indicator.parameters:addInteger("CooldownSec","Cooldown after trigger (s)","",10,0,600)

  indicator.parameters:addGroup("FM1")
  indicator.parameters:addBoolean("FM1_Enable","Enable FM1 (ΔP in window)","",true)
  indicator.parameters:addInteger("FM1_WindowSec","Window (seconds)","",5,1,30)
  indicator.parameters:addDouble("FM1_DeltaPips","Minimum |ΔP| (pips)","",8,0.5,1000)

  indicator.parameters:addGroup("FM2")
  indicator.parameters:addBoolean("FM2_Enable","Enable FM2 (speed)","",false)
  indicator.parameters:addInteger("FM2_WindowSec","Window (seconds)","",3,1,30)
  indicator.parameters:addDouble("FM2_SpeedPipsPerSec","Minimum speed (pips/s)","",3.0,0.1,100)
  indicator.parameters:addDouble("FM2_MinMovePips","Minimum ΔP (pips)","",5,0.5,1000)

  indicator.parameters:addGroup("FM3")
  indicator.parameters:addBoolean("FM3_Enable","Enable FM3 (range vs ATR)","",false)
  indicator.parameters:addInteger("FM3_ATR_Period","ATR period (bars)","",14,2,200)
  indicator.parameters:addDouble("FM3_Multiplier","Range ≥ K*ATR","",2.0,0.5,10.0)

  indicator.parameters:addGroup("Fractal + Fast")
  indicator.parameters:addBoolean("EnableBreakFast","BREAK + FAST (trend)","",true)
  indicator.parameters:addDouble("BreakBufferPips","Buffer beyond fractal (pips)","",0.0,0,50)
  indicator.parameters:addBoolean("EnableReverseFast","REVERSE + FAST (mean-revert)","",true)
  indicator.parameters:addDouble("RevProximityPips","Proximity to fractal for reverse (pips)","",3.0,0,100)
  indicator.parameters:addInteger("FractalWing","Fractal wing (2=Bill Williams)","",2,2,3)

  indicator.parameters:addGroup("Trading (TEST)")
  indicator.parameters:addBoolean("AllowTrade","Allow trading (DEMO/test)","",true)
  indicator.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)
  indicator.parameters:addString("Account","Account","", "")
  indicator.parameters:setFlag("Account", core.FLAG_ACCOUNT)
  indicator.parameters:addString("CustomID","Custom ID (QTXT/Comment)","", "NEWS-SCALP")
  indicator.parameters:addString("AmountType","Amount type","", "lots")
  indicator.parameters:addStringAlternative("AmountType","Lots","", "lots")
  indicator.parameters:addStringAlternative("AmountType","% of equity","", "%")
  indicator.parameters:addDouble("Amount","Amount (lots or %)","", 1, 0.01, 100)
  indicator.parameters:addBoolean("UseStop","Add stop","",false)
  indicator.parameters:addDouble("StopPips","Stop (pips)","",15,0.1,10000)
  indicator.parameters:addBoolean("UseLimit","Add limit","",false)
  indicator.parameters:addDouble("LimitPips","Limit (pips)","",15,0.1,10000)
  indicator.parameters:addBoolean("UseTrailingStop","Trailing stop (native)","",false)
  indicator.parameters:addInteger("TrailStep","Trail step","",1,1,1000)

  indicator.parameters:addGroup("Labels & Zone")
  indicator.parameters:addBoolean("ShowLabels","Show labels by levels","",true)
  indicator.parameters:addInteger("LabelOffset","Label offset above line (px)","",6,0,50)
  indicator.parameters:addBoolean("ShowZoneShade","Shade the zone between levels","",true)
  indicator.parameters:addString("ZoneShadeColor","Zone shadow color","", "YELLOW")
  indicator.parameters:addInteger("ZoneShadeAlpha","Zone opacity (0..100)","",22,0,100)

  indicator.parameters:addGroup("UI")
  indicator.parameters:addString("Corner","HUD corner","", "TopRight")
  indicator.parameters:addStringAlternative("Corner","Top-left","", "TopLeft")
  indicator.parameters:addStringAlternative("Corner","Top-right","", "TopRight")
  indicator.parameters:addStringAlternative("Corner","Bottom-left","", "BottomLeft")
  indicator.parameters:addStringAlternative("Corner","Bottom-right","", "BottomRight")
  indicator.parameters:addInteger("HUDX","HUD X margin","",10,0,200)
  indicator.parameters:addInteger("HUDY","HUD Y margin","",10,0,200)
  indicator.parameters:addInteger("FontPx","Font px","",14,8,48)
  indicator.parameters:addString("ColorReady","Ready color","", "Green")
  indicator.parameters:addString("ColorWait","Wait color","", "Orange")
  indicator.parameters:addString("ColorWarn","Warn color","", "Red")

  -- Debug / Trade Log
  indicator.parameters:addGroup("Debug / Logs")
  indicator.parameters:addBoolean("EnableTradeLog","Enable Trade Log (terminal & HUD)","", true)
  indicator.parameters:addInteger("HUD_LogLines","HUD: number of log lines","", 8, 0, 20)
end

-----------------------------------------
-- PREPARE
-----------------------------------------
function Prepare(nameOnly)
  S.src=instance.source
  S.sym=S.src:instrument()
  S.useBid=S.src:isBid()
  S.pt=getPointSize(S.sym)
  S.entryMode=instance.parameters.EntryMode

  -- EVENT from parts -> TS (chart)
  S.eventTZ  = instance.parameters.EventTZ
  local y = instance.parameters.EventYear
  local m = instance.parameters.EventMonth
  local d = instance.parameters.EventDay
  local hh= instance.parameters.EventHour
  local mi= instance.parameters.EventMinute
  local tdate= {year = y, month = m, day = d, hour = hh, min = mi, sec = 0}
  S.eventOleTS = core.tableToDate(tdate)

  -- HUD info conversions (TS -> Local/UTC/EST)
  S.eventOle_LOCAL = core.host:execute("convertTime", core.TZ_TS, core.TZ_LOCAL, S.eventOleTS)
  S.eventOle_UTC   = core.host:execute("convertTime", core.TZ_TS, core.TZ_UTC,   S.eventOleTS)
  S.eventOle_EST   = core.host:execute("convertTime", core.TZ_TS, core.TZ_EST,   S.eventOleTS)

  S.armBefore=instance.parameters.ArmBeforeSec
  S.expireMin=instance.parameters.ExpireMinutes

  S.distPips=instance.parameters.DistancePips
  S.autoOpenMarket=instance.parameters.AutoOpenMarket
  S.entrySim=instance.parameters.EntrySim

  S.fm_dir=instance.parameters.FastDir
  S.coolSec=instance.parameters.CooldownSec
  S.fm1_en=instance.parameters.FM1_Enable; S.fm1_win=instance.parameters.FM1_WindowSec; S.fm1_delta=instance.parameters.FM1_DeltaPips
  S.fm2_en=instance.parameters.FM2_Enable; S.fm2_win=instance.parameters.FM2_WindowSec; S.fm2_speed=instance.parameters.FM2_SpeedPipsPerSec; S.fm2_minMove=instance.parameters.FM2_MinMovePips
  S.fm3_en=instance.parameters.FM3_Enable; S.fm3_atrN=instance.parameters.FM3_ATR_Period; S.fm3_mult=instance.parameters.FM3_Multiplier

  S.enableBreakFast=instance.parameters.EnableBreakFast
  S.enableReverseFast=instance.parameters.EnableReverseFast
  S.breakBufferPips=instance.parameters.BreakBufferPips
  S.revProxPips=instance.parameters.RevProximityPips
  S.fractWing=instance.parameters.FractalWing

  S.allow=instance.parameters.AllowTrade
  S.account=instance.parameters.Account
  S.custom=instance.parameters.CustomID
  S.amountType=instance.parameters.AmountType
  S.amount=instance.parameters.Amount
  S.useStop=instance.parameters.UseStop
  S.stopP=instance.parameters.StopPips
  S.useLimit=instance.parameters.UseLimit
  S.limitP=instance.parameters.LimitPips
  S.useTrailStop=instance.parameters.UseTrailingStop
  S.trailStep=instance.parameters.TrailStep

  S.trA={ en=instance.parameters.TrailA_Enable, min=instance.parameters.TrailA_MinProfit, step=instance.parameters.TrailA_RetraceStep }
  S.trB={ en=instance.parameters.TrailB_Enable, beAct=instance.parameters.TrailB_BEActivate, bePlus=instance.parameters.TrailB_BEPlus, step=instance.parameters.TrailB_RetraceStep }
  S.trC={ en=instance.parameters.TrailC_Enable, hold=instance.parameters.TrailC_HoldSeconds, snap=instance.parameters.TrailC_SnapTPPips }

  S.corner=instance.parameters.Corner; S.hx=instance.parameters.HUDX; S.hy=instance.parameters.HUDY
  S.fontPx=instance.parameters.FontPx
  S.colReady=colorByName(instance.parameters.ColorReady)
  S.colWait=colorByName(instance.parameters.ColorWait)
  S.colWarn=colorByName(instance.parameters.ColorWarn)

  S.showLabels=instance.parameters.ShowLabels
  S.labelOffset=instance.parameters.LabelOffset
  S.showZone=instance.parameters.ShowZoneShade
  S.zoneAlpha=instance.parameters.ZoneShadeAlpha
  S.zoneColorRGB=colorByName(instance.parameters.ZoneShadeColor)

  S.logEnabled = instance.parameters.EnableTradeLog
  S.logLinesMax = instance.parameters.HUD_LogLines
  S.hudLog = {}

  instance:name("News Scalper v4 ["..S.sym.."]")
  if nameOnly then return end

  instance:ownerDrawn(true)
  core.host:execute("addCommand", S.CMD_OPEN_LONG,  "Open LONG now",  "Buy market")
  core.host:execute("addCommand", S.CMD_OPEN_SHORT, "Open SHORT now", "Sell market")
  core.host:execute("addCommand", S.CMD_ARM_NOW,    "Arm now",        "Arm straddle / fast-move")
  core.host:execute("addCommand", S.CMD_CLOSE_ALL,  "Close all",      "Close all (CustomID)")
 -- === Add Commands (UI) ===
    core.host:execute("addCommand", S.CMD_CREATE_OCO, "Create OCO orders", "Place two linked OCO entry orders");
    core.host:execute("addCommand", S.CMD_CLOSE_ALL_OCO, "Close all OCO", "Cancel/close all active OCO group orders");
  
  core.host:execute("setTimer", S.timer_id, 1)

  S.armed=false; S.firedSide=nil; S.refPrice=nil; S.longLevel=nil; S.shortLevel=nil
  S.lastOpenTimeTS=nil; S.peakPL=nil; S.beArmed=false; S.coolUntilTS=nil
  S.buf={}
  S.lastUpFr=nil; S.lastDnFr=nil; S.lastUpIndex=nil; S.lastDnIndex=nil
  S.lastTriggerBar=nil; S.lastTriggerTimeTS=nil

  _ui.inited=false
  pushHudLog("News Scalper initialized")
end

function ReleaseInstance() core.host:execute("killTimer", S.timer_id) end

-----------------------------------------
-- STRADDLE (A)
-----------------------------------------
local function armLevelsNow()
  local ref=lastPrice(S.sym, S.useBid); if not ref then return false end
  S.refPrice=ref
  S.longLevel=ref + S.distPips * S.pt
  S.shortLevel=ref - S.distPips * S.pt
  S.armed=true; S.firedSide=nil
  core.host:execute("setStatus",
    string.format("ARMED: ref=%.5f  L=%.5f  S=%.5f", ref, S.longLevel, S.shortLevel))
  log("ARMED straddle: ref=%.5f L=%.5f S=%.5f", ref, S.longLevel, S.shortLevel)
  return true
end

local function armIfTime_LEVEL()
  if S.entryMode~="TIME_LEVEL" then return end
  if S.armed or not S.eventOleTS then return end
  local now = nowTS()
  local secToEvent = (S.eventOleTS - now) * 86400
  if secToEvent <= S.armBefore then
    armLevelsNow()
  end
end

local function priceCrossedLevels()
  if not S.armed or S.firedSide~=nil then return end
  local p=lastPrice(S.sym, S.useBid); if not p then return end
  if S.entrySim then
    if p >= (S.longLevel or math.huge) then S.firedSide="LONG"
    elseif p <= (S.shortLevel or -math.huge) then S.firedSide="SHORT" end
  else
    if S.autoOpenMarket then
      local up=S.refPrice + S.distPips * S.pt * 0.8
      local dn=S.refPrice - S.distPips * S.pt * 0.8
      if p>=up then S.firedSide="LONG" elseif p<=dn then S.firedSide="SHORT" end
    end
  end
end

-----------------------------------------
-- FAST-MOVE (FM1/2/3)
-----------------------------------------
local function bufPush(now,p)
  table.insert(S.buf, {t=now,p=p})
  local minOle=now - (S.bufMaxSec/86400.0)
  local i=1
  while i<=#S.buf do
    if S.buf[i].t < minOle then table.remove(S.buf, i) else i=i+1 end
  end
end

local function fm_dir_allowed(sign)
  if S.fm_dir=="AUTO" or S.fm_dir=="BOTH" then return true end
  if S.fm_dir=="LONG" then return sign>0 end
  if S.fm_dir=="SHORT" then return sign<0 end
  return true
end

local function detectFM1(now)
  if not S.fm1_en or #S.buf<2 then return nil end
  local winOle=now - (S.fm1_win/86400.0)
  local pNow=S.buf[#S.buf].p
  local pMin,pMax=pNow,pNow
  for i=1,#S.buf do
    local it=S.buf[i]
    if it.t>=winOle then
      if it.p<pMin then pMin=it.p end
      if it.p>pMax then pMax=it.p end
    end
  end
  local need=S.fm1_delta * S.pt
  if (pNow - pMin) >= need and fm_dir_allowed(1) then return "LONG","FM1" end
  if (pMax - pNow) >= need and fm_dir_allowed(-1) then return "SHORT","FM1" end
  return nil
end

local function detectFM2(now)
  if not S.fm2_en or #S.buf<2 then return nil end
  local winOle=now - (S.fm2_win/86400.0)
  local pNow=S.buf[#S.buf].p
  local oldest=nil
  for i=1,#S.buf do if S.buf[i].t>=winOle then oldest=S.buf[i]; break end end
  if not oldest then oldest=S.buf[1] end
  local dt=math.max(0.001, oleDiffSeconds(oldest.t, now))
  local dp=pNow - oldest.p
  local speed=math.abs(dp)/S.pt / dt
  if speed >= (S.fm2_speed or 3.0) and math.abs(dp) >= (S.fm2_minMove or 5)*S.pt then
    local sign=(dp>=0) and 1 or -1
    if fm_dir_allowed(sign) then return (sign>0) and "LONG" or "SHORT", "FM2" end
  end
  return nil
end

local function calcATR(n)
  n=math.floor(n or 14); if n<2 then n=2 end
  local count=S.src:size()
  if count < n+1 then return nil end
  local trSum=0
  for i=count-n+1, count do
    local h=S.src.high[i]; local l=S.src.low[i]; local c1=S.src.close[i-1]
    if h and l and c1 then
      local tr=math.max(h-l, math.abs(h-c1), math.abs(l-c1))
      trSum=trSum+tr
    end
  end
  return trSum/n
end

local function detectFM3()
  if not S.fm3_en then return nil end
  local count=S.src:size(); if count<2 then return nil end
  local i=count
  if not (S.src:hasData(i) and S.src:hasData(i-1)) then return nil end
  local h=S.src.high[i]; local l=S.src.low[i]; local o=S.src.open[i]; local c=S.src.close[i]
  local atr=calcATR(S.fm3_atrN); if not atr then return nil end
  local range=h-l
  if range >= (S.fm3_mult or 2.0) * atr then
    local sign=(c-o>=0) and 1 or -1
    if fm_dir_allowed(sign) then return (sign>0) and "LONG" or "SHORT", "FM3" end
  end
  return nil
end

local function detectFastMove(now)
  local s,t=detectFM1(now); if s then return s,t end
  s,t=detectFM2(now); if s then return s,t end
  s,t=detectFM3(); if s then return s,t end
  return nil
end

-----------------------------------------
-- FRACTALS
-----------------------------------------
local function isUpFractal(i, wing)
  if i-wing < 1 or i+wing > S.src:size() then return false end
  local hi=S.src.high[i]
  for k=1,wing do
    if not (hi and S.src.high[i-k] and S.src.high[i+k]) then return false end
    if hi <= S.src.high[i-k] then return false end
    if hi <= S.src.high[i+k] then return false end
  end
  return true
end

local function isDnFractal(i, wing)
  if i-wing < 1 or i+wing > S.src:size() then return false end
  local lo=S.src.low[i]
  for k=1,wing do
    if not (lo and S.src.low[i-k] and S.src.low[i+k]) then return false end
    if lo >= S.src.low[i-k] then return false end
    if lo >= S.src.low[i+k] then return false end
  end
  return true
end

local function updateLastFractals()
  local wing = S.fractWing or 2
  local n = S.src:size()
  if n < 2*wing+2 then return end
  local lastCheck = n - wing - 1
  for i = lastCheck, wing+1, -1 do
    if (not S.lastUpIndex) and isUpFractal(i, wing) then
      S.lastUpIndex = i; S.lastUpFr = S.src.high[i]
    end
    if (not S.lastDnIndex) and isDnFractal(i, wing) then
      S.lastDnIndex = i; S.lastDnFr = S.src.low[i]
    end
    if S.lastUpIndex and S.lastDnIndex then break end
  end
end

-----------------------------------------
-- TRAIL / TRADE
-----------------------------------------
local function doOpen(side)
  if not S.allow or not side then return end
  local ok=openMarket(
    S.sym, (side=="LONG") and "BUY" or "SELL",
    S.account, S.amountType, S.amount, S.custom,
    S.useStop, S.stopP, S.useLimit, S.limitP, S.useTrailStop, S.trailStep
  )
  if ok then
    local now = nowTS()
    S.lastOpenTimeTS=now
    S.lastTriggerTimeTS=now
    local idx=core.findDate(S.src, now, false)
    S.lastTriggerBar = (idx>=0 and idx) or nil
    core.host:execute("setStatus", "Opened "..side.." (News Scalper)")
  end
end

local function plSumPipsForCustom()
  local t=core.host:findTable("trades"); if not t then return 0,0 end
  local e=t:enumerator(); local row=e:next(); local sum,cnt=0,0
  while row do
    local q=row.QTXT or row.Comment or ""
    if row.AccountID==S.account and q and string.find(q,S.custom or "",1,true) then
      local pips=row.Pips or row.PL_pips
      if pips then sum=sum+pips; cnt=cnt+1 end
    end
    row=e:next()
  end
  return sum,cnt
end

local function trailingEngine()
  local sum,cnt=plSumPipsForCustom()
  if cnt==0 then S.peakPL=nil; S.beArmed=false; return end
  if (S.peakPL==nil) or (sum>S.peakPL) then S.peakPL=sum end
  local now = nowTS()

  if S.trC and S.trC.en and S.lastOpenTimeTS and oleDiffSeconds(S.lastOpenTimeTS, now) >= (S.trC.hold or 0) then
    if sum >= (S.trC.snap or math.huge) then
      local n=closeAllOurTrades(S.account, S.custom)
      if n>0 then core.host:execute("setStatus", string.format("SNAP TP: +%.1f pips (closed %d)", sum, n)) end
      return
    end
  end
  if S.trB and S.trB.en then
    if (not S.beArmed) and sum >= (S.trB.beAct or math.huge) then
      S.beArmed=true
      if (S.peakPL or 0) < (S.trB.bePlus or 0) then S.peakPL=S.trB.bePlus end
    end
    if S.beArmed then
      local retr=(S.peakPL or 0) - sum
      if retr >= (S.trB.step or 1) and sum <= (S.trB.bePlus or 0) then
        local n=closeAllOurTrades(S.account, S.custom)
        if n>0 then core.host:execute("setStatus", string.format("BE+TRAIL exit: sum=%.1f, peak=%.1f (closed %d)", sum, S.peakPL or 0, n)) end
        return
      end
    end
  end
  if S.trA and S.trA.en and (S.peakPL or 0) >= (S.trA.min or 0) then
    local retr=(S.peakPL or 0) - sum
    if retr >= (S.trA.step or 1) then
      local n=closeAllOurTrades(S.account, S.custom)
      if n>0 then core.host:execute("setStatus", string.format("TRAIL A exit: sum=%.1f, peak=%.1f (closed %d)", sum, S.peakPL or 0, n)) end
      return
    end
  end
end

-----------------------------------------
-- UPDATE / TIMER / CMDS
-----------------------------------------
function Update(period, mode) end

function AsyncOperationFinished(cookie)
  if cookie ~= S.timer_id then
    if cookie == S.CMD_OPEN_LONG  then doOpen("LONG")
    elseif cookie == S.CMD_OPEN_SHORT then doOpen("SHORT")
    elseif cookie == S.CMD_ARM_NOW then
      if S.entryMode=="TIME_LEVEL" then armLevelsNow()
      else S.armed=true; S.firedSide=nil; core.host:execute("setStatus","ARM FAST-MOVE"); log("ARM FAST-MOVE") end
    elseif cookie == S.CMD_CLOSE_ALL then
      local n=closeAllOurTrades(S.account, S.custom)
      CloseTrades()
      core.host:execute("setStatus","Close All: "..n)
	  -- === Handle OCO Commands ===
	elseif cookie == S.CMD_CREATE_OCO then
        local ok, err = CreateOCOOrders()
        if not ok then
            core.host:execute("setStatus", "Create OCO failed: " .. tostring(err))
        end
        return;
    elseif cookie == S.CMD_CLOSE_ALL_OCO then
        local ok, err = CloseAllOCO()
        if not ok then
            core.host:execute("setStatus", "Close OCO failed: " .. tostring(err))
        end
        return;
    
	  
    end
    return
  end

  local now = nowTS()
  local p=lastPrice(S.sym, S.useBid); if p then bufPush(now, p) end

  -- confirmed fractals
  updateLastFractals()

  -- A) level flow
  if S.entryMode=="TIME_LEVEL" then
    if S.eventOleTS then armIfTime_LEVEL() end
    if S.eventOleTS and S.expireMin and S.expireMin>0 then
      if oleDiffMinutes(S.eventOleTS, now) >= S.expireMin then S.armed=false; S.firedSide=nil end
    end
    if S.armed and not S.firedSide then
      priceCrossedLevels()
      if S.firedSide and S.autoOpenMarket and S.allow then doOpen(S.firedSide); S.armed=false end
    end
  end

  -- FAST modes
  local fmActive=false
  if S.entryMode=="TIME_FASTMOVE" or S.entryMode=="TIME_FRACTALFAST" then
    if S.eventOleTS then
      local secToEvent = (S.eventOleTS - now) * 86400
      local inBefore   = (secToEvent <= 0) and (secToEvent >= -S.armBefore)
      local inAfter    = oleDiffMinutes(S.eventOleTS, now) < S.expireMin
      fmActive = inBefore or inAfter
    end
  elseif S.entryMode=="FASTMOVE_ONLY" or S.entryMode=="FRACTALFAST_ONLY" then
    fmActive=true
  end

  if fmActive then
    if not S.coolUntilTS or now >= S.coolUntilTS then
      local side,tag=detectFastMove(now)
      if side then
        local decided=nil
        local pt=S.pt; local buff=(S.breakBufferPips or 0)*pt; local prox=(S.revProxPips or 0)*pt

        local fractOn = (S.entryMode=="TIME_FRACTALFAST" or S.entryMode=="FRACTALFAST_ONLY")
        if fractOn then
          if S.enableBreakFast then
            if side=="LONG" and S.lastUpFr and p >= (S.lastUpFr + buff) then
              decided="LONG"; tag=tag.."+BRK↑"
            elseif side=="SHORT" and S.lastDnFr and p <= (S.lastDnFr - buff) then
              decided="SHORT"; tag=tag.."+BRK↓"
            end
          end
          if (not decided) and S.enableReverseFast then
            if side=="LONG" and S.lastDnFr and math.abs(p - S.lastDnFr) <= prox then
              decided="SHORT"; tag=tag.."+REV@LFr"
            elseif side=="SHORT" and S.lastUpFr and math.abs(p - S.lastUpFr) <= prox then
              decided="LONG";  tag=tag.."+REV@HFr"
            end
          end
        end

        if not decided then decided=side end
        S.firedSide=decided

        -- store time & bar of trigger
        S.lastTriggerTimeTS = now
        local idx=core.findDate(S.src, now, false)
        S.lastTriggerBar = (idx>=0 and idx) or nil

        local banner = fractOn and "FAST+FRACTAL" or "FAST MOVE"
        core.host:execute("setStatus", banner.." TRIGGER: "..decided.." via "..tag)
        log("%s TRIGGER: %s via %s", banner, decided, tag)
        if S.allow then doOpen(decided) end
        S.coolUntilTS = now + secToOle(S.coolSec)
      end
    end
  end

  if countOurTrades(S.account, S.custom) > 0 then trailingEngine() end
  return core.ASYNC_REDRAW
end

-----------------------------------------
-- DRAW / UI (HUD + lines)
-----------------------------------------
local function hudAnchor(context, corner, offx, offy, boxW, boxH)
  local L,T,R,B=context:left(),context:top(),context:right(),context:bottom()
  if corner=="TopLeft" then return L+offx, T+offy, L+offx+boxW, T+offy+boxH end
  if corner=="BottomLeft" then return L+offx, B-offy-boxH, L+offx+boxW, B-offy end
  if corner=="BottomRight" then return R-offx-boxW, B-offy-boxH, R-offx, B-offy end
  return R-offx-boxW, T+offy, R-offx, T+offy+boxH -- TopRight
end

function Draw(stage, context)
  if stage ~= 0 then return end
  if not _ui.inited then
    _ui.fontHUD=1; context:createFont(_ui.fontHUD, "Arial", S.fontPx or 14, S.fontPx or 14, 0)
    _ui.penEvent=11; context:createPen(_ui.penEvent, context.SOLID, 2, core.rgb(200,200,50))
    _ui.penLong=12;  context:createPen(_ui.penLong,  context.DASH, 2, core.rgb(0,180,0))
    _ui.penShort=13; context:createPen(_ui.penShort, context.DASH, 2, core.rgb(200,60,60))
    _ui.brushHUD=21; context:createSolidBrush(_ui.brushHUD, core.rgb(0,0,0))
    _ui.brushLabelBG=31; context:createSolidBrush(_ui.brushLabelBG, core.rgb(10,10,10))
    _ui.brushLabelShadow=32; context:createSolidBrush(_ui.brushLabelShadow, core.rgb(0,0,0))
    _ui.brushZone=41; context:createSolidBrush(_ui.brushZone, S.zoneColorRGB or core.rgb(220,220,0))
    _ui.fontBanner=51; context:createFont(_ui.fontBanner, "Arial", (S.fontPx or 14)+2, (S.fontPx or 14)+2, 1)
    _ui.penFrUp=61; context:createPen(_ui.penFrUp, context.DOT, 1, core.rgb(180,120,0))
    _ui.penFrDn=62; context:createPen(_ui.penFrDn, context.DOT, 1, core.rgb(120,180,255))
    _ui.penTrigger=71; context:createPen(_ui.penTrigger, context.SOLID, 2, core.rgb(120,255,120))
    _ui.inited=true
  end

  local L,T,R,B=context:left(),context:top(),context:right(),context:bottom()
  context:setClipRectangle(L, T, R, B)

  -- Banner (activity)
  local now = nowTS()
  local timeModes = (S.entryMode=="TIME_FASTMOVE" or S.entryMode=="TIME_FRACTALFAST")
  local fmActive=false
  local statusTxt=""
  if timeModes and S.eventOleTS then
    local secToEvent = (S.eventOleTS - now) * 86400
    local inBefore   = (secToEvent <= 0) and (secToEvent >= -S.armBefore)
    local inAfter    = oleDiffMinutes(S.eventOleTS, now) < S.expireMin
    fmActive = inBefore or inAfter
    if secToEvent > 0 then
      statusTxt = "WINDOW: T-"..math.max(0, math.floor(secToEvent)).."s"
    elseif inAfter then
      local minsLeft = math.max(0, math.floor((S.eventOleTS + S.expireMin/1440 - now)*1440))
      statusTxt = "WINDOW: LIVE  (ends in "..minsLeft.." min)"
    else
      statusTxt = "WINDOW: INACTIVE"
    end
  elseif S.entryMode=="FASTMOVE_ONLY" or S.entryMode=="FRACTALFAST_ONLY" then
    fmActive=true
    statusTxt = (S.entryMode=="FRACTALFAST_ONLY") and "FAST+FRACTAL: ARMED" or "FAST MOVE: ARMED"
  end
  if fmActive then
    local cooldown=(S.coolUntilTS and now<S.coolUntilTS)
    local label = (S.entryMode=="TIME_FRACTALFAST" or S.entryMode=="FRACTALFAST_ONLY") and "FAST+FRACTAL" or "FAST MOVE"
    local txt = cooldown and (label.." COOLDOWN") or (label.." ARMED")
    local tw,th=context:measureText(_ui.fontBanner, txt, 0)
    local bx=(R-L)/2 - tw/2; local by=T+8
    context:drawRectangle(-1, _ui.brushLabelShadow, bx+2, by+2, bx+tw+12, by+th+12, context:convertTransparency(60))
    context:drawRectangle(-1, _ui.brushHUD,        bx,   by,   bx+tw+12, by+th+12, context:convertTransparency(55))
    context:drawText(_ui.fontBanner, txt, core.rgb(255,255,0), -1, bx+6, by+6, bx+6+tw, by+6+th, context.SINGLELINE + context.LEFT + context.TOP)
  end

  -- Simplified HUD block
  local pad=8; local rowH=(S.fontPx or 14)+4
  local baseRows = 6  -- Title/Mode, State, Times, Window, Fractals, Trading
  local hudRows = baseRows + math.max(0, (S.logEnabled and #S.hudLog or 0))
  local boxW=560; local boxH=rowH*(hudRows) + pad*2
  local x1,y1,x2,y2=hudAnchor(context, S.corner or "TopRight", S.hx or 10, S.hy or 10, boxW, boxH)
  context:drawRectangle(-1, _ui.brushHUD, x1, y1, x2, y2, context:convertTransparency(65))

  local modeLbl =
      (S.entryMode=="TIME_LEVEL" and "A:Time+Level")
   or (S.entryMode=="TIME_FASTMOVE" and "B:Time+FastMove")
   or (S.entryMode=="FASTMOVE_ONLY" and "C:FastMove Only")
   or (S.entryMode=="TIME_FRACTALFAST" and "D:Time+Fractal+Fast")
   or "E:Fractal+Fast Only"

  local line1="NEWS SCALPER  |  "..modeLbl
  local line2=(S.armed and not S.firedSide) and "ARMED" or (S.firedSide and ("FIRED: "..S.firedSide) or "IDLE")

  -- Combine CHART and Local lines for compactness
  local chartStr = (S.eventOleTS and fmtTZLabel(S.eventOleTS, "LOCAL") or "—")
  local localStr = (S.eventOle_LOCAL and fmtTZLabel(S.eventOle_LOCAL, "LOCAL") or "—")
  local line3 = "TS/Local:   "..chartStr.."   |   "..localStr

  local line4 = statusTxt
  local line5 = string.format("Fractals: H=%s  L=%s",
    S.lastUpFr and string.format("%.5f", S.lastUpFr) or "—",
    S.lastDnFr and string.format("%.5f", S.lastDnFr) or "—")
  local line6=(S.allow and "TRADING ENABLED (TEST)") or "DISPLAY-ONLY"

  local tx,ty=x1+pad,y1+pad
  local style=context.SINGLELINE + context.LEFT + context.TOP
  context:drawText(_ui.fontHUD, line1, S.colReady or core.rgb(0,200,0), -1, tx, ty,               x2-pad, ty+rowH,   style)
  context:drawText(_ui.fontHUD, line2, core.rgb(235,235,235),           -1, tx, ty+rowH,          x2-pad, ty+2*rowH, style)
  context:drawText(_ui.fontHUD, line3, core.rgb(200,230,255),           -1, tx, ty+2*rowH,        x2-pad, ty+3*rowH, style)
  context:drawText(_ui.fontHUD, line4, core.rgb(220,180,100),           -1, tx, ty+3*rowH,        x2-pad, ty+4*rowH, style)
  context:drawText(_ui.fontHUD, line5, core.rgb(255,220,120),           -1, tx, ty+4*rowH,        x2-pad, ty+5*rowH, style)
  context:drawText(_ui.fontHUD, line6, core.rgb(0,180,255),             -1, tx, ty+5*rowH,        x2-pad, ty+6*rowH, style)

  -- HUD Log feed (optional)
  if S.logEnabled and #S.hudLog>0 then
    local yy = ty + 6*rowH
    for i=#S.hudLog,1,-1 do
      local ln = S.hudLog[i]
      context:drawText(_ui.fontHUD, "• "..ln, core.rgb(210,210,210), -1, tx, yy, x2-pad, yy+rowH, style)
      yy = yy + rowH
    end
  end

  -- Event vertical + shaded window (still helpful)
  if (S.entryMode=="TIME_LEVEL" or S.entryMode=="TIME_FASTMOVE" or S.entryMode=="TIME_FRACTALFAST") and S.eventOle_EST then
    local xStart = context:positionOfDate(S.eventOle_EST - (S.armBefore / 86400.0))
    local xEnd   = context:positionOfDate(S.eventOle_EST + (S.expireMin / 1440.0))
    if xStart and xEnd then
      local x1z, x2z = math.min(xStart, xEnd), math.max(xStart, xEnd)
      local rx1 = math.max(L, math.min(R, x1z))
      local rx2 = math.max(L, math.min(R, x2z))
      if rx2 > rx1 then
        context:drawRectangle(-1, _ui.brushZone, rx1, T, rx2, B, context:convertTransparency(S.zoneAlpha or 22))
      end
    end
    local Xe = context:positionOfDate(S.eventOle_EST)
    if Xe then
      local xv = math.max(L, math.min(R, Xe))
      context:drawLine(_ui.penEvent, xv, T, xv, B)
    end
  end

  -- Trigger vertical (C/E)
  if (S.entryMode=="FASTMOVE_ONLY" or S.entryMode=="FRACTALFAST_ONLY") then
    if S.lastTriggerBar and S.src:hasData(S.lastTriggerBar) then
      local X=context:positionOfBar(S.lastTriggerBar)
      context:drawLine(_ui.penTrigger, X, T, X, B)
    end
  end

  -- Straddle lines + zone
  local yLong,yShort=nil,nil
  if S.longLevel then local ok,y=context:pointOfPrice(S.longLevel); if ok then context:drawLine(_ui.penLong, L, y, R, y); yLong=y end end
  if S.shortLevel then local ok,y=context:pointOfPrice(S.shortLevel); if ok then context:drawLine(_ui.penShort,L, y, R, y); yShort=y end end
  if S.showZone and yLong and yShort then
    local yTop=math.min(yLong,yShort); local yBot=math.max(yLong,yShort)
    context:drawRectangle(-1, _ui.brushZone, L, yTop, R, yBot, context:convertTransparency(S.zoneAlpha or 22))
  end

  -- Fractal lines + labels
  local function drawLabelAbove(yLine, text, txtColor)
    if not yLine then return end
    local margin,padText,shadowOffset=6,4,1
    local tw,th=context:measureText(_ui.fontHUD, text, 0)
    local yTop=yLine - (S.labelOffset or 6) - th - padText*2
    local xLeft=R - tw - margin - padText*2
    local xRight=R - margin
    local yBottom=yTop + th + padText*2
    context:drawRectangle(-1, _ui.brushLabelShadow, xLeft+shadowOffset, yTop+shadowOffset, xRight+shadowOffset, yBottom+shadowOffset, context:convertTransparency(50))
    context:drawRectangle(-1, _ui.brushLabelBG,     xLeft, yTop, xRight, yBottom, context:convertTransparency(35))
    context:drawText(_ui.fontHUD, text, txtColor, -1, xLeft+padText, yTop+padText, xRight-padText, yBottom-padText, context.SINGLELINE + context.LEFT + context.VCENTER)
  end

  if S.lastUpFr then
    local ok, y = context:pointOfPrice(S.lastUpFr); if ok then
      context:drawLine(_ui.penFrUp, L, y, R, y)
      drawLabelAbove(y, "Fractal HIGH", core.rgb(255,200,100))
    end
  end
  if S.lastDnFr then
    local ok, y = context:pointOfPrice(S.lastDnFr); if ok then
      context:drawLine(_ui.penFrDn, L, y, R, y)
      drawLabelAbove(y, "Fractal LOW", core.rgb(140,200,255))
    end
  end

  -- Straddle labels
  if S.showLabels then
    if yLong  then drawLabelAbove(yLong,  "LONG ENTRY",  core.rgb(0,255,0)) end
    if yShort then drawLabelAbove(yShort, "SHORT ENTRY", core.rgb(255,80,80)) end
  end
end



-- ============================================================================
-- OCO HOOKS (minimalni kostur – slobodno nadogradi svoju logiku kasnije)
-- ============================================================================
 
-- Low-level builder for a single OCO entry leg, fully using S.* postavke
-- Create two linked entry orders (straddle) as one OCO group
-- Create two linked entry orders (straddle) as one OCO group
function CreateOCOOrders()
    if not S.allow then
        core.host:execute("setStatus", "[OCO] Trading disabled (AllowTrade=false)")
        return false, "AllowTrade=false"
    end
    if not S.account or S.account == "" then
        core.host:execute("setStatus", "[OCO] Missing Account")
        return false, "No account"
    end

    local dist = tonumber(S.distPips or 0)
    if not dist or dist <= 0 then
        core.host:execute("setStatus", "[OCO] DistancePips must be > 0")
        return false, "bad distance"
    end

    -- pripremi OCO komandu i dodaj 2 naloga (BUY iznad, SELL ispod)
    local vm = core.valuemap()
    vm.Command = "CreateOCO"

    vm:append(CreateOCOOrder("B",  dist))   -- buy strana, +dist pipsa od tržišta
    vm:append(CreateOCOOrder("S", -dist))   -- sell strana, -dist pipsa od tržišta

    local ok, msg = terminal:execute(100, vm)
    if not ok then
        log("[OCO] CreateOCO failed: %s", tostring(msg))
        core.host:execute("setStatus", "[OCO] CreateOCO failed")
        return false, msg
    end

    log("[OCO] CreateOCO OK (dist=%.1f pips, SL=%s TP=%s)",
        dist,
        S.useStop  and tostring(S.stopP)  or "off",
        S.useLimit and tostring(S.limitP) or "off")
    core.host:execute("setStatus", "[OCO] CreateOCO sent")
    return true
end

-- Low-level builder for a single OCO entry leg, fully using S.* postavke
function CreateOCOOrder(aBuySell, adistance)
    local sym = S.sym
    local acc = S.account

    -- market info
    local offers = core.host:findTable("offers"); assert(offers, "offers nil")
    local row = offers:find("Instrument", sym);   assert(row, "instrument not subscribed: "..tostring(sym))
    local offerId = row.OfferID
    local ask = row.Ask
    local bid = row.Bid
    local pt  = row.PointSize or getPointSize(sym)

    -- količina (lots ili %)
    local base_size = core.host:execute("getTradingProperty", "baseUnitSize", sym, acc)
    local qtyUnits
    if S.amountType == "lots" then
        qtyUnits = math.max(1, math.floor((S.amount or 1) * base_size))
    else
        local arow = core.host:findTable("accounts"):find("AccountID", acc)
        local equity = arow and arow.Equity or 0
        local emr = core.host:execute("getTradingProperty", "EMR", sym, acc)
        local units = (emr and emr > 0) and math.max(1, math.floor((equity * (S.amount or 0) / 100.0) / emr)) or 1
        qtyUnits = math.max(1, units * base_size)
    end

    -- ciljna cijena iz udaljenosti u pipsima
    local rate
    if adistance > 0 then
        rate = ask + adistance * pt
    else
        rate = bid + adistance * pt
    end

    -- odredi tip naloga (LE/SE) prema odnosu rate vs trenutna cijena
    local function orderTypeFor(buySell, r, priceNow)
        -- BUY: iznad tržišta je StopEntry (SE), ispod LimitEntry (LE)
        -- SELL: ispod tržišta je StopEntry (SE), iznad LimitEntry (LE)
        if buySell == "B" then
            return (r > priceNow) and "SE" or "LE"
        else
            return (r < priceNow) and "SE" or "LE"
        end
    end
    local nowPx = (aBuySell == "B") and ask or bid
    local ordType = orderTypeFor(aBuySell, rate, nowPx)

    local canClose = core.host:execute("getTradingProperty", "canCreateMarketClose", sym, acc)

    -- sastavi valuemap za JEDAN entry nalog
    local vm = core.valuemap()
    vm.OrderType = ordType
    vm.Rate      = rate
    vm.OfferID   = offerId
    vm.AcctID    = acc
    vm.Quantity  = qtyUnits
    vm.BuySell   = aBuySell       -- "B" ili "S"
    vm.CustomID  = S.custom or "NEWS"

    -- SL/TP (pegged na tržište) + trailing opcionalno
    if S.useLimit then
        vm.PegTypeLimit = "M"
        vm.PegPriceOffsetPipsLimit = (aBuySell == "B") and (S.limitP or 0) or -(S.limitP or 0)
    end
    if S.useStop then
        vm.PegTypeStop = "M"
        vm.PegPriceOffsetPipsStop = (aBuySell == "B") and -(S.stopP or 0) or (S.stopP or 0)
        if S.useTrailStop then
            vm.TrailStepStop = S.trailStep or 1
        end
    end

    -- ako broker ne dopušta regularni SL/TP -> ELS
    if (not canClose) and (S.useStop or S.useLimit) then
        vm.EntryLimitStop = "Y"
    end

    return vm
end




-- Cancel all active OCO entry orders (robust)
function CloseAllOCO()
    local orders = core.host:findTable("orders")
    if not orders then
        core.host:execute("setStatus", "[OCO] Orders table not available")
        return false, "orders nil"
    end

    local canceled, scanned, matched = 0, 0, 0
    local e = orders:enumerator()
    local row = e:next()

    while row do
        scanned = scanned + 1

        -- robustno: OCO ako ima ContingencyID (grupa) i radi (Status == 'W')
        local isWorking = (row.Status == "W") or (row.WorkingIndicator == true)
        local hasGroup  = (row.ContingencyID ~= nil and tostring(row.ContingencyID) ~= "")

        -- (opcionalno) zadrži samo naše (po Custom/QTXT)
        local ours = true
        if S.custom and S.custom ~= "" then
            local q = row.QTXT or row.Comment or ""
            ours = (q and string.find(q, S.custom, 1, true)) and true or false
        end

        if isWorking and hasGroup and ours then
            matched = matched + 1
            local vm = core.valuemap()
           -- vm.Command   = "CreateOrder"
            vm.Command   = "DeleteOrder"			
            vm.OrderType = "C"               -- Cancel entry order
            vm.OrderID   = row.OrderID
            vm.AcctID    = row.AccountID
            vm.OfferID   = row.OfferID       -- <- neki serveri traže i OfferID
            vm.GTC       = "IOC"

            local ok, err = terminal:execute(2, vm)
            if ok then
                canceled = canceled + 1
                log("[OCO] CANCEL OrderID=%s  Instr=%s  Qty=%s",
                    tostring(row.OrderID), tostring(row.Instrument), tostring(row.Amount or row.Quantity or ""))
            else
                log("[OCO] CANCEL FAIL OrderID=%s  err=%s", tostring(row.OrderID), tostring(err))
            end
        end
        row = e:next()
    end

    if matched == 0 then
        log("[OCO] No matching OCO orders. Hint: check Status=='W', ContingencyID present, QTXT='%s'", tostring(S.custom))
    end

    core.host:execute("setStatus",
        string.format("[OCO] CloseAll: scanned=%d matched=%d canceled=%d", scanned, matched, canceled))
    return true
end

-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76412s
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