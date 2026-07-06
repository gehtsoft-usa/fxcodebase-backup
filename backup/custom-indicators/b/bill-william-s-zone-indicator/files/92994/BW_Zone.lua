-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60393
-- Id: 11279

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
    indicator:name("Bill William's zone indicator");
    indicator:description("Bill William's zone indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Fast_Period", "Fast period", "", 5);
    indicator.parameters:addInteger("Slow_Period", "Slow period", "", 35);
    indicator.parameters:addInteger("AD_Period", "AD period", "", 5);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 3, 1, 5);
end

local first;
local source = nil;
local Fast_Period;
local Slow_Period;
local AD_Period;
local UP=nil;
local DN=nil;
local AO, AC;
local Dir;

function Prepare(nameOnly)
    source = instance.source;
    Fast_Period=instance.parameters.Fast_Period;
    Slow_Period=instance.parameters.Slow_Period;
    AD_Period=instance.parameters.AD_Period;
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Fast_Period .. ", " .. instance.parameters.Slow_Period .. ", " .. instance.parameters.AD_Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Dir=instance:addInternalStream(0, 0);
    AO = core.indicators:create("AO", source, Fast_Period, Slow_Period);
    AC = core.indicators:create("AC", source, Fast_Period, Slow_Period, AD_Period);
	
	first = math.max(AO.DATA:first(),AC.DATA:first())
    UP = instance:addStream("UP", core.Dot, name .. ".UP", "UP", instance.parameters.UPclr, first);
    DN = instance:addStream("DN", core.Dot, name .. ".DN", "DN", instance.parameters.DNclr, first);
    UP:setWidth(instance.parameters.DotSize);
    DN:setWidth(instance.parameters.DotSize);
end

function Update(period, mode)
 
    AO:update(mode);
    AC:update(mode);
	
	 if period>first then
    Dir[period]=Dir[period-1];
    if AO.DATA[period]>AO.DATA[period-1] and AO.DATA[period-1]>AO.DATA[period-2] and AO.DATA[period-2]>AO.DATA[period-3] and AO.DATA[period-3]>AO.DATA[period-4] and AC.DATA[period]>AC.DATA[period-1] and AC.DATA[period-1]>AC.DATA[period-2] and AC.DATA[period-2]>AC.DATA[period-3] and AC.DATA[period-3]>AC.DATA[period-4] then
     if Dir[period]~=1 then
      Dir[period]=1;
      UP[period]=source.high[period];
     else
      UP[period]=nil; 
     end
    else
     UP[period]=nil;
    end
    if AO.DATA[period]<AO.DATA[period-1] and AO.DATA[period-1]<AO.DATA[period-2] and AO.DATA[period-2]<AO.DATA[period-3] and AO.DATA[period-3]<AO.DATA[period-4] and AC.DATA[period]<AC.DATA[period-1] and AC.DATA[period-1]<AC.DATA[period-2] and AC.DATA[period-2]<AC.DATA[period-3] and AC.DATA[period-3]<AC.DATA[period-4] then
     if Dir[period]~=-1 then
      Dir[period]=-1;
      DN[period]=source.low[period];
     else
      DN[period]=nil; 
     end
    else
     DN[period]=nil;
    end
    if (AO.DATA[period]<AO.DATA[period-1] or AC.DATA[period]<AC.DATA[period-1]) and Dir[period]==1 then
     Dir[period]=0;
    elseif (AO.DATA[period]>AO.DATA[period-1] or AC.DATA[period]>AC.DATA[period-1]) and Dir[period]==-1 then
     Dir[period]=0;
    end
   elseif period==first then
    Dir[period]=0; 
   end 
end

