-- Id: 841

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1262

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

function Init()
    indicator:name("Ehlers CG Oscillator");
    indicator:description("Ehlers CG Oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addInteger("Length", "Length", "", 10);

    indicator.parameters:addColor("clr_buff1", "Color of Buff1", "Color of Buff1", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clr_buff2", "Color of Buff2", "Color of Buff2", core.rgb(0, 128, 0));
end

local first;
local source = nil;
local Length;
local Price;
local Buff1=nil;
local Buff2=nil;

function Prepare(nameOnly)   
    source = instance.source;
    Length=instance.parameters.Length;
    Price = instance:addInternalStream(0, 0);
    first = source:first()+Length;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Length .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
    Buff1 = instance:addStream("Buff1", core.Line, name .. ".Buff1", "Buff1", instance.parameters.clr_buff1, first);
    Buff1:setPrecision(math.max(2, instance.source:getPrecision()));
    Buff2 = instance:addStream("Buff2", core.Line, name .. ".Buff2", "Buff2", instance.parameters.clr_buff2, first);
    Buff2:setPrecision(math.max(2, instance.source:getPrecision()));
    Buff1:addLevel(0);
end

function Update(period, mode)
    if (period>first) then
     local Num=0.;
     local Demon=0.;
     Price[period]=(source.high[period]+source.low[period])/2.;
     for i=0,Length-1,1 do
      Num=Num+(i+1)*Price[period-i];
      Demon=Demon+Price[period-i];
     end
     if Demon~=0. then
      Buff1[period]=-Num/Demon+(Length+1.)/2.;
     else
      Buff1[period]=0.;
     end
     Buff2[period]=Buff1[period-1];
    end 
end

