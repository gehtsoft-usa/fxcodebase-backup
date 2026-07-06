-- Id: 2998
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3292

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
    indicator:name("BoxPrice with StDev indicator");
    indicator:description("BoxPrice with StDev indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("Dev", "Deviation", "", 2);
    indicator.parameters:addInteger("Period", "Period for StDev", "", 20);
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
local Dev;
local Period;
local BarsBack;
local UpLine=nil;
local DnLine=nil;
local UpCloud=nil;
local DnCloud=nil;

function Prepare(nameOnly)
    source = instance.source;
    Dev=instance.parameters.Dev;
    Period=instance.parameters.Period;
    BarsBack=instance.parameters.BarsBack;
    first = source:first()+BarsBack;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Dev .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    UpLine = instance:addStream("UpLine", core.Line, name .. ".UpLine", "UpLine", instance.parameters.clrUp, first);
    DnLine = instance:addStream("DnLine", core.Line, name .. ".DnLine", "DnLine", instance.parameters.clrDn, first);
    UpCloud=instance:addInternalStream(0, 0);
    DnCloud=instance:addInternalStream(0, 0);
    instance:createChannelGroup("CloudGroup","Cloud" , UpCloud, DnCloud, instance.parameters.clrCloud, 100-instance.parameters.Transparency);
    UpLine:setWidth(instance.parameters.widthLinReg);
    UpLine:setStyle(instance.parameters.styleLinReg);
    DnLine:setWidth(instance.parameters.widthLinReg);
    DnLine:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if (period==source:size()-1 and period>first+Period) then
    local StDev=core.stdev(source,core.rangeTo(period,Period));
    local HighPrice=source[period]+StDev*Dev;
    local LowPrice=source[period]-StDev*Dev;
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

