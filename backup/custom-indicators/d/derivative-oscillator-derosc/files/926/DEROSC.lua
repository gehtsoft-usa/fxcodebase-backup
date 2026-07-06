-- Id: 276

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=537

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Derivative Oscillator");
    indicator:description("Derivative Oscillator as mentioned in Constance Brown's book Technical Analysys for Trading Professional.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
     indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("RSI_N", "RSI Periods", "No description", 14);
    indicator.parameters:addInteger("EMA_N1", "EMA(RSI) periods", "No description", 5);
    indicator.parameters:addInteger("EMA_N2", "EMA(EMA(RSI)) periods", "No description", 3);
    indicator.parameters:addInteger("MVA_N", "MVA(EMA(EMA(RSI))) periods", "No description", 9);
	
	
	 indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("DO_color", "Color of DO", "Color of DO", core.rgb(0, 0, 128));
	indicator.parameters:addBoolean("Color", "Use Color Mode", "", false);
	indicator.parameters:addColor("DO_color_Up", "Color of Up", "Color of DO", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DO_color_Down", "Color of Down", "Color of DO", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local RSI_N;
local EMA_N1;
local EMA_N2;
local MVA_N;

local RSI;
local EMA1;
local EMA2;
local MVA;

local first;
local source = nil;

-- Streams block
local DO = nil;
local Color;
-- Routine
function Prepare(nameOnly) 
    RSI_N = instance.parameters.RSI_N;
    EMA_N1 = instance.parameters.EMA_N1;
    EMA_N2 = instance.parameters.EMA_N2;
    MVA_N = instance.parameters.MVA_N;
	Color= instance.parameters.Color;
    source = instance.source;
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. RSI_N .. ", " .. EMA_N1 .. ", " .. EMA_N2 .. ", " .. MVA_N .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    RSI = core.indicators:create("RSI", source, RSI_N);
    EMA1 = core.indicators:create("EMA", RSI.DATA, EMA_N1);
    EMA2 = core.indicators:create("EMA", EMA1.DATA, EMA_N2);
    MVA = core.indicators:create("MVA", EMA2.DATA, MVA_N);
    first = MVA.DATA:first();
    
    DO = instance:addStream("DO", core.Bar, name, "DO", instance.parameters.DO_color, first);
	
	DO:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
function Update(period, mode)
    RSI:update(mode);
    EMA1:update(mode);
    EMA2:update(mode);
    MVA:update(mode);

    if period >= first then
        DO[period] = EMA2.DATA[period] - MVA.DATA[period];
    end
	
	if Color then
		if DO[period] > DO[period-1] then
		DO:setColor(period,  instance.parameters.DO_color_Up);
		else
		DO:setColor(period,  instance.parameters.DO_color_Down);
		end	
	end
end

