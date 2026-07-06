-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1169

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
    indicator:name("ASCTrendK indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("RISK", "RISK", "", 3);
end

local first;
local RISK;
local source = nil;
local open = nil;
local high = nil;
local low = nil;
local close = nil;

function Prepare(nameOnly)
    source = instance.source;
    RISK=instance.parameters.RISK;
    first = source:first()+10;
    local name = profile:id() .. "(" .. source:name() .. ", " .. RISK .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Table_value2=instance:addInternalStream(0, 0);
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("HA", "HA", open, high, low, close);
end

function Update(period, mode)
    if (period<first) then
	return;
	end
	
     local x1=67+RISK;
     local x2=33-RISK;
     local ASC_Trend_Up=0; 
     local ASC_Trend_Down=0; 
     local SummRange=0; 
     local AvgRange=0;
     for u=0,9,1 do
      SummRange=SummRange+source.high[period-u]-source.low[period-u];
     end
     AvgRange=SummRange/10.;
     local WprPeriod=3+RISK*2;
     for u=0,9,1 do
      if math.abs(source.open[period-u]-source.close[period-u-1])>=AvgRange*2. then
       WprPeriod=3;
      end
     end
     for u=0,6,1 do
      if math.abs(source.close[period-u-3]-source.close[period-u])>=AvgRange*4.6 then
       WprPeriod=4;
      end
     end
     local WPR=-(core.max(source.high,core.rangeTo(period,WprPeriod))-source.close[period])*100./(core.max(source.high,core.rangeTo(period,WprPeriod))-core.min(source.low,core.rangeTo(period,WprPeriod)));
     local WprAbs=100+WPR;
     if WprAbs<x2 then
      open[period]=source.close[period];
      close[period]=source.open[period];
      high[period]=source.low[period];
      low[period]=source.high[period];
     end
     if WprAbs>x1 then
      open[period]=source.open[period];
      close[period]=source.close[period];
      high[period]=source.high[period];
      low[period]=source.low[period];
     end
 
end

