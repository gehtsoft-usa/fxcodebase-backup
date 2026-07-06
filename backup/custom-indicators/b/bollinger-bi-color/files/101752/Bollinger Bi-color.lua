-- Id: 14650
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62521

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- The indicator corresponds to the Bollinger Bands indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 5 "Trend System" (page 91-94)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Bollinger Bi-color");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Bollinger");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Period","", 20, 1, 10000);
    indicator.parameters:addDouble("Dev", "Multiplier","", 2.0, 0.0001, 1000.0);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Up Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color","", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthBBB", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleBBB", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleBBB", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addBoolean("HideAve", "Hide Cental Line","", false);

    indicator.parameters:addInteger("widthBBA", "Central Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleBBA", "Central Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleBBA", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;
local D;

local firstPeriod;
local source = nil;

-- Streams block
local TL = nil;
local BL = nil;
local AL = nil;
local Up, Down,Neutral;
-- Routine
function Prepare(nameOnly)
    N = instance.parameters.N;
    D = instance.parameters.Dev;
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	Neutral= instance.parameters.Neutral;
    source = instance.source;
    firstPeriod = source:first() + N - 1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ", " .. D .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    TL = instance:addStream("TL", core.Line, name .. ".TL", "TL", Up, firstPeriod)
    TL:setWidth(instance.parameters.widthBBB);
    TL:setStyle(instance.parameters.styleBBB);
    BL = instance:addStream("BL", core.Line, name .. ".BL", "BL", Up, firstPeriod)
    BL:setWidth(instance.parameters.widthBBB);
    BL:setStyle(instance.parameters.styleBBB);
    if not instance.parameters.HideAve then
        AL = instance:addStream("AL", core.Line, name .. ".AL", "AL", Up, firstPeriod)
        AL:setWidth(instance.parameters.widthBBA);
        AL:setStyle(instance.parameters.styleBBA);
    end
end

-- Indicator calculation routine
function Update(period)
    if period < firstPeriod then
	return;
	end
        local ml = mathex.avg(source, period - N + 1, period);
        local d = mathex.stdev(source, period - N + 1, period);
        local Dd = D * d;
        TL[period] = ml + Dd;
        BL[period] = ml - Dd;
        if AL ~= nil then
            AL[period] = ml;
        end
     
	 local T1=0;
	 local T2=0;
	 
	 if TL[period]> TL[period-1] then
	 TL:setColor(period, Up);
	 T1=1;
	 elseif TL[period]< TL[period-1] then
	 TL:setColor(period, Down);
	 T1=-1;
	 else
	 TL:setColor(period, Neutral);
	 T1=0;
	 end
	 
	 if BL[period]> BL[period-1] then
	 BL:setColor(period, Up);
	 T2=1;
	 elseif BL[period]< BL[period-1] then
	 BL:setColor(period, Down);
	 T2=-1;
	 else
	 BL:setColor(period, Neutral);
	 T1=0;
	 end
	 
	 if not instance.parameters.HideAve then
		 if T1== 1 and T2==1 then
		 AL:setColor(period, Up);
		 elseif T1== -1 and T2==-1 then
		 AL:setColor(period, Down);
		 else
		 AL:setColor(period, Neutral);
		 end
	 end
end





