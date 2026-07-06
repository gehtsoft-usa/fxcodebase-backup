-- Id: 22452

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66826

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

 

-- initializes the indicator
function Init()

    indicator:name("Dochian Channel of Moving Average")
    indicator:description("The simple trend-following indicator. Shows highest high and lowest low for the specified number of periods.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
	indicator.parameters:addGroup("MA Calculation");
	indicator.parameters:addInteger("Period", "MA Period", "Period" , 20, 1, 2000);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
  
  
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods", "", 20, 2, 10000);
    indicator.parameters:addString("AC", "Analyze the current period", "", "yes");
    indicator.parameters:addStringAlternative("AC", "no", "", "no");
    indicator.parameters:addStringAlternative("AC", "yes", "", "yes");
	
	indicator.parameters:addString("SM", "Show middle line", "", "no");
    indicator.parameters:addStringAlternative("SM", "no", "", "no");
    indicator.parameters:addStringAlternative("SM", "yes", "", "yes");
	
 
	
	
	indicator.parameters:addGroup("Line Style");
    indicator.parameters:addColor("clrDU", "Color of the Up line", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clrDN", "Color of the Down line", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clrDM", "Color of the middle line", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE); 
end

local first = 0;
local n = 0;
local ac = true;
local sm = false;
local source = nil;
local dn = nil;
local du = nil;
local dm = nil;
local High, Low;
local Method, Period; 
local Size;
local ShowLabel;
-- initializes the instance of the indicator
function Prepare(nameOnly) 
    source = instance.source;
    n = instance.parameters.N;
	
	
	 local name = profile:id() .. "(" .. source:name() .. "," .. n .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    ac = (instance.parameters.AC == "yes");
    sm = (instance.parameters.SM == "yes"); 

    Method=instance.parameters.Method;
	Period=instance.parameters.Period;
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	High = core.indicators:create(Method, source.high, Period);
	Low = core.indicators:create(Method, source.low, Period);
	
    first = n + High.DATA:first() - 1;
    if (not ac) then
        first = first + 1;
    end
   
    du = instance:addStream("DU", core.Line, name .. ".DU", "DU", instance.parameters.clrDU,  first)
	du:setWidth(instance.parameters.width1);
    du:setStyle(instance.parameters.style1);
    dn = instance:addStream("DN", core.Line, name .. ".DN", "DN", instance.parameters.clrDN,  first)
	dn:setWidth(instance.parameters.width2);
    dn:setStyle(instance.parameters.style2);
    if (sm) then
        dm = instance:addStream("DM", core.Line, name .. ".DM", "DM", instance.parameters.clrDM,  first)
		dm:setWidth(instance.parameters.width3);
        dm:setStyle(instance.parameters.style3);
    end
	 
end


 
-- calculate the value
function Update(period)


    High:update(mode);
	Low:update(mode);
	
    if (period< first) then
	return;
	end
     
    
 	
        if (ac) then
            dn[period] = mathex.min(Low.DATA, period-n+1, period);
			du[period] = mathex.max(High.DATA, period-n+1, period);
        else
            dn[period] = mathex.min(Low.DATA, period-n+1-1, period-1);
			du[period] = mathex.max(High.DATA, period-n+1-1, period-1);
        end		
        
	
	
	     if (sm) then
            dm[period] = (du[period] + dn[period]) / 2;
        end
end

