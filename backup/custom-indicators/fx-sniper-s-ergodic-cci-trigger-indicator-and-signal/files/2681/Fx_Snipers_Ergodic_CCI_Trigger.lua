-- Id: 16282

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
    indicator:name("Fx Sniper's Ergodic CCI Trigger");
    indicator:description("Fx Sniper's Ergodic CCI Trigger");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
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
    indicator.parameters:addColor("clr1", "Color of Egodic CCI", "Color of Egodic CCI", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clr2", "Color of Trigger Line", "Color of Trigger Line", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local pq;
local pr;
local ps;
local trigger;
local MA_Method;
local var1;
local var2;
local var2a;
local var2b;
local var2c;
local var3;
local var4;
local buff1;
local buff2;

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
    
    mtm = instance:addInternalStream(0, 0);
    absmtm = instance:addInternalStream(0, 0);
    assert(core.indicators:findIndicator(MA_Method) ~= nil, MA_Method .. " indicator must be installed");
    var1 = core.indicators:create(MA_Method, mtm, pq);
    var2 = core.indicators:create(MA_Method, var1.DATA, pr);
    var2a = core.indicators:create(MA_Method, absmtm, pq);
    var2b = core.indicators:create(MA_Method, var2a.DATA, pr);
    var2c = core.indicators:create(MA_Method, var2.DATA, ps);
    var3 = core.indicators:create(MA_Method, var2b.DATA, ps);
    first = math.max(var1.DATA:first(),var2.DATA:first(),var2a.DATA:first(), var2b.DATA:first(),var2c.DATA:first(),var3.DATA:first());
    
    buff1 = instance:addStream("buff1", core.Line, name .. ".Egodic CCI", "Egodic CCI", instance.parameters.clr1, first);
    var4 = core.indicators:create(MA_Method, buff1, trigger);
    buff2 = instance:addStream("buff2", core.Line, name .. ".Trigger Line", "Trigger Line", instance.parameters.clr2, var4.DATA:first());
	
	
	buff1:setPrecision(math.max(2, source:getPrecision()));
	buff2:setPrecision(math.max(2, source:getPrecision()));
end

function Update(period, mode)
    mtm[period]=source.close[period]-source.close[period-1];
    absmtm[period]=math.abs(mtm[period]);
	
    var1:update(mode);
    var2:update(mode);
    var2a:update(mode);
    var2b:update(mode);
    var2c:update(mode);
    var3:update(mode);
	
	
    if (period<first) then
	return;
	end
	
	var4:update(mode);
	
    if (period<var4.DATA:first()) then
	return;
	end
      buff1[period]=(500.*var2c.DATA[period])/var3.DATA[period]; 
      buff2[period]=var4.DATA[period];
     
end

