-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60135
-- Id: 10729

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
    indicator:name("QStick");
    indicator:description("QStick");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Length", "Length", "Length", 8);
    indicator.parameters:addString("MA_Mode", "MA_Mode", "MA_Mode", "MVA");
	 indicator.parameters:addStringAlternative("MA_Mode", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("MA_Mode", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("MA_Mode", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("MA_Mode", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("MA_Mode", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("MA_Mode", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("MA_Mode", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("MA_Mode", "WMA", "WMA" , "WMA");
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("QStick_Up", "Color of Up QStick", "Color of QStick", core.rgb(0, 255, 0));
	indicator.parameters:addColor("QStick_Down", "Color of DOwn QStick", "Color of QStick", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Length;
local MA_Mode;

local first;
local source = nil;
local MA;
-- Streams block
local QStick ,Diff ;

-- Routine
function Prepare(nameOnly)
    Length = instance.parameters.Length;
    MA_Mode = instance.parameters.MA_Mode;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. " Length : " .. tostring(Length) .. " MA Mode :  " .. tostring(MA_Mode) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Diff= instance:addInternalStream(0, 0);
        
    assert(core.indicators:findIndicator(MA_Mode) ~= nil, MA_Mode .. " indicator must be installed");
        MA = core.indicators:create(MA_Mode, Diff, Length);
        first = MA.DATA:first();
        QStick = instance:addStream("QStick", core.Bar, name, "QStick", instance.parameters.QStick_Up, MA.DATA:first());
    QStick:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    Diff[period]=  source[period] -source[period-1];
    if period < first  then
	return;
	end
	
	MA:update(mode);
	
        QStick[period] = MA.DATA[period];
		
		if QStick[period] > QStick[period-1] then
		QStick:setColor(period, instance.parameters.QStick_Up);
		else
		QStick:setColor(period, instance.parameters.QStick_Down);
		end
		
    
end

