-- Id: 6834
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=20399

--+------------------------------------------------------------------+
--|                                            http://fxcodebase.com |
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
	-- set the name of the indicator
	indicator:name("OHLC4");
	indicator:description("Outputs an OHLC4 price stream");
	indicator:requiredSource(core.Bar);
	indicator:type(core.Indicator);
	-- parameters need for calculation
		-- no parameters need for this calc
	-- display parameters
	indicator.parameters:addColor("OHCL4_color", "Indicator line color","",core.rgb(255,0,0));	
end

local source;
local OHLC4;

function Prepare(nameOnly)
	source = instance.source;
	
	-- Base name of the indicator
	local name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	OHLC4 = instance:addStream("OHLC4",core.Line,name .. ".OHLC4","OHLC4",instance.parameters.OHCL4_color,source:first());
end

function Update(period)
	if period >= source:first() then
		OHLC4[period] = (source.open[period] + source.high[period] + source.low[period] + source.close[period])/4;
	end
end