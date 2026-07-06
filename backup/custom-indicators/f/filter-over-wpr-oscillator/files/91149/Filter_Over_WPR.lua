-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59992
-- Id: 10543

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
    indicator:name("Filter over WPR oscillator");
    indicator:description("Filter over WPR oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 14);
    indicator.parameters:addInteger("PercentD", "Percent D", "", 3);
    indicator.parameters:addInteger("Smooth", "Smooth", "", 5);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr1", "Strong bears color", "Strong bears color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clr2", "Strong bulls color", "Strong bulls color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("clr3", "Potential to bulls color", "Potential to bulls color", core.rgb(0, 255, 255));
    indicator.parameters:addColor("clr4", "Potential to bears color", "Potential to bears color", core.rgb(255, 128, 64));
end

local first;
local source = nil;
local Period;
local PercentD;
local Smooth;
local Stoch;
local trend;
local FilterOverWPR=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    PercentD=instance.parameters.PercentD;
    Smooth=instance.parameters.Smooth;
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.PercentD .. ", " .. instance.parameters.Smooth .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    trend = instance:addInternalStream(0, 0);
    Stoch = core.indicators:create("STOCHASTIC", source, Period, PercentD, Smooth, "EMA", "EMA");
	first = Stoch.D:first();
    FilterOverWPR = instance:addStream("FilterOverWPR", core.Bar, name .. ".FilterOverWPR", "FilterOverWPR", instance.parameters.clr1, first);
    FilterOverWPR:setPrecision(math.max(2, instance.source:getPrecision()));
	
	FilterOverWPR:addLevel(0);
end

function Update(period, mode)
   if period>first then
    Stoch:update(mode);
    local PK=Stoch.K[period];
    local PD=Stoch.D[period];
    FilterOverWPR[period]=1;
    if PK>20 and PK>PD and PK<40 and PD<40 then
     trend[period]=1;
    elseif PK<=20 then
     trend[period]=2;
    elseif PK<80 and PK<PD and PK>60 and PD>60 then
     trend[period]=3;
    elseif PK>=80 then
     trend[period]=4;
    else
     trend[period]=trend[period-1]; 
    end
    
    if trend[period]==1 then
     FilterOverWPR:setColor(period, instance.parameters.clr3);
    elseif trend[period]==2 then
     FilterOverWPR:setColor(period, instance.parameters.clr1);
    elseif trend[period]==3 then
     FilterOverWPR:setColor(period, instance.parameters.clr4);
    else
     FilterOverWPR:setColor(period, instance.parameters.clr2);
    end
   end 
end

