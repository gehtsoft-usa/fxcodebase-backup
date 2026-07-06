-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=273

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


-- EMA High/Low/Close Envelopes Indicator
-- Changes & Added Featured:
-- 1. Added Support For Coloring, now point where envelope is broken by the chart you will have a dot at
--    point where envelope is broken, and at the top/bottom of the bar that broke it. When high breaks 
--    high-envelope its colored blue, and when low break low-envelope its colored red.
--    (This coloring using Dots is a temporary solution till new release which will have support for bar coloring)
-- 2. Added shifting for each of 3 envelopes, so now you can specify by which amount of periods you wish
--    to shift any or all 3 envelopes.
--
-- OPTIONAL: This indicator can be used with EMA HLC Oscillator, which will display histogram which will diplay
--			 positive or negative bars at the point when Hi or Low prices break the envelope. 
--    
-- SUPPORT: http://www.fxcodebase.com/
-- 
--

function Init()
    indicator:name("EMA HLC Envelope (Color+Shifting)");
    indicator:description("Shows EMA lines for High, Low, Close rates. Colors bars when envelope is broken. Envelopes can be shifted.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
  
  
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("EMA", "EMA", "EMA # of Periods", 14);
    indicator.parameters:addInteger("HEMAS", "High EMA Shift", "High EMA Shift # periods", 0);
    indicator.parameters:addInteger("LEMAS", "Low EMA Shift", "Low EMA Shift # periods", 0);
    indicator.parameters:addInteger("CEMAS", "Cloce EMA Shift", "Close EMA Shift # periods", 0);
    
	
	indicator.parameters:addGroup("Style");
	 
    indicator.parameters:addColor("EMAH_color", "Color of EMA High", "Color of EMA High", core.rgb(0, 0, 60));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("EMAL_color", "Color of EMA Low", "Color of EMA Low", core.rgb(60, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("EMAC_color", "Color of EMA Close", "Color of EMA Close", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
    
    indicator.parameters:addColor("HBAR_color", "Color of High Bar over Envelope", "HBAR_color", core.rgb(38, 38, 255));
    indicator.parameters:addColor("LBAR_color", "Color of Low Bar over Envelope", "LBAR_color", core.rgb(255, 38, 38));
end

-- Parameters block
local EMA;
local HEMAS;
local LEMAS;
local CEMAS;

local first;
local source = nil;

local EMAHind = nil;
local EMALind = nil;
local EMACind = nil;

-- Streams block
local EMAH = nil;
local EMAL = nil;
local EMAC = nil;

local HBAR1 = nil;
local HBAR2 = nil;
local LBAR1 = nil;
local LBAR2 = nil;

-- Routine
function Prepare(nameOnly)
	EMA = instance.parameters.EMA;
	HEMAS = instance.parameters.HEMAS;
	LEMAS = instance.parameters.LEMAS;
	CEMAS = instance.parameters.CEMAS;
	source = instance.source;
	local name = profile:id() .. "(" .. source:name() .. ", ".. EMA .. ") (ENV.SHIFT High: " .. HEMAS .. ", Low: " .. LEMAS .. ", Close: " .. CEMAS .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
    
    EMAHind = core.indicators:create("EMA", source.high, instance.parameters.EMA);
    EMALind = core.indicators:create("EMA", source.low, instance.parameters.EMA);
    EMACind = core.indicators:create("EMA", source.close, instance.parameters.EMA);
    first = EMAHind.DATA:first();
    
	EMAH = instance:addStream("EMAH", core.Line, name .. ".EMAH", "EMAH", instance.parameters.EMAH_color, EMAHind.DATA:first() + HEMAS, HEMAS);
	EMAH:setWidth(instance.parameters.width1);
    EMAH:setStyle(instance.parameters.style1);
	EMAL = instance:addStream("EMAL", core.Line, name .. ".EMAL", "EMAL", instance.parameters.EMAL_color, EMALind.DATA:first() + LEMAS, LEMAS);
	EMAL:setWidth(instance.parameters.width2);
    EMAL:setStyle(instance.parameters.style2);
	EMAC = instance:addStream("EMAC", core.Line, name .. ".EMAC", "EMAC", instance.parameters.EMAC_color, EMACind.DATA:first() + CEMAS, CEMAS);
	EMAC:setWidth(instance.parameters.width3);
    EMAC:setStyle(instance.parameters.style3);
		
	HBAR1 = instance:addStream("HBAR1", core.Dot, name .. ".HBAR1", "HBAR1", instance.parameters.HBAR_color, first);
	HBAR2 = instance:addStream("HBAR2", core.Dot, name .. ".HBAR1", "HBAR1", instance.parameters.HBAR_color, first);
	
	LBAR1 = instance:addStream("LBAR1", core.Dot, name .. ".HBAR1", "HBAR1", instance.parameters.LBAR_color, first);
	LBAR2 = instance:addStream("LBAR2", core.Dot, name .. ".HBAR1", "HBAR1", instance.parameters.LBAR_color, first);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
	-- UPDATE ALL 3 EMA ENVELOPE INDICATORS
	EMAHind:update(mode);
	EMALind:update(mode);
	EMACind:update(mode);
	
	if( period > EMAHind.DATA:first() and period > EMALind.DATA:first() and period > EMACind.DATA:first() ) then
		-- THESE 3 ARE CALCULATION FOR DISPLAY OF EMA ENVELOPES
		-- added: + n-amount of periods to shift				
		if (period + HEMAS > 0 ) then
			EMAH[period + HEMAS] = EMAHind.DATA[period];
		end 
		
		if (period + LEMAS > 0 ) then
			EMAL[period + LEMAS] = EMALind.DATA[period];
		end 
		
		if (period + CEMAS > 0 ) then
			EMAC[period + CEMAS] = EMACind.DATA[period];
		end 
			
		-- COLORING CALCULATION
		if( source.high[period] >= EMAH[period]) then
			HBAR1[period] = source.high[period];
			HBAR2[period] = EMAH[period];
		end
		
		if( source.low[period] <= EMAL[period]) then
			LBAR2[period] = EMAL[period];
			LBAR1[period] = source.low[period];
		end		
	end
end