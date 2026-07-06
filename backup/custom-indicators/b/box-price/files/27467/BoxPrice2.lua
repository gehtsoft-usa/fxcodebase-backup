--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("BoxPrice indicator");
    indicator:description("BoxPrice indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("PipsAbove", "PipsAbove", "", 50);
    indicator.parameters:addInteger("PipsBelow", "PipsBelow", "", 50);
    indicator.parameters:addInteger("BarsBack", "BarsBack", "", 20);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUp", "Color Up", "Color Up", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrDn", "Color Dn", "Color Dn", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clrCloud", "Color cloud", "Color cloud", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 3, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("Transparency", "Transparency", "", 50,0,100);
end

local first;
local source = nil;
local PipsAbove;
local PipsBelow;
local BarsBack;
local UpLine=nil;
local DnLine=nil;
local UpCloud=nil;
local DnCloud=nil;
local LastH, LastL;
local LastPeriod;

function Prepare()
    source = instance.source;
    PipsAbove=instance.parameters.PipsAbove;
    PipsBelow=instance.parameters.PipsBelow;
    BarsBack=instance.parameters.BarsBack;
    first = source:first()+BarsBack;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.PipsAbove .. ", " .. instance.parameters.PipsBelow .. ")";
    instance:name(name);
    UpLine = instance:addStream("UpLine", core.Line, name .. ".UpLine", "UpLine", instance.parameters.clrUp, first);
    DnLine = instance:addStream("DnLine", core.Line, name .. ".DnLine", "DnLine", instance.parameters.clrDn, first);
    UpCloud=instance:addInternalStream(0, 0);
    DnCloud=instance:addInternalStream(0, 0);
    instance:createChannelGroup("CloudGroup","Cloud" , UpCloud, DnCloud, instance.parameters.clrCloud, 100-instance.parameters.Transparency);
    UpLine:setWidth(instance.parameters.widthLinReg);
    UpLine:setStyle(instance.parameters.styleLinReg);
    DnLine:setWidth(instance.parameters.widthLinReg);
    DnLine:setStyle(instance.parameters.styleLinReg);
    LastH, LastL=0, 0;
    LastPeriod=0;
end

function Update(period, mode)
   if (period==source:size()-1) then
    if source[period]>LastH or source[period]<LastL or LastPeriod~=period then
     local HighPrice=source[period]+PipsAbove*source:pipSize();
     local LowPrice=source[period]-PipsBelow*source:pipSize();
     LastH, LastL=HighPrice, LowPrice;
     LastPeriod=period;
     local First=math.max(first+1,period-BarsBack);
     core.drawLine(UpLine,core.range(First,period),HighPrice,First,HighPrice,period);
     core.drawLine(DnLine,core.range(First,period),LowPrice,First,LowPrice,period);
     core.drawLine(UpCloud,core.range(First,period),HighPrice,First,HighPrice,period);
     core.drawLine(DnCloud,core.range(First,period),LowPrice,First,LowPrice,period);
     UpLine[First-1]=nil;
     DnLine[First-1]=nil;
     UpCloud[First-1]=nil;
     DnCloud[First-1]=nil;
    end 
   end 
end

