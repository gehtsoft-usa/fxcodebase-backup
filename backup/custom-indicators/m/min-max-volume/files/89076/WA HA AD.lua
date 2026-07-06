-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59373
-- Id: 9874

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
    indicator:name("Heiken Ashi Williams Accumulation/Distribution");
    indicator:description("Heiken Ashi Williams Accumulation/Distribution");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addColor("clrAD", "Color of AD", "Color of AD", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local AD, HA;

function Prepare(nameOnly)
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	HA = core.indicators:create("HA",source);
    first=HA.DATA:first()+2;
    AD = instance:addStream("AD", core.Line, name .. ".AD", "AD", instance.parameters.clrAD, first);
    AD:setPrecision(math.max(2, instance.source:getPrecision()));
	AD:setWidth(instance.parameters.width);
    AD:setStyle(instance.parameters.style);
end


function Update(period, mode)

    HA:update(mode);
	
    if (period>first+1) then
     local TRH=math.max(HA.high[period],HA.close[period-1]);
     local TRL=math.min(HA.low[period],HA.close[period-1]);
     local ad;
     if HA.close[period]>HA.close[period-1]+source:pipSize() then
      ad=HA.close[period]-TRL;
     elseif HA.close[period]<HA.close[period-1]-source:pipSize() then
      ad=HA.close[period]-TRH;
     else
      ad=0.;
     end
     AD[period]=AD[period-1]+ad;
    else
     AD[period]=0.; 
    end 
end

