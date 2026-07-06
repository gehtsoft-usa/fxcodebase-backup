-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=13892
-- Id: 5892

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("RSI Improved");
    indicator:description("RSI Improved");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("OriginalPeriod", "Period of original RSI", "", 14);
    indicator.parameters:addInteger("RotatedPeriod", "Period of rotated RSI", "", 7);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("OriginalClr", "Original Color", "Original Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("RotatedClr", "Rotated Color", "Rotated Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DeltaClr", "Delta Color", "Delta Color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("DeltaSpeedClr", "Delta Speed Color", "Delta Speed Color", core.rgb(0, 255, 255));
end

local first;
local source = nil;
local OriginalPeriod;
local RotatedPeriod;
local O_RSI;
local R_RSI;
local OriginalRSI=nil;
local RotatedRSI=nil;
local Delta=nil;
local SpeedDelta=nil;

function Prepare(nameOnly)
    source = instance.source;
    OriginalPeriod=instance.parameters.OriginalPeriod;
    RotatedPeriod=instance.parameters.RotatedPeriod;
  
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.OriginalPeriod .. ", " .. instance.parameters.RotatedPeriod .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    O_RSI = core.indicators:create("RSI", source, OriginalPeriod);
    R_RSI = core.indicators:create("RSI", source, RotatedPeriod);
	first=math.max(O_RSI.DATA:first(),R_RSI.DATA:first() );
	
    OriginalRSI = instance:addStream("OriginalRSI", core.Line, name .. ".OriginalRSI", "OriginalRSI", instance.parameters.OriginalClr, O_RSI.DATA:first());
    OriginalRSI:setPrecision(math.max(2, instance.source:getPrecision()));
    RotatedRSI = instance:addStream("RotatedRSI", core.Line, name .. ".RotatedRSI", "RotatedRSI", instance.parameters.RotatedClr, R_RSI.DATA:first());
    RotatedRSI:setPrecision(math.max(2, instance.source:getPrecision()));
    Delta = instance:addStream("Delta", core.Bar, name .. ".Delta", "Delta", instance.parameters.DeltaClr, first);
    Delta:setPrecision(math.max(2, instance.source:getPrecision()));
    DeltaSpeed = instance:addStream("DeltaSpeed", core.Line, name .. ".DeltaSpeed", "DeltaSpeed", instance.parameters.DeltaSpeedClr, first);
    DeltaSpeed:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   
    O_RSI:update(mode);
    R_RSI:update(mode);
	if period > O_RSI.DATA:first() then
    OriginalRSI[period]=O_RSI.DATA[period];
	end
	if period > R_RSI.DATA:first() then
    RotatedRSI[period]=100-R_RSI.DATA[period];
	end
	if (period<first) then
	return;
	end	
    Delta[period]=OriginalRSI[period]-RotatedRSI[period];
    DeltaSpeed[period]=Delta[period-1]-Delta[period];
 
end

