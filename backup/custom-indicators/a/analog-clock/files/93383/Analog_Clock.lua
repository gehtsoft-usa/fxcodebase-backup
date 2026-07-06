-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60501
-- Id: 11467

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
    indicator:name("Draw the close price path");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addGroup("Clock parameters");
    indicator.parameters:addString("Corner", "Corner", "", "Right-Top");
    indicator.parameters:addStringAlternative("Corner", "Right-Top", "", "Right-Top");
    indicator.parameters:addStringAlternative("Corner", "Left-Top", "", "Left-Top");
    indicator.parameters:addStringAlternative("Corner", "Right-Bottom", "", "Right-Bottom");
    indicator.parameters:addStringAlternative("Corner", "Left-Bottom", "", "Left-Bottom");
    indicator.parameters:addInteger("Size", "Size", "", 100);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("ClockColor", "Clock color", "", core.rgb(0, 0, 128));
    indicator.parameters:addColor("ClockFillColor", "Clock Fill color", "", core.rgb(128, 255, 255));
    indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 75, 0, 100);
    indicator.parameters:addColor("HandColor", "Hand color", "", core.rgb(255, 255, 0));
end

local first = 0;
local source = nil;
local ClockColor;
local ClockFillColor;
local HandColor;
local transparency;
local Corner;
local Size;
local SecSize=0.85;
local MinSize=0.7;
local HourSize=0.6;
local IntCorner;
local TimerID;

-- initializes the instance of the indicator
function Prepare(onlyName)
    source = instance.source;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    instance:setLabelColor(instance.parameters.ClockColor);

    if onlyName then
        return ;
    end

    instance:ownerDrawn(true);

    Corner = instance.parameters.Corner;

    if Corner=="Right-Top" then
     IntCorner=0;
    elseif Corner=="Right-Bottom" then
     IntCorner=1;
    elseif Corner=="Left-Top" then
     IntCorner=2;
    else
     IntCorner=3;
    end
    
    
    Size = instance.parameters.Size;
    ClockColor = instance.parameters.ClockColor;
    ClockFillColor = instance.parameters.ClockFillColor;
    HandColor = instance.parameters.HandColor;
    transparency = instance.parameters.transparency;
    if transparency == 100 then
        transparency = 255;
    elseif transparency == 0 then
        transparency = 0;
    else
        transparency = math.floor(255 * (transparency / 100.0) + 0.5);
    end
    TimerID=core.host:execute("setTimer", 100, 1);
end

function AsyncOperationFinished(id, success, msg)
 if id == 100 then
  instance:updateFrom(source:size()-1);
 end
end
 


function Update(period)
end

local init = false;

function now()
    if __debug__hook ~= nil then
        return core.host:execute("convertTime", core.TZ_EST, core.TZ_LOCAL, core.now());
    else
        return win32.currentTimeLocal();
    end
end

function Draw(stage, context)
    if stage == 2 then
        if not init then
            context:createSolidBrush(2, ClockFillColor);
            context:createPen(1, context.SOLID, 1, ClockColor);
            context:createPen(6, context.SOLID, 1, ClockColor);
            context:createPen(7, context.SOLID, 3, ClockColor);
            context:createPen(3, context.SOLID, 1, HandColor);
            context:createPen(4, context.SOLID, 2, HandColor);
            context:createPen(5, context.SOLID, 3, HandColor);
            init = true;
        end
        
        local x1,y1,x2,y2;
        local i;
        if IntCorner==0 then
         x1=context:right()-Size;
         y1=context:top();
         x2=context:right();
         y2=context:top()+Size;
        elseif IntCorner==1 then
         x1=context:right()-Size;
         y1=context:bottom()-Size;
         x2=context:right();
         y2=context:bottom();
        elseif IntCorner==2 then
         x1=context:left();
         y1=context:top();
         x2=context:left()+Size;
         y2=context:top()+Size;
        else
         x1=context:left();
         y1=context:bottom()-Size;
         x2=context:left()+Size;
         y2=context:bottom();
        end
        
        local x_center, y_center=(x1+x2)/2, (y1+y2)/2;
        
        context:drawEllipse(1,2,x1,y1,x2,y2,transparency);
        
        for i=0,11,1 do
         x1, y1 = math2d.polarToCartesian(Size/2, i*math.pi/6);
         x1, y1 = x1+x_center, y1+y_center;
         x2, y2 = math2d.polarToCartesian(0.9*Size/2, i*math.pi/6);
         x2, y2 = x2+x_center, y2+y_center;
         if i==0 or i==3 or i==6 or i==9 then
          context:drawLine(7, x1, y1, x2, y2);
         else
          context:drawLine(6, x1, y1, x2, y2);
         end 
        end
        
        local TimeTable=core.dateToTable(now());
        local Hour=TimeTable.hour+TimeTable.min/60+TimeTable.sec/3600;
        local Min=TimeTable.min+TimeTable.sec/60;
        if Hour>11 then Hour=Hour-12 end
        local Sec_Angle=TimeTable.sec/30*math.pi-math.pi/2;
        local Sec_x, Sec_y = math2d.polarToCartesian(SecSize*Size/2,Sec_Angle);
        Sec_x, Sec_y = Sec_x+x_center, Sec_y+y_center;
        local Min_Angle=Min/30*math.pi-math.pi/2;
        local Min_x, Min_y = math2d.polarToCartesian(MinSize*Size/2,Min_Angle);
        Min_x, Min_y = Min_x+x_center, Min_y+y_center;
        local Hour_Angle=Hour/6*math.pi-math.pi/2;
        local Hour_x, Hour_y = math2d.polarToCartesian(HourSize*Size/2,Hour_Angle);
        Hour_x, Hour_y = Hour_x+x_center, Hour_y+y_center;
        context:drawLine(3, x_center, y_center, Sec_x, Sec_y);
        context:drawLine(4, x_center, y_center, Min_x, Min_y);
        context:drawLine(5, x_center, y_center, Hour_x, Hour_y);
        
    end
end

function ReleaseInstance()
    core.host:execute("killTimer", TimerID);
end




