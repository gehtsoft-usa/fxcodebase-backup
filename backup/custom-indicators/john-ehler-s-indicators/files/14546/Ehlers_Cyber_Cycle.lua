-- Id: 4529

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
    indicator:name("Ehlers Cyber Cycle");
    indicator:description("Ehlers Cyber Cycle");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addDouble("Alpha", "Alpha", "", 0.07);

    indicator.parameters:addColor("clr_buff1", "Color of Buff1", "Color of Buff1", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clr_buff2", "Color of Buff2", "Color of Buff2", core.rgb(0, 128, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Alpha;
local Price;
local Smooth;
local Buff1=nil;
local Buff2=nil;

function Prepare(nameOnly)   
    source = instance.source;
    Alpha=instance.parameters.Alpha;
    Price = instance:addInternalStream(0, 0);
    Smooth = instance:addInternalStream(0, 0);
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Alpha .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    Buff1 = instance:addStream("Buff1", core.Line, name .. ".Buff1", "Buff1", instance.parameters.clr_buff1, first+8);
    Buff1:setPrecision(math.max(2, instance.source:getPrecision()));
    Buff2 = instance:addStream("Buff2", core.Line, name .. ".Buff2", "Buff2", instance.parameters.clr_buff2, first+8);
    Buff2:setPrecision(math.max(2, instance.source:getPrecision()));
    Buff1:setWidth(instance.parameters.widthLinReg);
    Buff1:setStyle(instance.parameters.styleLinReg);
    Buff2:setWidth(instance.parameters.widthLinReg);
    Buff2:setStyle(instance.parameters.styleLinReg);
    Buff1:addLevel(0);
end

function Update(period, mode)
    Price[period]=(source.high[period]+source.low[period])/2.; 
    if (period>first+4) then
     Smooth[period]=(Price[period]+2.*Price[period-1]+2.*Price[period-2]+Price[period-3])/6.;
     if period<first+8 then
      Buff1[period]=(Price[period]-2.*Price[period-1]+Price[period-2])/4.;
     else
      Buff1[period]=(1.-0.5*Alpha)*(1.-0.5*Alpha)*(Smooth[period]-2.*Smooth[period-1]+Smooth[period-2])+2.*(1.-Alpha)*Buff1[period-1]-(1.-Alpha)*(1.-Alpha)*Buff1[period-2];
     end
     Buff2[period]=Buff1[period-1];
    
    end 
end

