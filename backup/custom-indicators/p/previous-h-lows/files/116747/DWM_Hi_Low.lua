-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65506

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
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
    indicator:name("DWM_Hi_Low");
    indicator:description("DWM_Hi_Low");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("CountDays", "Count days", "Count days", 10);
    indicator.parameters:addBoolean("ShowCurrD", "Show current daily", "Show current daily", true);
    indicator.parameters:addBoolean("ShowCurrW", "Show current weekly", "Show current weekly", true);
    indicator.parameters:addBoolean("ShowCurrM", "Show current monthly", "Show current monthly", true);
    indicator.parameters:addBoolean("ShowPrevD", "Show previous daily", "Show previous daily", true);
    indicator.parameters:addBoolean("ShowPrevW", "Show previous weekly", "Show previous weekly", true);
    indicator.parameters:addBoolean("ShowPrevM", "Show previous monthly", "Show previous monthly", true);


    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("CurrDUclr", "Current daily upper color", "Current daily upper color", core.rgb(128, 128, 0));
    indicator.parameters:addColor("CurrDLclr", "Current daily lower color", "Current daily lower color", core.rgb(255, 255, 0));
    indicator.parameters:addColor("CurrWUclr", "Current weekly upper color", "Current weekly upper color", core.rgb(0, 128, 128));
    indicator.parameters:addColor("CurrWLclr", "Current weekly lower color", "Current weekly lower color", core.rgb(0, 255, 255));
    indicator.parameters:addColor("CurrMUclr", "Current monthly upper color", "Current monthly upper color", core.rgb(128, 0, 128));
    indicator.parameters:addColor("CurrMLclr", "Current monthly lower color", "Current monthly lower color", core.rgb(255, 0, 255));
    indicator.parameters:addInteger("CurrDwidth", "Current daily width", "Current daily width", 1, 1, 5);
    indicator.parameters:addInteger("CurrDstyle", "Current daily style", "Current daily style", core.LINE_SOLID);
    indicator.parameters:setFlag("CurrDstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("CurrWwidth", "Current weekly width", "Current weekly width", 1, 1, 5);
    indicator.parameters:addInteger("CurrWstyle", "Current weekly style", "Current weekly style", core.LINE_SOLID);
    indicator.parameters:setFlag("CurrWstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("CurrMwidth", "Current monthly width", "Current monthly width", 1, 1, 5);
    indicator.parameters:addInteger("CurrMstyle", "Current monthly style", "Current monthly style", core.LINE_SOLID);
    indicator.parameters:setFlag("CurrMstyle", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("PrevDclr", "Previous daily color", "Previous daily color", core.rgb(0, 0, 128));
    indicator.parameters:addColor("PrevWclr", "Previous weekly color", "Previous weekly color", core.rgb(0, 128, 0));
    indicator.parameters:addColor("PrevMclr", "Previous monthly color", "Previous monthly color", core.rgb(128, 0, 0));
    indicator.parameters:addInteger("PrevDwidth", "Previous daily width", "Previous daily width", 1, 1, 5);
    indicator.parameters:addInteger("PrevDstyle", "Previous daily style", "Previous daily style", core.LINE_SOLID);
    indicator.parameters:setFlag("PrevDstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("PrevWwidth", "Previous weekly width", "Previous weekly width", 1, 1, 5);
    indicator.parameters:addInteger("PrevWstyle", "Previous weekly style", "Previous weekly style", core.LINE_SOLID);
    indicator.parameters:setFlag("PrevWstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("PrevMwidth", "Previous monthly width", "Previous monthly width", 1, 1, 5);
    indicator.parameters:addInteger("PrevMstyle", "Previous monthly style", "Previous monthly style", core.LINE_SOLID);
    indicator.parameters:setFlag("PrevMstyle", core.FLAG_LINE_STYLE);

    indicator.parameters:addInteger("FontSize", "Font size", "0 - default", 0);
end

local source = nil;
local first;
local color;
local CountDays;
local ShowCurrD, ShowCurrW, ShowCurrM;
local ShowPrevD, ShowPrevW, ShowPrevM;
local L, H={}, {};
local BS, BE={}, {};
local WeekL0, WeekL1, WeekH0, WeekH1;
local WeekBS0, WeekBS1, WeekBE0, WeekBE1;
local MonthL0, MonthL1, MonthH0, MonthH1;
local MonthBS0, MonthBS1, MonthBE0, MonthBE1;

-- initializes the instance of the indicator
function Prepare(nameOnly) 
    source = instance.source;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    instance:ownerDrawn(true);
    
    CountDays = instance.parameters.CountDays;

    ShowCurrD = instance.parameters.ShowCurrD; 
    ShowCurrW = instance.parameters.ShowCurrW; 
    ShowCurrM = instance.parameters.ShowCurrM; 

    ShowPrevD = instance.parameters.ShowPrevD; 
    ShowPrevW = instance.parameters.ShowPrevW; 
    ShowPrevM = instance.parameters.ShowPrevM; 

    color = instance.parameters.CurrDUclr;
    instance:setLabelColor(color);
end

function CalcDayHL(D)
    local StartB, EndB;
    local StartD, EndD=math.floor(D), math.floor(D)+1;
    StartB=core.findDate(source, StartD, false);

    EndB=core.findDate(source, EndD, false);
    if EndB<source:size()-1 then
        EndB=EndB-1;
    end

    if StartB<first or StartB>EndB then
        return nil, nil, nil, nil;
    end

    local MinPr, MaxPr=mathex.minmax(source, StartB, EndB);

    return MaxPr, MinPr, StartB, EndB;
end

function CalcWeekHL(D)
    local StartB, EndB;
    local T=core.dateToTable(D);
    local StartD=math.floor(D)-T.wday+1;
    local EndD=StartD+7;
    StartB=core.findDate(source, StartD, false);

    EndB=core.findDate(source, EndD, false);
    if EndB<source:size()-1 then
        EndB=EndB-1;
    end

    if StartB<first or StartB>EndB then
        return nil, nil, nil, nil;
    end

    local MinPr, MaxPr=mathex.minmax(source, StartB, EndB);

    return MaxPr, MinPr, StartB, EndB;
end

function CalcMonthHL(D)
    local StartB, EndB;
    local T=core.dateToTable(D);
    local StartD=math.floor(D)-T.day+1;
    T=core.dateToTable(StartD);
    T.month=T.month+1;
    if T.month>12 then
        T.month=1;
        T.year=T.year+1;
    end
    local EndD=core.tableToDate(T);
    StartB=core.findDate(source, StartD, false);

    EndB=core.findDate(source, EndD, false);
    if EndB<source:size()-1 then
        EndB=EndB-1;
    end

    if StartB<first or StartB>EndB then
        return nil, nil, nil, nil;
    end

    local MinPr, MaxPr=mathex.minmax(source, StartB, EndB);

    return MaxPr, MinPr, StartB, EndB;
end

function Update(period)
    if period==source:size()-1 then
        local i;
        for i=0, CountDays, 1 do
            H[i], L[i], BS[i], BE[i]=CalcDayHL(source:date(period)-i);
        end
        WeekH0, WeekL0, WeekBS0, WeekBE0=CalcWeekHL(source:date(period)); 
        WeekH1, WeekL1, WeekBS1, WeekBE1=CalcWeekHL(source:date(period)-7); 

        MonthH0, MonthL0, MonthBS0, MonthBE0=CalcMonthHL(source:date(period)); 
        local T=core.dateToTable(source:date(period));
        MonthH1, MonthL1, MonthBS1, MonthBE1=CalcMonthHL(source:date(period)-T.day); 
    end
end

local init = false;

function Draw(stage, context)
    if stage == 0 then
    
        if not init then
            context:createPen(1, context:convertPenStyle(instance.parameters.CurrDstyle), instance.parameters.CurrDwidth, instance.parameters.CurrDUclr);
            context:createPen(2, context:convertPenStyle(instance.parameters.CurrDstyle), instance.parameters.CurrDwidth, instance.parameters.CurrDLclr);
            context:createPen(3, context:convertPenStyle(instance.parameters.CurrWstyle), instance.parameters.CurrWwidth, instance.parameters.CurrWUclr);
            context:createPen(4, context:convertPenStyle(instance.parameters.CurrWstyle), instance.parameters.CurrWwidth, instance.parameters.CurrWLclr);
            context:createPen(5, context:convertPenStyle(instance.parameters.CurrMstyle), instance.parameters.CurrMwidth, instance.parameters.CurrMUclr);
            context:createPen(6, context:convertPenStyle(instance.parameters.CurrMstyle), instance.parameters.CurrMwidth, instance.parameters.CurrMLclr);

            context:createPen(7, context:convertPenStyle(instance.parameters.PrevDstyle), instance.parameters.PrevDwidth, instance.parameters.PrevDclr);
            context:createPen(8, context:convertPenStyle(instance.parameters.PrevWstyle), instance.parameters.PrevWwidth, instance.parameters.PrevWclr);
            context:createPen(9, context:convertPenStyle(instance.parameters.PrevMstyle), instance.parameters.PrevMwidth, instance.parameters.PrevMclr);

            if instance.parameters.FontSize==0 then
              context:createFont(30, "Arial", 0, -context:pointsToPixels(source:pipSize()), 0);
            else  
              context:createFont(30, "Arial", 0, instance.parameters.FontSize, 0);
            end

            init = true;
        end

        local firstBar, lastBar=context:firstBar(), context:lastBar();
        local top, bottom, left, right=context:top(), context:bottom(), context:left(), context:right();
        local B1, B2;
        local i;
        local x1, x2, y, v;
        local Str;
        local w, h;

        context:setClipRectangle(left, top, right, bottom);

        if ShowCurrD and BS[0]~=nil then
            if BE[0]>firstBar and BS[0]<lastBar then
                B1=math.max(BS[0], firstBar);
                B2=math.min(BE[0], lastBar);
                x1=context:positionOfBar(B1);
                x2=context:positionOfBar(B2);
                v, y=context:pointOfPrice(H[0]);
                if y>=top and y<=bottom then
                    context:drawLine(1, x1, y, x2, y);
                    Str="Daily High " .. H[0];
                    w, h=context:measureText(30, Str, context.LEFT);
                    context:drawText(30, Str, instance.parameters.CurrDUclr, -1, x1, y-h, x1+w, y, context.LEFT);
                end

                v, y=context:pointOfPrice(L[0]);
                if y>=top and y<=bottom then
                    context:drawLine(2, x1, y, x2, y);
                    Str="Daily Low " .. L[0];
                    w, h=context:measureText(30, Str, context.LEFT);
                    context:drawText(30, Str, instance.parameters.CurrDLclr, -1, x1, y-h, x1+w, y, context.LEFT);
                end

            end
        end

        if ShowPrevD and BS[1]~=nil then
            if BE[1]>firstBar and BS[1]<lastBar then
                B1=math.max(BS[1], firstBar);
                B2=math.min(BE[1], lastBar);
                x1=context:positionOfBar(B1);
                x2=context:positionOfBar(B2);
                v, y=context:pointOfPrice(H[1]);
                if y>=top and y<=bottom then
                    context:drawLine(7, x1, y, x2, y);
                    Str="Prev Daily High " .. H[1];
                    w, h=context:measureText(30, Str, context.LEFT);
                    context:drawText(30, Str, instance.parameters.PrevDclr, -1, x1, y-h, x1+w, y, context.LEFT);
                end

                v, y=context:pointOfPrice(L[1]);
                if y>=top and y<=bottom then
                    context:drawLine(7, x1, y, x2, y);
                    Str="Prev Daily Low " .. L[1];
                    w, h=context:measureText(30, Str, context.LEFT);
                    context:drawText(30, Str, instance.parameters.PrevDclr, -1, x1, y-h, x1+w, y, context.LEFT);
                end

            end
        end

        for i=2, CountDays, 1 do
            if BS[i]~=nil then
                if BE[i]>firstBar and BS[i]<lastBar then
                    B1=math.max(BS[i], firstBar);
                    B2=math.min(BE[i], lastBar);
                    x1=context:positionOfBar(B1);
                    x2=context:positionOfBar(B2);
                    v, y=context:pointOfPrice(H[i]);
                    if y>=top and y<=bottom then
                        context:drawLine(7, x1, y, x2, y);
                    end

                    v, y=context:pointOfPrice(L[i]);
                    if y>=top and y<=bottom then
                        context:drawLine(7, x1, y, x2, y);
                    end
                end
            end
        end

        if ShowCurrW and WeekH0~=nil then
            if WeekBE0>firstBar and WeekBS0<lastBar then
                B1=math.max(WeekBS0, firstBar);
                B2=math.min(WeekBE0, lastBar);
                x1=context:positionOfBar(B1);
                x2=context:positionOfBar(B2);
                v, y=context:pointOfPrice(WeekH0);
                if y>=top and y<=bottom then
                    context:drawLine(3, x1, y, x2, y);
                    Str="Weekly High " .. WeekH0;
                    w, h=context:measureText(30, Str, context.LEFT);
                    context:drawText(30, Str, instance.parameters.CurrWUclr, -1, x1, y-h, x1+w, y, context.LEFT);
                end

                v, y=context:pointOfPrice(WeekL0);
                if y>=top and y<=bottom then
                    context:drawLine(4, x1, y, x2, y);
                    Str="Weekly Low " .. WeekL0;
                    w, h=context:measureText(30, Str, context.LEFT);
                    context:drawText(30, Str, instance.parameters.CurrWLclr, -1, x1, y-h, x1+w, y, context.LEFT);
                end

            end
        end

        if ShowPrevW and WeekH1~=nil then
            if WeekBE1>firstBar and WeekBS1<lastBar then
                B1=math.max(WeekBS1, firstBar);
                B2=math.min(WeekBE1, lastBar);
                x1=context:positionOfBar(B1);
                x2=context:positionOfBar(B2);
                v, y=context:pointOfPrice(WeekH1);
                if y>=top and y<=bottom then
                    context:drawLine(8, x1, y, x2, y);
                    Str="Prev Weekly High " .. WeekH1;
                    w, h=context:measureText(30, Str, context.LEFT);
                    context:drawText(30, Str, instance.parameters.PrevWclr, -1, x1, y-h, x1+w, y, context.LEFT);
                end

                v, y=context:pointOfPrice(WeekL1);
                if y>=top and y<=bottom then
                    context:drawLine(8, x1, y, x2, y);
                    Str="Prev Weekly Low " .. WeekL1;
                    w, h=context:measureText(30, Str, context.LEFT);
                    context:drawText(30, Str, instance.parameters.PrevWclr, -1, x1, y-h, x1+w, y, context.LEFT);
                end

            end
        end

        if ShowCurrM and MonthH0~=nil then
            if MonthBE0>firstBar and MonthBS0<lastBar then
                B1=math.max(MonthBS0, firstBar);
                B2=math.min(MonthBE0, lastBar);
                x1=context:positionOfBar(B1);
                x2=context:positionOfBar(B2);
                v, y=context:pointOfPrice(MonthH0);
                if y>=top and y<=bottom then
                    context:drawLine(5, x1, y, x2, y);
                    Str="Monthly High " .. MonthH0;
                    w, h=context:measureText(30, Str, context.LEFT);
                    context:drawText(30, Str, instance.parameters.CurrMUclr, -1, x1, y-h, x1+w, y, context.LEFT);
                end

                v, y=context:pointOfPrice(MonthL0);
                if y>=top and y<=bottom then
                    context:drawLine(6, x1, y, x2, y);
                    Str="Monthly Low " .. MonthL0;
                    w, h=context:measureText(30, Str, context.LEFT);
                    context:drawText(30, Str, instance.parameters.CurrMLclr, -1, x1, y-h, x1+w, y, context.LEFT);
                end

            end
        end

        if ShowPrevM and MonthH1~=nil then
            if MonthBE1>firstBar and MonthBS1<lastBar then
                B1=math.max(MonthBS1, firstBar);
                B2=math.min(MonthBE1, lastBar);
                x1=context:positionOfBar(B1);
                x2=context:positionOfBar(B2);
                v, y=context:pointOfPrice(MonthH1);
                if y>=top and y<=bottom then
                    context:drawLine(9, x1, y, x2, y);
                    Str="Prev Monthly High " .. MonthH1;
                    w, h=context:measureText(30, Str, context.LEFT);
                    context:drawText(30, Str, instance.parameters.PrevMclr, -1, x1, y-h, x1+w, y, context.LEFT);
                end

                v, y=context:pointOfPrice(MonthL1);
                if y>=top and y<=bottom then
                    context:drawLine(9, x1, y, x2, y);
                    Str="Prev Monthly Low " .. MonthL1;
                    w, h=context:measureText(30, Str, context.LEFT);
                    context:drawText(30, Str, instance.parameters.PrevMclr, -1, x1, y-h, x1+w, y, context.LEFT);
                end

            end
        end

        context:resetClipRectangle();

    end
end



