-- Id: 1263
-- This indicator is a port of WAVE-PM Metatrade indicator
-- The original indicator:
--   developed by Mark Whistler/EcTrader.net
--   email: Mark@WallStreetRockStar.com
-- http://www.WallStreetRockStar.com
-- http://www.fxVolatility.com
--
-- Please visit the http://www.fxVolatility.com to by ebook with
-- detailed explanation on how the indicator is used.

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1848

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Porting note: The algoritm is a bit optimized, so now it executes approximatelly
-- ten times faster than the original algo.

function Init()
    indicator:name("Mark Whistler's Active Volatility Energy - Price Mass");
    indicator:description("Please visit http://www.fxVolatility.com for details.");

    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("ShortBandsPeriod", "Short bands period", "", 14, 1, 300);
    indicator.parameters:addInteger("ShortBandsShift", "Short bands shift", "", 0, 0, 100);
    indicator.parameters:addDouble("ShortBandsDeviations", "Short bands deviations", "", 2.2, 0.00001, 100);

    indicator.parameters:addInteger("LongBandsPeriod", "Long bands period", "", 55, 1, 300);
    indicator.parameters:addInteger("LongBandsShift", "Long bands shift", "", 0, 0, 100);
    indicator.parameters:addDouble("LongBandsDeviations", "Long bands deviations", "", 2.2, 0.00001, 100);

    indicator.parameters:addInteger("Chars", "Characteristics", "", 100, 1, 300);

    indicator.parameters:addGroup("Line Style");
    indicator.parameters:addColor("ShortColorUp", "A color of the short line Up", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("LongColorUp", "A color of the long line Up", "", core.rgb(255, 0, 0));
	
	
	  indicator.parameters:addColor("ShortColorDown", "A color of the short line Down", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("LongColorDown", "A color of the long line Down", "", core.rgb(255, 0, 0));
 	
	
	indicator.parameters:addGroup("Pivot Levels");	
	indicator.parameters:addBoolean("Show", "Show Central Line", "", true);
	indicator.parameters:addBoolean("OverBoughtOverSold", "Show OverBought OverSold Lines", "", true);
	indicator.parameters:addBoolean("MinMax", "Show Min/Max Lines", "", true);
	indicator.parameters:addDouble("central", "Cental Level","", 0.8);
    indicator.parameters:addDouble("overbought", "Overbought Level","", 0.8);
    indicator.parameters:addDouble("oversold","Oversold Level","", 0.2);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addBoolean("Additional", "Show Additional lines", "", true);
	indicator.parameters:addDouble("Level1","1. Level","", 0.3);
	indicator.parameters:addDouble("Level2","2. Level","", 0.7);
	
end

local ShortBandsPeriod;
local ShortBandsShift;
local ShortBandsDeviations;
local LongBandsPeriod;
local LongBandsShift;
local LongBandsDeviations;
local Chars;
local OverBoughtOverSold;
local source;
local MinMax;
local ShortDev;
local LongDev;
local ShortDev1;
local LongDev1;
local ShortOscillator;
local LongOscillator;

local firstLong;
local firstShort;
local firstLong;
local firstShort;
local point;
local Show;
local Additional,Level1, Level2;
function Prepare(nameOnly)
    source = instance.source;
    point = source:pipSize();

    ShortBandsPeriod = instance.parameters.ShortBandsPeriod;
	MinMax = instance.parameters.MinMax;
    ShortBandsShift = instance.parameters.ShortBandsShift;
    ShortBandsDeviations = instance.parameters.ShortBandsDeviations;
    LongBandsPeriod = instance.parameters.LongBandsPeriod;
    LongBandsShift = instance.parameters.LongBandsShift;
    LongBandsDeviations = instance.parameters.LongBandsDeviations;
    Chars = instance.parameters.Chars;
	OverBoughtOverSold= instance.parameters.OverBoughtOverSold;
	Show= instance.parameters.Show;
	Additional= instance.parameters.Additional;
	Level1= instance.parameters.Level1;
	Level2= instance.parameters.Level2;

    local name;
    name = profile:id() .. "(" .. source:name() .. "," .. ShortBandsPeriod .. "," .. ShortBandsShift .. "," .. ShortBandsDeviations .. "," .. LongBandsPeriod .. "," .. LongBandsShift .. "," .. LongBandsDeviations .. "," .. Chars .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    firstShort = source:first() + ShortBandsPeriod + ShortBandsShift;
    firstLong = source:first() + LongBandsPeriod + LongBandsShift;

    ShortDev = instance:addInternalStream(firstShort, 0);
    ShortDev1 = instance:addInternalStream(firstShort, 0);
    LongDev = instance:addInternalStream(firstLong, 0);
    LongDev1 = instance:addInternalStream(firstLong, 0);

    ShortOscillator = instance:addStream("Short", core.Line, name .. ".Short", "Short", instance.parameters.ShortColorUp, firstShort + Chars);
    ShortOscillator:setPrecision(math.max(2, instance.source:getPrecision()));
    LongOscillator = instance:addStream("Long", core.Line, name .. ".Long", "Long", instance.parameters.LongColorUp, firstLong + Chars);
    LongOscillator:setPrecision(math.max(2, instance.source:getPrecision()));
    
	if OverBoughtOverSold then
	ShortOscillator:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	ShortOscillator:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);   
    end	
	
	if Show then	
	ShortOscillator:addLevel(instance.parameters.central, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	end
	
	if MinMax then
	ShortOscillator:addLevel(1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    ShortOscillator:addLevel(0, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	end
	
	if  Additional then
	ShortOscillator:addLevel(Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	ShortOscillator:addLevel(Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  	
	end
	
end

function Update(period, mode)
    Process(period, firstShort, ShortBandsPeriod, ShortBandsShift, ShortBandsDeviations, ShortDev, ShortDev1, ShortOscillator, instance.parameters.ShortColorUp, instance.parameters.ShortColorDown);
    Process(period, firstLong, LongBandsPeriod, LongBandsShift, LongBandsDeviations, LongDev, LongDev1, LongOscillator, instance.parameters.LongColorUp, instance.parameters.LongColorDown);
end

function Process(period, first, BandsPeriod, BandsShift, BandsDeviation, DevBuffer, DevBuffer1, Oscillator, Up, Down)
    if period >= first then
        local range, avg, temp, sum;

        range = core.rangeTo(period - BandsShift, BandsPeriod);
        avg = core.avg(source, range);

        range = core.rangeTo(period, BandsPeriod);
		
        sum = 0;
        for i = range.from, range.to, 1 do
            temp = source[i] - avg;
            sum = sum + temp * temp;
        end
        DevBuffer[period] = BandsDeviation * math.sqrt(sum / BandsPeriod);
        DevBuffer1[period] = math.pow(DevBuffer[period] / point, 2);

        if period >= first + Chars then
            range = core.rangeTo(period, Chars);
            temp = core.sum(DevBuffer1, range);
            temp = math.sqrt(temp / Chars) * point;
            if temp ~= 0 then
                temp = DevBuffer[period] / temp;
            end
            Oscillator[period] = math.tanh(temp);
			if Oscillator[period] >  Oscillator[period-1] then 
			Oscillator:setColor(period, Up);
			else
			Oscillator:setColor(period, Down);
			end
        end
    end
end


