-- Id: 1805
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2304

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
    indicator:name("USDX Slope indicator");
    indicator:description("USDX Slope indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Shift", "Shift", "Shift", 1);
    indicator.parameters:addInteger("Period", "Period", "Period", 80);
    indicator.parameters:addString("Method", "Method", "", "SMA");
    indicator.parameters:addStringAlternative("Method", "SMA", "", "SMA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addString("Price", "Price", "", "close");
    indicator.parameters:addStringAlternative("Price", "open", "", "open");
    indicator.parameters:addStringAlternative("Price", "close", "", "close");
    indicator.parameters:addStringAlternative("Price", "high", "", "high");
    indicator.parameters:addStringAlternative("Price", "low", "", "low");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr1", "Color UpUp", "Color UpUp", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clr2", "Color DnUp", "Color DnUp", core.rgb(255, 255, 0));
    indicator.parameters:addColor("clr3", "Color UpDn", "Color UpDn", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clr4", "Color DnDn", "Color DnDn", core.rgb(255, 0, 255));
end

local first;
local source = nil;
local USDX;
local Slope;
local Shift;
local buff1=nil;
local buff2=nil;
local buff3=nil;
local buff4=nil;

function Prepare(nameOnly)
    source = instance.source;
    Shift=instance.parameters.Shift;
	
	
	assert(core.indicators:findIndicator("USDX") ~= nil, "Please, download and install USDX.LUA indicator");    
	assert(core.indicators:findIndicator("SLOPE_DIRECTION_LINE") ~= nil, "Please, download and install SLOPE_DIRECTION_LINE.LUA indicator");    
	
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    USDX = core.indicators:create("USDX", source);
    Slope = core.indicators:create("SLOPE_DIRECTION_LINE", source, instance.parameters.Period, instance.parameters.Method, instance.parameters.Price);
    first = math.max(USDX.DATA:first(),Slope.DATA:first())+2;
    buff1 = instance:addStream("buff1", core.Bar, name .. "UpUp", "UpUp", instance.parameters.clr1, first);
    buff1:setPrecision(math.max(2, instance.source:getPrecision()));
    buff2 = instance:addStream("buff2", core.Bar, name .. "DnUp", "DnUp", instance.parameters.clr2, first);
    buff2:setPrecision(math.max(2, instance.source:getPrecision()));
    buff3 = instance:addStream("buff3", core.Bar, name .. "UpDn", "UpDn", instance.parameters.clr3, first);
    buff3:setPrecision(math.max(2, instance.source:getPrecision()));
    buff4 = instance:addStream("buff4", core.Bar, name .. "DnDn", "DnDn", instance.parameters.clr4, first);
    buff4:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
    USDX:update(mode);
    Slope:update(mode);
    local i;
    if (period>first+Shift) then
     for i=first+Shift,period,1 do
     local USDX_Diff=USDX.DATA[i]-USDX.DATA[i-Shift];
     if Slope.UpTrend[i]>0 then
      if USDX_Diff>0. then
       buff1[i]=100;
       buff2[i]=0;
       buff3[i]=0;
       buff4[i]=0;
      elseif USDX_Diff<0. then
       buff3[i]=100;
       buff1[i]=0;
       buff2[i]=0;
       buff4[i]=0;
      end 
     elseif Slope.DnTrend[i]>0 then
      if USDX_Diff>0. then
       buff2[i]=100;
       buff1[i]=0;
       buff3[i]=0;
       buff4[i]=0;
      elseif USDX_Diff<0. then
       buff4[i]=100;
       buff1[i]=0;
       buff2[i]=0;
       buff3[i]=0;
      end 
     end
     end
    end 
end

