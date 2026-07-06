-- Id: 11183
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60334

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Day channel indicator");
    indicator:description("Day channel indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("StartTime", "Start time", "", "12:30");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Bclr", "Border color", "Border color", core.rgb(255, 255, 0));
    indicator.parameters:addColor("color", "Fill Color", "", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 75, 0, 100);
end

local first;
local source = nil;
local StartH, StartM;
local StartTime;
local Upper=nil;
local Lower=nil;
local transparency;

function ParseTime(time)
    local Pos = string.find(time, ":");
    local h = tonumber(string.sub(time, 1, Pos - 1));
    local m = tonumber(string.sub(time, Pos + 1));
    return (60*h+m), h, m, ((h >= 0 and h < 24 and m >= 0 and m < 60 ) or (h == 24 and m == 0));
end

function Prepare(onlyName)
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.StartTime .. ")";

    if onlyName then
        return ;
    end
    
    first = source:first()+2;
    instance:name(name);
    StartTime, StartH, StartM, valid = ParseTime(instance.parameters.StartTime);
    assert(valid, "Time " .. instance.parameters.StartTime .. " is invalid");
    
    Upper = instance:addStream("Upper", core.Line, name .. ".Upper", "Upper", instance.parameters.Bclr, first);
    Lower = instance:addStream("Lower", core.Line, name .. ".Lower", "Lower", instance.parameters.Bclr, first);
    Upper:setVisible(false);
    Lower:setVisible(false);
    instance:ownerDrawn(true);
end

function Update(period, mode)
   if period>first then
    local D=source:date(period);
    local T=core.dateToTable(D);
    local CandleTime=60*T.hour+T.min;
    local b, e;
    local i;
    if CandleTime>=StartTime then
     b=core.datetime(T.year, T.month, T.day, StartH, StartM, 0);
     e=b+1;
    else
     e=core.datetime(T.year, T.month, T.day, StartH, StartM, 0);
     b=e-1;
    end

    local b_index, e_index = core.findDate(source, b, false), core.findDate(source, e, false);
    
    if b_index>=first and e_index<source:size() then
     Lower[period], Upper[period] = mathex.minmax(source, b_index, e_index);
    end 
    
    if period==source:size()-1 and (Lower[period]~=Lower[period-1] or Upper[period]~=Upper[period-1]) then
     for i=b_index, period, 1 do
      Lower[i]=Lower[period];
      Upper[i]=Upper[period];
     end
    end
    
   end 
end

local init = false;

function Draw(stage, context)
    if stage == 0 then
    
        if not init then
            context:createPen(1, context.SOLID, 1, instance.parameters.Bclr);
            context:createSolidBrush(2, instance.parameters.color);
            transparency=context:convertTransparency(instance.parameters.transparency);
            init = true;
        end

        local lastx2;
        local lastx;
        local yu0, yu1, yl0, yl1;
        
        local Upoints, Lpoints = context:createPoints(), context:createPoints();
        local firstBar=context:firstBar();
        
        if firstBar<first then
         return;
        end
        
        lastx2, lastx = context:positionOfBar(firstBar);
        v, yu1 = context:pointOfPrice(Upper[firstBar]);
        v, yl1 = context:pointOfPrice(Lower[firstBar]);
        
        context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());

        context:startEnumeration();
        while true do
            index, x, x1, x2, c1, c2 = context:nextBar();
            if index == nil then
                break;
            end
            lastx2=x2;
            
            u0, l0 = Upper[index], Lower[index];
            
            v, yu0 = context:pointOfPrice(u0);
            v, yl0 = context:pointOfPrice(l0);
            
            if index==firstBar then
             Upoints:add(x1,yu0);
             Lpoints:add(x1,yl0);
            end
            
            if yu0~=yu1 then
             Upoints:add(x1, yu1);
             Upoints:add(x1, yu0);
             context:drawRectangle(-1, 2, lastx, yu1, x1+1, yl1, transparency);
             lastx=x1;
            end
            
            if yl0~=yl1 then
             Lpoints:add(x1, yl1);
             Lpoints:add(x1, yl0);
             context:drawRectangle(-1, 2, lastx, yu1, x1+1, yl1, transparency);
             lastx=x1;
            end
            
            yu1=yu0;
            yl1=yl0;
        end
        
        Upoints:add(lastx2, yu0);
        Lpoints:add(lastx2, yl0);
        context:drawRectangle(-1, 2, lastx, yu0, lastx2+1, yl0, transparency);
        
        context:drawPolyline(1, Upoints);
        context:drawPolyline(1, Lpoints);
        
        context:resetClipRectangle();
    end
end


