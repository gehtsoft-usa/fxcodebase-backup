-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27798
-- Id: 8138

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("Day quadrangle");
    indicator:description("Day quadrangle");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("BeginTime", "Begin time of the day", "", "17:00");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("OHclr", "Open-High color", "Open-High color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("OHwidth", "Open-High width", "Open-High width", 1, 1, 5);
    indicator.parameters:addInteger("OHstyle", "Open-High style", "Open-High style", core.LINE_SOLID);
    indicator.parameters:setFlag("OHstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("OLclr", "Open-Low color", "Open-Low color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("OLwidth", "Open-Low width", "Open-Low width", 1, 1, 5);
    indicator.parameters:addInteger("OLstyle", "Open-Low style", "Open-Low style", core.LINE_SOLID);
    indicator.parameters:setFlag("OLstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("HCclr", "High-Close color", "High-Close color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("HCwidth", "High-Close width", "High-Close width", 1, 1, 5);
    indicator.parameters:addInteger("HCstyle", "High-Close style", "High-Close style", core.LINE_SOLID);
    indicator.parameters:setFlag("HCstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("LCclr", "Low-Close color", "Low-Close color", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("LCwidth", "Low-Close width", "Low-Close width", 1, 1, 5);
    indicator.parameters:addInteger("LCstyle", "Low-Close style", "Low-Close style", core.LINE_SOLID);
    indicator.parameters:setFlag("LCstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addBoolean("ShowOC", "Show Open-Close line", "", true);
    indicator.parameters:addColor("OCclr", "Open-Close color", "Open-Close color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("OCwidth", "Open-Close width", "Open-Close width", 1, 1, 5);
    indicator.parameters:addInteger("OCstyle", "Open-Close style", "Open-Close style", core.LINE_SOLID);
    indicator.parameters:setFlag("OCstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addBoolean("ShowHL", "Show High-Low line", "", true);
    indicator.parameters:addColor("HLclr", "High-Low color", "High-Low color", core.rgb(128, 128, 0));
    indicator.parameters:addInteger("HLwidth", "High-Low width", "High-Low width", 1, 1, 5);
    indicator.parameters:addInteger("HLstyle", "High-Low style", "High-Low style", core.LINE_SOLID);
    indicator.parameters:setFlag("HLstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("FillT", "Fill transparency (%)", "", 70, 0, 100);
end

local first;
local source = nil;
local OpenStream, HighStream, LowStream;
local BeginT;
local OHclr, OLclr, HCclr, LCclr, OCclr, HLclr;
local OHwidth, OLwidth, HCwidth, LCwidth, OCwidth, HLwidth;
local OHstyle, OLstyle, HCstyle, LCstyle, OCstyle, HLwidth;
local ShowOC, ShowHL;
local UPclr, DNclr, FillT;
local UpStream, DnStream;

function Prepare(nameOnly)
    source = instance.source;
    ShowOC = instance.parameters.ShowOC;
    ShowHL = instance.parameters.ShowHL;
    OHclr = instance.parameters.OHclr;
    OLclr = instance.parameters.OLclr;
    HCclr = instance.parameters.HCclr;
    LCclr = instance.parameters.LCclr;
    OCclr = instance.parameters.OCclr;
    HLclr = instance.parameters.HLclr;
    OHwidth = instance.parameters.OHwidth;
    OLwidth = instance.parameters.OLwidth;
    HCwidth = instance.parameters.HCwidth;
    LCwidth = instance.parameters.LCwidth;
    OCwidth = instance.parameters.OCwidth;
    HLwidth = instance.parameters.HLwidth;
    OHstyle = instance.parameters.OHstyle;
    OLstyle = instance.parameters.OLstyle;
    HCstyle = instance.parameters.HCstyle;
    LCstyle = instance.parameters.LCstyle;
    OCstyle = instance.parameters.OCstyle;
    HLstyle = instance.parameters.HLstyle;
    UPclr = instance.parameters.UPclr;
    DNclr = instance.parameters.DNclr;
    FillT = 100-instance.parameters.FillT;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    OpenStream = instance:addInternalStream(first, 0);
    HighStream = instance:addInternalStream(first, 0);
    LowStream = instance:addInternalStream(first, 0);
    UpStream = instance:addInternalStream(first, 0);
    DnStream = instance:addInternalStream(first, 0);
    local BeginTime=instance.parameters.BeginTime;
    local Pos=string.find(BeginTime,":");
    local BeginH=tonumber(string.sub(BeginTime,1,Pos-1));
    local BeginM=tonumber(string.sub(BeginTime,Pos+1));
    BeginT=60*BeginH+BeginM;
    instance:createChannelGroup("D_Q", "D_Q", UpStream, DnStream, UPclr, FillT);
end

function DayNumber(period)
 local D=source:date(period);
 local T=core.dateToTable(D);
 local wday=T.wday;
 local CandleTime=60*T.hour+T.min;
 if CandleTime<BeginT then
  wday=wday-1;
  if wday<1 then
   wday=7;
  end
 end
 return wday;
end


function Update(period, mode)
   if period>first then
    if DayNumber(period)~=DayNumber(period-1) then
     OpenStream[period]=period;
     HighStream[period]=period;
     LowStream[period]=period;
    else
     OpenStream[period]=OpenStream[period-1];
     if source.high[period]>source.high[HighStream[period-1]] then
      HighStream[period]=period;
     else
      HighStream[period]=HighStream[period-1];
     end
     if source.low[period]<source.low[LowStream[period-1]] then
      LowStream[period]=period;
     else
      LowStream[period]=LowStream[period-1];
     end
    end
    local OpenDate = source:date(OpenStream[period]);
    local HighDate = source:date(HighStream[period]);
    local LowDate = source:date(LowStream[period]);
    local CloseDate = source:date(period);
    local ClosePrice = source.close[period];
    local OpenPrice = source.open[OpenStream[period]];
    local HighPrice = source.high[HighStream[period]];
    local LowPrice = source.low[LowStream[period]];
    
    core.host:execute("drawLine", OpenStream[period]*6, OpenDate, OpenPrice, HighDate, HighPrice, OHclr, OHstyle, OHwidth);
    core.host:execute("drawLine", OpenStream[period]*6+1, OpenDate, OpenPrice, LowDate, LowPrice, OLclr, OLstyle, OLwidth);
    core.host:execute("drawLine", OpenStream[period]*6+2, HighDate, HighPrice, CloseDate, ClosePrice, HCclr, HCstyle, HCwidth);
    core.host:execute("drawLine", OpenStream[period]*6+3, LowDate, LowPrice, CloseDate, ClosePrice, LCclr, LCstyle, LCwidth);

    if OpenStream[period]~=HighStream[period] then
     core.drawLine(UpStream, core.range(OpenStream[period], HighStream[period]), OpenPrice, OpenStream[period], HighPrice, HighStream[period]);
    end
    if HighStream[period]~=period then 
     core.drawLine(UpStream, core.range(HighStream[period], period), HighPrice, HighStream[period], ClosePrice, period);
    end
    if OpenStream[period]~=LowStream[period] then 
     core.drawLine(DnStream, core.range(OpenStream[period], LowStream[period]), OpenPrice, OpenStream[period], LowPrice, LowStream[period]);
    end
    if LowStream[period]~=period then 
     core.drawLine(DnStream, core.range(LowStream[period], period), LowPrice, LowStream[period], ClosePrice, period);
    end 

    if ClosePrice>=OpenPrice then
     FillBand(OpenStream[period],period,UPclr);
    else
     FillBand(OpenStream[period],period,DNclr);
    end
    
    if ShowOC then
     core.host:execute("drawLine", OpenStream[period]*6+4, OpenDate, OpenPrice, CloseDate, ClosePrice, OCclr, OCstyle, OCwidth);
    end
    if ShowHL then
     core.host:execute("drawLine", OpenStream[period]*6+5, HighDate, HighPrice, LowDate, LowPrice, HLclr, HLstyle, HLwidth);
    end
   elseif period==first then
    OpenStream[period]=period;
    HighStream[period]=period;
    LowStream[period]=period;
   end 
end

function FillBand(firstPeriod, lastPeriod, clr)
 local i;
 for i=firstPeriod, lastPeriod, 1 do
  UpStream:setColor(i, clr);
 end
end

