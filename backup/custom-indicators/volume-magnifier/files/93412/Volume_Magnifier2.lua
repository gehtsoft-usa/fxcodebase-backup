-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60510
-- Id: 11483

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
    indicator.parameters:addString("frame", "Timeframe", "", "D1");
    indicator.parameters:setFlag("frame", core.FLAG_PERIODS);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Band Color", "", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("transparency", "Band Transparency", "0 - opaque, 100 - transparent", 75, 0, 100);
    indicator.parameters:addBoolean("ColorMode", "ColorMode", "", true);
    indicator.parameters:addColor("MainClr", "Main color", "Main color", core.rgb(128, 128, 0));
    indicator.parameters:addColor("UPcolor", "UP Chart color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNcolor", "DN Chart color", "", core.rgb(255, 0, 0));
end

local source = nil;
local color;
local Type;
local src;
local loading;
local ColorMode;
local UPcolor, DNcolor, MainClr;
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
    MainClr = instance.parameters.MainClr;
    ColorMode = instance.parameters.ColorMode;
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
        
    end
end



