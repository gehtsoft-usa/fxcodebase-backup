-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=11901
-- Id: 5733

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
    indicator:name("Stochastic RSI Rainbow indicator");
    indicator:description("Stochastic RSI Rainbow indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("RSI_Period", "RSI_Period", "", 1);
    indicator.parameters:addInteger("K_Period", "K_Period", "", 3);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr1", "Color 1", "Color 1", core.rgb(0, 0, 128));
    indicator.parameters:addColor("clr2", "Color 2", "Color 2", core.rgb(0, 0, 255));
    indicator.parameters:addColor("clr3", "Color 3", "Color 3", core.rgb(0, 128, 0));
    indicator.parameters:addColor("clr4", "Color 4", "Color 4", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clr5", "Color 5", "Color 5", core.rgb(128, 0, 0));
    indicator.parameters:addColor("clr6", "Color 6", "Color 6", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clr7", "Color 7", "Color 7", core.rgb(255, 128, 64));
    indicator.parameters:addColor("clr8", "Color 8", "Color 8", core.rgb(255, 128, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local RSI_Period;
local K_Period;
local Ind_St={};
local St={};
local i;

function Prepare(nameOnly)
    source = instance.source;
    RSI_Period=instance.parameters.RSI_Period;
    K_Period=instance.parameters.K_Period;
    assert(core.indicators:findIndicator("STOCHASTICRSI") ~= nil, "Please, download and install STOCHASTICRSI.LUA indicator");  
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.RSI_Period .. ", " .. instance.parameters.K_Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    for i=1,8,1 do
     Ind_St[i]=core.indicators:create("STOCHASTICRSI", source, RSI_Period*(i+2), K_Period*(i+2), 3, "MVA");
     St[i]=instance:addStream("St" .. i, core.Line, name .. ".St" .. i, "St" .. i, instance.parameters:getColor("clr" .. i), Ind_St[i].DATA:first());
    St[i]:setPrecision(math.max(2, instance.source:getPrecision()));
     St[i]:setWidth(instance.parameters.widthLinReg);
     St[i]:setStyle(instance.parameters.styleLinReg);
    end
end

function Update(period, mode)
    
    for i=1,8,1 do
     Ind_St[i]:update(mode);
	  if period > Ind_St[i].DATA:first() then
     St[i][period]=Ind_St[i].DATA[period];
	 end
    end
 
end

