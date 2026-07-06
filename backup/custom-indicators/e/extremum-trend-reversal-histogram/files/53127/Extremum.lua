-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=31128
-- Id: 8362

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
    indicator:name("Extremum indicator");
    indicator:description("Extremum indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 20);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("ExtremunLineClr", "Extremum line color", "Extremum line color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("UpperLineClr", "Upper line color", "Upper line color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("LowerLineClr", "Lower line color", "Lower line color", core.rgb(255, 255, 0));
    indicator.parameters:addColor("LowerHistClr", "Lower histogram color", "Lower histogram color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("SignalHistClr", "Signal histogram color", "Signal histogram color", core.rgb(128, 0, 255));
    indicator.parameters:addColor("UpperHistClr", "Upper histogram color", "Upper histogram color", core.rgb(0, 128, 255));
end

local first;
local source = nil;
local Period;
local ExtremumLine=nil;
local UpperLine=nil;
local LowerLine=nil;
local LowerHist=nil;
local SignalHist=nil;
local UpperHist=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    ExtremumLine = instance:addStream("ExtremumLine", core.Line, name .. ".ExtremumLine", "ExtremumLine", instance.parameters.ExtremunLineClr, first);
    ExtremumLine:setPrecision(math.max(2, instance.source:getPrecision()));
    UpperLine = instance:addStream("UpperLine", core.Line, name .. ".UpperLine", "UpperLine", instance.parameters.UpperLineClr, first);
    UpperLine:setPrecision(math.max(2, instance.source:getPrecision()));
    LowerLine = instance:addStream("LowerLine", core.Line, name .. ".LowerLine", "LowerLine", instance.parameters.LowerLineClr, first);
    LowerLine:setPrecision(math.max(2, instance.source:getPrecision()));
    LowerHist = instance:addStream("LowerHist", core.Bar, name .. ".LowerHist", "LowerHist", instance.parameters.LowerHistClr, first);
    LowerHist:setPrecision(math.max(2, instance.source:getPrecision()));
    SignalHist = instance:addStream("SignalHist", core.Bar, name .. ".SignalHist", "SignalHist", instance.parameters.SignalHistClr, first);
    SignalHist:setPrecision(math.max(2, instance.source:getPrecision()));
    UpperHist = instance:addStream("UpperHist", core.Bar, name .. ".UpperHist", "UpperHist", instance.parameters.UpperHistClr, first);
    UpperHist:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if (period>first) then
    local i;
    local n=0;
    local m=0;
    for i=0, Period-1, 1 do
     if source.high[period]>source.high[period-i] and source.high[period]-source.high[period-i]>n then
      n=source.high[period]-source.high[period-i];
     end
     if source.low[period]<source.low[period-i] and source.low[period]-source.low[period-i]<m then
      m=source.low[period]-source.low[period-i];
     end
    end
    local sum, dif = m+n, m-n;
    ExtremumLine[period]=sum;
    UpperLine[period]=dif;
    LowerLine[period]=-dif;
    if math.abs(sum)==math.abs(dif) then
     SignalHist[period]=-sum/2;
    else
     SignalHist[period]=0; 
    end
    if sum<0 then
     LowerHist[period]=sum;
    else
     LowerHist[period]=0;
    end
    if sum>0 then
     UpperHist[period]=sum;
    else
     UpperHist[period]=0;
    end 
   end 
end

