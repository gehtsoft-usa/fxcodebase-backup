-- Id: 6240
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=15511

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

--                                 Symphonie Extreme Indicator v3.0 
--                                         Copyright � William Blau 
--                           Originally coded � 2006 by Profitrader 


function Init()
    indicator:name("Symphonie Extreme indicator");
    indicator:description("Symphonie Extreme indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("r", "r", "", 12);
    indicator.parameters:addInteger("s", "s", "", 12);
    indicator.parameters:addInteger("u", "u", "", 5);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UpPosClr", "Up Positive Color", "Up Positive Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("UpNegClr", "Up Negative Color", "Up Negative Color", core.rgb(0, 128, 0));
    indicator.parameters:addColor("DnPosClr", "Dn Positive Color", "Dn Positive Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DnNegClr", "Dn Negative Color", "Dn Negative Color", core.rgb(128, 0, 0));
end

local first;
local source = nil;
local r, s, u;
local UpTicks, DnTicks;
local UpEMA, DnEMA;
local UpDEMA, DnDEMA;
local TVI;
local pipSize;
local Symp_Extreme=nil;

function Prepare(nameOnly)
    source = instance.source;
    r=instance.parameters.r;
    s=instance.parameters.s;
    u=instance.parameters.u;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. r .. ", " .. s .. ", " .. u .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    UpTicks=instance:addInternalStream(first, 0);
    DnTicks=instance:addInternalStream(first, 0);
    UpEMA=core.indicators:create("EMA", UpTicks, r);
    DnEMA=core.indicators:create("EMA", DnTicks, r);
    UpDEMA=core.indicators:create("EMA", UpEMA.DATA, s);
    DnDEMA=core.indicators:create("EMA", DnEMA.DATA, s);
    TVI_Raw=instance:addInternalStream(first, 0);
    TVI=core.indicators:create("EMA", TVI_Raw, u);
    Symp_Extreme = instance:addStream("Symp_Extreme", core.Bar, name .. ".Symp_Extreme", "Symp_Extreme", instance.parameters.UpPosClr, TVI.DATA:first() );
    Symp_Extreme:setPrecision(math.max(2, instance.source:getPrecision()));
    pipSize=source:pipSize();
end

function Update(period, mode)
   if period<source:first() then
   return;
   end
   
   
    UpTicks[period]=(source.volume[period]+(source.close[period]-source.open[period])/pipSize)/2;
    DnTicks[period]=source.volume[period]-UpTicks[period];
    UpEMA:update(mode);
    DnEMA:update(mode);
    UpDEMA:update(mode);
    DnDEMA:update(mode);
	
	
   if period<DnDEMA.DATA:first() then
   return;
   end
   
    if UpDEMA.DATA[period]+DnDEMA.DATA[period]~=0 then
     TVI_Raw[period]=100*(UpDEMA.DATA[period]-DnDEMA.DATA[period])/(UpDEMA.DATA[period]+DnDEMA.DATA[period]);
    else
     TVI_Raw[period]=0;
    end 
    TVI:update(mode);
	
	
	if period<TVI.DATA:first() then
   return;
   end
    Symp_Extreme[period]=TVI.DATA[period];
    if TVI.DATA[period]>TVI.DATA[period-1] then
     if TVI.DATA[period]>=0 then
      Symp_Extreme:setColor(period,instance.parameters.UpPosClr);
     else
      Symp_Extreme:setColor(period,instance.parameters.UpNegClr);
     end
    else
     if TVI.DATA[period]>=0 then
      Symp_Extreme:setColor(period,instance.parameters.DnPosClr);
     else
      Symp_Extreme:setColor(period,instance.parameters.DnNegClr);
     end
    end
   
end

