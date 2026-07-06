-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=9559
-- Id: 5251

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
    indicator:name("BB_MACD oscillator");
    indicator:description("BB_MACD oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("FastEMA", "Fast EMA Period", "", 12);
    indicator.parameters:addInteger("SlowEMA", "Slow EMA Period", "", 26);
    indicator.parameters:addInteger("SignalSMA", "Signal EMA Period", "", 10);
    indicator.parameters:addInteger("ADX_Period", "ADX Period", "", 16);
    indicator.parameters:addDouble("StdDev_Coeff", "StdDev Coeff", "", 1);
    indicator.parameters:addBoolean("ShowDots", "Show dots", "", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MACD_Up_Trend_Clr", "MACD UP Trend Color", "MACD UP Trend Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("MACD_Dn_Trend_Clr", "MACD DN Trend Color", "MACD DN Trend Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("MACD_Signal_Clr", "MACD Signal Color", "MACD Signal Color", core.rgb(128, 128, 0));
    indicator.parameters:addColor("Upper_Band_Clr", "Upper Band Color", "Upper Band Color", core.rgb(0, 128, 0));
    indicator.parameters:addColor("Lower_Band_Clr", "Lower Band Color", "Lower Band Color", core.rgb(128, 0, 0));
    indicator.parameters:addColor("MACD_Up_Signal_Clr", "MACD UP Signal Color", "MACD UP Signal Color", core.rgb(100, 255, 0));
    indicator.parameters:addColor("MACD_Dn_Signal_Clr", "MACD DN Signal Color", "MACD DN Signal Color", core.rgb(255, 100, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 1, 1, 5);
end

local first;
local source = nil;
local FastEMA;
local SlowEMA;
local SignalSMA;
local ADX_Period;
local StdDev_Coeff;
local ShowDots;
local MACD_Up_Trend=nil;
local MACD_Dn_Trend=nil;
local MACD_Signal=nil;
local Upper_Band=nil;
local Lower_Band=nil;
local MACD_Up_Signal=nil;
local MACD_Dn_Signal=nil;
local MACD_Array;
local Fast_EMA;
local Slow_EMA;
local Signal_SMA;
local StdDev;

function Prepare(nameOnly)
    source = instance.source;
    FastEMA=instance.parameters.FastEMA;
    SlowEMA=instance.parameters.SlowEMA;
    SignalSMA=instance.parameters.SignalSMA;
    ADX_Period=instance.parameters.ADX_Period;
    StdDev_Coeff=instance.parameters.StdDev_Coeff;
    ShowDots=instance.parameters.ShowDots;
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.FastEMA .. ", " .. instance.parameters.SlowEMA .. ", " .. instance.parameters.SignalSMA .. ", " .. instance.parameters.ADX_Period .. ", " .. instance.parameters.StdDev_Coeff .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	assert(core.indicators:findIndicator("STDDEV2") ~= nil, "Please, download and install STDDEV2.LUA indicator"); 
	
    MACD_Array = instance:addInternalStream(0, 0);
    Fast_EMA = core.indicators:create("EMA", source, FastEMA);
    Slow_EMA = core.indicators:create("EMA", source, SlowEMA);
	
	 first = math.max(Fast_EMA .DATA:first() ,Slow_EMA .DATA:first())
	 
    Signal_SMA = core.indicators:create("EMA", MACD_Array, SignalSMA);
    StdDev = core.indicators:create("STDDEV2", MACD_Array, SignalSMA, "EMA");
    if ShowDots then
     MACD_Up_Trend = instance:addStream("MACD_Up_Trend", core.Dot, name .. ".MACD_Up_Trend", "MACD_Up_Trend", instance.parameters.MACD_Up_Trend_Clr, first);
     MACD_Dn_Trend = instance:addStream("MACD_Dn_Trend", core.Dot, name .. ".MACD_Dn_Trend", "MACD_Dn_Trend", instance.parameters.MACD_Dn_Trend_Clr, first);
     MACD_Up_Trend:setWidth(instance.parameters.DotSize);
     MACD_Dn_Trend:setWidth(instance.parameters.DotSize);
    else
     MACD_Up_Trend = instance:addStream("MACD_Up_Trend", core.Line, name .. ".MACD_Up_Trend", "MACD_Up_Trend", instance.parameters.MACD_Up_Trend_Clr, first);
     MACD_Dn_Trend = instance:addStream("MACD_Dn_Trend", core.Line, name .. ".MACD_Dn_Trend", "MACD_Dn_Trend", instance.parameters.MACD_Dn_Trend_Clr, first);
     MACD_Up_Trend:setWidth(instance.parameters.widthLinReg);
     MACD_Up_Trend:setStyle(instance.parameters.styleLinReg);
     MACD_Dn_Trend:setWidth(instance.parameters.widthLinReg);
     MACD_Dn_Trend:setStyle(instance.parameters.styleLinReg);
    end
     MACD_Signal = instance:addStream("MACD_Signal", core.Line, name .. ".MACD_Signal", "MACD_Signal", instance.parameters.MACD_Signal_Clr, Signal_SMA.DATA:first() );
     Upper_Band = instance:addStream("Upper_Band", core.Line, name .. ".Upper_Band", "Upper_Band", instance.parameters.Upper_Band_Clr, Signal_SMA.DATA:first() );
     Lower_Band = instance:addStream("Lower_Band", core.Line, name .. ".Lower_Band", "Lower_Band", instance.parameters.Lower_Band_Clr, Signal_SMA.DATA:first() );
     MACD_Up_Signal = instance:addStream("MACD_Up_Signal", core.Dot, name .. ".MACD_Up_Signal", "MACD_Up_Signal", instance.parameters.MACD_Up_Signal_Clr, first);
     MACD_Dn_Signal = instance:addStream("MACD_Dn_Signal", core.Dot, name .. ".MACD_Dn_Signal", "MACD_Dn_Signal", instance.parameters.MACD_Dn_Signal_Clr, first);
     MACD_Signal:setWidth(instance.parameters.widthLinReg);
     MACD_Signal:setStyle(instance.parameters.styleLinReg);
     Upper_Band:setWidth(instance.parameters.widthLinReg);
     Upper_Band:setStyle(instance.parameters.styleLinReg);
     Lower_Band:setWidth(instance.parameters.widthLinReg);
     Lower_Band:setStyle(instance.parameters.styleLinReg);
     MACD_Up_Signal:setWidth(instance.parameters.DotSize);
     MACD_Dn_Signal:setWidth(instance.parameters.DotSize);
     MACD_Signal:addLevel(0);    
	 
	 
	MACD_Up_Trend:setPrecision(math.max(2, instance.source:getPrecision()));
	MACD_Dn_Trend:setPrecision(math.max(2, instance.source:getPrecision()));
	MACD_Signal:setPrecision(math.max(2, instance.source:getPrecision()));
	
	Upper_Band:setPrecision(math.max(2, instance.source:getPrecision()));
	Upper_Band:setPrecision(math.max(2, instance.source:getPrecision()));
	
	MACD_Up_Signal:setPrecision(math.max(2, instance.source:getPrecision()));
	MACD_Dn_Signal:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
    Fast_EMA:update(mode);
    Slow_EMA:update(mode);
    MACD_Array[period]=Fast_EMA.DATA[period]-Slow_EMA.DATA[period];
    Signal_SMA:update(mode);
    StdDev:update(mode);
	
	if period <Signal_SMA.DATA:first() then
	return;
	end
	
    MACD_Signal[period]=Signal_SMA.DATA[period];
    Upper_Band[period]=MACD_Signal[period]+StdDev.DATA[period]*StdDev_Coeff;
    Lower_Band[period]=MACD_Signal[period]-StdDev.DATA[period]*StdDev_Coeff;

    MACD_Up_Trend[period]=nil;
    MACD_Dn_Trend[period]=nil;
    MACD_Up_Signal[period]=nil;
    MACD_Dn_Signal[period]=nil;
    if MACD_Array[period]<MACD_Array[period-1] then
     MACD_Dn_Trend[period]=MACD_Array[period];
     MACD_Dn_Signal[period]=MACD_Array[period];
    elseif MACD_Array[period]>MACD_Array[period-1] then
     MACD_Up_Trend[period]=MACD_Array[period];
     MACD_Up_Signal[period]=MACD_Array[period];
    else
     if MACD_Up_Trend[period-1]==nil then
      MACD_Up_Trend[period]=nil;
     end 
     if MACD_Dn_Trend[period-1]==nil then
      MACD_Dn_Trend[period]=nil;
     end 
     if MACD_Up_Signal[period-1]==nil then
      MACD_Up_Signal[period]=nil;
     end 
     if MACD_Dn_Signal[period-1]==nil then
      MACD_Dn_Signal[period]=nil;
     end 
    end
    
    if MACD_Up_Trend[period]>Upper_Band[period] or MACD_Up_Signal[period]>Upper_Band[period] then
     MACD_Up_Trend[period]=nil;
    end 
    if MACD_Up_Signal[period]<=Upper_Band[period] and MACD_Up_Signal[period]>=Lower_Band[period] then
     MACD_Up_Signal[period]=nil;
    end
    if MACD_Dn_Trend[period]>Upper_Band[period] then
     MACD_Dn_Trend[period]=nil;
    end
    if MACD_Dn_Trend[period]<Lower_Band[period] or MACD_Dn_Signal[period]<Lower_Band[period] then
     MACD_Dn_Trend[period]=nil;
    end
    if MACD_Dn_Signal[period]>=Lower_Band[period] and MACD_Dn_Signal[period]<=Upper_Band[period] then
     MACD_Dn_Signal[period]=nil;
    end
    if MACD_Up_Trend[period]<Lower_Band[period] then
     MACD_Up_Trend[period]=nil;
    end
    
    
end

