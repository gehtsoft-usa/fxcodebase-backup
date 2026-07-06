-- Id: 3002
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3293

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("MaDev oscillator");
    indicator:description("MaDev oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Method", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth");
    
    indicator.parameters:addString("Price", "Price", "", "close");
    indicator.parameters:addStringAlternative("Price", "close", "", "close");
    indicator.parameters:addStringAlternative("Price", "open", "", "open");
    indicator.parameters:addStringAlternative("Price", "high", "", "high");
    indicator.parameters:addStringAlternative("Price", "low", "", "low");
    indicator.parameters:addStringAlternative("Price", "median", "", "median");
    indicator.parameters:addStringAlternative("Price", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Price", "weighted", "", "weighted");
 
    indicator.parameters:addInteger("Period", "Period", "", 20);
    
    indicator.parameters:addInteger("Frame", "Number points for extremums", "", 3);
    
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUP", "Color of UP", "Color of UP", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clrDN", "Color of DN", "Color of DN", core.rgb(0, 0, 255));
    indicator.parameters:addColor("clrNE", "Color of NE", "Color of NE", core.rgb(128, 128, 128));
end

local first;
local source = nil;
local Method;
local Period;
local Frame;
local Price;
local Dev;
local MA;
local BuffUp=nil;
local BuffDn=nil;
local BuffNe=nil;
local sourcePrice;

function Prepare(nameOnly)
    source = instance.source;
    Method=instance.parameters.Method;
    Period=instance.parameters.Period;
    Frame=instance.parameters.Frame;
    Price=instance.parameters.Price;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Method .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Frame .. ", " .. instance.parameters.Price .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Dev = instance:addInternalStream(0, 0);
    if Price=="close" then
     sourcePrice=source.close;
    elseif Price=="open" then
     sourcePrice=source.open;
    elseif Price=="high" then
     sourcePrice=source.high;
    elseif Price=="low" then
     sourcePrice=source.low;
    elseif Price=="median" then
     sourcePrice=source.median;
    elseif Price=="typical" then
     sourcePrice=source.typical;
    else
     sourcePrice=source.weighted;
    end 
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator"); 
    MA = core.indicators:create("AVERAGES", sourcePrice, Method, Period, false);
	first = MA.DATA:first();
	
    
    BuffNe = instance:addStream("BuffNe", core.Bar, name .. ".Ne", "Ne", instance.parameters.clrNE, first);
    BuffNe:setPrecision(math.max(2, instance.source:getPrecision()));
    BuffUp = instance:addStream("BuffUp", core.Bar, name .. ".Up", "Up", instance.parameters.clrUP, first);
    BuffUp:setPrecision(math.max(2, instance.source:getPrecision()));
    BuffDn = instance:addStream("BuffDn", core.Bar, name .. ".Dn", "Dn", instance.parameters.clrDN, first);
    BuffDn:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if (period<first ) then
   return;
   end
    MA:update(mode);
    Dev[period]=sourcePrice[period]-MA.DATA[period];
    BuffNe[period]=Dev[period];
    if period>first+Frame+1 then
     local Min=true;
     local Max=true;
     local i;
     local Shift=math.floor((Frame-1)/2);
     for i=1,Shift,1 do
      if Dev[period-Shift-1]>=Dev[period-i-Shift-1] or Dev[period-Shift-1]>=Dev[period+i-Shift-1] then
       Min=false;
      end
      if Dev[period-Shift-1]<=Dev[period-i-Shift-1] or Dev[period-Shift-1]<=Dev[period+i-Shift-1] then
       Max=false;
      end
     end
     if Min==true and sourcePrice[period-Shift-1]<MA.DATA[period-Shift-1] then
      BuffDn[period-Shift-1]=Dev[period-Shift-1];
     end
     if Max==true and sourcePrice[period-Shift-1]>MA.DATA[period-Shift-1] then
      BuffUp[period-Shift-1]=Dev[period-Shift-1];
     end
    end 
 
    
end

