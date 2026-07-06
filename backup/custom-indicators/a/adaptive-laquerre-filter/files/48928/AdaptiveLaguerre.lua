-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27884
-- Id: 8203

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
    indicator:name("Adaptive Laguerre indicator");
    indicator:description("Adaptive Laguerre indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 10);
    indicator.parameters:addInteger("Order", "Order", "", 4);
    indicator.parameters:addBoolean("AdaptiveMode", "Use adaptive mode", "", true);
    indicator.parameters:addInteger("AdaptiveSmooth", "Adaptive smooth", "", 5);
    indicator.parameters:addString("Method", "Adaptive smooth method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addBoolean("ColorMode", "ColorMode", "", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MainClr", "Main color", "Main color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Order;
local Order2;
local AdaptiveMode;
local AdaptiveSmooth;
local Method;
local ColorMode;
local AdaptiveLaguerre=nil;
local diff;
local gamma;
local MA_gamma;
local Ls={};

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Order=instance.parameters.Order;
    AdaptiveMode=instance.parameters.AdaptiveMode;
    AdaptiveSmooth=instance.parameters.AdaptiveSmooth;
    Method=instance.parameters.Method;
    ColorMode=instance.parameters.ColorMode;
    Order2=math.floor(Order/2);
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Order .. ", " .. instance.parameters.AdaptiveSmooth .. ", " .. instance.parameters.Method .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
	
    first = source:first();
    diff=instance:addInternalStream(0, 0);
    gamma=instance:addInternalStream(0, 0);
    local i;
    for i=0,Order-1,1 do
     Ls[i]=instance:addInternalStream(0, 0);
    end
    if AdaptiveMode then
     MA_gamma=core.indicators:create("AVERAGES", gamma, Method, AdaptiveSmooth, false);	  
    end
    AdaptiveLaguerre = instance:addStream("AdaptiveLaguerre", core.Line, name .. ".AdaptiveLaguerre", "AdaptiveLaguerre", instance.parameters.MainClr, first+2*Period);
    AdaptiveLaguerre:setWidth(instance.parameters.widthLinReg);
    AdaptiveLaguerre:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   local i;
   if period>first+2*Period then
   
    diff[period]=math.abs(source[period]-AdaptiveLaguerre[period-1]);
    local sgamma;
    if AdaptiveMode then
	
			 if period<source:first()+1 +Period then
			 return;
			 end
			 
			 local min, max = mathex.minmax(diff, period-Period+1, period);
			 if max-min==0 then
			  gamma[period]=0;
			 else
			  gamma[period]=(diff[period]-min)/(max-min);
			 end
			 
			 if period<MA_gamma.DATA:first() then
			 return;
			 end
			 
			 MA_gamma:update(mode);
			 sgamma=MA_gamma.DATA[period];
    else
     sgamma=10/(Period+9);
    end
    local gam=1-sgamma;
    Ls[0][period]=(1-gam)*source[period]+gam*Ls[0][period-1];
    for i=1,Order-1,1 do
     Ls[i][period]=-gam*Ls[i-1][period]+Ls[i-1][period-1]+gam*Ls[i][period-1];
    end
	
	
    local sum=0;
    for i=1,Order2,1 do
     sum=sum+i*(Ls[i-1][period]+Ls[Order-i][period]);
    end
    local ssum=(1+Order2)*Order2;
    if Order % 2==1 then
     sum=sum+(Order+1)/2*Ls[(Order-1)/2][period];
     ssum=ssum+(Order+1)/2;
    end
	
	
    AdaptiveLaguerre[period]=sum/ssum;
   if ColorMode then
		 if AdaptiveLaguerre[period]>AdaptiveLaguerre[period-1] then
		  AdaptiveLaguerre:setColor(period, instance.parameters.UPclr);
		 elseif AdaptiveLaguerre[period]<AdaptiveLaguerre[period-1] then
		  AdaptiveLaguerre:setColor(period, instance.parameters.DNclr);
		 else
		  AdaptiveLaguerre:setColor(period, instance.parameters.MainClr);
		 end
    end
    
   elseif period>first+Period then 
    diff[period]=math.abs(source[period]-AdaptiveLaguerre[period-1]);
    for i=0,Order-1,1 do
     Ls[i][period]=source[period];
    end
   end
end

