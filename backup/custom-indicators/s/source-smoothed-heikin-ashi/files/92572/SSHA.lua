-- Id: 11087
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60288

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
function Init()
    indicator:name("Source Smoothed Heikin-Ashi");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Trend");
   -- indicator:setTag("replaceSource", "t");
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Method1", "The smoothing method for prices", "The methods marked by the star (*) requires to have approriate indicators installed", "EMA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA*", "", "SMMA");
    indicator.parameters:addStringAlternative("Method1", "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("Method1", "Wilders*", "", "WMA");
	indicator.parameters:addStringAlternative("Method1", "SuperSmoother", "", "SUPERSMOOTHER");

    indicator.parameters:addInteger("N1", "Periods to smooth prices", "", 20, 1, 1000);


	
	indicator.parameters:addGroup("Style");
	 indicator.parameters:addColor("UP", "Color of Up Candel", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DOWN", "Color of Down Candle", "", core.rgb(255, 0, 0));
end

local smopen = nil;
local smhigh = nil;
local smlow = nil;
local smclose = nil;

local open = nil;
local high = nil;
local low = nil;
local close = nil;

local first1 = 0;
local first2 = 0;

local UP, DOWN;

-- Routine
function Prepare(nameOnly)
    source = instance.source;
   
    -- was missing, so N1 was not set
    local N1 = instance.parameters.N1;
	
	UP = instance.parameters.UP;
	DOWN = instance.parameters.DOWN;
	
	assert(core.indicators:findIndicator(instance.parameters.Method1) ~= nil, "Please, download and install " .. instance.parameters.Method1 ..  " indicator");
	
    local name = "Heikin-Ashi Smoothed" .. "(" .. source:name() .. "," .. instance.parameters.Method1 .. "," .. instance.parameters.N1 .. ")"
    instance:name(name);
    if nameOnly then
        return;
    end
    smopen = core.indicators:create(instance.parameters.Method1, source.open, N1);
    smclose = core.indicators:create(instance.parameters.Method1, source.close, N1);
    smhigh = core.indicators:create(instance.parameters.Method1, source.high, N1);
    smlow = core.indicators:create(instance.parameters.Method1, source.low, N1);

    first1 = smopen.DATA:first() + 1;
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first2)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first2)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first2)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first2)
    instance:createCandleGroup("HAS", "HAS", open, high, low, close);
end

-- Indicator calculation routine
function Update(period, mode)
    -- smooth source
    smopen:update(mode);
    smhigh:update(mode);
    smlow:update(mode);
    smclose:update(mode);

    if period < first1 then
	return;
	end
        -- calculate candles
        if (period == first1) then
            open[period] = (smopen.DATA[period - 1] + smclose.DATA[period - 1]) / 2;
        else
           open[period] = (open[period - 1] + close[period - 1]) / 2;
        end
        close[period] = (smopen.DATA[period] + smhigh.DATA[period] + smlow.DATA[period] + smclose.DATA[period]) / 4;
        high[period] = math.max(open[period], close[period], smhigh.DATA[period]);
        low[period] = math.min(open[period], close[period], smlow.DATA[period]);

     
	 if open[period] > close[period] then
		open:setColor(period, DOWN);	
		elseif open[period] < close[period] then
		open:setColor(period, UP);
		else
		open:setColor(period, core.rgb(128, 128, 128));
		end		
   
  
end



