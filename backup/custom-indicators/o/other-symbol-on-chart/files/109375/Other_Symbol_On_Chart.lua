-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64165

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
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
    indicator:name("Other symbol on chart");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("instrument", "Instrument", "", "EUR/JPY");
    indicator.parameters:setFlag("instrument", core.FLAG_INSTRUMENTS);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addString("Position", "Position", "", "2");
    indicator.parameters:addStringAlternative("Position", "Under chart", "", "0");
    indicator.parameters:addStringAlternative("Position", "Over chart", "", "2");
    indicator.parameters:addString("Type", "Type", "", "5");
    indicator.parameters:addStringAlternative("Type", "Line (open)", "", "0");
    indicator.parameters:addStringAlternative("Type", "Line (close)", "", "1");
    indicator.parameters:addStringAlternative("Type", "Line (high)", "", "2");
    indicator.parameters:addStringAlternative("Type", "Line (low)", "", "3");
    indicator.parameters:addStringAlternative("Type", "Bar", "", "4");
    indicator.parameters:addStringAlternative("Type", "Candlestick", "", "5");
    indicator.parameters:addStringAlternative("Type", "Quadrangle", "", "6");
    indicator.parameters:addColor("UPcolor", "UP Chart color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNcolor", "DN Chart color", "", core.rgb(255, 0, 0));
	
	 indicator.parameters:addInteger("transparency", "transparency", "", 50);
end

local source = nil;
local instrument;
local UPcolor, DNcolor;
local Type;
local Position;
local src;
local loading;
local transparency;
-- initializes the instance of the indicator
function Prepare(onlyName)
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end
    instrument = instance.parameters.instrument;
    UPcolor = instance.parameters.UPcolor;
    DNcolor = instance.parameters.DNcolor;
    Type = tonumber(instance.parameters.Type);
    Position = tonumber(instance.parameters.Position);

    instance:ownerDrawn(true);
    src = core.host:execute("getSyncHistory", instrument, source:barSize(), source:isBid(), 0, 200, 100);
    loading = true;
    
    instance:setLabelColor(UPcolor);
end

function Update(period)
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
 if cookie == 100 then
  loading=true;
 elseif cookie == 200 then
  loading=false;
 end
end


local init = false;

