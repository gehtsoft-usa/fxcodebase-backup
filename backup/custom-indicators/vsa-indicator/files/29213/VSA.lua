
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=15508

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
    indicator:name("VSA BAR DOTS indicator");
    indicator:description("VSA BAR DOTS indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("K", "K", "", 3.6);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("MDclr", "Middle Color", "Middle Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 3, 1, 5);
end

local first;
local source = nil;
local K;
local UpBar=nil;
local MiddleBar=nil;
local DnBar=nil;

function Prepare(nameOnly)
    source = instance.source;
    K=instance.parameters.K;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. K .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    UpBar = instance:addStream("UpBar", core.Dot, name .. ".UpBar", "UpBar", instance.parameters.UPclr, first);
    MiddleBar = instance:addStream("MiddleBar", core.Dot, name .. ".MiddleBar", "MiddleBar", instance.parameters.MDclr, first);
    DnBar = instance:addStream("DnBar", core.Dot, name .. ".DnBar", "DnBar", instance.parameters.DNclr, first);
    UpBar:setWidth(instance.parameters.DotSize);
    MiddleBar:setWidth(instance.parameters.DotSize);
    DnBar:setWidth(instance.parameters.DotSize);
end

function Update(period, mode)
   if (period>first) then
    local Middle=(source.high[period-1]+source.low[period-1])/2;
    local D=(source.high[period-1]-source.low[period-1])/K;
    local Up=Middle+D;
    local Dn=Middle-D;
    if source.close[period-1]<=Up and source.close[period-1]>=Dn then
     MiddleBar[period-1]=Middle;
     UpBar[period-1]=nil;
     DnBar[period-1]=nil;
    elseif source.close[period-1]>Up then
     UpBar[period-1]=Up;
     MiddleBar[period-1]=nil;
     DnBar[period-1]=nil;
    else
     DnBar[period-1]=Dn;
     UpBar[period-1]=nil;
     MiddleBar[period-1]=nil;
    end;
   end 
end

