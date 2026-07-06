-- Id: 106
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


-- EMA HLC Oscillator (Should be used together with EMA HLC Indicator)
-- Note: EMA High/Low/Close Envelopes Indicator Addition
--
-- Changes & Added Featured:
-- 1. Since EMA HLC Indicator was modified to support shifting of the envelopes by specified n-amount
--    of periods, this oscillator has this feature too. 
-- 
-- WARNING: For accurate display of data this indicator must be configured with same parameters as 
--			original EMA HLC Envelope indicator you are using it with. So if EMA HLC Envelope Indicator
--			has EMA set at 14 periods, so must this oscillator user 14 periods for accurate display of
--			the histogram. Same thing goes for envelope shifting, must be configured exactly alike. 
--    
-- SUPPORT: http://www.fxcodebase.com/
-- 
--
function Init()
    indicator:name("EMA HLC Oscillator");
    indicator:description("EMA HLC Oscilaltor");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("EMA", "EMA", "EMA # of Periods", 14);
    indicator.parameters:addInteger("HEMAS", "High EMA Shift", "High EMA Shift # periods", 0);
    indicator.parameters:addInteger("LEMAS", "Low EMA Shift", "Low EMA Shift # periods", 0);
    
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("H_color", "Color of High Bar over High Envelope", "H_color", core.rgb(40, 40, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("L_color", "Color of Low Bar over Low Envelope", "L_color", core.rgb(255, 40, 40));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Parameters block
local HEMAS;
local LEMAS;

local first;
local source = nil;

-- Indicator instances
local EMAHind = nil;
local EMALind = nil;

-- Streams block
local EMAH = nil;
local EMAL = nil;

-- Histograms
local HISTOGRAMHIGH = nil;
local HISTOGRAMLOW = nil;


-- Routine
function Prepare(nameOnly)
	EMA = instance.parameters.EMA;
	HEMAS = instance.parameters.HEMAS;
	LEMAS = instance.parameters.LEMAS;
	
	source = instance.source;
	local name = profile:id() .. "(" .. source:name() .. " OSCILLATOR";
	instance:name(name);
	if nameOnly then
		return;
	end
    
    	EMAHind = core.indicators:create("EMA", source.high, instance.parameters.EMA);
    	EMALind = core.indicators:create("EMA", source.low, instance.parameters.EMA);
    
	first = EMAHind.DATA:first();
	
	-- AS IN EMA HLC Envelope Indicator we have 3 Envelope streams
	-- Only in this Oscillator we need them for calculation of difference
	-- between point when evelope is broken, and distance between price and envelope.
	-- So for that we use Internal streams which are no displayed anywhere.
	EMAH = instance:addInternalStream(EMAHind.DATA:first() + HEMAS, HEMAS);
	EMAL = instance:addInternalStream(EMALind.DATA:first() + LEMAS, LEMAS);
		
	HISTOGRAMHIGH = instance:addStream("HISTBLUE", core.Bar, name .. ".HBAR1", "HBAR1", instance.parameters.H_color, first);
    HISTOGRAMHIGH:setPrecision(math.max(2, instance.source:getPrecision()));
	HISTOGRAMHIGH:setWidth(instance.parameters.width1);
    HISTOGRAMHIGH:setStyle(instance.parameters.style1);
	HISTOGRAMLOW = instance:addStream("HISTRED", core.Bar, name .. ".HBAR1", "HBAR1", instance.parameters.L_color, first);
    HISTOGRAMLOW:setPrecision(math.max(2, instance.source:getPrecision()));
	HISTOGRAMLOW:setWidth(instance.parameters.width2);
    HISTOGRAMLOW:setStyle(instance.parameters.style2);
end

-- Indicator calculation routine
function Update(period, mode)
	-- Update our 3 EMA indicator instances
	EMAHind:update(mode);
	EMALind:update(mode);
	
	if( period >= EMAHind.DATA:first() and period >= EMALind.DATA:first()) then		
		-- THESE 3 ARE CALCULATION FOR DISPLAY OF EMA ENVELOPES
		-- added: + n-amount of periods to shift				
		if (period + HEMAS > 0) then
			EMAH[period + HEMAS] = EMAHind.DATA[period];
		end 
		
		if (period + LEMAS > 0) then
			EMAL[period + LEMAS] = EMALind.DATA[period];
		end 	
		
		-- HISTOGRAM CALCULATION
		if( source.high[period] >= EMAH[period]) then
			HISTOGRAMHIGH[period] = source.high[period] - EMAH[period];
		end
		
		if( source.low[period] <= EMAL[period]) then
			HISTOGRAMLOW[period] = source.low[period] - EMAL[period]
		end		
	end
end