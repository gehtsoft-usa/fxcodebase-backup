-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=10399


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
    indicator:name("MBKAsctrend3 indicator");
    indicator:description("MBKAsctrend3 indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("WPRPeriod1", "Period for WPR1", "", 9);
    indicator.parameters:addInteger("WPRPeriod2", "Period for WPR2", "", 33);
    indicator.parameters:addInteger("WPRPeriod3", "Period for WPR3", "", 77);
    indicator.parameters:addInteger("Swing", "Swing", "", 3);
    indicator.parameters:addInteger("AverSwing", "Average swing", "", -5);
    indicator.parameters:addInteger("W1", "Weight for WPR1", "", 1);
    indicator.parameters:addInteger("W2", "Weight for WPR2", "", 3);
    indicator.parameters:addInteger("W3", "Weight for WPR3", "", 1);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 3, 1, 5);
end

local first;
local source = nil;
local WPRPeriod1;
local WPRPeriod2;
local WPRPeriod3;
local Swing;
local AverSwing;
local W1;
local W2;
local W3;
local MBKAsctrend=nil;
local WPR1;
local WPR2;
local WPR3;
local MaxPeriod;
local UpLevel;
local DnLevel;
local Up1Level;
local Dn1Level;
local trend;
local RangeStream;
local SSP;

 function Prepare(nameOnly)  
    source = instance.source;
    WPRPeriod1=instance.parameters.WPRPeriod1;
    WPRPeriod2=instance.parameters.WPRPeriod2;
    WPRPeriod3=instance.parameters.WPRPeriod3;
    Swing=instance.parameters.Swing;
    AverSwing=instance.parameters.AverSwing;
    local SumWeight=instance.parameters.W1+instance.parameters.W2+instance.parameters.W3;
    W1=instance.parameters.W1/SumWeight;
    W2=instance.parameters.W2/SumWeight;
    W3=instance.parameters.W3/SumWeight;    
    MaxPeriod=math.max(WPRPeriod1,WPRPeriod2,WPRPeriod3, 10);
	first = source:first() +MaxPeriod;
	
	 local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.WPRPeriod1 .. ", " .. instance.parameters.WPRPeriod2 .. ", " .. instance.parameters.WPRPeriod3 .. ", " .. instance.parameters.Swing .. ", " .. instance.parameters.AverSwing .. ", " .. instance.parameters.W1 .. ", " .. instance.parameters.W2 .. ", " .. instance.parameters.W3 .. ")";
    instance:name(name);
	if   (nameOnly) then
        return;
    end
	
	
	
    WPR1 = core.indicators:create("RLW", source, WPRPeriod1);
    WPR2 = core.indicators:create("RLW", source, WPRPeriod2);
    WPR3 = core.indicators:create("RLW", source, WPRPeriod3);
    trend = instance:addInternalStream(0, 0);
    RangeStream = instance:addInternalStream(0, 0);
    UpLevel=67+Swing;
    DnLevel=33-Swing;
    Up1Level=50-AverSwing;
    Dn1Level=50+AverSwing;
    SSP=10;
   
    MBKAsctrend = instance:addStream("MBKAsctrend", core.Dot, name .. ".MBKAsctrend", "MBKAsctrend", instance.parameters.UPclr, first);
    MBKAsctrend:setWidth(instance.parameters.DotSize);
end

function Update(period, mode)


   RangeStream[period]=source.high[period]-source.low[period];
   if (period<first) then
   return;
   end    
    WPR1:update(mode);
    WPR2:update(mode);
    WPR3:update(mode);
    local WPRvalue=W1*(WPR1.DATA[period]+100)+W2*(WPR2.DATA[period]+100)+W3*(WPR3.DATA[period]+100);
    local WPRlong=WPR3.DATA[period]+100;
    trend[period]=trend[period-1];
    if WPRvalue<DnLevel and WPRlong<=Dn1Level then
     trend[period]=-1;
    end
    if WPRvalue>UpLevel and WPRlong>=Up1Level then
     trend[period]=1;
    end
    if trend[period-1]~=trend[period] then
     local Range=mathex.avg(RangeStream,core.rangeTo(period,SSP));
     if trend[period]>0 then
      MBKAsctrend[period]=source.low[period]-Range*0.8;
      MBKAsctrend:setColor(period,instance.parameters.UPclr)
     else
      MBKAsctrend[period]=source.high[period]+Range*0.8;
      MBKAsctrend:setColor(period,instance.parameters.DNclr)
     end
    end
   
   
end

