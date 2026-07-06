-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3169


--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("Impulse Bar indicator");
    indicator:description("Impulse Bar indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("FastEMA", "FastEMA", "", 12);
    indicator.parameters:addInteger("SlowEMA", "SlowEMA", "", 26);
    indicator.parameters:addInteger("SignalEMA", "SignalEMA", "", 9);
    indicator.parameters:addString("app_price", "app_price", "", "close");
    indicator.parameters:addStringAlternative("app_price", "close", "", "close");
    indicator.parameters:addStringAlternative("app_price", "open", "", "open");
    indicator.parameters:addStringAlternative("app_price", "high", "", "high");
    indicator.parameters:addStringAlternative("app_price", "low", "", "low");
    indicator.parameters:addStringAlternative("app_price", "median", "", "median");
    indicator.parameters:addStringAlternative("app_price", "typical", "", "typical");
    indicator.parameters:addStringAlternative("app_price", "weighted", "", "weighted");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(0, 255, 255));
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(255, 0, 255));
    indicator.parameters:addColor("NEclr", "Neutral Color", "Neutral Color", core.rgb(147, 112, 219));
end

local first;
local source = nil;
local FastEMA;
local SlowEMA;
local SignalEMA;
local app_price;
local MACD_Osmax;
local HU=nil;
local LU=nil;
local HN=nil;
local LN=nil;
local HD=nil;
local LD=nil;

local open=nil;
local close=nil;
local high=nil;
local low=nil;
function Prepare(nameOnly)
    source = instance.source;
    FastEMA=instance.parameters.FastEMA;
    SlowEMA=instance.parameters.SlowEMA;
    SignalEMA=instance.parameters.SignalEMA;
    app_price=instance.parameters.app_price; 
	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.FastEMA .. ", " .. instance.parameters.SlowEMA .. ", " .. instance.parameters.SignalEMA .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator("MACD_OSMAX") ~= nil, "Please, download and install MACD_OSMAX.LUA indicator");  
	
    if app_price=="close" then
     MACD_Osmax = core.indicators:create("MACD_OSMAX", source.close, FastEMA, SlowEMA, SignalEMA, 1, instance.parameters.UPclr, instance.parameters.DNclr, instance.parameters.NEclr);
    elseif app_price=="open" then
     MACD_Osmax = core.indicators:create("MACD_OSMAX", source.open, FastEMA, SlowEMA, SignalEMA, 1, instance.parameters.UPclr, instance.parameters.DNclr, instance.parameters.NEclr);
    elseif app_price=="high" then
     MACD_Osmax = core.indicators:create("MACD_OSMAX", source.high, FastEMA, SlowEMA, SignalEMA, 1, instance.parameters.UPclr, instance.parameters.DNclr, instance.parameters.NEclr);
    elseif app_price=="low" then
     MACD_Osmax = core.indicators:create("MACD_OSMAX", source.low, FastEMA, SlowEMA, SignalEMA, 1, instance.parameters.UPclr, instance.parameters.DNclr, instance.parameters.NEclr);
    elseif app_price=="median" then
     MACD_Osmax = core.indicators:create("MACD_OSMAX", source.median, FastEMA, SlowEMA, SignalEMA, 1, instance.parameters.UPclr, instance.parameters.DNclr, instance.parameters.NEclr);
    elseif app_price=="typical" then
     MACD_Osmax = core.indicators:create("MACD_OSMAX", source.typical, FastEMA, SlowEMA, SignalEMA, 1, instance.parameters.UPclr, instance.parameters.DNclr, instance.parameters.NEclr);
    else
     MACD_Osmax = core.indicators:create("MACD_OSMAX", source.weighted, FastEMA, SlowEMA, SignalEMA, 1, instance.parameters.UPclr, instance.parameters.DNclr, instance.parameters.NEclr);
    end
    first = MACD_Osmax.DATA:first()+2;
   
    
     
	 
	 open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("ZONE", "", open, high, low, close);
end

function Update(period, mode)

   MACD_Osmax:update(mode);
   
     high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];	
   
   if (period<first) then
   open:setColor(period, instance.parameters.NEclr);
    return;     
   end 
   
   open:setColor(period,MACD_Osmax.DATA:colorI(period)) ;
end

