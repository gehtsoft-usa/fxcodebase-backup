-- Id: 559

-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=896

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
    indicator:name("Momentum");
    indicator:description("Momentum");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "N", "Period", 14);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrMom", "Color of momentum", "Color of momentum", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

end

local first;
local source = nil;
local N;

function Prepare(nameOnly)
    source = instance.source;
    N=instance.parameters.N;
    first = source:first()+N;
    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    Momentum = instance:addStream("Momentum", core.Line, name .. ".Momentum", "Momentum", instance.parameters.clrMom, first);
    Momentum:setPrecision(math.max(2, instance.source:getPrecision()));
	Momentum:setWidth(instance.parameters.width);
    Momentum:setStyle(instance.parameters.style);
end

function Update(period, mode)
    if (period<first) then
	return;
	end
	
     Momentum[period]=source[period]*100./source[period-N];
  
end

