-- Id: 1564
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2107


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
-- The CLEAR method is described in the Stock & Commodities Sep 2010 issue
-- in Ron Black articles "Getting Clear With Short-Term Swings"
function Init()
    indicator:name("Clear Method Oscillator");
    indicator:description("The oscillator detects market direction changes using Ron Black's 'Getting Clear With Short-Term Swings' described in Sep 2010 issue of Stock & Commodities");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Line Color", "", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

end

local clear;
local sw;

function Prepare(nameOnly)
    local name;

    

    name = profile:id() .. "(" .. instance.source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator("RB_CLEAR") ~= nil, "The RB_CLEAR.LUA indicator must be downloaded and installed");
    clear = core.indicators:create("RB_CLEAR", instance.source);

    sw = instance:addStream("Sw", core.Line, name, "Sw", instance.parameters.clr, 0);
    sw:setWidth(instance.parameters.width);
    sw:setStyle(instance.parameters.style);
	sw:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
    clear:update(mode);
    if period > 0 then
        if clear.Up:hasData(period) then
            sw[period] = 1;
        elseif clear.Dn:hasData(period) then
            sw[period] = 0;
        end
    end
end
