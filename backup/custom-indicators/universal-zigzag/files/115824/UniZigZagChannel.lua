-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65327

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
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
    indicator:name("UniZigZagChannel indicator");
    indicator:description("UniZigZagChannel indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("UpBandPrice", "Upper band price", "", "2");
    indicator.parameters:addStringAlternative("UpBandPrice", "close", "", "0");
    indicator.parameters:addStringAlternative("UpBandPrice", "open", "", "1");
    indicator.parameters:addStringAlternative("UpBandPrice", "high", "", "2");
    indicator.parameters:addStringAlternative("UpBandPrice", "low", "", "3");
    indicator.parameters:addStringAlternative("UpBandPrice", "median", "", "4");
    indicator.parameters:addStringAlternative("UpBandPrice", "typical", "", "5");
    indicator.parameters:addStringAlternative("UpBandPrice", "weighted close", "", "6");
    indicator.parameters:addStringAlternative("UpBandPrice", "HA close", "", "7");
    indicator.parameters:addStringAlternative("UpBandPrice", "HA open", "", "8");
    indicator.parameters:addStringAlternative("UpBandPrice", "HA high", "", "9");
    indicator.parameters:addStringAlternative("UpBandPrice", "HA low", "", "10");
    indicator.parameters:addStringAlternative("UpBandPrice", "HA median", "", "11");
    indicator.parameters:addStringAlternative("UpBandPrice", "HA typical", "", "12");
    indicator.parameters:addStringAlternative("UpBandPrice", "HA weighted", "", "13");

    indicator.parameters:addString("LoBandPrice", "Lower band price", "", "3");
    indicator.parameters:addStringAlternative("LoBandPrice", "close", "", "0");
    indicator.parameters:addStringAlternative("LoBandPrice", "open", "", "1");
    indicator.parameters:addStringAlternative("LoBandPrice", "high", "", "2");
    indicator.parameters:addStringAlternative("LoBandPrice", "low", "", "3");
    indicator.parameters:addStringAlternative("LoBandPrice", "median", "", "4");
    indicator.parameters:addStringAlternative("LoBandPrice", "typical", "", "5");
    indicator.parameters:addStringAlternative("LoBandPrice", "weighted close", "", "6");
    indicator.parameters:addStringAlternative("LoBandPrice", "HA close", "", "7");
    indicator.parameters:addStringAlternative("LoBandPrice", "HA open", "", "8");
    indicator.parameters:addStringAlternative("LoBandPrice", "HA high", "", "9");
    indicator.parameters:addStringAlternative("LoBandPrice", "HA low", "", "10");
    indicator.parameters:addStringAlternative("LoBandPrice", "HA median", "", "11");
    indicator.parameters:addStringAlternative("LoBandPrice", "HA typical", "", "12");
    indicator.parameters:addStringAlternative("LoBandPrice", "HA weighted", "", "13");

    indicator.parameters:addString("BreakOutMode", "Breakout mode", "", "0");
    indicator.parameters:addStringAlternative("BreakOutMode", "close", "", "0");
    indicator.parameters:addStringAlternative("BreakOutMode", "Up/Lo band price", "", "1");

    indicator.parameters:addDouble("ReversalValue", "Reversal Value", "", 12);
    
    indicator.parameters:addString("RetraceMethod", "Retrace Method", "", "0");
    indicator.parameters:addStringAlternative("RetraceMethod", "Price channel", "", "0");
    indicator.parameters:addStringAlternative("RetraceMethod", "% of price", "", "1");
    indicator.parameters:addStringAlternative("RetraceMethod", "Price change in pips", "", "2");
    indicator.parameters:addStringAlternative("RetraceMethod", "ATR multiplier", "", "3");

    indicator.parameters:addInteger("ATRPeriod", "ATR Period", "", 50);
    indicator.parameters:addBoolean("ShowZigZag", "Show Zigzag", "", true);
    indicator.parameters:addBoolean("ShowSignals", "Show signals", "", true);
    indicator.parameters:addBoolean("ShowPriceChannel", "Show price channel", "", true);
	
	

    indicator.parameters:addString("ZigZagChannelMode", "ZigZag Channel Mode", "", "1");
    indicator.parameters:addStringAlternative("ZigZagChannelMode", "Off", "", "0");
    indicator.parameters:addStringAlternative("ZigZagChannelMode", "High/Low channel", "", "1");
    indicator.parameters:addStringAlternative("ZigZagChannelMode", "Chaos bands", "", "2");
	
	indicator.parameters:addBoolean("Signal", "Signal Mode", "", false);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr1", "Upper ZigZag Color", "Upper ZigZag Color", core.rgb(255, 128, 255));
    indicator.parameters:addInteger("width1", "Upper ZigZag width", "Upper ZigZag width", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Upper ZigZag style", "Upper ZigZag style", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clr2", "Lower ZigZag Color", "Lower ZigZag Color", core.rgb(128, 128, 255));
    indicator.parameters:addInteger("width2", "Lower ZigZag width", "Lower ZigZag width", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Lower ZigZag style", "Lower ZigZag style", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clr3", "UniZigZag Upper Color", "UniZigZag Upper Color", core.rgb(255, 128, 64));
    indicator.parameters:addInteger("width3", "UniZigZag Upper width", "UniZigZag Upper width", 1, 1, 5);
    indicator.parameters:addInteger("style3", "UniZigZag Upper style", "UniZigZag Upper style", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clr4", "UniZigZag Lower Color", "UniZigZag Lower Color", core.rgb(0, 128, 192));
    indicator.parameters:addInteger("width4", "UniZigZag Lower width", "UniZigZag Lower width", 1, 1, 5);
    indicator.parameters:addInteger("style4", "UniZigZag Lower style", "UniZigZag Lower style", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clr5", "Up Signal Color", "Up Signal Color", core.rgb(255, 128, 64));
    indicator.parameters:addInteger("width5", "Up Signal size", "Up Signal size", 15);
    indicator.parameters:addColor("clr6", "Dn Signal Color", "Dn Signal Color", core.rgb(0, 128, 192));
    indicator.parameters:addInteger("width6", "Dn Signal size", "Dn Signal size", 15);
    indicator.parameters:addColor("clr7", "Channels Upper band Color", "Channels Upper band Color", core.rgb(255, 128, 64));
    indicator.parameters:addInteger("width7", "Channels Upper band width", "Channels Upper band width", 1, 1, 5);
    indicator.parameters:addInteger("style7", "Channels Upper band style", "Channels Upper band style", core.LINE_DASH);
    indicator.parameters:setFlag("style7", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clr8", "Channels Lower band Color", "Channels Lower band Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width8", "Channels Lower band width", "Channels Lower band width", 1, 1, 5);
    indicator.parameters:addInteger("style8", "Channels Lower band style", "Channels Lower band style", core.LINE_DASH);
    indicator.parameters:setFlag("style8", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local UpBandPrice;
local LoBandPrice;
local BreakOutMode;
local ReversalValue;
local RetraceMethod;
local ATRPeriod;
local ShowZigZag;
local ShowSignals;
local ShowPriceChannel;
local ZigZagChannelMode;
local ATR;

local upZZ1, dnZZ1, hiBuffer, loBuffer, upSignal, dnSignal, hiband, loband, upPrice, loPrice;
local HAopen, HAclose, HAhigh, HAlow;
local upBand, loBand, trend;
local hiTime, loTime;
local hiValue, loValue;
local ZZpoint;

local pipSize;

local Signal;

function Prepare(nameOnly) 
    source = instance.source;
    pipSize=source:pipSize();
    pipSize=pipSize*math.pow(10, source:getPrecision() % 2);
    UpBandPrice=instance.parameters.UpBandPrice;
    LoBandPrice=instance.parameters.LoBandPrice;
    BreakOutMode=instance.parameters.BreakOutMode;
    ReversalValue=instance.parameters.ReversalValue;
    RetraceMethod=instance.parameters.RetraceMethod;
    ATRPeriod=instance.parameters.ATRPeriod;
    ShowZigZag=instance.parameters.ShowZigZag;
    ShowSignals=instance.parameters.ShowSignals;
    ShowPriceChannel=instance.parameters.ShowPriceChannel;
    ZigZagChannelMode=instance.parameters.ZigZagChannelMode;

    first = source:first()+2;
	
	
	   local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    upPrice = instance:addInternalStream(first, 0);
    loPrice = instance:addInternalStream(first, 0);

    upBand = instance:addInternalStream(first, 0);
    loBand = instance:addInternalStream(first, 0);
    trend = instance:addInternalStream(first, 0);
    hiTime = instance:addInternalStream(first, 0);
    loTime = instance:addInternalStream(first, 0);
    hiValue = instance:addInternalStream(first, 0);
    loValue = instance:addInternalStream(first, 0);

    ZZpoint = instance:addInternalStream(first, 0);

    ATR=core.indicators:create("ATR", source, ATRPeriod);

    HAopen = instance:addInternalStream(first, 0);
    HAclose = instance:addInternalStream(first, 0);
    HAhigh = instance:addInternalStream(first, 0);
    HAlow = instance:addInternalStream(first, 0);
	

 
	
	if instance.parameters.Signal then
	Signal = instance:addStream("Signal", core.Bar, name .. ".Signal", "Signal", instance.parameters.clr5, first);
	else	
	Signal = instance:addInternalStream(0, 0)
    end
	
    upZZ1 = instance:addStream("Upper ZigZag", core.Line, name .. ".Upper ZigZag", "Upper ZigZag", instance.parameters.clr1, first);
    upZZ1:setWidth(instance.parameters.width1);
    upZZ1:setStyle(instance.parameters.style1);
    dnZZ1 = instance:addStream("Lower ZigZag", core.Line, name .. ".Lower ZigZag", "Lower ZigZag", instance.parameters.clr2, first);
    dnZZ1:setWidth(instance.parameters.width2);
    dnZZ1:setStyle(instance.parameters.style2);
    hiBuffer = instance:addStream("UniZigZag Upper Band", core.Line, name .. ".UniZigZag Upper Band", "UniZigZag Upper Band", instance.parameters.clr3, first);
    hiBuffer:setWidth(instance.parameters.width3);
    hiBuffer:setStyle(instance.parameters.style3);
    loBuffer = instance:addStream("UniZigZag Lower Band", core.Line, name .. ".UniZigZag Lower Band", "UniZigZag Lower Band", instance.parameters.clr4, first);
    loBuffer:setWidth(instance.parameters.width4);
    loBuffer:setStyle(instance.parameters.style4);
    upSignal=instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.width5, core.H_Center, core.V_Top, instance.parameters.clr5, 0);
    dnSignal=instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.width6, core.H_Center, core.V_Bottom, instance.parameters.clr6, 0);
    hiband = instance:addStream("Channel\'s Upper Band", core.Line, name .. ".Channel\'s Upper Band", "Channel\'s Upper Band", instance.parameters.clr7, first);
    hiband:setWidth(instance.parameters.width7);
    hiband:setStyle(instance.parameters.style7);
    loband = instance:addStream("Channel\'s Lower Band", core.Line, name .. ".Channel\'s Lower Band", "Channel\'s Lower Band", instance.parameters.clr8, first);
    loband:setWidth(instance.parameters.width8);
    loband:setStyle(instance.parameters.style8);
end

function GetPrice(period, PriceType)
  if PriceType=="0" then
    return source.close[period];
  elseif PriceType=="1" then
    return source.open[period];
  elseif PriceType=="2" then
    return source.high[period];
  elseif PriceType=="3" then
    return source.low[period];
  elseif PriceType=="4" then
    return source.median[period];
  elseif PriceType=="5" then
    return source.typical[period];
  elseif PriceType=="6" then
    return source.weighted[period];
  elseif PriceType=="7" then
    return HAclose[period];
  elseif PriceType=="8" then
    return HAopen[period];
  elseif PriceType=="9" then
    return HAhigh[period];
  elseif PriceType=="10" then
    return HAlow[period];
  elseif PriceType=="11" then
    return (HAhigh[period]+HAlow[period])/2;
  elseif PriceType=="12" then
    return (HAclose[period]+HAhigh[period]+HAlow[period])/3;
  else
    return (2*HAclose[period]+HAhigh[period]+HAlow[period])/4;
  end
end

function Update(period, mode)
   ATR:update(mode);
   if period>first then
    HAclose[period]=(source.open[period]+source.close[period]+source.low[period]+source.high[period])/4;
    HAopen[period]=(HAopen[period-1]+HAclose[period-1])/2;
    HAhigh[period]=math.max(source.high[period], HAopen[period], HAclose[period]);
    HAlow[period]=math.min(source.low[period], HAopen[period], HAclose[period]);
   elseif period==first then
    HAclose[period]=source.close[period];
    HAopen[period]=source.open[period];
    HAhigh[period]=source.high[period];
    HAlow[period]=source.low[period];
   end 

   upPrice[period]=GetPrice(period, UpBandPrice);
   loPrice[period]=GetPrice(period, LoBandPrice);

   upBand[period]=upBand[period-1];
   loBand[period]=loBand[period-1];
   trend[period]=trend[period-1];
   hiTime[period]=hiTime[period-1];
   loTime[period]=loTime[period-1];

   if RetraceMethod=="0" then
    upBand[period]=upPrice[HighestBar(ReversalValue, period, 0, period)];
    loBand[period]=loPrice[LowestBar(ReversalValue, period, 0, period)];
   elseif RetraceMethod=="1" then 
    if upPrice[period]>upBand[period] then
      upBand[period]=upPrice[period];
      loBand[period]=upBand[period]*(1-0.01*ReversalValue);
    end
    if loPrice[period]<loBand[period] then
      loBand[period]=loPrice[period];
      upBand[period]=loBand[period]*(1+0.01*ReversalValue);
    end
   elseif RetraceMethod=="2" then 
    if upPrice[period]>=upBand[period] then
      upBand[period]=upPrice[period];
      loBand[period]=upBand[period]-ReversalValue*pipSize;
    end
    if loPrice[period]<=loBand[period] then
      loBand[period]=loPrice[period];
      upBand[period]=loBand[period]*ReversalValue*pipSize;
    end
   else
    if upPrice[period]>=upBand[period] then
      upBand[period]=upPrice[period];
      loBand[period]=upBand[period]-ReversalValue*ATR.DATA[period];
    end
    if loPrice[period]<=loBand[period] then
      loBand[period]=loPrice[period];
      upBand[period]=loBand[period]*ReversalValue*ATR.DATA[period];
    end
   end 

   upSignal:setNoData(period);
   dnSignal:setNoData(period);

   if ShowPriceChannel then
    hiband[period]=upBand[period];
    loband[period]=loBand[period];
   end

   local upbreak, dnbreak=false, false;

   if BreakOutMode=="1" then
    if upPrice[period]>upBand[period-1] and trend[period]<=0 then
      upbreak=true;
    end
    if loPrice[period]<loBand[period-1] and trend[period]>=0 then
      dnbreak=true;
    end
   else
    if source.close[period]>upBand[period-1] and trend[period]<=0 then
      upbreak=true;
    end
    if source.close[period]<loBand[period-1] and trend[period]>=0 then
      dnbreak=true;
    end
   end

   if upbreak and (loPrice[period]>=loBand[period-1] or (loPrice[period]<loBand[period-1] and source.close[period]>source.close[period-1])) and upBand[period-1]>0 then
    trend[period]=1;
    local lobar=LowestBar(period-hiTime[period], period, 1, period);
    loValue[period]=loPrice[lobar];
    loTime[period]=lobar;
	
	Signal[period]=-1;
	
    if ShowSignals then
      dnSignal:set(period, loValue[period], "\225");
    end
    if ShowZigZag then
      ZZpoint[lobar]=loValue[period];
    end
   end

   if dnbreak and (upPrice[period]<=upBand[period-1] or (upPrice[period]>upBand[period-1] and source.close[period]<source.close[period-1])) and loBand[period-1]>0 then
    trend[period]=-1;
    local hibar=HighestBar(period-loTime[period], period, 1, period);
    hiValue[period]=upPrice[hibar];
    hiTime[period]=hibar;
	 
	 Signal[period]=1;
	 
    if ShowSignals then
      upSignal:set(period, hiValue[period], "\226");
	  
    end
    if ShowZigZag then
      ZZpoint[hibar]=hiValue[period];
    end
   end

   if ZigZagChannelMode=="1" or ZigZagChannelMode=="2" then
    hiBuffer[period]=hiBuffer[period-1];
    loBuffer[period]=loBuffer[period-1];

    if hiValue[period]>0 then
      hiBuffer[period]=hiValue[period];
    end
    if ZigZagChannelMode=="1" then
      if upPrice[period]>hiBuffer[period] then
        hiBuffer[period]=upPrice[period];
      end
    end

    if loValue[period]>0 then
      loBuffer[period]=loValue[period];
    end
    if ZigZagChannelMode=="1" then
      if loPrice[period]<loBuffer[period] then
        loBuffer[period]=loPrice[period];
      end
    end
   end
    
  if period==source:size()-1 then
    DrawZZ();
  end
end

function DrawZZ()
  local i, i2;
  local prevPos=nil;
  local prevVal, Val;

  for i=first, source:size()-1, 1 do
    if ZZpoint[i]==source.low[i] or ZZpoint[i]==source.high[i] then
      if ZZpoint[i]==source.low[i] then
        Val=source.low[i];
      else
        Val=source.high[i];
      end
      if prevPos~=nil then
        for i2=prevPos, i, 1 do
          if Val>prevVal then
            upZZ1[i2]=Val+(i2-i)*(Val-prevVal)/(i-prevPos);
          else
            dnZZ1[i2]=Val+(i2-i)*(Val-prevVal)/(i-prevPos);
          end
        end
      end
      prevPos=i;
      prevVal=Val;
    end
  end
end

function LowestBar(len, k, opt, period)
  local min=100000000;
  local lobar, i, lo1, lo0;
  if len<=0 or len>=k then
    lobar=k;
  else
    for i=k-len+1, k, 1 do
      lo0=loPrice[i];
      if opt==1 then
        if i>=period then
          lo1=loPrice[period];
        else
          lo1=loPrice[i+1];
        end
      end
      if (opt==1 and lo0<=min) or (opt==0 and lo0<=min) then
        min=lo0;
        lobar=i;
      end
    end
  end

  return lobar;
end

function HighestBar(len, k, opt, period)
  local max=-100000000;
  local hibar, i, hi1, hi0;
  if len<=0 or len>=k then
    hibar=k;
  else
    for i=k-len+1, k, 1 do
--      core.host:trace("i=" .. i .. ", len=" .. len .. ", k=" .. k);
      hi0=upPrice[i];
      if opt==1 then
        if i>=period then
          hi1=upPrice[period];
        else
          hi1=upPrice[i+1];
        end
      end
      if (opt==1 and hi0>=max) or (opt==0 and hi0>=max) then
        max=hi0;
        hibar=i;
      end
    end
  end

  return hibar;
end

