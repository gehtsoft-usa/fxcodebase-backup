-- Id: 6003
--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
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
   
    O_RSI = core.indicators:create("RSI", source, OriginalPeriod);
    R_RSI = core.indicators:create("RSI", source, RotatedPeriod);
	first=math.max(O_RSI.DATA:first(),R_RSI.DATA:first() );
	
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.OriginalPeriod .. ", " .. instance.parameters.RotatedPeriod .. ")";
    instance:name(name);
    Delta = instance:addStream("Delta", core.Bar, name .. ".Delta", "Delta", instance.parameters.DeltaClr, first);
    Delta:setPrecision(math.max(2, instance.source:getPrecision()));
    DeltaSpeed = instance:addStream("DeltaSpeed", core.Line, name .. ".DeltaSpeed", "DeltaSpeed", instance.parameters.DeltaSpeedClr,first  );
    DeltaSpeed:setPrecision(math.max(2, instance.source:getPrecision()));
    OriginalRSI = instance:addStream("OriginalRSI", core.Line, name .. ".OriginalRSI", "OriginalRSI", instance.parameters.OriginalClr, O_RSI.DATA:first());
    OriginalRSI:setPrecision(math.max(2, instance.source:getPrecision()));
    RotatedRSI = instance:addStream("RotatedRSI", core.Line, name .. ".RotatedRSI", "RotatedRSI", instance.parameters.RotatedClr, R_RSI.DATA:first());
    RotatedRSI:setPrecision(math.max(2, instance.source:getPrecision()));
    OriginalRSI:setWidth(instance.parameters.widthLinReg);
    OriginalRSI:setStyle(instance.parameters.styleLinReg);
    RotatedRSI:setWidth(instance.parameters.widthLinReg);
    RotatedRSI:setStyle(instance.parameters.styleLinReg);
    OriginalRSI:addLevel(instance.parameters.Level1);
    OriginalRSI:addLevel(instance.parameters.Level2);
    OriginalRSI:addLevel(instance.parameters.Level3);
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

