-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3522
-- Id: 3219

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("Coral indicator");
    indicator:description("Coral indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("Coeff", "Coefficient", "", 0.063492063492);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clru", "Color Up Color", "Color", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("clrd", "Color Down Color", "Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width", "width", "width", 1, 1, 5);
    indicator.parameters:addInteger("style", "style", "style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
end

local first;
local source = nil;
local Coral=nil;
local Buff1=0;
local Buff2=0;
local Buff3=0;
local Buff4=0;
local Buff5=0;
local Buff6=0;
local Coeff;

function Prepare(nameOnly)
    source = instance.source;
    Coeff=instance.parameters.Coeff;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. Coeff .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Buff1 = instance:addInternalStream(first, 0);
    Buff2 = instance:addInternalStream(first, 0);
    Buff3 = instance:addInternalStream(first, 0);
    Buff4 = instance:addInternalStream(first, 0);
    Buff5 = instance:addInternalStream(first, 0);
    Buff6 = instance:addInternalStream(first, 0);
    Coral = instance:addStream("Coral", core.Line, name .. ".Coral", "Coral", instance.parameters.clru, first);
    Coral:setWidth(instance.parameters.width);
    Coral:setStyle(instance.parameters.style);
end

function Update(period, mode)
   if (period>first) then
    Buff1[period]=Coeff*source[period]+(1-Coeff)*Buff1[period-1];
    Buff2[period]=Coeff*Buff1[period]+(1-Coeff)*Buff2[period-1];
    Buff3[period]=Coeff*Buff2[period]+(1-Coeff)*Buff3[period-1];
    Buff4[period]=Coeff*Buff3[period]+(1-Coeff)*Buff4[period-1];
    Buff5[period]=Coeff*Buff4[period]+(1-Coeff)*Buff5[period-1];
    Buff6[period]=Coeff*Buff5[period]+(1-Coeff)*Buff6[period-1];
    Coral[period]=(-0.064)*Buff6[period]+0.672*Buff5[period]-2.352*Buff4[period]+2.744*Buff3[period];
   elseif period==first then
    Buff1[period]=source[period]; 
    Buff2[period]=source[period]; 
    Buff3[period]=source[period]; 
    Buff4[period]=source[period]; 
    Buff5[period]=source[period]; 
    Buff6[period]=source[period]; 
   end 
   
   
   if Coral[period]  > Coral[period-1] then
   Coral:setColor(period, instance.parameters.clru);
   else
   Coral:setColor(period, instance.parameters.clrd);
   end   
end

