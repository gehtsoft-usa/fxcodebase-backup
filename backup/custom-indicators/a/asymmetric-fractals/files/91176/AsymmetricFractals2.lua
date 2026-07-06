-- Id: 10558
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32544

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
    indicator:name("Asymmetric fractals");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
  
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("FrameBefore", "Number of bars before fractal", "Number of bars before fractal", 2);
    indicator.parameters:addInteger("FrameAfter", "Number of bars after fractal", "Number of bars after fractal", 2);
    
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UpClr", "Up fractal color", "Up fractal color", core.rgb(0,255,0));
    indicator.parameters:addColor("DnClr", "Down fractal color", "Down fractal color", core.rgb(255,0,0));
    indicator.parameters:addInteger("ArrowSize", "Arrow size", "", 0);
end

local source;
local first;
local up, down;
local FrameBefore, FrameAfter;
local ArrowSize;
local UpClr, DnClr;

function Prepare(onlyName)
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.FrameBefore .. ", " .. instance.parameters.FrameAfter .. ")";

    if onlyName then
        return ;
    end

    first = source:first();
    
    up = instance:addStream("up", core.Dot, name .. ".up", "up", instance.parameters.UpClr, first);
    down = instance:addStream("down", core.Dot, name .. ".down", "down", instance.parameters.DnClr, first);
    up:setVisible(false);
    down:setVisible(false);
    UpClr=instance.parameters.UpClr;
    DnClr=instance.parameters.DnClr;
    ArrowSize=instance.parameters.ArrowSize;
    
    instance:ownerDrawn(true);
	
    FrameBefore=instance.parameters.FrameBefore;
    FrameAfter=instance.parameters.FrameAfter;
  
    local name = profile:id() .. " ( " .. FrameBefore .. ", " .. FrameAfter .. " )";
    instance:name(name);
end

function Update(period, mode)
 if period>first+FrameBefore+FrameAfter then
  local i;
  local UpFr, DnFr = true, true;
  for i=1, FrameBefore, 1 do
   if source.high[period-FrameAfter]<=source.high[period-i-FrameAfter] then
    UpFr=false;
   end
   if source.low[period-FrameAfter]>=source.low[period-i-FrameAfter] then
    DnFr=false;
   end
  end
  for i=1, FrameAfter, 1 do
   if source.high[period-FrameAfter]<=source.high[period-FrameAfter+i] then
    UpFr=false;
   end
   if source.low[period-FrameAfter]>=source.low[period-FrameAfter+i] then
    DnFr=false;
   end
  end
  if UpFr then
   up[period-FrameAfter]=source.high[period-FrameAfter];
  else
   up[period-FrameAfter]=nil;
  end
  if DnFr then
   down[period-FrameAfter]=source.low[period-FrameAfter];
  else
   down[period-FrameAfter]=nil;
  end
 end
end

local init = false;

function Draw(stage, context)
    if stage == 2 then
    
        if not init then
           if ArrowSize==0 then
              context:createFont(1, "Wingdings", 0, -context:pointsToPixels(source:pipSize()), 0);
            else  
              context:createFont(1, "Wingdings", 0, ArrowSize, 0);
            end 
            init = true;
        end
        
        local firstBar, lastBar = context:firstBar(), context:lastBar();
        local i;
        local h, w;
        local x, x1, x2;
        local Arrow;
        local v, y;
        
        for i=firstBar, lastBar, 1 do
         if up[i]~=nil then
          x, x1, x2 = context:positionOfBar(i);
          Arrow="\234";
          w, h = context:measureText(1, Arrow, context.CENTER+context.BOTTOM);
          v, y = context:pointOfPrice(up[i]);
          context:drawText(1, Arrow, UpClr, -1, x-w/2, y-h, x+w/2, y, context.CENTER+context.BOTTOM);
         end
         if down[i]~=nil then
          x, x1, x2 = context:positionOfBar(i);
          Arrow="\233";
          w, h = context:measureText(1, Arrow, context.CENTER+context.TOP);
          v, y = context:pointOfPrice(down[i]);
          context:drawText(1, Arrow, DnClr, -1, x-w/2, y, x+w/2, y+h, context.CENTER+context.TOP);
         end
        end

    end
end



