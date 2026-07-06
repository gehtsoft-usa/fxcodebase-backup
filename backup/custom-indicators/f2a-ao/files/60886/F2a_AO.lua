-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=36260
-- Id: 9087

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
    indicator:name("F2a_AO indicator");
    indicator:description("F2a_AO indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Filter", "Filter", "", 3);
    indicator.parameters:addInteger("FastPeriod", "Fast period", "", 13);
    indicator.parameters:addInteger("SlowPeriod", "Slow period", "", 144);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("ArrowSize", "Arrow size", "", 10);
end

local first;
local source = nil;
local Filter;
local FastPeriod;
local SlowPeriod;
local Series;
local Range;
local trend;
local Filter_EMA;
local Fast_EMA;
local Slow_EMA;
local UP=nil;
local DN=nil;
local Count={};
local Value1={};
local Value2={};
local count;

function Prepare(nameOnly)
    source = instance.source;
    Filter=instance.parameters.Filter;
    FastPeriod=instance.parameters.FastPeriod;
    SlowPeriod=instance.parameters.SlowPeriod;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Filter .. ", " .. instance.parameters.FastPeriod .. ", " .. instance.parameters.SlowPeriod .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
   
    Series=instance:addInternalStream(source:first() , 0);
    Range=instance:addInternalStream(source:first() , 0);
    trend=instance:addInternalStream(source:first() , 0);
    Filter_EMA = core.indicators:create("EMA", Series, Filter);
    Fast_EMA = core.indicators:create("EMA", Series, FastPeriod);
    Slow_EMA = core.indicators:create("EMA", Series, SlowPeriod);
	
	 first = math.max(Filter_EMA.DATA:first(),Fast_EMA.DATA:first(),Slow_EMA.DATA:first());
    UP = instance:createTextOutput("UP", "UP", "Wingdings", instance.parameters.ArrowSize, core.H_Center, core.V_Top, instance.parameters.UPclr, 0);
    DN = instance:createTextOutput("DN", "DN", "Wingdings", instance.parameters.ArrowSize, core.H_Center, core.V_Bottom, instance.parameters.DNclr, 0);
    local i;
    for i=0, 4, 1 do
     Count[i]=0;
     Value1[i]=0;
     Value2[i]=0;
    end
    count=1;
end

function Update(period, mode)
   if period<source:first()  then
   return;
   end
   
    Series[period]=(5*source.close[period]+2*source.open[period]+source.high[period]+source.low[period])/9;
    Range[period]=source.high[period]-source.low[period];
	
	
    Filter_EMA:update(mode);
    Fast_EMA:update(mode);
    Slow_EMA:update(mode);
	
	if period < first then
	return;
	end
	
    Value1[Count[0]]=Fast_EMA.DATA[period]-Slow_EMA.DATA[period];
    Value2[Count[0]]=Filter_EMA.DATA[period];
    local current=Value2[Count[0]];
    local prev=Value2[Count[1]];
	
    local Range_=mathex.avg(Range, period-9, period);
    trend[period]=trend[period-1];
    UP:setNoData(period);
    DN:setNoData(period);
    if trend[period]<=0 then
     if Value1[Count[0]]>Value1[Count[1]] and current>=prev and Value1[Count[1]]<=Value1[Count[2]] then
      UP:set(period, source.low[period]-Range_/2, "\225");
      if period~=source:size()-1 then
       trend[period]=1;
      end
     end
    end
    if trend[period]>=0 then
     if Value1[Count[0]]<Value1[Count[1]] and current<=prev and Value1[Count[1]]>=Value1[Count[2]] then
      DN:set(period, source.high[period]+Range_/2, "\226");
      if period~=source:size()-1 then
       trend[period]=-1;
      end 
     end
    end
    
    if period~=source:size()-1 then
     count=count-1;
     if count<0 then
      count=2;
     end
     local i;
     for i=0, 2, 1 do
      if i+count>2 then
       Count[i]=i+count-3;
      else
       Count[i]=i+count;
      end
     end
    end
    
end

