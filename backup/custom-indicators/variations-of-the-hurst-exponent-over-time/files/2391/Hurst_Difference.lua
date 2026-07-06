-- Id: 837
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1258

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
    indicator:name("Hurst Difference");
    indicator:description("Hurst Difference");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 30);
    indicator.parameters:addString("app_price", "app_price", "", "close");
    indicator.parameters:addStringAlternative("app_price", "close", "", "close");
    indicator.parameters:addStringAlternative("app_price", "open", "", "open");
    indicator.parameters:addStringAlternative("app_price", "high", "", "high");
    indicator.parameters:addStringAlternative("app_price", "low", "", "low");
    indicator.parameters:addStringAlternative("app_price", "median", "", "median");
    indicator.parameters:addStringAlternative("app_price", "typical", "", "typical");
    indicator.parameters:addStringAlternative("app_price", "weighted", "", "weighted");
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr_Line", "Color of Line", "Color of Line", core.rgb(255, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

end

local first;
local source = nil;
local Period;
local app_price;
local Price;
local fdi;
local HurstBuff=nil;

 function Prepare(nameOnly)   
    source = instance.source;
    Period=instance.parameters.Period;
    app_price=instance.parameters.app_price;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.app_price .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    Price = instance:addInternalStream(0, 0);
    fdi = instance:addInternalStream(0, 0);
    HurstBuff = instance:addStream("HurstBuff", core.Line, name .. ".HurstBuff", "HurstBuff", instance.parameters.clr_Line, first+Period);
    HurstBuff:setPrecision(math.max(2, instance.source:getPrecision()));
	HurstBuff:setWidth(instance.parameters.width);
    HurstBuff:setStyle(instance.parameters.style);
	
    HurstBuff:addLevel(0);
end

function Update(period, mode)
    if app_price=="close" then
     Price[period]=source.close[period];
    elseif app_price=="open" then
     Price[period]=source.open[period];
    elseif app_price=="high" then
     Price[period]=source.high[period];
    elseif app_price=="low" then
     Price[period]=source.low[period];
    elseif app_price=="median" then
     Price[period]=(source.high[period]+source.low[period])/2.;
    elseif app_price=="typical" then
     Price[period]=(source.high[period]+source.low[period]+source.close[period])/3.;
    else
     Price[period]=(source.high[period]+source.low[period]+2.*source.close[period])/4.;
    end
     
    if (period>first+Period) then
 
	 local priceMin, priceMax= mathex.minmax(Price, period-Period+1, period);
     local length=0.;
     local priorDiff=0.;
     local sum=0.;
     
     for i=period-Period+1,period,1 do
      if priceMax-priceMin>0. then
       diff=(Price[i]-priceMin)/(priceMax-priceMin);
       if i>period-Period+1 then
        length=length+math.sqrt(math.pow(diff-priorDiff,2)+(1./math.pow(Period,2)));
       end
       priorDiff=diff;
      end
     end
     
     if length>0. then
      fdi[period]=1.+(math.log(length)+math.log(2.))/math.log(2.*(Period-1))
     else
      fdi[period]=0.;
     end
     
     HurstBuff[period]=fdi[period-1]-fdi[period];

    end 
end

