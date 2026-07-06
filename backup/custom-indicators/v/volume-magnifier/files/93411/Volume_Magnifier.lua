-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60510
-- Id: 11482

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Volume magnifier");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Price Parameters");
    indicator.parameters:addString("frame", "Timeframe", "", "m1");
    indicator.parameters:setFlag("frame", core.FLAG_PERIODS);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Arrow Color", "", core.rgb(128, 255, 255));
    indicator.parameters:addBoolean("ColorMode", "ColorMode", "", true);
    indicator.parameters:addColor("Zcolor", "Zone color", "", core.rgb(128, 255, 255));
    indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 75, 0, 100);
    indicator.parameters:addColor("MainClr", "Main color", "Main color", core.rgb(128, 128, 0));
    indicator.parameters:addColor("UPcolor", "UP Chart color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNcolor", "DN Chart color", "", core.rgb(255, 0, 0));
end

local source = nil;
local color;
local x1m, x2m;
local src;
local loading;
local ColorMode;
local UPcolor, DNcolor, MainClr, Zcolor;
local barSize, TradingDayOffset, TradingWeekOffset;
local arrow;

-- initializes the instance of the indicator
function Prepare(onlyName)
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end
    
    arrow = "\241";

    barSize = instance.source:barSize();
    TradingDayOffset = core.host:execute("getTradingDayOffset");
    TradingWeekOffset = core.host:execute("getTradingWeekOffset");

    instance:ownerDrawn(true);
    instance:drawOnMainChart(true);
    src = core.host:execute("getSyncHistory", instance.source:instrument(), instance.parameters.frame, instance.source:isBid(), 0, 400, 300);
    loading = true;
    
    color = instance.parameters.color;
    Zcolor = instance.parameters.Zcolor;
    MainClr = instance.parameters.MainClr;
    ColorMode = instance.parameters.ColorMode;
    UPcolor = instance.parameters.UPcolor;
    DNcolor = instance.parameters.DNcolor;
    Type = tonumber(instance.parameters.Type);
    instance:setLabelColor(color);
    core.host:execute("addCommand", 100, "Move start point here", "Move start point here");
    core.host:execute("addCommand", 200, "Move end point here", "Move end point here");
end

function Update(period)
end

local init = false;

function AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == 100 then
     local t, c;
     t, c = core.parseCsv(message, ";");
     if c >= 4 then
      local x1m_new = tonumber(t[2]);
      if x1m_new<x2m then
       x1m=x1m_new;
      elseif x1m_new>x2m then
       x1m=x2m;
       x2m=x1m_new;
      end
     end 
    elseif cookie == 200 then   
     local t, c;
     t, c = core.parseCsv(message, ";");
     if c >= 4 then
      local x2m_new = tonumber(t[2]);
      if x2m_new>x1m then
       x2m=x2m_new;
      elseif x2m_new<x1m then
       x2m=x1m;
       x1m=x2m_new;
      end
     end 
    elseif cookie == 300 then
     loading = true;
    elseif cookie == 400 then
     loading = false;
    end
end


function Draw(stage, context)
    if stage == 2 then
    
        if not init then
            context:createFont(2, "Wingdings", 0, -context:pointsToPixels(source:pipSize()), 0);
            if ColorMode then
             context:createPen(3, context.SOLID, 1, UPcolor);
             context:createPen(4, context.SOLID, 1, DNcolor);
             context:createSolidBrush(5, UPcolor);
             context:createSolidBrush(6, DNcolor);
            else
             context:createPen(3, context.SOLID, 1, MainClr);
             context:createPen(4, context.SOLID, 1, MainClr);
             context:createSolidBrush(5, MainClr);
             context:createSolidBrush(6, MainClr);
            end
            local left, right = context:left(), context:right();
            local middle = (left+right)/2;
            local range = (right-left)/2;
            x1m, x2m = middle-range/5, middle+range/5;
            init = true;
        end
        
        local top, bottom, left, right = context:top(), context:bottom(), context:left(), context:right();
        local w, h = context:measureText(2, arrow, context.LEFT);
        context:drawText(2, arrow, color, -1, x1m-w/2, top, x1m+w/2, top+h, context.CENTER);
        context:drawText(2, arrow, color, -1, x2m-w/2, top, x2m+w/2, top+h, context.CENTER);
        
        if loading then
         return;
        end
        
        local beginIndex, endIndex = context:indexOfBar(x1m), context:indexOfBar(x2m);
        local first, last = source:first(), source:size()-1;
        if endIndex<first or beginIndex>last then
         return;
        end
        beginIndex=math.max(math.min(beginIndex, last), first);
        endIndex=math.max(math.min(endIndex, last), first);
        local beginDate, endDate = core.getcandle(barSize, source:date(endIndex), TradingDayOffset, TradingWeekOffset);
        beginDate = source:date(beginIndex);
        
        local beginBar, endBar = core.findDate(src, beginDate, false), core.findDate(src, endDate, false);
        
        if beginBar==-1 or endBar==-1 then
         return;
        end
        
        if src:date(endBar) == endDate then
         endBar = endBar-1;
        end 
        
        local Xsize, Ysize = right-left, bottom-top;

        local points = context:createPoints();
        
        local min, max = 0, mathex.max(src.volume, beginBar, endBar);
        
        local i;
        
        local x1, x2, xc, xD, y1, y2;
        
        for i=beginBar,endBar,1 do
         x1 = left+Xsize*(0.9*(i-beginBar)/(endBar+1-beginBar)+0.05);
         x2 = left+Xsize*(0.9*(i-beginBar+1)/(endBar+1-beginBar)+0.05);
         xc=(x1+x2)/2;
         xD=(x2-x1)/3;
         y1 = top+Ysize*(0.9*max/(max-min)+0.05);
         y2 = top+Ysize*(0.9*(max-src.volume[i])/(max-min)+0.05);
         
         if src.volume[i]>=src.volume[i-1] then
          context:drawRectangle(3, 5, xc-xD, y1, xc+xD, y2);
         else
	  context:drawRectangle(4, 6, xc-xD, y1, xc+xD, y2);
	 end 
        end 
    elseif stage == 100 then
        if not init100 then
            context:createSolidBrush(1, Zcolor);
            transparency = context:convertTransparency(instance.parameters.transparency);
            init100 = true;
        end
        if x1m~=nil and x2m~=nil then
         context:drawRectangle(-1, 1, x1m, context:top(), x2m, context:bottom(), transparency);
        end 

    end
end



