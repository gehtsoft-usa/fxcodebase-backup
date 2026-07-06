
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1389

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
    indicator:name("Fx Sniper's Ergodic CCI Trigger on chart");
    indicator:description("Fx Sniper's Ergodic CCI Trigger on chart");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("pq", "pq", "pq", 4);
    indicator.parameters:addInteger("pr", "pr", "pr", 8);
    indicator.parameters:addInteger("ps", "ps", "ps", 5);
    indicator.parameters:addInteger("trigger", "trigger", "trigger", 4);
    indicator.parameters:addString("MA_Method", "Method of MA", "", "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA_Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("MA_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "TMA", "", "TMA");
    
    indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("clr1", "Color of UP", "Color of UP", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clr2", "Color of DN", "Color of DN", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local pq;
local pr;
local ps;
local trigger;
local MA_Method;
local Ind;
local UP;
local DN;

function Prepare(nameOnly)
    source = instance.source;
    pq=instance.parameters.pq;
    pr=instance.parameters.pr;
    ps=instance.parameters.ps;
    trigger=instance.parameters.trigger;
    MA_Method=instance.parameters.MA_Method;
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.pq .. ", " .. instance.parameters.pr .. ", " .. instance.parameters.ps .. ", " .. instance.parameters.trigger .. ", " .. instance.parameters.MA_Method .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator("FX_SNIPERS_ERGODIC_CCI_TRIGGER") ~= nil, "Please, download and installFX_SNIPERS_ERGODIC_CCI_TRIGGER.LUA indicator");
	
    Ind = core.indicators:create("FX_SNIPERS_ERGODIC_CCI_TRIGGER", source, pq,pr,ps,trigger,MA_Method);
    first = Ind.DATA:first()+2;
    
    UP = instance:createTextOutput ("Up", "Up", "Wingdings", 10, core.H_Center, core.V_Bottom, instance.parameters.clr1, 0);
    DN = instance:createTextOutput ("Dn", "Dn", "Wingdings", 10, core.H_Center, core.V_Top, instance.parameters.clr2, 0);
end

function Update(period, mode)
    if (period>first) then
     Ind:update(mode);
     if Ind.buff1[period]>Ind.buff2[period] and Ind.buff1[period-1]<=Ind.buff2[period-1] then
      UP:set(period, source.low[period], "\225", "UP");
     end
     if Ind.buff1[period]<Ind.buff2[period] and Ind.buff1[period-1]>=Ind.buff2[period-1] then
      DN:set(period, source.high[period], "\226", "DN");
     end
    end 
end

