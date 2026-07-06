-- Id: 
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66637

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

local Modules = {};

function Init()
    indicator:name("Majors Interaction");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addBoolean("zone_show_weak", "zone_show_weak", "", true);
    indicator.parameters:addBoolean("zone_show_untested", "zone_show_untested", "", true);
    indicator.parameters:addBoolean("zone_show_turncoat", "zone_show_turncoat", "", false);
    indicator.parameters:addDouble("zone_fuzzfactor", "zone_fuzzfactor", "", 0.75);
    indicator.parameters:addDouble("fractal_fast_factor", "fractal_fast_factor", "", 3.0);
    indicator.parameters:addDouble("fractal_slow_factor", "fractal_slow_factor", "", 6.0);
    indicator.parameters:addInteger("zone_linewidth", "zone_linewidth", "", 1);
    indicator.parameters:addInteger("zone_style", "zone_style", "", 0);
    indicator.parameters:setFlag("zone_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addBoolean("zone_show_info", "zone_show_info", "", true);
    indicator.parameters:addBoolean("zone_merge", "zone_merge", "", true);
    indicator.parameters:addBoolean("zone_extend", "zone_extend", "", true);
    signaler:Init(indicator.parameters);
    indicator.parameters:addInteger("zone_alert_waitseconds", "zone_alert_waitseconds", "", 300);
    indicator.parameters:addInteger("Text_size", "Text_size", "", 8);
    indicator.parameters:addColor("Text_color", "Text_color", "Text_color", core.rgb(0, 0, 0));
    indicator.parameters:addString("sup_name", "sup_name", "", "Sup");
    indicator.parameters:addString("res_name", "res_name", "", "Res");
    indicator.parameters:addString("test_name", "test_name", "", "Retests");
    indicator.parameters:addColor("color_support_weak", "color_support_weak", "", core.colors().DarkSlateGray);
    indicator.parameters:addColor("color_support_untested", "color_support_untested", "", core.colors().SeaGreen);
    indicator.parameters:addColor("color_support_verified", "color_support_verified", "", core.colors().Green);
    indicator.parameters:addColor("color_support_proven", "color_support_proven", "", core.colors().LimeGreen);
    indicator.parameters:addColor("color_support_turncoat", "color_support_turncoat", "", core.colors().OliveDrab);
    indicator.parameters:addColor("color_resist_weak", "color_resist_weak", "", core.colors().Indigo);
    indicator.parameters:addColor("color_resist_untested", "color_resist_untested", "", core.colors().Orchid);
    indicator.parameters:addColor("color_resist_verified", "color_resist_verified", "", core.colors().Crimson);
    indicator.parameters:addColor("color_resist_proven", "color_resist_proven", "", core.colors().Red);
    indicator.parameters:addColor("color_resist_turncoat", "color_resist_turncoat", "", core.colors().DarkOrange);
    
    indicator.parameters:addColor("ner_hi_zone_P1_color", "ner_hi_zone_P1 color", "", core.colors().Red);
    indicator.parameters:addColor("ner_hi_zone_P2_color", "ner_hi_zone_P2 color", "", core.colors().Red);
    indicator.parameters:addColor("ner_lo_zone_P1_color", "ner_lo_zone_P1 color", "", core.colors().DodgerBlue);
    indicator.parameters:addColor("ner_lo_zone_P2_color", "ner_lo_zone_P2 color", "", core.colors().DodgerBlue);
end

local FastDnPts;
local FastUpPts;
local SlowDnPts;
local SlowUpPts;

local zones = {};

local ZONE_SUPPORT = 1;
local ZONE_RESIST = 2;
local ZONE_WEAK = 0;
local ZONE_TURNCOAT = 1;
local ZONE_UNTESTED = 2;
local ZONE_VERIFIED = 3;
local ZONE_PROVEN = 4;
local UP_POINT = 1;
local DN_POINT = -1;

local ner_lo_zone_P1;
local ner_lo_zone_P2;
local ner_hi_zone_P1;
local ner_hi_zone_P2;
local atr;
local source;
function Prepare(nameOnly)
    for _, module in pairs(Modules) do module:Prepare(nameOnly); end
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 
    if nameOnly then
        return;
    end
    instance:ownerDrawn(true);
    source = instance.source;

    zone_show_weak = instance.parameters.zone_show_weak;
    zone_show_untested = instance.parameters.zone_show_untested;
    zone_show_turncoat = instance.parameters.zone_show_turncoat;
    zone_fuzzfactor = instance.parameters.zone_fuzzfactor;
    fractal_fast_factor = instance.parameters.fractal_fast_factor * 2 + math.ceil(instance.parameters.fractal_fast_factor / 2);
    fractal_slow_factor = instance.parameters.fractal_slow_factor * 2 + math.ceil(instance.parameters.fractal_slow_factor / 2);
    zone_linewidth = instance.parameters.zone_linewidth;
    zone_style = instance.parameters.zone_style;
    zone_show_info = instance.parameters.zone_show_info;
    zone_merge = instance.parameters.zone_merge;
    zone_extend = instance.parameters.zone_extend;
    zone_show_alerts = instance.parameters.zone_show_alerts;
    zone_alert_popups = instance.parameters.zone_alert_popups;
    zone_alert_sounds = instance.parameters.zone_alert_sounds;
    zone_alert_waitseconds = instance.parameters.zone_alert_waitseconds;
    Text_size = instance.parameters.Text_size;
    Text_color = instance.parameters.Text_color;
    sup_name = instance.parameters.sup_name;
    res_name = instance.parameters.res_name;
    test_name = instance.parameters.test_name;
    color_support_weak = instance.parameters.color_support_weak;
    color_support_untested = instance.parameters.color_support_untested;
    color_support_verified = instance.parameters.color_support_verified;
    color_support_proven = instance.parameters.color_support_proven;
    color_support_turncoat = instance.parameters.color_support_turncoat;
    color_resist_weak = instance.parameters.color_resist_weak;
    color_resist_untested = instance.parameters.color_resist_untested;
    color_resist_verified = instance.parameters.color_resist_verified;
    color_resist_proven = instance.parameters.color_resist_proven;
    color_resist_turncoat = instance.parameters.color_resist_turncoat;
    atr = core.indicators:create("ATR", source, 7);
    
    SlowDnPts = instance:createTextOutput("SlowDnPts", "SlowDnPts", "Wingdings", Text_size, core.H_Center, core.V_Bottom, Text_color, 0);
    SlowUpPts = instance:createTextOutput("SlowUpPts", "SlowUpPts", "Wingdings", Text_size, core.H_Center, core.V_Bottom, Text_color, 0);
    FastDnPts = instance:createTextOutput("FastDnPts", "FastDnPts", "Wingdings", Text_size, core.H_Center, core.V_Bottom, Text_color, 0);
    FastUpPts = instance:createTextOutput("FastUpPts", "FastUpPts", "Wingdings", Text_size, core.H_Center, core.V_Bottom, Text_color, 0);

    ner_hi_zone_P1 = instance:addStream("ner_hi_zone_P1", core.Line, "ner_hi_zone_P1", "ner_hi_zone_P1", instance.parameters.ner_hi_zone_P1_color, 0);
    ner_hi_zone_P2 = instance:addStream("ner_hi_zone_P2", core.Line, "ner_hi_zone_P2", "ner_hi_zone_P2", instance.parameters.ner_hi_zone_P2_color, 0);
    ner_lo_zone_P1 = instance:addStream("ner_lo_zone_P1", core.Line, "ner_lo_zone_P1", "ner_lo_zone_P1", instance.parameters.ner_lo_zone_P1_color, 0);
    ner_lo_zone_P2 = instance:addStream("ner_lo_zone_P2", core.Line, "ner_lo_zone_P2", "ner_lo_zone_P2", instance.parameters.ner_lo_zone_P2_color, 0);
end

local last_serial;

function ExtAsyncOperationFinished(cookie, success, message, message1, message2) for _, module in pairs(Modules) do if module.AsyncOperationFinished ~= nil then module:AsyncOperationFinished(cookie, success, message, message1, message2); end end end

function Update(period)
    for _, module in pairs(Modules) do if module.BlockTrading ~= nil and module:BlockTrading(nil, source, period) then return; end end for _, module in pairs(Modules) do if module.ExtUpdate ~= nil then module:ExtUpdate(id, source, period); end end
    if(Fractal(UP_POINT,fractal_fast_factor,period)==true) then
        FastUpPts:set(period, source.high[period], "\218");
    else
        FastUpPts:setNoData(period)
    end
    if(Fractal(DN_POINT,fractal_fast_factor,period)==true) then
        FastDnPts:set(period, source.low[period], "\217");
    else
        FastDnPts:setNoData(period)
    end
    if(Fractal(UP_POINT,fractal_slow_factor,period)==true) then
        SlowUpPts:set(period, source.high[period], "\218");
    else
        SlowUpPts:setNoData(period)
    end
    if(Fractal(DN_POINT,fractal_slow_factor,period)==true) then
        SlowDnPts:set(period, source.low[period], "\217");
    else
        SlowDnPts:setNoData(period)
    end
    if last_serial ~= source:serial(NOW) then
        if (period == source:size() - 1) then
            FindZones();
            last_serial = source:serial(NOW);
        end
    end
    CheckAlerts();
end

local init = false;
local FONT_ID = 1;
local support_turncoat_PEN = 2;
local support_turncoat_BRUSH = 3;
local color_support_proven_PEN = 4;
local color_support_proven_BRUSH = 5;
local color_support_verified_PEN = 6;
local color_support_verified_BRUSH = 7;
local color_support_untested_PEN = 8;
local color_support_untested_BRUSH = 9;
local color_support_weak_PEN = 10;
local color_support_weak_BRUSH = 11;
local color_resist_proven_PEN = 12;
local color_resist_proven_BRUSH = 13;
local color_resist_turncoat_PEN = 14;
local color_resist_turncoat_BRUSH = 15;
local color_resist_verified_PEN = 16;
local color_resist_verified_BRUSH = 17;
local color_resist_untested_PEN = 18;
local color_resist_untested_BRUSH = 19;
local color_resist_weak_PEN = 20;
local color_resist_weak_BRUSH = 21;
 
function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        context:createFont(FONT_ID, "Courier New", 0, context:pointsToPixels(Text_size), 0);
        context:createPen(support_turncoat_PEN, context.SOLID, zone_linewidth, color_support_turncoat);
        context:createSolidBrush(support_turncoat_BRUSH, color_support_turncoat)
        context:createPen(color_support_proven_PEN, context.SOLID, zone_linewidth, color_support_proven);
        context:createSolidBrush(color_support_proven_BRUSH, color_support_proven)
        context:createPen(color_support_verified_PEN, context.SOLID, zone_linewidth, color_support_verified);
        context:createSolidBrush(color_support_verified_BRUSH, color_support_verified)
        context:createPen(color_support_untested_PEN, context.SOLID, zone_linewidth, color_support_untested);
        context:createSolidBrush(color_support_untested_BRUSH, color_support_untested)
        context:createPen(color_support_weak_PEN, context.SOLID, zone_linewidth, color_support_weak);
        context:createSolidBrush(color_support_weak_BRUSH, color_support_weak)
        context:createPen(color_resist_proven_PEN, context.SOLID, zone_linewidth, color_resist_proven);
        context:createSolidBrush(color_resist_proven_BRUSH, color_resist_proven)
        context:createPen(color_resist_turncoat_PEN, context.SOLID, zone_linewidth, color_resist_turncoat);
        context:createSolidBrush(color_resist_turncoat_BRUSH, color_resist_turncoat)
        context:createPen(color_resist_verified_PEN, context.SOLID, zone_linewidth, color_resist_verified);
        context:createSolidBrush(color_resist_verified_BRUSH, color_resist_verified)
        context:createPen(color_resist_untested_PEN, context.SOLID, zone_linewidth, color_resist_untested);
        context:createSolidBrush(color_resist_untested_BRUSH, color_resist_untested)
        context:createPen(color_resist_weak_PEN, context.SOLID, zone_linewidth, color_resist_weak);
        context:createSolidBrush(color_resist_weak_BRUSH, color_resist_weak)
		
 
		
        init = true;
    end

    local lower_nerest_zone_P1=0;
    local lower_nerest_zone_P2=0;
    local higher_nerest_zone_P1=0;
    local higher_nerest_zone_P2=0;

    for _, zone in ipairs(zones) do
        local lbl;
        if (zone.strength==ZONE_PROVEN) then
            lbl="Proven";
        elseif (zone.strength==ZONE_VERIFIED) then
            lbl="Verified";
        elseif (zone.strength==ZONE_UNTESTED) then
            lbl="Untested";
        elseif (zone.strength==ZONE_TURNCOAT) then
            lbl="Turncoat";
        else
            lbl="Weak";
        end

        if (zone.type==ZONE_SUPPORT) then
            lbl = lbl .. " " .. sup_name;
        else
            lbl = lbl .. " " .. res_name;
        end

        if (zone.hits>0 and zone.strength>ZONE_UNTESTED) then
            if (zone.hits==1) then
                lbl = lbl .. ", " .. test_name .. "=" .. zone.hits;
            else
                lbl = lbl .. ", " .. test_name .. "=" .. zone.hits;
            end
        end

        if not (zone.strength==ZONE_WEAK and zone_show_weak==false)
            and not (zone.strength==ZONE_UNTESTED and zone_show_untested==false)
            and not (zone.strength==ZONE_TURNCOAT and zone_show_turncoat==false)
        then
            local x = context:positionOfBar(source:size());
            if zone_show_info then
                local vpos = zone.hi-(zone.hi-zone.lo)/2;
                local visible, y_line = context:pointOfPrice(vpos);
                local W, H = context:measureText(FONT_ID, lbl, context.LEFT);
                core.host:trace(W);
                core.host:trace(H);
                context:drawText(FONT_ID, lbl, Text_color, -1, x, y_line, x + W, y_line + H, context.LEFT);
            end

            local x1 = context:positionOfBar(zone.start);
            local visible, y1 = context:pointOfPrice(zone.hi);
            local visible, y2 = context:pointOfPrice(zone.lo);
            if(zone.type==ZONE_SUPPORT) then
                if(zone.strength==ZONE_TURNCOAT) then
                    context:drawRectangle(support_turncoat_PEN, support_turncoat_BRUSH, x1, y1, x, y2, 128);
                elseif(zone.strength==ZONE_PROVEN) then
                    context:drawRectangle(color_support_proven_PEN, color_support_proven_BRUSH, x1, y1, x, y2, 128);
                elseif(zone.strength==ZONE_VERIFIED) then
                    context:drawRectangle(color_support_verified_PEN, color_support_verified_BRUSH, x1, y1, x, y2, 128);
                elseif(zone.strength==ZONE_UNTESTED) then
                    context:drawRectangle(color_support_untested_PEN, color_support_untested_BRUSH, x1, y1, x, y2, 128);
                else
                    context:drawRectangle(color_support_weak_PEN, color_support_weak_BRUSH, x1, y1, x, y2, 128);
                end
            else
                if(zone.stregth==ZONE_TURNCOAT) then
                    context:drawRectangle(color_resist_turncoat_PEN, color_resist_turncoat_BRUSH, x1, y1, x, y2, 128);
                elseif(zone.strength==ZONE_PROVEN) then
                    context:drawRectangle(color_resist_proven_PEN, color_resist_proven_BRUSH, x1, y1, x, y2, 128);
                elseif(zone.strength==ZONE_VERIFIED) then
                    context:drawRectangle(color_resist_verified_PEN, color_resist_verified_BRUSH, x1, y1, x, y2, 128);
                elseif(zone.strength==ZONE_UNTESTED) then
                    context:drawRectangle(color_resist_untested_PEN, color_resist_untested_BRUSH, x1, y1, x, y2, 128);
                else
                    context:drawRectangle(color_resist_weak_PEN, color_resist_weak_BRUSH, x1, y1, x, y2, 128);
                end
            end
        end
        --nearest zones
        if(zone.lo>lower_nerest_zone_P2 and source.close[NOW] > zone.lo) then
            lower_nerest_zone_P1=zone.hi;
            lower_nerest_zone_P2=zone.lo;
        end
        if(zone.hi<higher_nerest_zone_P1 and source.close[NOW] < zone.hi) then
            higher_nerest_zone_P1=zone.hi;
            higher_nerest_zone_P2=zone.lo;
        end
    end

    ner_hi_zone_P1[NOW]=higher_nerest_zone_P1;
    ner_hi_zone_P2[NOW]=higher_nerest_zone_P2;
    ner_lo_zone_P1[NOW]=lower_nerest_zone_P1;
    ner_lo_zone_P2[NOW]=lower_nerest_zone_P2;
end

function AsyncOperationFinished(cookie)
end

local lastalert = 0;
function CheckAlerts()
    if zone_show_alerts == false then
        return;
    end

    if source:date(NOW) - lastalert > zone_alert_waitseconds and CheckEntryAlerts() == true then
        lastalert = source:date(NOW);
    end
end

function CheckEntryAlerts()
    for _, zone in ipairs(zones) do
        if source.close[NOW] >= zone.lo and source.close[NOW]<zone.hi and zone_show_alerts then
            if(zone.type==ZONE_SUPPORT) then
                signaler:Signal(source:instrument() .. source:barSize() .. ": Support Zone Entered");
            else
                signaler:Signal(source:instrument() .. source:barSize() .. ": Resistance Zone Entered");
            end

            return(true);
        end
    end

    return(false);
end

function FindZones()
    atr:update(core.UpdateLast);
    if source:size() < 5 then
        return;
    end
    local i;
    local j;
    local shift;
    local bustcount = 0;
    local testcount = 0;
    local hival,loval;
    local turned=false;
    local hasturned=false;

    local temp_hi = {};
    local temp_lo = {};
    local temp_start = {};
    local temp_hits = {};
    local temp_strength = {};
    local temp_count = 0;
    local temp_turn = {};
    local temp_merge = {};
    local merge1 = {};
    local merge2 = {}
    local merge_count = 0;

    for shift = 0, source:size() - 5 do
        local fu = atr.DATA[shift] / 2 * zone_fuzzfactor;
        local isWeak;
        local touchOk= false;
        local isBust = false;
        if FastUpPts:hasData(shift) then
            isWeak = not SlowUpPts:hasData(shift);
            hival=source.high[shift];
            if(zone_extend==true) then
                hival = hival + fu;
            end

            loval = math.max(math.min(source.close[shift], source.high[shift] - fu), source.high[shift] - fu * 2);
            turned=false;
            hasturned=false;
            isBust=false;

            bustcount = 0;
            testcount = 0;

            for i = shift + 1, source:size() - 1 do
                FastUpPts_value = FastUpPts:get(i);
                FastDnPts_value = FastDnPts:get(i);
                if((turned==false and FastUpPts_value >= loval and FastUpPts_value <= hival) or 
                    (turned==true and FastDnPts_value <= hival and FastDnPts_value >= loval))
                then
                    touchOk=true;
                    for j = i - 11, i - 1 do
                        FastUpPts_value = FastUpPts:get(j);
                        FastDnPts_value = FastDnPts:get(j);
                        if((turned==false and FastUpPts_value >=loval and FastUpPts_value <=hival) or 
                            (turned==true and FastDnPts_value <=hival and FastDnPts_value >=loval))
                        then
                            touchOk=false;
                            break;
                        end
                    end

                    if(touchOk==true) then
                        bustcount=0;
                        testcount = testcount + 1;
                    end
                end

                if((turned==false and source.high[i]>hival) or 
                    (turned==true and source.low[i]<loval))
                then
                    -- this level has been busted at least once
                    bustcount = bustcount + 1;
                    if(bustcount>1 or isWeak==true) then
                        -- busted twice or more
                        isBust=true;
                        break;
                    end

                    if(turned == true) then
                        turned = false;
                    elseif(turned==false) then
                        turned=true;
                    end

                    hasturned=true;

                    -- forget previous hits
                    testcount=0;
                end
            end

            if(isBust==false) then
                -- level is still valid, add to our list
                temp_hi[temp_count] = hival;
                temp_lo[temp_count] = loval;
                temp_turn[temp_count] = hasturned;
                temp_hits[temp_count] = testcount;
                temp_start[temp_count] = shift;
                temp_merge[temp_count] = false;

                if(testcount>3) then
                    temp_strength[temp_count]=ZONE_PROVEN;
                elseif(testcount>0) then
                    temp_strength[temp_count]=ZONE_VERIFIED;
                elseif(hasturned==true) then
                    temp_strength[temp_count]=ZONE_TURNCOAT;
                elseif(isWeak==false) then
                    temp_strength[temp_count]=ZONE_UNTESTED;
                else
                    temp_strength[temp_count]=ZONE_WEAK;
                end

                temp_count = temp_count + 1;
            end
        elseif FastDnPts:hasData(shift) then
            -- a zigzag low point
            isWeak = not SlowDnPts:hasData(shift);
            loval=source.low[shift];
            if(zone_extend==true) then
                loval = loval - fu;
            end

            hival=math.min(math.max(source.close[shift], source.low[shift]+fu), source.low[shift]+fu*2);
            turned=false;
            hasturned=false;

            bustcount = 0;
            testcount = 0;
            isBust=false;

            for i = shift + 1, source:size() - 1 do
                FastUpPts_value = FastUpPts:get(i);
                FastDnPts_value = FastDnPts:get(i);
                if((turned==true and FastUpPts_value >=loval and FastUpPts_value <=hival) or 
                    (turned==false and FastDnPts_value <=hival and FastDnPts_value >=loval))
                then
                    -- Potential touch, just make sure its been 10+candles since the prev one
                    touchOk=true;
                    for j = i - 11, i - 1 do
                        FastUpPts_value = FastUpPts:get(j);
                        FastDnPts_value = FastDnPts:get(j);
                        if((turned==true and FastUpPts_value >=loval and FastUpPts_value <=hival) or 
                            (turned==false and FastDnPts_value <=hival and FastDnPts_value >=loval))
                        then
                            touchOk=false;
                            break;
                        end
                    end

                    if(touchOk==true) then
                        -- we have a touch_ If its been busted once, remove bustcount
                        -- as we know this level is still valid & has just switched sides
                        bustcount=0;
                        testcount = testcount + 1;
                    end
                end

                if((turned==true and source.high[i]>hival) or 
                    (turned==false and source.low[i]<loval))
                then
                    -- this level has been busted at least once
                    bustcount = bustcount + 1;

                    if(bustcount>1 or isWeak==true) then
                        -- busted twice or more
                        isBust=true;
                        break;
                    end

                    if(turned == true) then
                        turned = false;
                    elseif(turned==false) then
                        turned=true;
                    end

                    hasturned=true;

                    -- forget previous hits
                    testcount=0;
                end
            end

            if(isBust==false) then
                -- level is still valid, add to our list
                temp_hi[temp_count] = hival;
                temp_lo[temp_count] = loval;
                temp_turn[temp_count] = hasturned;
                temp_hits[temp_count] = testcount;
                temp_start[temp_count] = shift;
                temp_merge[temp_count] = false;

                if(testcount>3) then
                    temp_strength[temp_count]=ZONE_PROVEN;
                elseif(testcount>0) then
                    temp_strength[temp_count]=ZONE_VERIFIED;
                elseif(hasturned==true) then
                    temp_strength[temp_count]=ZONE_TURNCOAT;
                elseif(isWeak==false) then
                    temp_strength[temp_count]=ZONE_UNTESTED;
                else
                    temp_strength[temp_count]=ZONE_WEAK;
                end

                temp_count = temp_count + 1;
            end
        end
    end

    -- look for overlapping zones___
    if(zone_merge==true) then
        merge_count=1;
        local iterations=0;
        while (merge_count>0 and iterations<3) do
            merge_count=0;
            iterations = iterations + 1;

            for i=0, temp_count do
                temp_merge[i]=false;
            end

            for i = 0, temp_count - 1 do
                if not (temp_hits[i]==-1 or temp_merge[j]==true) then
                    for j = i + 1, temp_count - 1 do
                        if not (temp_hits[j]==-1 or temp_merge[j]==true) then
                            if((temp_hi[i]>=temp_lo[j] and temp_hi[i]<=temp_hi[j]) or 
                                (temp_lo[i] <= temp_hi[j] and temp_lo[i] >= temp_lo[j]) or
                                (temp_hi[j] >= temp_lo[i] and temp_hi[j] <= temp_hi[i]) or
                                (temp_lo[j] <= temp_hi[i] and temp_lo[j] >= temp_lo[i]))
                            then
                                merge1[merge_count] = i;
                                merge2[merge_count] = j;
                                temp_merge[i] = true;
                                temp_merge[j] = true;
                                merge_count = merge_count + 1;
                            end
                        end
                    end
                end
            end
            -- ___ and merge them ___
            for i=0, merge_count - 1 do
                local target = merge1[i];
                local source = merge2[i];

                temp_hi[target] = math.max(temp_hi[target], temp_hi[source]);
                temp_lo[target] = math.min(temp_lo[target], temp_lo[source]);
                temp_hits[target] = temp_hits[target] + temp_hits[source];
                temp_start[target] = math.max(temp_start[target], temp_start[source]);
                temp_strength[target]=math.max(temp_strength[target],temp_strength[source]);
                if(temp_hits[target]>3) then
                    temp_strength[target]=ZONE_PROVEN;
                end

                if(temp_hits[target]==0 and temp_turn[target]==false) then
                    temp_hits[target]=1;
                    if(temp_strength[target]<ZONE_VERIFIED) then
                        temp_strength[target]=ZONE_VERIFIED;
                    end
                end

                if(temp_turn[target] == false or temp_turn[source] == false) then
                    temp_turn[target] = false;
                end
                if(temp_turn[target] == true) then
                    temp_hits[target] = 0;
                end

                temp_hits[source]=-1;
            end
        end
    end

    -- copy the remaining list into our official zones arrays
    zone_count=0;
    for i=0, temp_count - 1 do
        if(temp_hits[i]>=0 and zone_count<1000) then
            local zone = {};
            zones[#zones + 1] = zone;
            zone.hi = temp_hi[i];
            zone.lo = temp_lo[i];
            zone.hits = temp_hits[i];
            zone.turn = temp_turn[i];
            zone.start = temp_start[i];
            zone.strength = temp_strength[i];

            if(zone.hi<source.close[NOW - 4]) then
                zone.type=ZONE_SUPPORT;
            elseif(zone.lo>source.close[NOW - 4]) then
                zone.type=ZONE_RESIST;
            else
                for j = 5, 1000 do
                    if(source.close[NOW - j]<zone.lo) then
                        zone.type=ZONE_RESIST;
                        break;
                    elseif(source.close[NOW - j]>zone.hi) then
                        zone.type=ZONE_SUPPORT;
                        break;
                    end
                end

                if(j==1000) then
                    zone.type=ZONE_SUPPORT;
                end
            end

            zone_count = zone_count + 1;
        end
    end
end
function Fractal(M, P, shift)
    if (shift < P or shift + P > source:size() - 1) then
        return false;
    end

    for i = 1, P do
        if(M==UP_POINT) then
            if(source.high[shift-i]>source.high[shift]) then
                return(false);
            end
            if(source.high[shift+i]>=source.high[shift]) then
                return(false);
            end
        end
        if(M==DN_POINT) then
            if(source.low[shift-i]<source.low[shift]) then
                return(false);
            end
            if(source.low[shift+i]<=source.low[shift]) then
                return(false);
            end
        end
    end
    return(true);
end

signaler = {};
signaler.Name = "Signaler";
signaler.Debug = false;
signaler.Version = "1.2.2";

signaler._show_alert = nil;
signaler._sound_file = nil;
signaler._recurrent_sound = nil;
signaler._email = nil;
signaler._ids_start = nil;
signaler._advanced_alert_timer = nil;
signaler._tz = nil;
signaler._alerts = {};

function signaler:trace(str) if not self.Debug then return; end core.host:trace(self.Name .. ": " .. str); end
function signaler:OnNewModule(module) end
function signaler:RegisterModule(modules) for _, module in pairs(modules) do self:OnNewModule(module); module:OnNewModule(self); end modules[#modules + 1] = self; self._ids_start = (#modules) * 100; end

function signaler:ToJSON(item)
    local json = {};
    function json:AddStr(name, value)
        local separator = "";
        if self.str ~= nil then
            separator = ",";
        else
            self.str = "";
        end
        self.str = self.str .. string.format("%s\"%s\":\"%s\"", separator, tostring(name), tostring(value));
    end
    function json:AddNumber(name, value)
        local separator = "";
        if self.str ~= nil then
            separator = ",";
        else
            self.str = "";
        end
        self.str = self.str .. string.format("%s\"%s\":%f", separator, tostring(name), value or 0);
    end
    function json:AddBool(name, value)
        local separator = "";
        if self.str ~= nil then
            separator = ",";
        else
            self.str = "";
        end
        self.str = self.str .. string.format("%s\"%s\":%s", separator, tostring(name), value and "true" or "false");
    end
    function json:ToString()
        return "{" .. (self.str or "") .. "}";
    end
    
    local first = true;
    for idx,t in pairs(item) do
        local stype = type(t)
        if stype == "number" then
            json:AddNumber(idx, t);
        elseif stype == "string" then
            json:AddStr(idx, t);
        elseif stype == "boolean" then
            json:AddBool(idx, t);
        elseif stype == "function" or stype == "table" then
            --do nothing
        else
            core.host:trace(tostring(idx) .. " " .. tostring(stype));
        end
    end
    return json:ToString();
end

function signaler:ArrayToJSON(arr)
    local str = "[";
    for i, t in ipairs(self._alerts) do
        local json = self:ToJSON(t);
        if str == "[" then
            str = str .. json;
        else
            str = str .. "," .. json;
        end
    end
    return str .. "]";
end

function signaler:AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == self._advanced_alert_timer and #self._alerts > 0 and (self.last_req == nil or not self.last_req:loading()) then
        if self._advanced_alert_key == nil then
            return;
        end

        local data = self:ArrayToJSON(self._alerts);
        self._alerts = {};
        
        self.last_req = http_lua.createRequest();
        local query = string.format('{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}',
            self._advanced_alert_key, string.gsub(self.StrategyName or "", '"', '\\"'), data);
        self.last_req:setRequestHeader("Content-Type", "application/json");
        self.last_req:setRequestHeader("Content-Length", tostring(string.len(query)));

        self.last_req:start("http://profitrobots.com/api/v1/notification", "POST", query);
    end
end

function signaler:FormatEmail(source, period, message)
    --format email subject
    local subject = message .. "(" .. source:instrument() .. ")";
    --format email text
    local delim = "\013\010";
    local signalDescr = "Signal: " .. (self.StrategyName or "");
    local symbolDescr = "Symbol: " .. source:instrument();
    local messageDescr = "Message: " .. message;
    local ttime = core.dateToTable(core.host:execute("convertTime", 1, 4, source:date(period)));
    local dateDescr = string.format("Time:  %02i/%02i %02i:%02i", ttime.month, ttime.day, ttime.hour, ttime.min);
    local priceDescr = "Price: " .. source[period];
    local text = "You have received this message because the following signal alert was received:"
        .. delim .. signalDescr .. delim .. symbolDescr .. delim .. messageDescr .. delim .. dateDescr .. delim .. priceDescr;
    return subject, text;
end

function signaler:Signal(label, source)
    if source == nil then
        source = instance.bid;
        if instance.bid == nil then
            local pane = core.host.Window.CurrentPane;
            source = pane.Data:getStream(0);
        else
            source = instance.bid;
        end
    end
    if self._show_alert then
        terminal:alertMessage(source:instrument(), source[NOW], label, source:date(NOW));
    end

    if self._sound_file ~= nil then
        terminal:alertSound(self._sound_file, self._recurrent_sound);
    end

    if self._email ~= nil then
        terminal:alertEmail(self._email, profile:id().. " : " .. label, self:FormatEmail(source, NOW, label));
    end

    if self._advanced_alert_key ~= nil then
        self:AlertTelegram(label, source:instrument(), source:barSize());
    end
end

function signaler:AlertTelegram(message, instrument, timeframe)
    if core.host.Trading:getTradingProperty("isSimulation") then
        return;
    end
    local alert = {};
    alert.Text = message or "";
    alert.Instrument = instrument or "";
    alert.TimeFrame = timeframe or "";
    self._alerts[#self._alerts + 1] = alert;
end

function signaler:Init(parameters)
    parameters:addBoolean("signaler_show_alert", "Show Alert", "", true);
    parameters:addBoolean("signaler_play_sound", "Play Sound", "", false);
    parameters:addFile("signaler_sound_file", "Sound File", "", "");
    parameters:setFlag("signaler_sound_file", core.FLAG_SOUND);
    parameters:addBoolean("signaler_recurrent_sound", "Recurrent Sound", "", true);
    parameters:addBoolean("signaler_send_email", "Send Email", "", false);
    parameters:addString("signaler_email", "Email", "", "");
    parameters:setFlag("signaler_email", core.FLAG_EMAIL);
    parameters:addBoolean("use_advanced_alert", "Send Advanced Alert", "Telegram message or Channel post", false);
    parameters:addString("advanced_alert_key", "Advanced Alert Key", "You can get it via @profit_robots_bot Telegram bot", "");
end

function signaler:Prepare(name_only)
    if instance.parameters.signaler_play_sound then
        self._sound_file = instance.parameters.signaler_sound_file;
        assert(self._sound_file ~= "", "Sound file must be chosen");
    end
    self._show_alert = instance.parameters.signaler_show_alert;
    self._recurrent_sound = instance.parameters.signaler_recurrent_sound;
    if instance.parameters.signaler_send_email then
        self._email = instance.parameters.signaler_email;
        assert(self._email ~= "", "E-mail address must be specified");
    end
    --do what you usually do in prepare
    if name_only then
        return;
    end

    if instance.parameters.advanced_alert_key ~= "" and instance.parameters.use_advanced_alert then
        self._advanced_alert_key = instance.parameters.advanced_alert_key;
        require("http_lua");
        self._advanced_alert_timer = self._ids_start + 1;
        core.host:execute("setTimer", self._advanced_alert_timer, 1);
    end
end

signaler:RegisterModule(Modules);