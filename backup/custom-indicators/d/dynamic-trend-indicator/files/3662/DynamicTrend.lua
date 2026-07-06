-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1839

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
    indicator:name("Dynamic Trend Indicator");
    indicator:description("Dynamic Trend Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addInteger("Percent", "Percent", "Percent", 1);
    indicator.parameters:addInteger("MaxPeriod", "MaxPeriod", "MaxPeriod", 14);
	indicator.parameters:addBoolean("Signal", "Signal Mode", "", false);

    indicator.parameters:addColor("clrLine", "Color of line", "Color of line", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clrUP", "UP color", "UP color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clrDN", "DN color", "DN color", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Percent;
local MaxPeriod;
local Signal;
local Up, Down;

 function Prepare(nameOnly)   
 
    source = instance.source;
    Percent=instance.parameters.Percent;
	 Signal=instance.parameters.Signal;
    MaxPeriod=instance.parameters.MaxPeriod;
    first = source:first()+3+MaxPeriod;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Percent .. ", " .. instance.parameters.MaxPeriod .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    LineBuff = instance:addStream("Line", core.Line, name .. ".Line", "Line", instance.parameters.clrLine, first);
	LineBuff:setWidth(instance.parameters.width1);
    LineBuff:setStyle(instance.parameters.style1);
	if Signal then
	Up = instance:addStream("Long", core.Bar, name .. ".Long", "Long", instance.parameters.clrUP, first);
	Up:setWidth(instance.parameters.width2);
    Up:setStyle(instance.parameters.style2);
	Down = instance:addStream("Short", core.Bar, name .. ".Short", "Short", instance.parameters.clrDN, first);
	Down:setWidth(instance.parameters.width3);
    Down:setStyle(instance.parameters.style3);
	end
    buffUp = instance:createTextOutput ("Up", "Up", "Wingdings", 10, core.H_Center, core.V_Center, instance.parameters.clrUP, first);
    buffDn = instance:createTextOutput ("Dn", "Dn", "Wingdings", 10, core.H_Center, core.V_Center, instance.parameters.clrDN, first);
end

function Update(period, mode)

    buffUp:setNoData (period);
	buffDn:setNoData (period);
	
    if (period<first+MaxPeriod) then
	return;
	end
	
	 local Min, Max= mathex.minmax(source.close, period-1-MaxPeriod+1, period-1);
     if source.close[period]<LineBuff[period-1] then	 
      LineBuff[period]=Max-Percent*source:pipSize();
     else
      LineBuff[period]=Min+Percent*source:pipSize();
     end
     if source.close[period-3]>LineBuff[period-2] and source.close[period-2]<LineBuff[period-3] then
      buffUp:set(period, source.low[period]-10*source:pipSize(), "\225", "");
		  if Signal then
		  Up[period]=  source.low[period]-10*source:pipSize();
		  end
     end
     if source.close[period-2]<LineBuff[period-1] and source.close[period-2]>LineBuff[period-3] then
      buffDn:set(period, source.high[period]-10*source:pipSize(), "\226", "");
		  if Signal then
		  Down[period]= source.high[period]-10*source:pipSize();
		  end
     end
 
end

