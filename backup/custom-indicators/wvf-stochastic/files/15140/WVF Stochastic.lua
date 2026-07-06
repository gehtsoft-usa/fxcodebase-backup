-- Id: 4649
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6648

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
    indicator:name("WVF Stochastic ");
    indicator:description("WVF Stochastic ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	 indicator.parameters:addGroup("WTF Calculation"); 
    indicator.parameters:addInteger("WP", "WVF Period", "WVF Period", 14);
    
	 indicator.parameters:addGroup("Stochastic Calculation");
    indicator.parameters:addInteger("KP", "K Period", "", 5, 2, 1000); 
    indicator.parameters:addInteger("DP", "D Period Smoothing Period", "",  3, 2, 1000);

	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("K_color", "Color of K", "Color of K", core.rgb(255, 0, 0));
    indicator.parameters:addColor("D_color", "Color of D", "Color of D", core.rgb(0, 255, 0));
	
	
	indicator.parameters:addGroup("Overbought/oversold level");
   
    indicator.parameters:addInteger("overbought","Overbought Level", "", 80, 0, 100);
    indicator.parameters:addInteger("oversold", "Oversold Level", "", 20, 0, 100);
    indicator.parameters:addInteger("level_overboughtsold_width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:addColor("level_overboughtsold_color", "Line Color", "", core.rgb(255, 255, 0));
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local WP, KP, DP;
local WVF;
local first;
local source = nil;

-- Streams block
local K = nil;
local D = nil;
local Smoothing;

local mins, maxes;

-- Routine
function Prepare(nameOnly)
    WP = instance.parameters.WP;
    DP = instance.parameters.DP;
	KP = instance.parameters.KP;
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ", " .. WP .. ", " .. KP .. ", " .. DP .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    mins = instance:addInternalStream(source:first() + KP, 0);
    maxes = instance:addInternalStream(source:first() + KP, 0);
	
	assert(core.indicators:findIndicator("WVF") ~= nil, "Please, download and install WVF.LUA indicator");
	
	WVF = core.indicators:create("WVF", source, WP);
    K = instance:addStream("K", core.Line, name .. ".K", "K", instance.parameters.K_color, WVF.DATA:first()+KP);
    K:setPrecision(math.max(2, instance.source:getPrecision()));
	
	 Smoothing = core.indicators:create("MVA", K , DP);
	 
	 first= Smoothing.DATA:first();
	
    D = instance:addStream("D", core.Line, name .. ".D", "D", instance.parameters.D_color, first);
	
	D:setPrecision(2);
   

    D:addLevel(0);
    D:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    D:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    D:addLevel(100);
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

 	
	    WVF:update(mode);
		
if period < WVF.DATA:first()+KP  then 
 return;
 end
 
		 local minLow, maxHigh = mathex.minmax(WVF.DATA, period - KP + 1, period);
		 
		 
		 mins[period] = WVF.DATA[period] - minLow;
        maxes[period] = maxHigh - minLow;
		
		
		if maxes[period] > 0 then
           K[period] = mins[period] / maxes[period] * 100;
        else
            K[period] = 50;
        end
		
		
	
		
		Smoothing:update(mode);
		
		 if period < first  then 
		 return;
		 end
		
        D[period] = Smoothing.DATA[period];
   
end

