function Init()
    indicator:name("Bigger candles indicator");
    indicator:description("Bigger candles indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("TF", "Time frame for candles", "", "m15");
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("BodyClr", "Body Color", "Body Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("UpShadowClr", "Up shadow Color", "Up shadow Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DnShadowClr", "Dn shadow Color", "Dn shadow Color", core.rgb(0, 255, 128));
    indicator.parameters:addInteger("BodyTransparency", "Body Transparency", "0 - opaque, 100 - transparent", 75, 0, 100);
    indicator.parameters:addInteger("UpShadowTransparency", "Up shadow Transparency", "0 - opaque, 100 - transparent", 85, 0, 100);
    indicator.parameters:addInteger("DnShadowTransparency", "Dn shadow Transparency", "0 - opaque, 100 - transparent", 85, 0, 100);
end

local first;
local source = nil;
local TF;
local TradingDayOffset, TradingWeekOffset;
local BodyTransparency,UpShadowTransparency,DnShadowTransparency;

function Prepare(onlyName)
    TF=instance.parameters.TF;
    source = instance.source;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.TF .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end
    instance:ownerDrawn(true);
    TradingDayOffset = core.host:execute("getTradingDayOffset");
    TradingWeekOffset = core.host:execute("getTradingWeekOffset");
    instance:setLabelColor(instance.parameters.BodyClr);
end

function Update(period, mode)
end

local init = false;

function Draw(stage, context)
    if stage == 0 then
    
        if not init then
            context:createPen(1, context.SOLID, 1, instance.parameters.BodyClr);
            context:createSolidBrush(2, instance.parameters.BodyClr);
            context:createSolidBrush(3, instance.parameters.UpShadowClr);
            context:createSolidBrush(4, instance.parameters.DnShadowClr);
            BodyTransparency=context:convertTransparency(instance.parameters.BodyTransparency);
            UpShadowTransparency=context:convertTransparency(instance.parameters.UpShadowTransparency);
            DnShadowTransparency=context:convertTransparency(instance.parameters.DnShadowTransparency);
            init = true;
        end

        local m, pO, pH, pL, pC;
        local x_shift_p, y_shift_p;
        local beginCandle, endCandle;
        local beginIndex, endIndex;
        local O, H, L, C;
        local lastBegin = nil;
        local lastEnd;
        local lastH, lastL;
        local lastX1, lastX2;
        local MaxP, MinP;
        local lastIndex = context:lastBar();

        context:startEnumeration();
        while true do
            index, x, x1, x2, c1, c2 = context:nextBar();
            if index == nil then
                break;
            end
            
            beginCandle, endCandle = core.getcandle(TF, source:date(index), TradingDayOffset, TradingWeekOffset);
            beginIndex, endIndex = core.findDate(source, beginCandle, false), core.findDate(source, endCandle, false);
            if beginIndex==-1 or endIndex==-1 then
               break;
            end 
            if source:date(endIndex) == endCandle then
             endIndex = endIndex-1;
            end
            L, H = mathex.minmax(source, beginIndex, endIndex);
            if lastH~=H or lastL~=L or index == lastIndex then
             if lastBegin~=nil then
              O = source.open[lastBegin];
              C = source.close[lastEnd];
              m, pO = context:pointOfPrice(O);
              m, pH = context:pointOfPrice(lastH);
              m, pL = context:pointOfPrice(lastL);
              m, pC = context:pointOfPrice(C);
              MaxP, MinP = math.max(pO, pC), math.min(pO, pC);
              context:drawRectangle(1, -1, lastX1, pH, x1, pL);
              context:drawRectangle(-1, 2, lastX1, pO, x1, pC, BodyTransparency);
              context:drawRectangle(-1, 3, lastX1, MinP, x1, pH, UpShadowTransparency);
              context:drawRectangle(-1, 4, lastX1, MaxP, x1, pL, DnShadowTransparency);
             end
             lastBegin = beginIndex;
             lastH = H;
             lastL = L;
             lastX1 = x1;
            end
            lastEnd = endIndex;
            lastX2 = x2;
        end
        if lastBegin~=nil then
         O = source.open[lastBegin];
         C = source.close[lastEnd];
         m, pO = context:pointOfPrice(O);
         m, pH = context:pointOfPrice(lastH);
         m, pL = context:pointOfPrice(lastL);
         m, pC = context:pointOfPrice(C);
         MaxP, MinP = math.max(pO, pC), math.min(pO, pC);
         context:drawRectangle(1, -1, lastX1, pH, lastX2, pL);
         context:drawRectangle(-1, 2, lastX1, pO, lastX2, pC, BodyTransparency);
         context:drawRectangle(-1, 3, lastX1, MinP, lastX2, pH, UpShadowTransparency);
         context:drawRectangle(-1, 4, lastX1, MaxP, lastX2, pL, DnShadowTransparency);
        end
    end
end


