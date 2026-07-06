-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=993

--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("Elder Impulse Bar indicator");
    indicator:description("Elder Impulse Bar indicator");
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

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP_color", "Color of up signal", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DOWN_color", "Color of down signal", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("NE_color", "Color of neutral signal", "", core.rgb(0, 0, 255));
end

local first;
local source = nil;
local EMA;
local MACDF;
local MACDS;
local app_price;
local EIS;


local open, close,high,low;

function Prepare()
    source = instance.source;
    EMA=instance.parameters.EMA;
    MACDF=instance.parameters.MACDF;
    MACDS=instance.parameters.MACDS;
    app_price=instance.parameters.app_price;
   
   
     assert(core.indicators:findIndicator("ELDER_IMPULSE_SYSTEM") ~= nil, "Please, download and install ELDER_IMPULSE_SYSTEM.LUA indicator");  
	 
     EIS = core.indicators:create("ELDER_IMPULSE_SYSTEM", source[app_price], EMA, MACDF, MACDS);


    first = math.max( EIS.UP:first(), EIS.DN:first(),EIS.NE:first()) +1;
    open=instance:addInternalStream(first, 0);
    close=instance:addInternalStream(first, 0);
    high=instance:addInternalStream(first, 0);
    low=instance:addInternalStream(first, 0);
	
	 instance:createCandleGroup("EIB", "", open, high, low, close);

    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.EMA .. ", " .. instance.parameters.MACDF .. ", " .. instance.parameters.MACDS .. ")";
    instance:name(name);
	
end

function Update(period, mode)
   if (period>first) then
    EIS:update(mode);
	
	open[period]= source.open[period];
	close[period]= source.close[period];
	high[period]= source.high[period];
	low[period]= source.low[period];
	
	
	
    if EIS.UP[period]~= nil and EIS.UP[period]==100 then
   open:setColor(period, instance.parameters.UP_color);	

    elseif   EIS.DN[period]~= nil and EIS.DN[period]==100 then
     open:setColor(period, instance.parameters.DOWN_color);	
    elseif   EIS.NE[period]~= nil and EIS.NE[period]==100 then
	open:setColor(period, instance.parameters.NE_color);	
	else
	open:setColor(period, core.rgb(128,128, 128));	
    
    end
   end 
end

