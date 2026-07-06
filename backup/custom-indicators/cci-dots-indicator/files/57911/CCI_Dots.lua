-- Id: 8894

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=34071

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
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
 

function Init()
    indicator:name("CCI dots indicator");
    indicator:description("CCI dots indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("CCI_Period", "CCI period", "", 14);
    indicator.parameters:addInteger("Period", "Period", "", 10);
	
	indicator.parameters:addGroup("Filter Calculation");
	indicator.parameters:addBoolean("Use_Filter" , "Use Filter" , "", true);
	indicator.parameters:addString("MA_Price", "MA Price Source", "", "close");
    indicator.parameters:addStringAlternative("MA_Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("MA_Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("MA_Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("MA_Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("MA_Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("MA_Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("MA_Price", "WEIGHTED", "", "weighted");	
	
	indicator.parameters:addInteger("MA_Period", "MA Period", "", 14);
  
	indicator.parameters:addString("MA_Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("MA_Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("MA_Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("MA_Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("MA_Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("MA_Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("MA_Method", "WMA", "WMA" , "WMA");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP dot color", "UP dot color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DNclr", "DN dot color", "DN dot color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 3, 1, 5);
end

local first;
local source = nil;
local CCI_Period;
local Period;
local CCI;
local UP=nil;
local DN=nil;
local MA_Method, MA_Period, MA_Price,Use_Filter,MA;
function Prepare(nameOnly)
    source = instance.source;
    CCI_Period=instance.parameters.CCI_Period;
	MA_Method=instance.parameters.MA_Method;
	MA_Period=instance.parameters.MA_Period;
	MA_Price=instance.parameters.MA_Price;
	Use_Filter=instance.parameters.Use_Filter;
	
    Period=instance.parameters.Period;
    
    CCI = core.indicators:create("CCI", source, CCI_Period);
    assert(core.indicators:findIndicator(MA_Method) ~= nil, MA_Method .. " indicator must be installed");
	MA = core.indicators:create(MA_Method, source[MA_Price], MA_Period);
	first = math.max(CCI.DATA:first(), Period, MA.DATA:first());
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.CCI_Period .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    UP = instance:addStream("UP", core.Dot, name .. ".UP", "UP", instance.parameters.UPclr, first);
    DN = instance:addStream("DN", core.Dot, name .. ".DN", "DN", instance.parameters.DNclr, first);
    UP:setWidth(instance.parameters.DotSize);
    DN:setWidth(instance.parameters.DotSize);
end

function Update(period, mode)

    if Use_Filter then
	MA:update(mode);
	end	
	CCI:update(mode);
	
   if period<first then
   return;
   end
    
    local Range=(mathex.avg(source.high, period-Period+1, period)-mathex.avg(source.low, period-Period+1, period))/2;
	
    if CCI.DATA[period-1]>=0 and CCI.DATA[period]<0
	and (not Use_Filter or source.close[period]< MA.DATA[period]  )
	then
     UP[period]=source.high[period]+Range;
     DN[period]=nil;
    elseif CCI.DATA[period-1]<=0 and CCI.DATA[period]>0 
	and (not Use_Filter or source.close[period]> MA.DATA[period]  )
	then
     UP[period]=nil;
     DN[period]=source.low[period]-Range;
    else
     UP[period]=nil;
     DN[period]=nil; 
    end
   
end

