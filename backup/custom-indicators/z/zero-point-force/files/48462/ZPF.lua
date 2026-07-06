-- Id: 8103
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27690

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
    indicator:name("Zero Point Force");
    indicator:description("Zero Point Force");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
     indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Short", "Short Period", "Short Period", 12);
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
    indicator.parameters:addInteger("Long", "Long Period", "Long Period", 24);
	
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	   indicator.parameters:addInteger("Volume", "Volume Period", "Volume Period", 12);
	
	indicator.parameters:addString("Method3", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");
	
     indicator.parameters:addGroup("Style");
	 indicator.parameters:addInteger("Transparency", "Channel transparency (%)", "", 70, 0, 100);
    indicator.parameters:addColor("Up", "Color of Up Trend", "Color of Up Trend", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Color of Down Trend", "Color of Down Trend", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Short;
local Long;
local Volume;
local Method1,Method2,Method2;
local first;
local source = nil;

-- Streams block
local hh = nil;
local ll=nil;
local S, L, C;
local Transparency;
-- Routine
function Prepare(nameOnly)
    Short = instance.parameters.Short;
    Long = instance.parameters.Long;
	Volume = instance.parameters.Volume;
	Method1 = instance.parameters.Method1;
	Method2 = instance.parameters.Method2;
	Method3 = instance.parameters.Method3;
	Transparency = instance.parameters.Transparency;
    source = instance.source;
	 assert(source:supportsVolume(), "The source must have volume");
	 
	 
	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Short).. ", " .. tostring(Method1) .. ", " .. tostring(Long).. ", " .. tostring(Method2).. ", " .. tostring(Volume).. ", " .. tostring(Method3) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
        S = core.indicators:create(Method1, source.close, Short);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
        L = core.indicators:create(Method2, source.close, Long);
    assert(core.indicators:findIndicator(Method3) ~= nil, Method3 .. " indicator must be installed");
        V = core.indicators:create(Method3, source.volume, Volume );
        first = math.max(S.DATA:first(),L.DATA:first(),V.DATA:first())
        hh = instance:addStream("UP", core.Line, name, "UP", core.rgb(0, 0, 0), first);
    hh:setPrecision(math.max(2, instance.source:getPrecision()));
		ll = instance:addStream("DOWN", core.Line, name, "DOWN", core.rgb(0, 0, 0), first);
    ll:setPrecision(math.max(2, instance.source:getPrecision()));
		instance:createChannelGroup("ZPF", "ZPF", hh, ll, core.rgb(128, 128, 128), 100 - Transparency);

    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    S:update(mode);
	L:update(mode);
	V:update(mode);

    if period < first  then
	return;
	end
	
	   local zpf=V.DATA[period]*(S.DATA[period]-L.DATA[period])/2;
	   
      ll[period]=-zpf;
      hh[period]= zpf;
	  
	  if hh[period] > ll[period] then
	  hh:setColor(period, instance.parameters.Up);	
	  ll:setColor(period, instance.parameters.Up);
	  else
	  hh:setColor(period, instance.parameters.Down);
	   ll:setColor(period, instance.parameters.Down);
	  end

	
   
end

