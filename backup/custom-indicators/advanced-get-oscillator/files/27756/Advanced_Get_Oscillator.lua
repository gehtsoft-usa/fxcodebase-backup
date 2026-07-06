-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=14631
-- Id: 6005

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
    indicator:name("Advanced Get Oscillator");
    indicator:description("Advanced Get Oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("FastPeriod", "Period of fast MVA", "", 5);
    indicator.parameters:addInteger("SlowPeriod", "Period of slow MVA", "", 34);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("HistClr", "Histogram Color", "Histogram Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("UpLineClr", "UP line Color", "UP line Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DnLineClr", "DN line Color", "DN line Color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local FastPeriod;
local SlowPeriod;
local FastMA;
local SlowMA;
local Hist=nil;
local UpLine=nil;
local DnLine=nil;
local Coeff;

function Prepare(nameOnly)
    source = instance.source;
    FastPeriod=instance.parameters.FastPeriod;
    SlowPeriod=instance.parameters.SlowPeriod;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.FastPeriod .. ", " .. instance.parameters.SlowPeriod .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
 
    FastMA = core.indicators:create("MVA", source, FastPeriod);
    SlowMA = core.indicators:create("MVA", source, SlowPeriod);
	
	first = math.max(FastMA.DATA:first(),SlowMA.DATA:first());
	
    Hist = instance:addStream("Hist", core.Bar, name .. ".Histogram", "Histogram", instance.parameters.HistClr, first);
    UpLine = instance:addStream("UpLine", core.Line, name .. ".UpLine", "UpLine", instance.parameters.UpLineClr, first);
    DnLine = instance:addStream("DnLine", core.Line, name .. ".DnLine", "DnLine", instance.parameters.DnLineClr, first);
    UpLine:setWidth(instance.parameters.widthLinReg);
    UpLine:setStyle(instance.parameters.styleLinReg);
    DnLine:setWidth(instance.parameters.widthLinReg);
    DnLine:setStyle(instance.parameters.styleLinReg);
	Hist:setPrecision(math.max(2, instance.source:getPrecision()));
	DnLine:setPrecision(math.max(2, instance.source:getPrecision()));
	UpLine:setPrecision(math.max(2, instance.source:getPrecision()));
    Coeff=2/39;
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
    FastMA:update(mode);
    SlowMA:update(mode);
    Hist[period]=FastMA.DATA[period]-SlowMA.DATA[period];
    if Hist[period]>=0 then
     UpLine[period]=Hist[period]*Coeff+UpLine[period-1]*(1-Coeff);
     DnLine[period]=DnLine[period-1];
    else
     UpLine[period]=UpLine[period-1];
     DnLine[period]=Hist[period]*Coeff+DnLine[period-1]*(1-Coeff);
    end
 
end

