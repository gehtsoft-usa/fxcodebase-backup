-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=18855
-- Id: 6597

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Current time indicator");
    indicator:description("Current time indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Time", "Time", "", "EST");
    indicator.parameters:addStringAlternative("Time", "EST", "", "EST");
    indicator.parameters:addStringAlternative("Time", "UTC", "", "UTC");
    indicator.parameters:addStringAlternative("Time", "LOCAL", "", "LOCAL");
    indicator.parameters:addStringAlternative("Time", "TS", "", "TS");
    indicator.parameters:addStringAlternative("Time", "SERVER", "", "SERVER");
    indicator.parameters:addStringAlternative("Time", "FINANCIAL", "", "FINANCIAL");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 128, 0));
    indicator.parameters:addInteger("FontSize", "Font size", "", 20);
    indicator.parameters:addInteger("H_Shift", "Horizontal shift", "", 0);
    indicator.parameters:addInteger("V_Shift", "Vertical shift", "", 50);
end

local first;
local source = nil;
local Period;
local font;
local Time;

function Prepare(nameOnly)
    source = instance.source;
    Time=instance.parameters.Time;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Time .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    font = core.host:execute("createFont", "Arial", instance.parameters.FontSize, true, false);
end

function Update(period, mode)
   if (period==source:size()-1) then
    local CurTime=core.now();
    if Time=="EST" then
     CurTime=core.host:execute ("convertTime", core.TZ_LOCAL, core.TZ_EST, CurTime);
    elseif Time=="UTC" then
     CurTime=core.host:execute ("convertTime", core.TZ_LOCAL, core.TZ_UTC, CurTime);
    elseif Time=="TS" then
     CurTime=core.host:execute ("convertTime", core.TZ_LOCAL, core.TZ_TS, CurTime);
    elseif Time=="SERVER" then
     CurTime=core.host:execute ("convertTime", core.TZ_LOCAL, core.TZ_SERVER, CurTime);
    elseif Time=="FINANCIAL" then
     CurTime=core.host:execute ("convertTime", core.TZ_LOCAL, core.TZ_FINANCIAL, CurTime);
    end
    
    local table=core.dateToTable(CurTime);
    
    local Text="" .. table.day .. "." .. table.month .. "." .. table.year .. " " .. table.hour .. ":" .. table.min .. ":" .. table.sec;
    
        core.host:execute("drawLabel1", 1,instance.parameters.H_Shift, core.CR_RIGHT,instance.parameters.V_Shift, core.CR_TOP, core.H_Left, core.V_Center,
        font, instance.parameters.clr,  Text);

   end 
end

