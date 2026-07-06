-- Id: 4593
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6493

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

function Init()
    indicator:name("aNina indicator");
    indicator:description("aNina indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 10);
    indicator.parameters:addDouble("K", "K", "", 1);
    indicator.parameters:addString("Method", "Method", "", "High/Low");
    indicator.parameters:addStringAlternative("Method", "High/Low", "", "High/Low");
    indicator.parameters:addStringAlternative("Method", "Close", "", "Close");
    indicator.parameters:addInteger("Period_MA", "Period_MA", "", 50);
    indicator.parameters:addInteger("Level", "Level", "", 20);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrMin", "Color Min", "Color Min", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrMid", "Color Mid", "Color Mid", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clrB", "Color BUY", "Color BUY", core.rgb(255, 128, 0));
    indicator.parameters:addColor("clrS", "Color SELL", "Color SELL", core.rgb(255, 0, 128));
    indicator.parameters:addColor("clrE", "Color Exit", "Color Exit", core.rgb(128, 128, 0));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 3, 1, 5);
end

local first;
local source = nil;
local Period;
local K;
local Method;
local Level;
local Period_MA;
local WATR;
local SmaxMin,SminMin,SmaxMax,SminMax,SmaxMid,SminMid;
local TrendMin,TrendMax,TrendMid;
local lineMin,lineMax,lineMid;
local last;
local MA;
local BuffMin=nil;
local BuffMid=nil;
local BuffB=nil;
local BuffS=nil;
local BuffE=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Period_MA=instance.parameters.Period_MA;
    K=instance.parameters.K;
    Method=instance.parameters.Method;
    Level=instance.parameters.Level;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.K .. ", " .. instance.parameters.Method .. ", " .. instance.parameters.Period_MA .. ", " .. instance.parameters.Level .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    WATR = instance:addInternalStream(first+Period, 0);
    SmaxMin = instance:addInternalStream(first+Period, 0);
    SminMin = instance:addInternalStream(first+Period, 0);
    SmaxMax = instance:addInternalStream(first+Period, 0);
    SminMax = instance:addInternalStream(first+Period, 0);
    SmaxMid = instance:addInternalStream(first+Period, 0);
    SminMid = instance:addInternalStream(first+Period, 0);
    TrendMin = instance:addInternalStream(first+Period, 0);
    TrendMax = instance:addInternalStream(first+Period, 0);
    TrendMid = instance:addInternalStream(first+Period, 0);
    lineMin = instance:addInternalStream(first+Period, 0);
    lineMax = instance:addInternalStream(first+Period, 0);
    lineMid = instance:addInternalStream(first+Period, 0);
    last = instance:addInternalStream(first+Period, 0);
    MA = core.indicators:create("EMA", source.close, Period_MA);
    BuffMin = instance:addStream("BuffMin", core.Line, name .. ".Min", "Min", instance.parameters.clrMin, first+Period);
    BuffMid = instance:addStream("BuffMid", core.Line, name .. ".Mid", "Mid", instance.parameters.clrMid, first+Period);
    BuffB = instance:addStream("BuffB", core.Dot, name .. ".BUY", "BUY", instance.parameters.clrB, MA.DATA:first());
    BuffS = instance:addStream("BuffS", core.Dot, name .. ".SELL", "SELL", instance.parameters.clrS, MA.DATA:first());
    BuffE = instance:addStream("BuffE", core.Dot, name .. ".Exit", "Exit", instance.parameters.clrE, MA.DATA:first());
    BuffB:setWidth(instance.parameters.DotSize);
    BuffS:setWidth(instance.parameters.DotSize);
    BuffE:setWidth(instance.parameters.DotSize);
	
	
	BuffMin:setPrecision(math.max(2, instance.source:getPrecision()));
	BuffB:setPrecision(math.max(2, instance.source:getPrecision()));
	BuffS:setPrecision(math.max(2, instance.source:getPrecision()));
	BuffE:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if (period>first+Period) then
    local Sum=0;
    local i;
    for i=Period-1,0,-1 do
     Sum=Sum+(1+(Period-i)/Period)*math.abs(source.high[period-i]-source.low[period-i]);
    end
    WATR[period]=Sum/Period;
    
    local WATRmax=mathex.max(WATR,core.range(first+Period+1,period));
    local WATRmin=mathex.min(WATR,core.range(first+Period+1,period));

    local min=K*WATRmin;
    local max=K*WATRmax;
    local mid=(min+max)/2;
    local c=source.close[period];
    local h=source.high[period];
    local l=source.low[period];
    if Method=="High/Low" then
     SmaxMin[period]=l+2*min;
     SminMin[period]=h-2*min;
     SmaxMax[period]=l+2*max;
     SminMax[period]=h-2*max;
     SmaxMid[period]=l+2*mid;
     SminMid[period]=h-2*mid;
    else
     SmaxMin[period]=c+2*min;
     SminMin[period]=c-2*min;
     SmaxMax[period]=c+2*max;
     SminMax[period]=c-2*max;
     SmaxMid[period]=c+2*mid;
     SminMid[period]=c-2*mid;
    end
    TrendMin[period]=TrendMin[period-1];
    TrendMax[period]=TrendMax[period-1];
    TrendMid[period]=TrendMid[period-1];
    if c>SmaxMin[period-1] then TrendMin[period]=1 elseif c<SminMin[period-1] then TrendMin[period]=-1 end
    if c>SmaxMax[period-1] then TrendMax[period]=1 elseif c<SminMax[period-1] then TrendMax[period]=-1 end
    if c>SmaxMid[period-1] then TrendMid[period]=1 elseif c<SminMid[period-1] then TrendMid[period]=-1 end
    
    if TrendMin[period]>0 and SminMin[period]<SminMin[period-1] then SminMin[period]=SminMin[period-1] end
    if TrendMin[period]<0 and SmaxMin[period]>SmaxMin[period-1] then SmaxMin[period]=SmaxMin[period-1] end
    
    if TrendMax[period]>0 and SminMax[period]<SminMax[period-1] then SminMax[period]=SminMax[period-1] end
    if TrendMax[period]<0 and SmaxMax[period]>SmaxMax[period-1] then SmaxMax[period]=SmaxMax[period-1] end
    
    if TrendMid[period]>0 and SminMid[period]<SminMid[period-1] then SminMid[period]=SminMid[period-1] end
    if TrendMid[period]<0 and SmaxMid[period]>SmaxMid[period-1] then SmaxMid[period]=SmaxMid[period-1] end
    
    lineMin[period]=lineMin[period-1];
    lineMax[period]=lineMax[period-1];
    lineMid[period]=lineMid[period-1]
    if TrendMin[period]>0 then lineMin[period]=SminMin[period]+min elseif TrendMin[period]<0 then lineMin[period]=SmaxMin[period]-min end
    if TrendMax[period]>0 then lineMax[period]=SminMax[period]+max elseif TrendMax[period]<0 then lineMax[period]=SmaxMax[period]-max end
    if TrendMid[period]>0 then lineMid[period]=SminMid[period]+mid elseif TrendMid[period]<0 then lineMid[period]=SmaxMid[period]-mid end
    
    local bsMin=lineMax[period]-max;
    local bsMax=lineMax[period]+max;
    local Stoch1=(lineMin[period]-bsMin)/(2*max);
    local Stoch2=(lineMid[period]-bsMin)/(2*max);
    
    BuffMin[period]=Stoch1;
    BuffMid[period]=Stoch2;
    
    MA:update(mode);
	
	if period > MA.DATA:first() then
    local last_ma=FindLastMA(period);
    last[period]=last[period-1];
    if (BuffMin[period]-BuffMid[period])*(BuffMin[period-1]-BuffMid[period-1])<0 then
     last[period]=0;
     BuffE[period]=BuffMid[period];
     if BuffMin[period]>BuffMid[period] then
      if last_ma~=0 then
       if MA.DATA[last_ma]<source.open[period] then
        BuffB[period]=BuffMid[period];
        if last_ma==period and math.abs(MA.DATA[last_ma]-source.open[period])/source:pipSize()<Level then
         BuffE[period]=BuffMid[period];
        end
       else
        last[period]=period;
       end
      end
     elseif BuffMin[period]<BuffMid[period] then
      if last_ma~=0 then
       if MA.DATA[last_ma]>source.open[period] then
        BuffS[period]=BuffMin[period];
        if last_ma==period and math.abs(MA.DATA[last_ma]-source.open[period])/source:pipSize()<Level then
         BuffE[period]=BuffMin[period];
        end
       else
        last[period]=-period;
       end
      end 
     end
    else
     if last[period]>0 and source.open[period]>MA.DATA[period] then
      BuffB[period]=BuffMid[period];
      last[period]=0;
     end
     if last[period]<0 and source.open[period]<MA.DATA[period] then
      BuffS[period]=BuffMin[period];
      last[period]=0;
     end
    end
    end
   end
end

function FindLastMA(period)
 local i=period;
 while i>=first do
  if (source.close[i]-MA.DATA[i])*(source.open[i]-MA.DATA[i])<0 then
   return i;
  end
  i=i-1;
 end
 return 0;
end

