-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3614

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
    indicator:name("Range indicator");
    indicator:description("Range indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("replaceSource", "t");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("RangeSize", "Range of bar in pips", "", 10);

end

local first;
local source = nil;
local RangeSize;
local BuffUP=nil;
local BuffDN=nil;
local open_t = nil;
local high_t = nil;
local low_t = nil;
local close_t = nil;
local Count_t;
local i;
local open = nil;
local high = nil;
local low = nil;
local close = nil;


function Prepare(nameOnly) 
    source = instance.source;
    RangeSize=instance.parameters.RangeSize;
    first = source:first()+2;
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.RangeSize .. ")";
    instance:name(name);
	if onlyName then
        return ;
    end

	
    open_t = instance:addInternalStream(first, 0);
    high_t = instance:addInternalStream(first, 0);
    low_t = instance:addInternalStream(first, 0);
    close_t = instance:addInternalStream(first, 0);
 
	
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("RB", "RB", open, high, low, close);
end

function CheckBuff(period)
 local ii;
 if Count_t>period then
  for ii=first+1,period,1 do
   open_t[ii-1]=open_t[ii];
   high_t[ii-1]=high_t[ii];
   low_t[ii-1]=low_t[ii];
   close_t[ii-1]=close_t[ii];
  end
  Count_t=Count_t-1;
 end
end

function Update(period, mode)
   if (period==source:size()-1) then
    Count_t=first;
    open_t[Count_t]=source.open[first];
    high_t[Count_t]=source.high[first];
    low_t[Count_t]=source.low[first];
    close_t[Count_t]=source.close[first];
    for i=first+1,period,1 do
     if high_t[Count_t]-low_t[Count_t]>=RangeSize*source:pipSize() then
      Count_t=Count_t+1;
      CheckBuff(period);
      open_t[Count_t]=source.open[i];
      high_t[Count_t]=source.high[i];
      low_t[Count_t]=source.low[i];
      close_t[Count_t]=source.close[i];
     else
      high_t[Count_t]=math.max(high_t[Count_t],source.high[i]);
      low_t[Count_t]=math.min(low_t[Count_t],source.low[i]);
      close_t[Count_t]=source.close[i];
     end
    end 

    for i=first,period,1 do
     local NewPos=i-period+Count_t;
     if NewPos<=first then
      open[i]=nil;
      high[i]=nil;
      low[i]=nil;
      close[i]=nil;
     else
      open[i]=open_t[NewPos];
      high[i]=high_t[NewPos];
      low[i]=low_t[NewPos];
      close[i]=close_t[NewPos];
     end
    end    

   end 
end

