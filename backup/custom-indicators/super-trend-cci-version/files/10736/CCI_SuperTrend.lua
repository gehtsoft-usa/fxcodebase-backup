-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4306
-- Id: 3923

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("CCI SuperTrend Indicator");
    indicator:description("The indicator displays the signals based on CCI zero line Cross");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "ATR periods", "", 10);
	 indicator.parameters:addDouble("M", "ATR Multiplier", "", 2);
	indicator.parameters:addInteger("C", "CCI periods", "", 50);
   
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP_color", "Color of UP", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DN_color", "Color of DN", "", core.rgb(255, 0, 0));
	 indicator.parameters:addInteger("width", "Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("style", "Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;
local M;
local C;

local first;
local source = nil;

-- Streams block
local ATR = nil;
local CCI=nil;

local TREND;
local COLOR;

-- Routine
function Prepare(nameOnly)
    C= instance.parameters.C;
    N = instance.parameters.N;
    M = instance.parameters.M;
    source = instance.source;
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ", " .. M .. ", " .. C  .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
    ATR = core.indicators:create("ATR", source, N);
	CCI = core.indicators:create("CCI", source, C);
	
	 first = math.max(ATR.DATA:first(), CCI.DATA:first());
	
	UP = instance:addInternalStream(first, 0);
    DN = instance:addInternalStream(first, 0);
	
    
    Trend = instance:addStream("Trend", core.Line, name .. ".Trend", "Trend", instance.parameters.UP_color, first);    
	Trend:setWidth(instance.parameters.width);
    Trend:setStyle(instance.parameters.style);
end

-- Indicator calculation routine
function Update(period, mode)
    ATR:update(mode);
	CCI:update(mode);
	
	        UP[period] = source.high[period] + ATR.DATA[period] * M;
			DN[period] = source.low[period] - ATR.DATA[period] * M;
   
		
		if period < first +1	 then         
 		return;
		elseif period == first +1	 then  
		 Trend[period-1] = UP[period-1];
        end	 	
			
		
			
		if core.crossesOver(CCI.DATA, 0 , period) then	
		Trend[period] = DN[period];
		TREND ="Up";
		COLOR=instance.parameters.UP_color;
        elseif core.crossesUnder(CCI.DATA, 0 , period) then		
        Trend[period] = UP[period];
		TREND = "Down";
		COLOR=instance.parameters.DN_color;
		end
		
		if TREND == "Up" and Trend[period-1] < DN[period] then
		     Trend[period]=  DN[period];
		elseif TREND == "Up" then
		Trend[period]=Trend[period-1];
        end		
		
		if TREND == "Down" and Trend[period-1] > UP[period] then
		     Trend[period]=  UP[period];
		     
		elseif TREND == "Down" then
		Trend[period]=Trend[period-1];
		end
	
		Trend:setColor(period,COLOR);
		
end

