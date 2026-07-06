-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=58746
-- Id: 9619

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
    indicator:name("Window statistics");
    indicator:description("Shows statistics of the bars in the current window.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addString("Position", "Position", "", "Right");
    indicator.parameters:addStringAlternative("Position", "Right", "", "Right");
    indicator.parameters:addStringAlternative("Position", "Left", "", "Left");
    indicator.parameters:addInteger("FontSize", "Font size", "", 0);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color", "Color", "", core.rgb(255, 255, 0));
end

local source = nil;
local color;
local IntPosition;
local Range;
local first;
local FontSize;
local pipSize;

-- initializes the instance of the indicator
function Prepare(onlyName)
    source = instance.source;
    first = source:first();
    pipSize = source:pipSize();
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end

    instance:ownerDrawn(true);
    Range = instance:addInternalStream(first, 0);
    
    color = instance.parameters.Color;
    FontSize = instance.parameters.FontSize;
    if instance.parameters.Position=="Right" then
     IntPosition=0;
    else
     IntPosition=1;
    end
    instance:setLabelColor(color);
end

function Update(period)
 if period>first then
  Range[period]=source.high[period]-source.low[period];
 end
end

local init = false;

function ConvertDate(D)
 local t = core.dateToTable(D);
 return string.format("%02i/%02i/%04i %02i:%02i", t.month, t.day, t.year, t.hour, t.min);
end

function Draw(stage, context)
    if stage == 2 then
    
        if not init then
           if FontSize==0 then
              context:createFont(1, "Arial", 0, -context:pointsToPixels(source:pipSize()), 0);
            else  
              context:createFont(1, "Arial", 0, FontSize, 0);
            end 
            init = true;
        end
        
        local BeginBar=context:firstBar();
        local EndBar=context:lastBar();
        if BeginBar<EndBar then
         BeginBar = math.max(BeginBar, first);
         EndBar = math.min(EndBar, source:size()-1);
         local BeginTime=ConvertDate(source:date(BeginBar));
         local EndTime=ConvertDate(source:date(EndBar));
         local CountBars=EndBar-BeginBar+1;
         local MinPrice, MaxPrice = mathex.minmax(source, BeginBar, EndBar);
         local MinBarSize, MaxBarSize = mathex.minmax(Range, BeginBar, EndBar);
         local AverageBarSize = mathex.avg(Range, BeginBar, EndBar);
         MinBarSize, MaxBarSize, AverageBarSize = math.floor(MinBarSize/pipSize+0.5), math.floor(MaxBarSize/pipSize+0.5), math.floor(AverageBarSize/pipSize+0.5);
         local W, H=context:measureText(1, " Average bar size: ", context.LEFT);
         local Right, Left, Top = context:right(), context:left(), context:top();
         
         if IntPosition==0 then
          context:drawText(1, " Window statistics:", color, -1, Right-2*W, Top, Right, Top+H, context.RIGHT);
          context:drawText(1, " Begin time: " .. BeginTime, color, -1, Right-2*W, Top+H, Right, Top+2*H, context.RIGHT);
          context:drawText(1, " End time: " .. EndTime, color, -1, Right-2*W, Top+2*H, Right, Top+3*H, context.RIGHT);
          context:drawText(1, " Max. price: " .. MaxPrice, color, -1, Right-2*W, Top+3*H, Right, Top+4*H, context.RIGHT);
          context:drawText(1, " Min price: " .. MinPrice, color, -1, Right-2*W, Top+4*H, Right, Top+5*H, context.RIGHT);
          context:drawText(1, " Count of bars: " .. CountBars, color, -1, Right-2*W, Top+5*H, Right, Top+6*H, context.RIGHT);
          context:drawText(1, " Max. bar size: " .. MaxBarSize .. " pips", color, -1, Right-2*W, Top+6*H, Right, Top+7*H, context.RIGHT);
          context:drawText(1, " Min. bar size: " .. MinBarSize .. " pips", color, -1, Right-2*W, Top+7*H, Right, Top+8*H, context.RIGHT);
          context:drawText(1, " Average bar size: " .. AverageBarSize .. " pips", color, -1, Right-2*W, Top+8*H, Right, Top+9*H, context.RIGHT);
         else
          context:drawText(1, " Window statistics:", color, -1, Left, Top+2*H, Left+2*W, Top+3*H, context.LEFT);
          context:drawText(1, " Begin time: " .. BeginTime, color, -1, Left, Top+3*H, Left+2*W, Top+4*H, context.LEFT);
          context:drawText(1, " End time: " .. EndTime, color, -1, Left, Top+4*H, Left+2*W, Top+5*H, context.LEFT);
          context:drawText(1, " Max. price: " .. MaxPrice, color, -1, Left, Top+5*H, Left+2*W, Top+6*H, context.LEFT);
          context:drawText(1, " Min. price: " .. MinPrice, color, -1, Left, Top+6*H, Left+2*W, Top+7*H, context.LEFT);
          context:drawText(1, " Count of bars: " .. CountBars, color, -1, Left, Top+7*H, Left+2*W, Top+8*H, context.LEFT);
          context:drawText(1, " Max. bar size: " .. MaxBarSize .. " pips", color, -1, Left, Top+8*H, Left+2*W, Top+9*H, context.LEFT);
          context:drawText(1, " Min. bar size: " .. MinBarSize .. " pips", color, -1, Left, Top+9*H, Left+2*W, Top+10*H, context.LEFT);
          context:drawText(1, " Average bar size: " .. AverageBarSize .. " pips", color, -1, Left, Top+10*H, Left+2*W, Top+11*H, context.LEFT);
         end 
        
        end
    end
end