function Draw(stage, context)
    if stage == Position then
    
        if not init then
            context:createPen(1, context.SOLID, 1, UPcolor);
            context:createPen(2, context.SOLID, 1, DNcolor);
            context:createSolidBrush(3, UPcolor);
            context:createSolidBrush(4, DNcolor);
            init = true;
			
			transparency=context:convertTransparency (instance.parameters.transparency);
        end

        if loading then
         return;
        end
        
        local top, bottom, left, right = context:top(), context:bottom(), context:left(), context:right();
        local firstBar, lastBar = context:firstBar(), context:lastBar();
        firstBar = math.max(firstBar, source:first());
        lastBar = math.min(lastBar, source:size()-1);
        local firstBar2, lastBar2 = core.findDate(src, source:date(firstBar), false), core.findDate(src, source:date(lastBar), false);
        local MinW, MaxW;
        local x, x1, x2 = context:positionOfBar(firstBar);
        MinW = x1;
        x, x1, x2 = context:positionOfBar(lastBar);
        MaxW = x2;
        local MinPs, MaxPs = mathex.minmax(source, firstBar, lastBar);
        local v, MinP0, MaxP0;
        v, MinP0 = context:pointOfPrice(MinPs);
        v, MaxP0 = context:pointOfPrice(MaxPs);
        context:setClipRectangle(left, top, right, bottom);
        local i;
        
        if Type<4 then  
         local points = context:createPoints();
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
         local MinP, MaxP = mathex.minmax(Tsrc, firstBar2, lastBar2);
         local x, y;
         for i=firstBar2, lastBar2, 1 do
          x = (i-firstBar2)/(lastBar2-firstBar2)*(MaxW-MinW)+MinW;
          y = (Tsrc[i]-MinP)/(MaxP-MinP)*(MaxP0-MinP0)+MinP0;
          points:add(x,y);
         end
         context:drawPolyline(1, points,transparency);
        elseif Type==4 then
         local O, H, L, C;
         local yO, yH, yL, yC;
         local x1, x2, xc;
         local xD;
         local MinP, MaxP = mathex.minmax(src, firstBar2, lastBar2);
         for i=firstBar2, lastBar2, 1 do
          O, H, L, C = src.open[i], src.high[i], src.low[i], src.close[i];
          x1 = MinW+(MaxW-MinW)*((i-firstBar2)/(lastBar2+1-firstBar2));
          x2 = MinW+(MaxW-MinW)*((i-firstBar2+1)/(lastBar2+1-firstBar2));
          xc=(x1+x2)/2;
          xD=(x2-x1)/3;
          yO = (O-MinP)/(MaxP-MinP)*(MaxP0-MinP0)+MinP0;
          yH = (H-MinP)/(MaxP-MinP)*(MaxP0-MinP0)+MinP0;
          yL = (L-MinP)/(MaxP-MinP)*(MaxP0-MinP0)+MinP0;
          yC = (C-MinP)/(MaxP-MinP)*(MaxP0-MinP0)+MinP0;
          if C>=O then
           context:drawLine(1, xc, yH, xc, yL,transparency);
           context:drawLine(1, xc-xD, yO, xc, yO,transparency);
           context:drawLine(1, xc, yC, xc+xD, yC,transparency);
          else
           context:drawLine(2, xc, yH, xc, yL,transparency);
           context:drawLine(2, xc-xD, yO, xc, yO,transparency);
           context:drawLine(2, xc, yC, xc+xD, yC,transparency);
	  end 
         end
	elseif Type==5 then 
         local O, H, L, C;
         local yO, yH, yL, yC;
         local x1, x2, xc;
         local xD;
         local MinP, MaxP = mathex.minmax(src, firstBar2, lastBar2);
         for i=firstBar2, lastBar2, 1 do
          O, H, L, C = src.open[i], src.high[i], src.low[i], src.close[i];
          x1 = MinW+(MaxW-MinW)*((i-firstBar2)/(lastBar2+1-firstBar2));
          x2 = MinW+(MaxW-MinW)*((i-firstBar2+1)/(lastBar2+1-firstBar2));
          xc=(x1+x2)/2;
          xD=(x2-x1)/3;
          yO = (O-MinP)/(MaxP-MinP)*(MaxP0-MinP0)+MinP0;
          yH = (H-MinP)/(MaxP-MinP)*(MaxP0-MinP0)+MinP0;
          yL = (L-MinP)/(MaxP-MinP)*(MaxP0-MinP0)+MinP0;
          yC = (C-MinP)/(MaxP-MinP)*(MaxP0-MinP0)+MinP0;
          if C>O then
           context:drawLine(1, xc, yH, xc, yL,transparency);
           context:drawRectangle(1, 3, xc-xD, yO, xc+xD, yC,transparency);
          elseif C<O then
           context:drawLine(2, xc, yH, xc, yL,transparency);
           context:drawRectangle(2, 4, xc-xD, yO, xc+xD, yC,transparency);
          else
           context:drawLine(1, xc, yH, xc, yL,transparency);
           context:drawLine(1, xc-xD, yO, xc+xD, yO,transparency);
	  end 
         end
	else
         local O, H, L, C;
         local yO, yH, yL, yC;
         local x1, x2, xc;
         local MinP, MaxP = mathex.minmax(src, firstBar2, lastBar2);
         for i=firstBar2, lastBar2, 1 do
          O, H, L, C = src.open[i], src.high[i], src.low[i], src.close[i];
          x1 = MinW+(MaxW-MinW)*((i-firstBar2)/(lastBar2+1-firstBar2));
          x2 = MinW+(MaxW-MinW)*((i-firstBar2+1)/(lastBar2+1-firstBar2));
          xc=(x1+x2)/2;
          yO = (O-MinP)/(MaxP-MinP)*(MaxP0-MinP0)+MinP0;
          yH = (H-MinP)/(MaxP-MinP)*(MaxP0-MinP0)+MinP0;
          yL = (L-MinP)/(MaxP-MinP)*(MaxP0-MinP0)+MinP0;
          yC = (C-MinP)/(MaxP-MinP)*(MaxP0-MinP0)+MinP0;
          points = context:createPoints();
          points:add(x1,yO);
          points:add(xc,yH);
          points:add(x2,yC);
          points:add(xc,yL);
          if C>=O then
           context:drawPolygon(1, 3, points,transparency);
          else
	   context:drawPolygon(2, 4, points,transparency);
	  end 
         end
        end 
        
        

        context:resetClipRectangle();

    end
end



