--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("ATR pips indicator");
    indicator:description("ATR pips indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 13);
    indicator.parameters:addDouble("Multiplier", "Multiplier", "", 0.7);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 128, 0));
    indicator.parameters:addInteger("FontSize", "Font size", "", 20);
    indicator.parameters:addInteger("H_Shift", "Horizontal shift", "", 0);
    indicator.parameters:addInteger("V_Shift", "Vertical shift", "", 50);
end

local first;
local source = nil;
local Period;
local Multiplier;
local ATR;
local font;

function Prepare()
    source = instance.source;
    Period=instance.parameters.Period;
    Multiplier=instance.parameters.Multiplier;
    ATR = core.indicators:create("ATR", source, Period);
    first = ATR.DATA:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Multiplier .. ")";
    instance:name(name);
    font = core.host:execute("createFont", "Arial", instance.parameters.FontSize, true, false);
end

function Update(period, mode)
   if (period==source:size()-1) 
   or period < first 
   then
   return;
   end
   
    ATR:update(mode);
    
    local Text="" .. math.floor(Multiplier*100) .. "% of ATR (" .. Period .. "):" .. math.ceil(ATR.DATA[period]*Multiplier/source:pipSize()) .. " pips";
    core.host:execute("drawLabel1", 1,instance.parameters.H_Shift, core.CR_RIGHT,instance.parameters.V_Shift, core.CR_TOP, core.H_Left, core.V_Center,
        font, instance.parameters.clr,  Text);

 
end

