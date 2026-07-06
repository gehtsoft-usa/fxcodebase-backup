-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=58743

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Magnifier");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Price Parameters");
    indicator.parameters:addString("Type", "Type", "", "5");
    indicator.parameters:addStringAlternative("Type", "Line (open)", "", "0");
    indicator.parameters:addStringAlternative("Type", "Line (close)", "", "1");
    indicator.parameters:addStringAlternative("Type", "Line (high)", "", "2");
    indicator.parameters:addStringAlternative("Type", "Line (low)", "", "3");
    indicator.parameters:addStringAlternative("Type", "Bar", "", "4");
    indicator.parameters:addStringAlternative("Type", "Candlestick", "", "5");
    indicator.parameters:addStringAlternative("Type", "Quadrangle", "", "6");
    indicator.parameters:addString("frame", "Timeframe", "", "m1");
    indicator.parameters:setFlag("frame", core.FLAG_PERIODS);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Arrow Color", "", core.rgb(128, 255, 255));
    indicator.parameters:addColor("UPcolor", "UP Chart color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNcolor", "DN Chart color", "", core.rgb(255, 0, 0));
end

local source = nil;
local color;
local x1m, x2m;
local Type;
local src;
local loading;
local UPcolor, DNcolor;
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
    src = core.host:execute("getSyncHistory", instance.source:instrument(), instance.parameters.frame, instance.source:isBid(), 0, 400, 300);
    loading = true;
    
    color = instance.parameters.color;
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
            context:createPen(3, context.SOLID, 1, UPcolor);
            context:createPen(4, context.SOLID, 1, DNcolor);
            context:createSolidBrush(5, UPcolor);
            context:createSolidBrush(6, DNcolor);
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
        
        local min, max = mathex.minmax(src, beginBar, endBar);
        
        local i;
        if Type<4 then
         local Price;
         local Tsrc;
         if Type==0 then
          Tsrc=src.open;
         elseif Type==1 then
          Tsrc=src.close;
         elseif Type==2 then
          Tsrc=src.high;
         else
          Tsrc=src.low;
         end
         local x, y;
         for i=beginBar,endBar,1 do
          Price = Tsrc[i];
          x = left+Xsize*(0.9*(i-beginBar)/(endBar-beginBar)+0.05);
          y = top+Ysize*(0.9*(max-Price)/(max-min)+0.05);
          points:add(x,y);
         end
         context:drawPolyline(3, points);
	elseif Type==4 then
         local O, H, L, C;
         local yO, yH, yL, yC;
         local x1, x2, xc;
         local xD;
         for i=beginBar,endBar,1 do
          O, H, L, C = src.open[i], src.high[i], src.low[i], src.close[i];
          x1 = left+Xsize*(0.9*(i-beginBar)/(endBar+1-beginBar)+0.05);
          x2 = left+Xsize*(0.9*(i-beginBar+1)/(endBar+1-beginBar)+0.05);
          xc=(x1+x2)/2;
          xD=(x2-x1)/3;
          yO = top+Ysize*(0.9*(max-O)/(max-min)+0.05);
          yH = top+Ysize*(0.9*(max-H)/(max-min)+0.05);
          yL = top+Ysize*(0.9*(max-L)/(max-min)+0.05);
          yC = top+Ysize*(0.9*(max-C)/(max-min)+0.05);
          if C>=O then
           context:drawLine(3, xc, yH, xc, yL);
           context:drawLine(3, xc-xD, yO, xc, yO);
           context:drawLine(3, xc, yC, xc+xD, yC);
          else
           context:drawLine(4, xc, yH, xc, yL);
           context:drawLine(4, xc-xD, yO, xc, yO);
           context:drawLine(4, xc, yC, xc+xD, yC);
	  end 
         end
	elseif Type==5 then  
         local O, H, L, C;
         local yO, yH, yL, yC;
         local x1, x2, xc;
         local xD;
         for i=beginBar,endBar,1 do
          O, H, L, C = src.open[i], src.high[i], src.low[i], src.close[i];
          x1 = left+Xsize*(0.9*(i-beginBar)/(endBar+1-beginBar)+0.05);
          x2 = left+Xsize*(0.9*(i-beginBar+1)/(endBar+1-beginBar)+0.05);
          xc=(x1+x2)/2;
          xD=(x2-x1)/3;
          yO = top+Ysize*(0.9*(max-O)/(max-min)+0.05);
          yH = top+Ysize*(0.9*(max-H)/(max-min)+0.05);
          yL = top+Ysize*(0.9*(max-L)/(max-min)+0.05);
          yC = top+Ysize*(0.9*(max-C)/(max-min)+0.05);
          if C>O then
           context:drawLine(3, xc, yH, xc, yL);
           context:drawRectangle(3, 5, xc-xD, yO, xc+xD, yC);
          elseif C<O then
           context:drawLine(4, xc, yH, xc, yL);
           context:drawRectangle(4, 6, xc-xD, yO, xc+xD, yC);
          else
           context:drawLine(3, xc, yH, xc, yL);
           context:drawLine(3, xc-xD, yO, xc+xD, yO);
	  end 
         end
        else
         local O, H, L, C;
         local yO, yH, yL, yC;
         local x1, x2, xc;
         for i=beginBar,endBar,1 do
          O, H, L, C = src.open[i], src.high[i], src.low[i], src.close[i];
          x1 = left+Xsize*(0.9*(i-beginBar)/(endBar+1-beginBar)+0.05);
          x2 = left+Xsize*(0.9*(i-beginBar+1)/(endBar+1-beginBar)+0.05);
          xc=(x1+x2)/2;
          yO = top+Ysize*(0.9*(max-O)/(max-min)+0.05);
          yH = top+Ysize*(0.9*(max-H)/(max-min)+0.05);
          yL = top+Ysize*(0.9*(max-L)/(max-min)+0.05);
          yC = top+Ysize*(0.9*(max-C)/(max-min)+0.05);
          points = context:createPoints();
          points:add(x1,yO);
          points:add(xc,yH);
          points:add(x2,yC);
          points:add(xc,yL);
          if C>=O then
           context:drawPolygon(3, 5, points);
          else
	   context:drawPolygon(4, 6, points);
	  end 
         end
	  
	end 
    end
end



