-- More information about this indicator can be found at:
-- http://fxcodebase.com

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

function Init()
    indicator:name("Elder Impulse Bar indicator with Pivot Filter");
    indicator:description("Elder Impulse Bar indicator with Pivot Filter");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("EMA", "EMA periods for study", "", 13, 1, 100);
    indicator.parameters:addInteger("MACDF", "MACD periods fast", "", 12, 1, 100);
    indicator.parameters:addInteger("MACDS", "MACD periods slow", "", 26, 1, 100);
    indicator.parameters:addString("app_price", "app_price", "", "close");
    indicator.parameters:addStringAlternative("app_price", "close", "", "close");
    indicator.parameters:addStringAlternative("app_price", "open", "", "open");
    indicator.parameters:addStringAlternative("app_price", "high", "", "high");
    indicator.parameters:addStringAlternative("app_price", "low", "", "low");
    indicator.parameters:addStringAlternative("app_price", "median", "", "median");
    indicator.parameters:addStringAlternative("app_price", "typical", "", "typical");
    indicator.parameters:addStringAlternative("app_price", "weighted", "", "weighted");
	
	
	indicator.parameters:addGroup("Pivot Calculation");	
	indicator.parameters:addBoolean("Filter", "Use Pivot Filter", "Use Pivot Filter", true);
	indicator.parameters:addString("TF","Time Frame", "", "D1");
    indicator.parameters:setFlag("TF", core.FLAG_BARPERIODS);

    indicator.parameters:addString("CalcMode", "Calculation Mode", "", "Pivot");
    indicator.parameters:addStringAlternative("CalcMode", "Pivot", "", "Pivot");
    indicator.parameters:addStringAlternative("CalcMode", "Camarilla", "", "Camarilla");
    indicator.parameters:addStringAlternative("CalcMode", "Woodie", "", "Woodie");
    indicator.parameters:addStringAlternative("CalcMode", "Fibonacci", "", "Fibonacci");
    indicator.parameters:addStringAlternative("CalcMode", "Floor", "", "Floor");
    indicator.parameters:addStringAlternative("CalcMode", "FibonacciR", "", "FibonacciR")

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Color of up signal", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Color of down signal", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Neutral", "Color of neutral signal", "", core.rgb(0, 0, 255));
end
local Pivot, TF, CalcMode;
local first;
local source = nil;
local EMA;
local MACDF;
local MACDS;
local app_price;
local EIS;
local Up,Down,Neutral;

local open, close,high,low;
local Filter;
function Prepare(nameOnly)
    source = instance.source;
    EMA=instance.parameters.EMA;
    MACDF=instance.parameters.MACDF;
    MACDS=instance.parameters.MACDS;
	Filter=instance.parameters.Filter;
    app_price=instance.parameters.app_price;
	
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
   
    Pivot=instance.parameters.Pivot;
    TF=instance.parameters.TF
    CalcMode=instance.parameters.CalcMode;
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.EMA .. ", " .. instance.parameters.MACDF .. ", " .. instance.parameters.MACDS .. ")";
    instance:name(name);
    if (nameOnly) then
        return;
    end
    assert(core.indicators:findIndicator("ELDER_IMPULSE_SYSTEM") ~= nil, "Please, download and install ELDER_IMPULSE_SYSTEM.LUA indicator");
   
    EIS = core.indicators:create("ELDER_IMPULSE_SYSTEM", source[app_price], EMA, MACDF, MACDS);
    Pivot= core.indicators:create("PIVOT", source, TF, CalcMode, "HIST");	

    first = math.max( EIS.UP:first(), EIS.DN:first(),EIS.NE:first(), Pivot.DATA:first()) +1;
    open=instance:addInternalStream(first, 0);
    close=instance:addInternalStream(first, 0);
    high=instance:addInternalStream(first, 0);
    low=instance:addInternalStream(first, 0);
	
	instance:createCandleGroup("EIB", "", open, high, low, close);
end

function Update(period, mode)

   EIS:update(mode);
   Pivot:update(mode);
   
    open[period]= source.open[period];
	close[period]= source.close[period];
	high[period]= source.high[period];
	low[period]= source.low[period];
	
   if (period<first) then
   open:setColor(period, Neutral);	
   return;
   end
 
	
	
	
	
	
    if EIS.UP[period]~= nil and EIS.UP[period]==100 
	and (source.close[period] > Pivot.DATA[period] or not Filter)
	then
    open:setColor(period, Up);	
    elseif   EIS.DN[period]~= nil and EIS.DN[period]==100
	and (source.close[period] < Pivot.DATA[period] or not Filter)
	then
    open:setColor(period, Down);	
    elseif   EIS.NE[period]~= nil and EIS.NE[period]==100 then
	open:setColor(period, Neutral);	
	else
	open:setColor(period, Neutral);	    
    end
 
end

