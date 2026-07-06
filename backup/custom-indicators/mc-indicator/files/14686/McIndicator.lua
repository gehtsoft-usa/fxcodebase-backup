-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6396

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
    indicator:name("Mc indicator");
    indicator:description("Mc indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("MinEngulfCandles", "MinEngulfCandles", "", 4);
    indicator.parameters:addBoolean("WaitForCandleClose", "WaitForCandleClose", "", true);
    indicator.parameters:addBoolean("IgnoreWick", "IgnoreWick", "", false);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("TopClr", "Top Color", "Top Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("BottomClr", "Bottom Color", "Bottom Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 1, 1, 5);
end

local first;
local source = nil;
local MinEngulfCandles;
local WaitForCandleClose;
local IgnoreWick;
local BuffsTop={};
local BuffsBottom={};
local BuffTop=nil;
local BuffBottom=nil;

function Prepare(nameOnly)
    source = instance.source;
    MinEngulfCandles=instance.parameters.MinEngulfCandles;
    WaitForCandleClose=instance.parameters.WaitForCandleClose;
    IgnoreWick=instance.parameters.IgnoreWick;
    first = source:first()+MinEngulfCandles;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.MinEngulfCandles .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    local i;
    for i=1,MinEngulfCandles+1,1 do
     BuffTop = instance:addStream("BuffTop" .. i, core.Dot, name .. ".Top", "Top", instance.parameters.TopClr, first);
     BuffBottom = instance:addStream("BuffBottom" .. i, core.Dot, name .. ".Bottom", "Bottom", instance.parameters.BottomClr, first);
     BuffTop:setWidth(instance.parameters.DotSize);
     BuffBottom:setWidth(instance.parameters.DotSize);
     BuffsTop[i]=BuffTop;
     BuffsBottom[i]=BuffBottom;
    end 
end

function isMasterCandle(period)
 local i;
 for i=1,MinEngulfCandles,1 do
  if IgnoreWick then
   local MaxPrice=math.max(source.open[period+i-MinEngulfCandles],source.close[period+i-MinEngulfCandles]);
   local MinPrice=math.min(source.open[period+i-MinEngulfCandles],source.close[period+i-MinEngulfCandles]);
   if MaxPrice>source.high[period-MinEngulfCandles] or MinPrice<source.low[period-MinEngulfCandles] then
    return false;
   end
  else
   if source.high[period+i-MinEngulfCandles]>source.high[period-MinEngulfCandles] or source.low[period+i-MinEngulfCandles]<source.low[period-MinEngulfCandles] then
    return false;
   end
  end
 end
 return true;
end

function DrawLines(period)
 local i=1;
 while BuffsTop[i][period-MinEngulfCandles]>=source.high[period-MinEngulfCandles] and i<=MinEngulfCandles do
  i=i+1;
 end
 core.drawLine(BuffsTop[i],core.range(period-MinEngulfCandles,period),source.high[period-MinEngulfCandles],period-MinEngulfCandles,source.high[period-MinEngulfCandles],period);
 core.drawLine(BuffsBottom[i],core.range(period-MinEngulfCandles,period),source.low[period-MinEngulfCandles],period-MinEngulfCandles,source.low[period-MinEngulfCandles],period);
end

function Update(period, mode)
    
   if  (period<first) then
   return;
   end
   
    if WaitForCandleClose and period==source:size()-1 then
	
	    if isMasterCandle(period-1) then
		 DrawLines(period-1);
		end
		
	else
	
		if isMasterCandle(period) then
		 DrawLines(period);
		end
    end
end

