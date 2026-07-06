-- Id: 11271
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60389

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
    indicator:name("AwesomeMod oscillator");
    indicator:description("AwesomeMod oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Short_Period", "Short period", "", 18);
    indicator.parameters:addInteger("Medium_Period", "Medium period", "", 40);
    indicator.parameters:addInteger("Long_Period", "Long period", "", 200);
    indicator.parameters:addInteger("AO_Fast_Period", "AO fast period", "", 12);
    indicator.parameters:addInteger("AO_Slow_Period", "AO slow period", "", 18);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("SlowUPclr", "Slow AO UP color", "Slow AO color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("SlowDNclr", "Slow AO DN color", "Slow DN color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("FastUPclr", "Fast AO UP color", "Fast AO color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("FastDNclr", "Fast AO DN color", "Fast DN color", core.rgb(255, 128, 0));
end

local first,FIRST;
local source = nil;
local Short_Period;
local Medium_Period;
local Long_Period;
local AO_Fast_Period;
local AO_Slow_Period;
local Short_EMA, Medium_EMA, Long_EMA;
local AO_Slow_Tmp, AO_Fast_Tmp;
local Slow_MA, Fast_MA;
local AO_Slow=nil;
local AO_Fast=nil;

function Prepare(nameOnly)  
    source = instance.source;
    Short_Period=instance.parameters.Short_Period;
    Medium_Period=instance.parameters.Medium_Period;
    Long_Period=instance.parameters.Long_Period;
    AO_Fast_Period=instance.parameters.AO_Fast_Period;
    AO_Slow_Period=instance.parameters.AO_Slow_Period;
	
	 local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Short_Period .. ", " .. instance.parameters.Medium_Period .. ", " .. instance.parameters.Long_Period .. ", " .. instance.parameters.AO_Fast_Period .. ", " .. instance.parameters.AO_Slow_Period .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
   
    AO_Slow_Tmp=instance:addInternalStream(0, 0);
    AO_Fast_Tmp=instance:addInternalStream(0, 0);
    Short_EMA = core.indicators:create("EMA", source, Short_Period);
    Medium_EMA = core.indicators:create("EMA", source, Medium_Period);
	  Long_EMA = core.indicators:create("EMA", source, Long_Period);
	 first = math.max(Short_EMA.DATA:first(), Medium_EMA.DATA:first(), Long_EMA.DATA:first()) ;
	
  
    Slow_MA = core.indicators:create("MVA", AO_Slow_Tmp, AO_Slow_Period);
    Fast_MA = core.indicators:create("MVA", AO_Fast_Tmp, AO_Fast_Period);
	
	
	FIRST = math.max(Slow_MA.DATA:first(), Fast_MA.DATA:first()) ;
	 
   
    AO_Slow = instance:addStream("AO_Slow", core.Bar, name .. ".AO_Slow", "AO_Slow", instance.parameters.SlowUPclr, FIRST);
    AO_Fast = instance:addStream("AO_Fast", core.Bar, name .. ".AO_Fast", "AO_Fast", instance.parameters.FastUPclr, FIRST);
	
	 AO_Slow:setPrecision(math.max(2, instance.source:getPrecision())); 
	 AO_Fast:setPrecision(math.max(2, instance.source:getPrecision())); 
end

function Update(period, mode)
   if period<first then
   return;
   end
   
    Short_EMA:update(mode);
    Medium_EMA:update(mode);
    Long_EMA:update(mode);
    AO_Fast_Tmp[period]=100*(Short_EMA.DATA[period]/Medium_EMA.DATA[period]-1);
    AO_Slow_Tmp[period]=100*(Medium_EMA.DATA[period]/Long_EMA.DATA[period]-1);
    Slow_MA:update(mode);
    Fast_MA:update(mode);
	
	 if period<FIRST then
    return;
    end
   
    AO_Slow[period]=Slow_MA.DATA[period];
    AO_Fast[period]=Fast_MA.DATA[period];
    if AO_Slow[period]>=AO_Slow[period-1] then
     AO_Slow:setColor(period, instance.parameters.SlowUPclr);
    else
     AO_Slow:setColor(period, instance.parameters.SlowDNclr);
    end
    if AO_Fast[period]>=AO_Fast[period-1] then
     AO_Fast:setColor(period, instance.parameters.FastUPclr);
    else
     AO_Fast:setColor(period, instance.parameters.FastDNclr);
    end
  
end

