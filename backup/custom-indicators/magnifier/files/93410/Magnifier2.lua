--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
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
    indicator.parameters:addString("frame", "Timeframe", "", "D1");
    indicator.parameters:setFlag("frame", core.FLAG_PERIODS);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Band Color", "", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("transparency", "Band Transparency", "0 - opaque, 100 - transparent", 75, 0, 100);
    indicator.parameters:addColor("UPcolor", "UP Chart color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNcolor", "DN Chart color", "", core.rgb(255, 0, 0));
end

local source = nil;
local color;
local Type;
local src;
local loading;
local UPcolor, DNcolor;
local barSize, TradingDayOffset, TradingWeekOffset;
local transparency;

-- initializes the instance of the indicator
function Prepare(onlyName)
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end
    
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
end

function Update(period)
end

local init = false;

function AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == 300 then
     loading = true;
    elseif cookie == 400 then
     loading = false;
    end
end


function Draw(stage, context)
    if stage == 2 then
    
        if not init then
            context:createSolidBrush(1, color);
            context:createPen(3, context.SOLID, 1, UPcolor);
            context:createPen(4, context.SOLID, 1, DNcolor);
            context:createSolidBrush(5, UPcolor);
            context:createSolidBrush(6, DNcolor);
            transparency = context:convertTransparency(instance.parameters.transparency);
            init = true;
        end
        
        local top, bottom, left, right = context:top(), context:bottom(), context:left(), context:right();
        
        if loading then
         return;
        end
        
        local beginBar, endBar = src:first(), src:size()-1;
        local Xsize, Ysize = right-left, bottom-top;
        
        local beginChartDate, endChartDate = core.getcandle(barSize, source:date(math.min(context:lastBar(), source:size()-1)), TradingDayOffset, TradingWeekOffset);
        local beginChartDate = source:date(math.max(context:firstBar(), source:first()));
        local beginR, endR = core.findDate(src, beginChartDate, false), core.findDate(src, endChartDate, false);
        local beginX, endX = left+Xsize*(0.9*(beginR-beginBar)/(endBar+1-beginBar)+0.05), left+Xsize*(0.9*(endR+1-beginBar)/(endBar-beginBar)+0.05);
        context:drawRectangle(-1, 1, beginX, top, endX, bottom, transparency);
        
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



