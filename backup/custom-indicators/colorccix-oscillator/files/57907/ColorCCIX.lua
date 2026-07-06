-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=34067
-- Id: 8886

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
    indicator:name("ColorCCIX oscillator");
    indicator:description("ColorCCIX oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("JMAPeriod", "JMA period", "", 8);
    indicator.parameters:addInteger("JMAPhase", "JMA phase", "", 100);
    indicator.parameters:addInteger("JRXPeriod", "JRX period", "", 8);
    indicator.parameters:addString("Type", "Type", "", "Histogram");
    indicator.parameters:addStringAlternative("Type", "Dots", "", "Dots");
    indicator.parameters:addStringAlternative("Type", "Line", "", "Line");
    indicator.parameters:addStringAlternative("Type", "Histogram", "", "Histogram");
    indicator.parameters:addDouble("HLevel", "High level", "", 20);
    indicator.parameters:addDouble("MLevel", "Middle level", "", 0);
    indicator.parameters:addDouble("LLevel", "Low level", "", -20);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr1", "Color 1", "Color 1", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clr2", "Color 2", "Color 2", core.rgb(255, 128, 0));
    indicator.parameters:addColor("clr3", "Color 3", "Color 3", core.rgb(128, 255, 255));
    indicator.parameters:addColor("clr4", "Color 4", "Color 4", core.rgb(0, 0, 255));
    indicator.parameters:addColor("Lclr", "Line color", "Line color", core.rgb(0, 255, 0));
end

local first;
local source = nil;
local JMAPeriod;
local JMAPhase;
local JRXPeriod;
local Type;
local HLevel;
local MLevel;
local LLevel;
local JMA;
local upccx, dnccx;
local JRXup, JRXdn;
local CCIX=nil;
local Line=nil;

function Prepare(nameOnly)
    source = instance.source;
    JMAPeriod=instance.parameters.JMAPeriod;
    JMAPhase=instance.parameters.JMAPhase;
    JRXPeriod=instance.parameters.JRXPeriod;
    Type=instance.parameters.Type;
    HLevel=instance.parameters.HLevel;
    MLevel=instance.parameters.MLevel;
    LLevel=instance.parameters.LLevel;
    first = JRXup.DATA:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.JMAPeriod .. ", " .. instance.parameters.JMAPhase .. ", " .. instance.parameters.Type .. ", " .. instance.parameters.JRXPeriod .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    upccx=instance:addInternalStream(0, 0);
    dnccx=instance:addInternalStream(0, 0);
	
	assert(core.indicators:findIndicator("JMA") ~= nil, "Please, download and install JMA.LUA indicator");  
    assert(core.indicators:findIndicator("JRX") ~= nil, "Please, download and install JRX.LUA indicator");  	
	
    JMA=core.indicators:create("JMA", source, JMAPeriod, JMAPhase);
    JRXup=core.indicators:create("JRX", upccx, JRXPeriod);
    JRXdn=core.indicators:create("JRX", dnccx, JRXPeriod);
	
    Line = instance:addStream("Line", core.Line, name .. ".Line", "Line", instance.parameters.Lclr, first);
    Line:addLevel(HLevel);
    Line:addLevel(MLevel);
    Line:addLevel(LLevel);
    if Type=="Dots" then
     CCIX = instance:addStream("CCIX", core.Dot, name .. ".CCIX", "CCIX", instance.parameters.clr1, first);
    elseif Type=="Line" then
     CCIX = instance:addStream("CCIX", core.Line, name .. ".CCIX", "CCIX", instance.parameters.clr1, first);
    else
     CCIX = instance:addStream("CCIX", core.Bar, name .. ".CCIX", "CCIX", instance.parameters.clr1, first);
    end 
	
	Line:setPrecision(math.max(2, instance.source:getPrecision()));
    CCIX:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)

    JMA:update(mode);
	
	   if period<JMA.DATA:first() then
	   return;
	   end
	   
    upccx[period]=source[period]-JMA.DATA[period];
    dnccx[period]=math.abs(upccx[period]);
    JRXup:update(mode);
    JRXdn:update(mode);
	if period < first then
	return;
	end
	
    if JRXdn.DATA[period]~=0 then
     CCIX[period]=100*JRXup.DATA[period]/JRXdn.DATA[period];
     if CCIX[period]>=CCIX[period-1] then
      if CCIX[period]>HLevel then
       CCIX:setColor(period, instance.parameters.clr4);
      else
       CCIX:setColor(period, instance.parameters.clr3);
      end
     else
      if CCIX[period]<LLevel then
       CCIX:setColor(period, instance.parameters.clr1);
      else
       CCIX:setColor(period, instance.parameters.clr2);
      end
     end
     Line[period]=CCIX[period];
    end
 
end

