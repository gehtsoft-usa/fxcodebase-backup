-- Id: 2890
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3169


--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+
function Init()
    indicator:name("MACD Osmax Oscillator");
    indicator:description("MACD Osmax Oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("FastEMA", "FastEMA", "", 12);
    indicator.parameters:addInteger("SlowEMA", "SlowEMA", "", 26);
    indicator.parameters:addInteger("SignalEMA", "SignalEMA", "", 9);
    indicator.parameters:addInteger("OsmaX", "OsmaX", "", 2);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(0, 255, 255));
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(255, 0, 255));
    indicator.parameters:addColor("NEclr", "Neutral Color", "Neutral Color", core.rgb(147, 112, 219));	
	
    indicator.parameters:addColor("LineClr", "Line Color", "Line Color", core.rgb(192, 192, 192));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("SignalClr", "Signal Color", "Signal Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("MACDClr", "MACD Color", "MACD Color", core.rgb(127, 255, 212));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local FastEMA;
local SlowEMA;
local SignalEMA;
local OsmaX;
local FastMA;
local SlowMA;
local DiffMA;
local SignalMA;
local buffUP=nil;
local buffDN=nil;
local buffNE=nil;
local buffLine=nil;
local buffSignal=nil;
local buffMACD=nil;

function Prepare(nameOnly)
    source = instance.source;
    FastEMA=instance.parameters.FastEMA;
    SlowEMA=instance.parameters.SlowEMA;
    SignalEMA=instance.parameters.SignalEMA;
    OsmaX=instance.parameters.OsmaX;
	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.FastEMA .. ", " .. instance.parameters.SlowEMA .. ", " .. instance.parameters.SignalEMA .. ", " .. instance.parameters.OsmaX .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    FastMA = core.indicators:create("EMA", source, FastEMA);
    SlowMA = core.indicators:create("EMA", source, SlowEMA);
    first = math.max(FastMA.DATA:first(),SlowMA.DATA:first())+2;
    DiffMA = instance:addInternalStream(first, 0);
    SignalMA = core.indicators:create("EMA", DiffMA, SignalEMA);
    
	
	
    buff = instance:addStream("buff", core.Bar, name .. ".buff", "buff", instance.parameters.UPclr, first);    
    buffLine = instance:addStream("buffLine", core.Line, name .. ".Line", "Line", instance.parameters.LineClr, first);
	buffLine:setWidth(instance.parameters.width1);
    buffLine:setStyle(instance.parameters.style1);
    buffSignal = instance:addStream("buffSignal", core.Line, name .. ".Signal", "Signal", instance.parameters.SignalClr, first);
	buffSignal:setWidth(instance.parameters.width2);
    buffSignal:setStyle(instance.parameters.style2);
    buffMACD = instance:addStream("buffMACD", core.Line, name .. ".MACD", "MACD", instance.parameters.MACDClr, first);
	buffMACD:setWidth(instance.parameters.width3);
    buffMACD:setStyle(instance.parameters.style3);
	
	buff:setPrecision(math.max(2, instance.source:getPrecision()));
	buffLine:setPrecision(math.max(2, instance.source:getPrecision()));
	buffSignal:setPrecision(math.max(2, instance.source:getPrecision()));
	buffMACD:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if (period>first) then
    FastMA:update(mode);
    SlowMA:update(mode); 
    DiffMA[period]=FastMA.DATA[period]-SlowMA.DATA[period];
    buffMACD[period]=DiffMA[period];
    SignalMA:update(mode);
    buffSignal[period]=SignalMA.DATA[period];
    buffLine[period]=(buffMACD[period]-buffSignal[period])*OsmaX;
	buff[period]=buffLine[period];
    if DiffMA[period]>DiffMA[period-1] then
     if buffLine[period]>buffLine[period-1] then
      buff:setColor(period, instance.parameters.UPclr);
     else
      buff:setColor(period, instance.parameters.NEclr);
     end
    else
     if buffLine[period]<buffLine[period-1] then
      buff:setColor(period, instance.parameters.DNclr);
     else
       buff:setColor(period, instance.parameters.NEclr);
     end
    end
   end 
end

