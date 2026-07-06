-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6717

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
    indicator:name("SVE_Trends_Trail indicator");
    indicator:description("SVE_Trends_Trail indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("ATR_Mult", "ATR multiplication", "", 2.8, 1, 10);
    indicator.parameters:addInteger("ATR_Period", "ATR_Period", "", 10, 1, 100);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local ATR_Mult;
local ATR_Period;
local HL;
local diff2;
local support;
local Wilder;
local trends=nil;

function Prepare(nameOnly)
    source = instance.source;
    ATR_Mult=instance.parameters.ATR_Mult;
    ATR_Period=instance.parameters.ATR_Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.ATR_Mult .. ", " .. instance.parameters.ATR_Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    
    HL = instance:addInternalStream(0, 0);
    diff2 = instance:addInternalStream(0, 0);
    support = instance:addInternalStream(0, 0);
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
	
    Wilder = core.indicators:create("AVERAGES", diff2, "Wilder", ATR_Period, false);	
	first = Wilder.DATA:first();
    trends = instance:addStream("trends", core.Line, name .. ".trends", "trends", instance.parameters.clr, first);
    trends:setWidth(instance.parameters.widthLinReg);
    trends:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if (period<=source:first()) then 
    support[period]=source.close[period]; 
    trends[period]=source.close[period];   
   return;
   end
   
   
    HL[period]=source.high[period]-source.low[period];
	
	
	 if period<=(source:first()+ATR_Period) then 
	 return;
	 end
	
    local HiLo=math.min(HL[period],1.5*core.avg(HL,period-ATR_Period+1,period));
    local Href;
    if source.low[period]<=source.high[period-1] then
     Href=source.high[period]-source.close[period-1];
    else
     Href=source.high[period]-source.close[period-1]-(source.low[period]-source.high[period-1])/2;
    end
    local Lref;
    if source.high[period]>=source.low[period-1] then
     Lref=source.close[period-1]-source.low[period];
    else
     Lref=source.close[period-1]-source.low[period]-(source.low[period-1]-source.high[period])/2;
    end
    local diff1=math.max(HiLo,Href);
    diff2[period]=math.max(diff1,Lref);
	
	 if (period<=first)  then
	 return;
	 end
	 
    Wilder:update(mode);
	
	
    local ATRmod=Wilder.DATA[period];
    local loss=ATR_Mult*ATRmod;
    local resistance=source.close[period]+loss;
    if source.low[period]>=source.low[period-2] and source.low[period-1]>=source.low[period-2] and source.low[period-3]>=source.low[period-2] and source.low[period-4]>=source.low[period-2] then
     support[period]=source.low[period-2];
    elseif source.low[period]>source.high[period-1]*1.0013 then
     support[period]=source.high[period-1]*0.9945;
    elseif source.low[period]>support[period-1]*1.1 then
     support[period]=support[period-1]*1.05;
    else
     support[period]=support[period-1];
    end  
    if source.high[period]>trends[period-1]and source.high[period-1]>trends[period-1] then
     trends[period]=math.max(trends[period-1],support[period]);
    elseif source.high[period]<trends[period-1] and source.high[period-1]<trends[period-1] then
     trends[period]=math.min(trends[period-1],resistance);
    elseif source.high[period]>trends[period-1] then
     trends[period]=support[period];
    else
     trends[period]=resistance;
    end  
    
  
end

