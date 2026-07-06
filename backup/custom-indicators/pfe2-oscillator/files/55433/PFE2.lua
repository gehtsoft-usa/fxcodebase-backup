-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32540
-- Id: 8614

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
    indicator:name("PFE2 oscillator");
    indicator:description("PFE2 oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 7);
    indicator.parameters:addString("Method", "Method", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
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

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr1", "Color 1", "Color 1", core.rgb(255, 255, 128));
    indicator.parameters:addColor("clr2", "Color 2", "Color 2", core.rgb(0, 128, 0));
    indicator.parameters:addColor("clr3", "Color 3", "Color 3", core.rgb(128, 255, 0));
    indicator.parameters:addColor("clr4", "Color 4", "Color 4", core.rgb(255, 128, 128));
    indicator.parameters:addColor("clr5", "Color 5", "Color 5", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clr6", "Color 6", "Color 6", core.rgb(255, 128, 255));
end

local first;
local source = nil;
local Period;
local Method;
local PFE2=nil;
local MA;
local Count={};
local SMA={};
local Size=11;
local count=1;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Method=instance.parameters.Method;
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Method .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");  
	
    MA = core.indicators:create("AVERAGES", source, Method, Period, false);
	first = MA.DATA:first();
    PFE2 = instance:addStream("PFE2", core.Bar, name .. ".PFE2", "PFE2", instance.parameters.clr1, first);
    PFE2:setPrecision(math.max(2, instance.source:getPrecision()));
    local i;
    for i=0,Size,1 do
     Count[i]=0;
     SMA[i]=0;
    end
end

function Update(period, mode)
  
    MA:update(mode);
	 if period<first then
	 return;
	 end
	 
    SMA[Count[0]]=MA.DATA[period];
    local c2c=0;
    local r;
    for r=1,9,1 do
     c2c=c2c+math.sqrt((SMA[Count[r+1]]-SMA[Count[r]])*(SMA[Count[r+1]]-SMA[Count[r]])+1);
    end
    if c2c==0 then
     c2c=source:pipSize();
    end
    local dSMA=SMA[Count[0]]-SMA[Count[9]];
    local PFE=math.sqrt(dSMA*dSMA+100);
    local res=(PFE/c2c)*100;
    local fraceff;
    if dSMA>0 then
     fraceff=math.floor(res+0.5);
    else
     fraceff=math.floor(-res+0.5);
    end
    
    if period>first+Period+Size then
     PFE2[period]=math.floor(fraceff/3+PFE2[period-1]*2/3+0.5);
    else
     PFE2[period]=fraceff;
    end

    if period~=source:size()-1 then
     count=count-1;
     if count<0 then
      count=Size-1;
     end
     for r=0,Size-1,1 do
      if r+count>=Size then
       Count[r]=r+count-Size;
      else
       Count[r]=r+count;
      end
     end
    end 
    
    if PFE2[period]>0 then
     if PFE2[period]>PFE2[period-1] then
      PFE2:setColor(period, instance.parameters.clr1);
     elseif PFE2[period]==PFE2[period-1] then
      PFE2:setColor(period, instance.parameters.clr2);
     else
      PFE2:setColor(period, instance.parameters.clr3);
     end
    else
     if PFE2[period]>PFE2[period-1] then
      PFE2:setColor(period, instance.parameters.clr4);
     elseif PFE2[period]==PFE2[period-1] then
      PFE2:setColor(period, instance.parameters.clr5);
     else
      PFE2:setColor(period, instance.parameters.clr6);
     end
    end
 
end

