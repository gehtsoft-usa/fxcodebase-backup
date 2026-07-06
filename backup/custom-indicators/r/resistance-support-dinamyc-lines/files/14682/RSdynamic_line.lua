-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6306
-- Id: 4554

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
    indicator:name("RS dynamic line indicator");
    indicator:description("RS dynamic line indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 14);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr1", "Color 1", "Color 1", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clr2", "Color 2", "Color 2", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clr3", "Color 3", "Color 3", core.rgb(0, 0, 255));
    indicator.parameters:addColor("clr4", "Color 4", "Color 4", core.rgb(0, 255, 255));
end

local first;
local source = nil;
local Period;
local MA1, MA2, MA3, MA4;
local Stream1, Stream2, Stream3, Stream4;
local Buff1=nil;
local Buff2=nil;
local Buff3=nil;
local Buff4=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    
    Stream1 = instance:addInternalStream(source:first()+Period, 0);
    Stream2 = instance:addInternalStream(source:first()+Period, 0);
    Stream3 = instance:addInternalStream(source:first()+Period, 0);
    Stream4 = instance:addInternalStream(source:first()+Period, 0);
    MA1 = core.indicators:create("MVA", Stream1, Period);
    MA2 = core.indicators:create("MVA", Stream2, Period);
    MA3 = core.indicators:create("MVA", Stream3, Period/2);
    MA4 = core.indicators:create("MVA", Stream4, Period);
    
    first =  MA4.DATA:first();
    Buff1 = instance:addStream("Buff1", core.Line, name .. ".Stream1", "Stream1", instance.parameters.clr1, first);
    Buff2 = instance:addStream("Buff2", core.Line, name .. ".Stream2", "Stream2", instance.parameters.clr2, first);
    Buff3 = instance:addStream("Buff3", core.Line, name .. ".Stream3", "Stream3", instance.parameters.clr3, first);
    Buff4 = instance:addStream("Buff4", core.Line, name .. ".Stream4", "Stream4", instance.parameters.clr4, first);
end

function Update(period, mode)
   if (period< source:first()+Period) then
   return;
   end
   
   
    local HHV=mathex.max(source,core.rangeTo(period,Period));
    local LLV=mathex.min(source,core.rangeTo(period,Period));
    local HHV2=mathex.max(source,core.rangeTo(period,Period/2));
    local LLV2=mathex.min(source,core.rangeTo(period,Period/2));
    local a1=(HHV+LLV+source[period])/3;
    Stream1[period]=a1*2-HHV;
    Stream2[period]=a1*2-LLV;
    Stream3[period]=(HHV2+LLV2+source[period])/3;
    Stream4[period]=(Stream1[period]+Stream2[period]+Stream3[period])/3;
    
	if period< first then
	return;
	end
	
     MA1:update(mode);
     MA2:update(mode);
     MA3:update(mode);
     MA4:update(mode);
     Buff1[period]=MA1.DATA[period];
     Buff2[period]=MA2.DATA[period];
     Buff3[period]=MA3.DATA[period];
     Buff4[period]=MA4.DATA[period];
  
    
end

