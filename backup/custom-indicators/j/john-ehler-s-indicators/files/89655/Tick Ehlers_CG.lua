-- Id: 10043

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1262

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
    indicator:name("Ehlers CG Oscillator");
    indicator:description("Ehlers CG Oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Length", "Length", "", 10);
    indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("clr_buff1", "Color of Buff1", "Color of Buff1", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("widthLinReg1", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg1", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("clr_buff2", "Color of Buff2", "Color of Buff2", core.rgb(0, 128, 0));    
	indicator.parameters:addInteger("widthLinReg2", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg2", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg2", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Length;
 
local Buff1=nil;
local Buff2=nil;

function Prepare(nameOnly)   
    source = instance.source;
    Length=instance.parameters.Length;    
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
    Buff1:setWidth(instance.parameters.widthLinReg1);
    Buff1:setStyle(instance.parameters.styleLinReg1);
    Buff2:setWidth(instance.parameters.widthLinReg2);
    Buff2:setStyle(instance.parameters.styleLinReg2);
    Buff1:addLevel(0);
end

function Update(period, mode)
    if (period>first+Length) then
     local Num=0.;
     local Demon=0.;
    
     for i=0,Length-1,1 do
      Num=Num+(i+1)*source[period-i];
      Demon=Demon+source[period-i];
     end
     if Demon~=0. then
      Buff1[period]=-Num/Demon+(Length+1.)/2.;
     else
      Buff1[period]=0.;
     end
     Buff2[period]=Buff1[period-1];
    end 
end

