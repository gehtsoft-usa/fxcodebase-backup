-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60499

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Draw tick chart");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addGroup("Price Parameters");
    indicator.parameters:addString("Type", "Type", "", "5");
    indicator.parameters:addStringAlternative("Type", "Line (open)", "", "0");
    indicator.parameters:addStringAlternative("Type", "Line (close)", "", "1");
    indicator.parameters:addStringAlternative("Type", "Line (high)", "", "2");
    indicator.parameters:addStringAlternative("Type", "Line (low)", "", "3");
    indicator.parameters:addStringAlternative("Type", "Bar", "", "4");
    indicator.parameters:addStringAlternative("Type", "Candlestick", "", "5");
    indicator.parameters:addStringAlternative("Type", "Quadrangle", "", "6");
    indicator.parameters:addString("instrument", "Instrument", "", "EUR/USD");
    indicator.parameters:setFlag("instrument", core.FLAG_INSTRUMENTS);
    indicator.parameters:addString("frame", "Timeframe", "", "m1");
    indicator.parameters:setFlag("frame", core.FLAG_PERIODS);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addInteger("VScale", "Vertical scale", "Vertical scale", 20, 10, 50);
    indicator.parameters:addInteger("HScale", "Horizontal scale", "Horizontal scale", 20, 10, 50);
    indicator.parameters:addInteger("NBars", "Number of bars", "Number of bars", 10);
    indicator.parameters:addColor("Fcolor", "Frame color", "", core.rgb(255, 255, 0));
    indicator.parameters:addColor("UPcolor", "UP Chart color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNcolor", "DN Chart color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("transparency", "transparency", "", 50);
end

local source = nil;
local color;
local transparency;
local VScale;
local HScale;
local Fcolor;
local UPcolor, DNcolor;
local NBars;
local Xcorner, Ycorner;
local src;
local loading;
local frame;
local Type;
local Ticks;
local Description;

-- initializes the instance of the indicator
function Prepare(onlyName)
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end

    instance:ownerDrawn(true);
    
    VScale = instance.parameters.VScale/100;
    HScale = instance.parameters.HScale/100;
    Fcolor = instance.parameters.Fcolor;
    UPcolor = instance.parameters.UPcolor;
    DNcolor = instance.parameters.DNcolor;
    NBars = instance.parameters.NBars;
    frame = instance.parameters.frame;
    Type = tonumber(instance.parameters.Type);
    Ticks = frame=="t1";
    instance:setLabelColor(Fcolor);
    Xcorner, Ycorner=50, 50;
    src = core.host:execute("getSyncHistory", instance.parameters.instrument, instance.parameters.frame, instance.source:isBid(), NBars, 200, 100);
    loading = true;
    core.host:execute("addCommand", 1000, "Move here", "Move here");
    Description = instance.parameters.instrument .. " " .. instance.parameters.frame;
end

function Update(period)
end

local init = false;

function AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == 1000 then   
     local t, c;
     t, c = core.parseCsv(message, ";");
     if c >= 4 then
      Xcorner = tonumber(t[2]);
      Ycorner = tonumber(t[3]);
     end 
    elseif cookie == 100 then
     loading=true;
    elseif cookie == 200 then
     loading=false;
    end
end


function Draw(stage, context)
    if stage == 2 then
    
        if not init then
            context:createPen(1, context.SOLID, 1, Fcolor);
            context:createPen(2, context.SOLID, 1, UPcolor);
            context:createPen(3, context.SOLID, 1, DNcolor);
            context:createSolidBrush(4, UPcolor);
            context:createSolidBrush(5, DNcolor);
            context:createFont(6, "Arial", 0, -context:pointsToPixels(source:pipSize()), 0);
            init = true;
			transparency=context:convertTransparency (instance.parameters.transparency);
        end
        
        if loading then
         return;
        end
        
        local top, bottom, left, right = context:top(), context:bottom(), context:left(), context:right();
        
        local Xsize, Ysize = (right-left)*HScale, (bottom-top)*VScale;
        if Xcorner+Xsize>right then
         Xcorner=right-Xsize;
        end
        if Ycorner+Ysize>bottom then
         Ycorner=bottom-Ysize;
        end
        
        context:drawRectangle(1, -1, Xcorner, Ycorner, Xcorner+Xsize, Ycorner+Ysize);
        context:drawText(6, Description, Fcolor, -1, Xcorner, Ycorner, Xcorner+Xsize, Ycorner+Ysize, context.LEFT);
        local size=src:size()-1;
        local first=math.max(src:first(),size-NBars+1);
        local points = context:createPoints();
        
        local min, max = mathex.minmax(src, first, size);
        
        local i;
        if Ticks or Type<4 then
         local Price;
         local Tsrc;
         if Ticks then
          Tsrc=src;
         elseif Type==0 then
          Tsrc=src.open;
         elseif Type==1 then
          Tsrc=src.close;
         elseif Type==2 then
          Tsrc=src.high;
         else
          Tsrc=src.low;
         end
         local x, y;
         for i=first,size,1 do
          Price = Tsrc[i];
          x = Xcorner+Xsize*(0.9*(i-first)/(size-first)+0.05);
          y = Ycorner+Ysize*(0.9*(max-Price)/(max-min)+0.05);
          points:add(x,y);
         end
         context:drawPolyline(2, points,transparency);
	elseif Type==4 then
         local O, H, L, C;
         local yO, yH, yL, yC;
         local x1, x2, xc;
         local xD;
         local SumVolume = mathex.sum(src.volume, first, size);
         local X1Volume = Xsize*0.9/SumVolume;
         local Xstart=Xcorner+0.05*Xsize;
         for i=first,size,1 do
          O, H, L, C = src.open[i], src.high[i], src.low[i], src.close[i];
          x1 = Xstart;
          x2 = x1+src.volume[i]*X1Volume;
          Xstart = x2;
          xc=(x1+x2)/2;
          xD=(x2-x1)/3;
          yO = Ycorner+Ysize*(0.9*(max-O)/(max-min)+0.05);
          yH = Ycorner+Ysize*(0.9*(max-H)/(max-min)+0.05);
          yL = Ycorner+Ysize*(0.9*(max-L)/(max-min)+0.05);
          yC = Ycorner+Ysize*(0.9*(max-C)/(max-min)+0.05);
          if C>=O then
           context:drawLine(2, xc, yH, xc, yL,transparency);
           context:drawLine(2, xc-xD, yO, xc, yO,transparency);
           context:drawLine(2, xc, yC, xc+xD, yC,transparency);
          else
           context:drawLine(3, xc, yH, xc, yL,transparency);
           context:drawLine(3, xc-xD, yO, xc, yO,transparency);
           context:drawLine(3, xc, yC, xc+xD, yC,transparency);
	  end 
         end
	elseif Type==5 then  
         local O, H, L, C;
         local yO, yH, yL, yC;
         local x1, x2, xc;
         local xD;
         local SumVolume = mathex.sum(src.volume, first, size);
         local X1Volume = Xsize*0.9/SumVolume;
         local Xstart=Xcorner+0.05*Xsize;
         for i=first,size,1 do
          O, H, L, C = src.open[i], src.high[i], src.low[i], src.close[i];
          x1 = Xstart;
          x2 = x1+src.volume[i]*X1Volume;
          Xstart = x2;
          xc=(x1+x2)/2;
          xD=(x2-x1)/3;
          yO = Ycorner+Ysize*(0.9*(max-O)/(max-min)+0.05);
          yH = Ycorner+Ysize*(0.9*(max-H)/(max-min)+0.05);
          yL = Ycorner+Ysize*(0.9*(max-L)/(max-min)+0.05);
          yC = Ycorner+Ysize*(0.9*(max-C)/(max-min)+0.05);
          if C>O then
           context:drawLine(2, xc, yH, xc, yL,transparency);
           context:drawRectangle(2, 4, xc-xD, yO, xc+xD, yC,transparency);
          elseif C<O then
           context:drawLine(3, xc, yH, xc, yL,transparency);
           context:drawRectangle(3, 5, xc-xD, yO, xc+xD, yC,transparency);
          else
           context:drawLine(2, xc, yH, xc, yL,transparency);
           context:drawLine(2, xc-xD, yO, xc+xD, yO,transparency);
	  end 
         end
        else
         local O, H, L, C;
         local yO, yH, yL, yC;
         local x1, x2, xc;
         local SumVolume = mathex.sum(src.volume, first, size);
         local X1Volume = Xsize*0.9/SumVolume;
         local Xstart=Xcorner+0.05*Xsize;
         for i=first,size,1 do
          O, H, L, C = src.open[i], src.high[i], src.low[i], src.close[i];
          x1 = Xstart;
          x2 = x1+src.volume[i]*X1Volume;
          Xstart = x2;
          xc=(x1+x2)/2;
          yO = Ycorner+Ysize*(0.9*(max-O)/(max-min)+0.05);
          yH = Ycorner+Ysize*(0.9*(max-H)/(max-min)+0.05);
          yL = Ycorner+Ysize*(0.9*(max-L)/(max-min)+0.05);
          yC = Ycorner+Ysize*(0.9*(max-C)/(max-min)+0.05);
          points = context:createPoints();
          points:add(x1,yO);
          points:add(xc,yH);
          points:add(x2,yC);
          points:add(xc,yL);
          if C>=O then
           context:drawPolygon(2, 4, points,transparency);
          else
	   context:drawPolygon(3, 5, points,transparency);
	  end 
         end
	  
	end 

    end
end



