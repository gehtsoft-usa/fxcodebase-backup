-- Id: 8005

-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=27291

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
    indicator:name("Waddah Attar ADXxBollinger");
    indicator:description("Waddah Attar ADXxBollinger");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("ADXP", "ADX Period", "ADX Period", 14);
	
    indicator.parameters:addInteger("BBP", "Bollinger Period", "Bollinger Period", 20);
	indicator.parameters:addString("Price", "Bollinger Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Color of Up WAAB", "Color of WAAB", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Dn", "Color of Down WAAB", "Color of WAAB", core.rgb( 255, 0, 0));
	indicator.parameters:addColor("No", "Color of Neutral WAAB", "Color of WAAB", core.rgb( 128, 128, 128));
	
	
	indicator.parameters:addGroup("Level");	
    indicator.parameters:addDouble("Level", "Level","", 0);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);




end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local ADXP;
local BBP;

local first;
local source = nil;

-- Streams block
local WAAB = nil;
local ADX, DIP, DIM, TL, BL;
local Indicator={};
local Price;
local Up, Dn, No;
-- Routine
function Prepare(nameOnly)
    ADXP = instance.parameters.ADXP;
    BBP = instance.parameters.BBP;
	Price = instance.parameters.Price;
    source = instance.source;
    Up = instance.parameters.Up;
	Dn = instance.parameters.Dn;
	No = instance.parameters.No;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(ADXP) .. ", " .. tostring(BBP).. ", " .. tostring(Price) .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	Indicator[1] = core.indicators:create("ADX", source, ADXP);
	ADX= Indicator[1].DATA;
	
	Indicator[2] = core.indicators:create("DMI", source, ADXP);
	DIP= Indicator[2].DIP;
	DIM= Indicator[2].DIM;
	
	Indicator[3] = core.indicators:create("BB", source[Price], BBP);
	TL = Indicator[3].TL;
	BL = Indicator[3].BL;
	first = math.max(Indicator[1].DATA:first(),Indicator[2].DATA:first() ,Indicator[3].DATA:first() );


    if (not (nameOnly)) then
        WAAB = instance:addStream("WAAB", core.Bar, name, "WAAB", No, first);
    WAAB:setPrecision(math.max(2, instance.source:getPrecision()));
		WAAB:addLevel(instance.parameters.Level, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode) 

	Indicator[1]:update(mode);
	Indicator[2]:update(mode);
	Indicator[3]:update(mode);
	
	
    if period < first   then
	 WAAB:setColor(period, No);	
	return;
	end
	
    
      
    local  Explo = TL[period] -  BL[period];
	
	WAAB[period] = Explo*ADX[period] ; 
	
	
	if DIP[period]> DIM[period] then
	WAAB:setColor(period, Up);
	elseif DIP[period]< DIM[period] then
	WAAB:setColor(period, Dn);
	else
	WAAB:setColor(period, No);	
	end
	
	
   
end

