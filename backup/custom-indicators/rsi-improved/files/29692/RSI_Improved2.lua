-- Id: 6318
-- More information about this indicator can be found at:
-- http://fxcodebase.com/

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
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
    indicator:name("RSI Improved");
    indicator:description("RSI Improved");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("OriginalPeriod", "Period of original RSI", "", 14);
    indicator.parameters:addInteger("RotatedPeriod", "Period of rotated RSI", "", 7);
    indicator.parameters:addDouble("Level1", "Level1", "", 30);
    indicator.parameters:addDouble("Level2", "Level2", "", 50);
    indicator.parameters:addDouble("Level3", "Level3", "", 70);
    indicator.parameters:addDouble("Level4", "Level4", "", -30);
    indicator.parameters:addDouble("Level5", "Level5", "", -50);
    indicator.parameters:addDouble("Level6", "Level6", "", -70);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("OriginalClr", "Original Color", "Original Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("RotatedClr", "Rotated Color", "Rotated Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DeltaClr", "Delta Color", "Delta Color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("DeltaSpeedClr", "Delta Speed Color", "Delta Speed Color", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
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

function Prepare()
    source = instance.source;
    OriginalPeriod=instance.parameters.OriginalPeriod;
    RotatedPeriod=instance.parameters.RotatedPeriod;
    first = source:first()+2;
    O_RSI = core.indicators:create("RSI", source, OriginalPeriod);
    R_RSI = core.indicators:create("RSI", source, RotatedPeriod);
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.OriginalPeriod .. ", " .. instance.parameters.RotatedPeriod .. ")";
    instance:name(name);
    Delta = instance:addStream("Delta", core.Bar, name .. ".Delta", "Delta", instance.parameters.DeltaClr, first);
    Delta:setPrecision(math.max(2, instance.source:getPrecision()));
    DeltaSpeed = instance:addStream("DeltaSpeed", core.Line, name .. ".DeltaSpeed", "DeltaSpeed", instance.parameters.DeltaSpeedClr, first);
    DeltaSpeed:setPrecision(math.max(2, instance.source:getPrecision()));
    OriginalRSI = instance:addStream("OriginalRSI", core.Line, name .. ".OriginalRSI", "OriginalRSI", instance.parameters.OriginalClr, first);
    OriginalRSI:setPrecision(math.max(2, instance.source:getPrecision()));
    RotatedRSI = instance:addStream("RotatedRSI", core.Line, name .. ".RotatedRSI", "RotatedRSI", instance.parameters.RotatedClr, first);
    RotatedRSI:setPrecision(math.max(2, instance.source:getPrecision()));
    OriginalRSI:setWidth(instance.parameters.widthLinReg);
    OriginalRSI:setStyle(instance.parameters.styleLinReg);
    RotatedRSI:setWidth(instance.parameters.widthLinReg);
    RotatedRSI:setStyle(instance.parameters.styleLinReg);
    OriginalRSI:addLevel(instance.parameters.Level1);
    OriginalRSI:addLevel(instance.parameters.Level2);
    OriginalRSI:addLevel(instance.parameters.Level3);
    OriginalRSI:addLevel(instance.parameters.Level4);
    OriginalRSI:addLevel(instance.parameters.Level5);
    OriginalRSI:addLevel(instance.parameters.Level6);
end

function Update(period, mode)
   if (period>first) then
    O_RSI:update(mode);
    R_RSI:update(mode);
    OriginalRSI[period]=O_RSI.DATA[period];
    RotatedRSI[period]=100-R_RSI.DATA[period];
    Delta[period]=OriginalRSI[period]-RotatedRSI[period];
    DeltaSpeed[period]=Delta[period-1]-Delta[period];
   end 
end

