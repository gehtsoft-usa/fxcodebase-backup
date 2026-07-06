-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=238

--+------------------------------------------------------------------+
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
    indicator:name("EMA HLC Envelope");
    indicator:description("Shows EMA lines for High, Low, Close rates.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
   
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("EMAHigh", "EMA High", "No description", 14);
    indicator.parameters:addInteger("EMALow", "EMA Low", "No description", 14);
    indicator.parameters:addInteger("EMAClose", "EMA Close", "No description", 14);
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("EMAH_color", "Color of EMA High", "Color of EMA High", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	
    indicator.parameters:addColor("EMAL_color", "Color of EMA Low", "Color of EMA Low", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("EMAC_color", "Color of EMA Close", "Color of EMA Close", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
end

-- Parameters block
local EMAHigh;
local EMALow;
local EMAClose;

local first;
local source = nil;

-- Streams block
local EMAH = nil;
local EMAL = nil;
local EMAC = nil;

local EMAHind = nil;
local EMALind = nil;
local EMACind = nil;

-- Routine
function Prepare(nameOnly)
	EMAHigh = instance.parameters.EMAHigh;
	EMALow = instance.parameters.EMALow;
	EMAClose = instance.parameters.EMAClose;
	source = instance.source;
	local name = profile:id() .. "(" .. source:name() .. ", ".. EMAHigh .. ", ".. EMALow .. ", ".. EMAClose .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
    
    EMAHind = core.indicators:create("EMA", source.high, instance.parameters.EMAHigh);
    EMALind = core.indicators:create("EMA", source.low, instance.parameters.EMALow);
    EMACind = core.indicators:create("EMA", source.close, instance.parameters.EMAClose);
    
	first =EMAHind.DATA:first()
	
	
	EMAH = instance:addStream("EMAH", core.Line, name .. ".EMAH", "EMAH", instance.parameters.EMAH_color, first);
	EMAH:setWidth(instance.parameters.width1);
    EMAH:setStyle(instance.parameters.style1);
	
	EMAL = instance:addStream("EMAL", core.Line, name .. ".EMAL", "EMAL", instance.parameters.EMAL_color, first);
	EMAL:setWidth(instance.parameters.width2);
    EMAL:setStyle(instance.parameters.style2);

	EMAC = instance:addStream("EMAC", core.Line, name .. ".EMAC", "EMAC", instance.parameters.EMAC_color, first);
	EMAC:setWidth(instance.parameters.width3);
    EMAC:setStyle(instance.parameters.style3);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
	EMAHind:update(mode);
	EMALind:update(mode);
	EMACind:update(mode);
	
	if( period >= EMAHind.DATA:first() ) then	
		EMAH[period] = EMAHind.DATA[period];
		EMAL[period] = EMALind.DATA[period];
		EMAC[period] = EMACind.DATA[period];
	end
end