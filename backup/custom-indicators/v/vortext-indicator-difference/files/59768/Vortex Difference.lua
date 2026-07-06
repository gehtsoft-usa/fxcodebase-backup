-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=35281
-- Id: 9027

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+
function Init()
    indicator:name("Vortext Indicator Difference");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("N", "Length of the vortex", "No description", 14);
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("UP", "Up Histogram  in Up Trend", "The color of Up Histogram.", core.rgb(0, 255, 0));
	indicator.parameters:addColor("UPDOWN", "Down Histogram in Up Trend", "The color of Up Histogram.", core.rgb(0, 200, 0));	
	indicator.parameters:addColor("DOWNUP", "Up Histogram in Down Trend", "The color of Down Histogram.", core.rgb(255, 0, 0));
	indicator.parameters:addColor("DOWN", "Down Histogram in Down Trend", "The color of Down Histogram.", core.rgb(200, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
local N;

local first;
local source = nil;
local DIF;
-- Streams block
local VIP = nil;
local VIM = nil;
local iVIP = nil;
local iVIN = nil;
local iATR = nil;

-- Routine
function Prepare(nameOnly)
    N = instance.parameters.N;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    iATR = core.indicators:create("ATR", instance.source, 1);
 
    first = iATR.DATA:first() + N; 
    VIP =    instance:addInternalStream(0, 0);
	VIM =    instance:addInternalStream(0, 0);
    DIF = instance:addStream("DIF", core.Bar, name .. ".Dif", "VI-", instance.parameters.UP, first);
    DIF:setPrecision(math.max(2, instance.source:getPrecision()));

    iVIP = instance:addInternalStream(1, 0);
    iVIM = instance:addInternalStream(1, 0);
end

-- Indicator calculation routine
function Update(period, mode)
    iATR:update(mode);
    if period >= 1 then
        iVIP[period] = math.abs(source.high[period] - source.low[period - 1]);
        iVIM[period] = math.abs(source.low[period] - source.high[period - 1]);
    end
    if period >= first then
        local svip, svim, satr;
        local range;
        range = core.rangeTo(period, N);
        svip = core.sum(iVIP, range);
        svim = core.sum(iVIM, range);
        satr = core.sum(iATR.DATA, range);

        VIP[period] = svip / satr * 100;
        VIM[period] = svim / satr * 100;
		
		DIF [period] = VIP[period] -VIM[period];
		
		                 if DIF[period] > 0 then
							  if DIF[period] > DIF[period-1] then
							  DIF:setColor(period, instance.parameters.UP);
							  else
							   DIF:setColor(period, instance.parameters.UPDOWN);
							  end
						 else
						     if DIF[period] < DIF[period-1] then
							  DIF:setColor(period, instance.parameters.DOWN);
							  else
							   DIF:setColor(period, instance.parameters.DOWNUP);
							  end
						 end
		
    end
end

