-- Id: 1778

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1044

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
    indicator:name("Shifted Moving Average Indicator");
    indicator:description("The indicator shows the chosen moving average shifted by the specified number of periods and/or points.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Periods", "", 14);
    indicator.parameters:addString("MA", "Smoothing Method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "MVA");
    indicator.parameters:addStringAlternative("MA", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA", "TMA", "", "TMA");
    indicator.parameters:addStringAlternative("MA", "SMMA*", "", "SMMA");
    indicator.parameters:addStringAlternative("MA", "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("MA", "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("MA", "Wilders*", "", "WMA");
    indicator.parameters:addInteger("SX", "Shift in periods", "Postive is future, negative is past", 0);
    indicator.parameters:addInteger("SY", "Shift in points", "", 0);
	
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("width","Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("color", "Color of the line line", "", core.rgb(255, 0, 0));
end

local source;
local MA;
local OUT;
local first1, first2;
local SX, SY;

function Prepare(nameOnly)  
    local name;
    name = profile:id() .. "(" .. instance.source:name() .. "," .. instance.parameters.MA .. "(" .. instance.parameters.N  .. ")," .. instance.parameters.SX .. " bars," .. instance.parameters.SY .. " points)";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	assert (core.indicators:findIndicator(instance.parameters.MA )~= nil , "Please download " .. instance.parameters.MA.. " from the FxCodeBase.com")

    source = instance.source;
    SX = instance.parameters.SX;
    SY = instance.parameters.SY * source:pipSize();

    assert(core.indicators:findIndicator(instance.parameters.MA) ~= nil, instance.parameters.MA .. " indicator must be installed");
    MA = core.indicators:create(instance.parameters.MA, instance.source, instance.parameters.N);
    first1 = MA.DATA:first();
    first2 = first1 + SX;
    if first2 < 0 then
        first2 = 0;
    end
    OUT = instance:addStream("MA", core.Line, name .. ".MA", "MA", instance.parameters.color, first2, SX);
	OUT:setWidth(instance.parameters.width);
    OUT:setStyle(instance.parameters.style);
end

function Update(period, mode)
    MA:update(mode);

    local p1 = period + SX;
    if p1 >= 0 and period >= first1 then
        OUT[p1] = MA.DATA[period] + SY;
    end
end

