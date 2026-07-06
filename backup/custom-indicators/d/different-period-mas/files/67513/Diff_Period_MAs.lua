-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41292
-- Id: 9332

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
    indicator:name("Different period MA indicator");
    indicator:description("Different period MA indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addBoolean("EnableH", "Enable hour MA", "", true);
    indicator.parameters:addBoolean("EnableD", "Enable day MA", "", true);
    indicator.parameters:addBoolean("EnableW", "Enable week MA", "", true);
    indicator.parameters:addBoolean("EnableM", "Enable month MA", "", true);
    indicator.parameters:addBoolean("EnableY", "Enable year MA", "", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Hclr", "Hour MA color", "Hour MA color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("Hwidth", "Hour MA width", "Hour MA width", 1, 1, 5);
    indicator.parameters:addInteger("Hstyle", "Hour MA style", "Hour MA style", core.LINE_SOLID);
    indicator.parameters:setFlag("Hstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Dclr", "Day MA color", "Day MA color", core.rgb(128, 255, 0));
    indicator.parameters:addInteger("Dwidth", "Day MA width", "Day MA width", 1, 1, 5);
    indicator.parameters:addInteger("Dstyle", "Day MA style", "Day MA style", core.LINE_SOLID);
    indicator.parameters:setFlag("Dstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Wclr", "Week MA color", "Week MA color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Wwidth", "Week MA width", "Week MA width", 1, 1, 5);
    indicator.parameters:addInteger("Wstyle", "Week MA style", "Week MA style", core.LINE_SOLID);
    indicator.parameters:setFlag("Wstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Mclr", "Month MA color", "Month MA color", core.rgb(128, 128, 0));
    indicator.parameters:addInteger("Mwidth", "Month MA width", "Month MA width", 1, 1, 5);
    indicator.parameters:addInteger("Mstyle", "Month MA style", "Month MA style", core.LINE_SOLID);
    indicator.parameters:setFlag("Mstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Yclr", "Year MA color", "Year MA color", core.rgb(0, 255, 128));
    indicator.parameters:addInteger("Ywidth", "Year MA width", "Year MA width", 1, 1, 5);
    indicator.parameters:addInteger("Ystyle", "Year MA style", "Year MA style", core.LINE_SOLID);
    indicator.parameters:setFlag("Ystyle", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local EnableH;
local EnableD;
local EnableW;
local EnableM;
local EnableY;
local MA_H=nil;
local MA_D=nil;
local MA_W=nil;
local MA_M=nil;
local MA_Y=nil;
local ShiftH, ShiftD, ShiftW, ShiftM, ShiftY;

function Prepare(nameOnly)
    source = instance.source;
    EnableH=instance.parameters.EnableH;
    EnableD=instance.parameters.EnableD;
    EnableW=instance.parameters.EnableW;
    EnableM=instance.parameters.EnableM;
    EnableY=instance.parameters.EnableY;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    MA_H = instance:addStream("H", core.Line, name .. ".H", "H", instance.parameters.Hclr, first);
    MA_H:setWidth(instance.parameters.Hwidth);
    MA_H:setStyle(instance.parameters.Hstyle);
    MA_D = instance:addStream("D", core.Line, name .. ".D", "D", instance.parameters.Dclr, first);
    MA_D:setWidth(instance.parameters.Dwidth);
    MA_D:setStyle(instance.parameters.Dstyle);
    MA_W = instance:addStream("W", core.Line, name .. ".W", "W", instance.parameters.Wclr, first);
    MA_W:setWidth(instance.parameters.Wwidth);
    MA_W:setStyle(instance.parameters.Wstyle);
    MA_M = instance:addStream("M", core.Line, name .. ".M", "M", instance.parameters.Mclr, first);
    MA_M:setWidth(instance.parameters.Mwidth);
    MA_M:setStyle(instance.parameters.Mstyle);
    MA_Y = instance:addStream("Y", core.Line, name .. ".Y", "Y", instance.parameters.Yclr, first);
    MA_Y:setWidth(instance.parameters.Ywidth);
    MA_Y:setStyle(instance.parameters.Ystyle);
    ShiftH, ShiftD, ShiftW, ShiftM, ShiftY = 1/24, 1, 7, 30, 365;
end

function Update(period, mode)
   if period>first then
    local index;
    if EnableH then
     index=core.findDate(source, source:date(period)-ShiftH, false);
     if index~=-1 and index<period then
      MA_H[period]=mathex.avg(source, index+1, period);
     end
    end
    if EnableD then
     index=core.findDate(source, source:date(period)-ShiftD, false);
     if index~=-1 and index<period then
      MA_D[period]=mathex.avg(source, index+1, period);
     end
    end
    if EnableW then
     index=core.findDate(source, source:date(period)-ShiftW, false);
     if index~=-1 and index<period then
      MA_W[period]=mathex.avg(source, index+1, period);
     end
    end
    if EnableM then
     index=core.findDate(source, source:date(period)-ShiftM, false);
     if index~=-1 and index<period then
      MA_M[period]=mathex.avg(source, index+1, period);
     end
    end
    if EnableY then
     index=core.findDate(source, source:date(period)-ShiftY, false);
     if index~=-1 and index<period then
      MA_Y[period]=mathex.avg(source, index+1, period);
     end
    end
   end 
end

