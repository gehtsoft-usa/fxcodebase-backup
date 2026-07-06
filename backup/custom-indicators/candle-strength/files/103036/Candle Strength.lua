
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62827

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
    indicator:name("Candle Strength indicator");
    indicator:description("Candle Strength indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 128, 64));
    indicator.parameters:addInteger("FontSize", "Font size", "", 12);
end

local first;
local source = nil;
local font;
local strength;


function Prepare(nameOnly)
    source = instance.source;

    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	if   (nameOnly) then
        return;
    end
	
	
    font = core.host:execute("createFont", "Arial", instance.parameters.FontSize, true, false);
end

function Update(period, mode)

   if period < source:size()-1 then
   return;
   end

	if source.close[period-1] > source.open[period-1] then
	strength = math.floor(((source.close[period-1] - source.low[period-1]) / (source.high[period-1] - source.low[period-1])) * 100);
	else
	strength = math.floor(((source.high[period-1] - source.close[period-1]) / (source.high[period-1] - source.low[period-1])) * 100);
	end
	;
    
	
	local Text="Candle strength: " .. strength .. "%";
    core.host:execute("drawLabel1", 1,0, core.CR_RIGHT,50, core.CR_TOP, core.H_Left, core.V_Center,
        font, instance.parameters.clr,  Text);



end

