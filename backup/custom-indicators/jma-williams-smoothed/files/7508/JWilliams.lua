-- Id: 2909
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3189

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Williams %R with JMA smoothing");
    indicator:description("Williams %R with JMA smoothing");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Length", "Length", "Length", 14);
    indicator.parameters:addInteger("Phase", "Phase", "Phase", 0);
    indicator.parameters:addInteger("Period", "Period", "", 14);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("NEclr", "Neutral Color", "Neutral Color", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("widthLinReg", "Dot width", "Dot width", 3, 1, 5);
end

local first;
local source = nil;
local Length;
local Phase;
local Period;
local JMA;
local WBuffer;
local buffUP=nil;
local buffDN=nil;
local buffNE=nil;

function Prepare(nameOnly)
    source = instance.source;
    Length=instance.parameters.Length;
    Phase=instance.parameters.Phase;
    Period=instance.parameters.Period;
	
	assert(core.indicators:findIndicator("JMA") ~= nil, "Please, download and install JMA.LUA indicator");   
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Length .. ", " .. instance.parameters.Phase .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    JMA = core.indicators:create("JMA", source, Length, Phase);
    first = JMA.DATA:first()+2;
    WBuffer = instance:addInternalStream(first, 0);
    
    buffUP = instance:addStream("buffUP", core.Dot, name .. ".UP", "UP", instance.parameters.UPclr, first);
    buffUP:setPrecision(math.max(2, instance.source:getPrecision()));
    buffDN = instance:addStream("buffDN", core.Dot, name .. ".DN", "DN", instance.parameters.DNclr, first);
    buffDN:setPrecision(math.max(2, instance.source:getPrecision()));
    buffNE = instance:addStream("buffNE", core.Dot, name .. ".NE", "NE", instance.parameters.NEclr, first);
    buffNE:setPrecision(math.max(2, instance.source:getPrecision()));
    buffUP:setWidth(instance.parameters.widthLinReg);
    buffDN:setWidth(instance.parameters.widthLinReg);
    buffNE:setWidth(instance.parameters.widthLinReg);
end

function Update(period, mode)
   if (period>first+Period) then
    JMA:update(mode);
    local h=core.max(JMA.DATA,core.rangeTo(period,Period));
    local l=core.min(JMA.DATA,core.rangeTo(period,Period));
    if h==l then
     WBuffer[period]=0;
    else
     WBuffer[period]=(-100)*(h-JMA.DATA[period])/(h-l)+100;
    end
    if WBuffer[period]>WBuffer[period-1] then
     buffUP[period]=WBuffer[period];
     buffDN[period]=nil;
     buffNE[period]=nil;
    elseif WBuffer[period]<WBuffer[period-1] then
     buffDN[period]=WBuffer[period];
     buffUP[period]=nil;
     buffNE[period]=nil;
    else
     buffNE[period]=WBuffer[period];
     buffDN[period]=nil;
     buffUP[period]=nil;
    end
   end 
end

