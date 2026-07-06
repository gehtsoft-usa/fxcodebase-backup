-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59437
-- Id: 9938

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
    indicator:name("Percent B oscillator");
    indicator:description("Percent B oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("StdDev_Period", "Standard deviation period", "", 18);
    indicator.parameters:addInteger("Smooth_Period", "Smooth period", "", 3);
    indicator.parameters:addInteger("PeriodK", "K period for stochastics line", "", 30);
    indicator.parameters:addInteger("SmoothK", "Slowing K period", "", 3);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("PercBclr", "PercB color", "PercB color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("PercBwidth", "PercB line width", "PercB line width", 1, 1, 5);
    indicator.parameters:addInteger("PercBstyle", "PercB line style", "PercB line style", core.LINE_SOLID);
    indicator.parameters:setFlag("PercBstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Kclr", "K color", "K color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Kwidth", "K line width", "K line width", 1, 1, 5);
    indicator.parameters:addInteger("Kstyle", "K line style", "K line style", core.LINE_DASH);
    indicator.parameters:setFlag("Kstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Lclr", "Levels color", "Levels color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("Lwidth", "Levels width", "Levels width", 1, 1, 5);
    indicator.parameters:addInteger("Lstyle", "Levels style", "Levels style", core.LINE_DASH);
    indicator.parameters:setFlag("Lstyle", core.FLAG_LINE_STYLE);
end

local first,FIRST;
local source = nil;
local StdDev_Period;
local Smooth_Period;
local PeriodK;
local SmoothK;
local Rainbow;
local EMA1, EMA2;
local ZLRB;
local TEMA;
local StdDev;
local WMA;
local PercB=nil;
local K=nil;
local Close;
local fastK;
local SMA;

function Prepare(nameOnly)
    source = instance.source;
    Close=source.close;
    StdDev_Period=instance.parameters.StdDev_Period;
    Smooth_Period=instance.parameters.Smooth_Period;
    PeriodK=instance.parameters.PeriodK;
    SmoothK=instance.parameters.SmoothK;
    first = source:first()+10;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.StdDev_Period .. ", " .. instance.parameters.Smooth_Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Rainbow = instance:addInternalStream(0, 0);
    fastK = instance:addInternalStream(0, 0);
    ZLRB = instance:addInternalStream(0, 0);
	
	assert(core.indicators:findIndicator("STDDEV") ~= nil, "Please, download and install STDDEV.LUA indicator");  
	assert(core.indicators:findIndicator("TEMA1") ~= nil, "Please, download and install TEMA1.LUA indicator");
	
    EMA1 = core.indicators:create("EMA", Rainbow, Smooth_Period);
    EMA2 = core.indicators:create("EMA", EMA1.DATA, Smooth_Period);
    TEMA = core.indicators:create("TEMA1", ZLRB, Smooth_Period);
    SMA = core.indicators:create("MVA", fastK, SmoothK);
    StdDev = core.indicators:create("STDDEV", TEMA.DATA, StdDev_Period);
    WMA = core.indicators:create("LWMA", TEMA.DATA, StdDev_Period);
	
	FIRST= math.max(WMA.DATA:first(),SMA.DATA:first() );
    PercB = instance:addStream("PercB", core.Line, name .. ".PercB", "PercB", instance.parameters.PercBclr, FIRST);
    PercB:setPrecision(math.max(2, instance.source:getPrecision()));
    PercB:setWidth(instance.parameters.PercBwidth);
    PercB:setStyle(instance.parameters.PercBstyle);
    K = instance:addStream("K", core.Line, name .. ".K", "K", instance.parameters.Kclr, FIRST);
    K:setPrecision(math.max(2, instance.source:getPrecision()));
    K:setWidth(instance.parameters.Kwidth);
    K:setStyle(instance.parameters.Kstyle);
    PercB:addLevel(0, instance.parameters.Lstyle, instance.parameters.Lwidth, instance.parameters.Lclr);
    PercB:addLevel(50, instance.parameters.Lstyle, instance.parameters.Lwidth, instance.parameters.Lclr);
    PercB:addLevel(100, instance.parameters.Lstyle, instance.parameters.Lwidth, instance.parameters.Lclr);
end

function Update(period, mode)
   if period<first  then
   return;
   end
   
    Rainbow[period]=(20*Close[period]+75*Close[period-1]+180*Close[period-2]+336*Close[period-3]+463*Close[period-4]+462*Close[period-5]+330*Close[period-6]+165*Close[period-7]+55*Close[period-8]+11*Close[period-9]+Close[period-10])/2098;
    EMA1:update(mode);
    EMA2:update(mode);
	
	if period < EMA2.DATA:first() then
	return;
	end
	
	
    local diff=EMA1.DATA[period]-EMA2.DATA[period];
    ZLRB[period]=EMA1.DATA[period]+diff;
    TEMA:update(mode);
    StdDev:update(mode);
    WMA:update(mode);
	
	if period < FIRST then
	return;
	end
	
    PercB[period]=100*(TEMA.DATA[period]+2*StdDev.DATA[period]-WMA.DATA[period])/(4*StdDev.DATA[period]);
   
     local RBC=(Rainbow[period]+source.typical[period])/2;
     local Min, Max = mathex.minmax(source, period-PeriodK+1, period);
     local nom=RBC-Min;
     local den=Max-Min;
     if den==0 then
      fastK[period]=fastK[period-1];
     else
      fastK[period]=math.min(100, math.max(0, 100*nom/den))
     end 
  
    SMA:update(mode);
    K[period]=SMA.DATA[period];
  
end

