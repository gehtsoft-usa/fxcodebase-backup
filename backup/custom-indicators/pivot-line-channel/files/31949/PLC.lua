-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=17533
-- Id: 6466

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Pivot Line channel");
    indicator:description("Pivot Line channel");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
	indicator.parameters:addGroup("Pivot Calculatin");
    indicator.parameters:addString("BS", "Time Frame", "", "D1");
    indicator.parameters:setFlag("BS", core.FLAG_PERIODS);

    indicator.parameters:addString("CalcMode", "Pivot Mode", "", "Pivot");
    indicator.parameters:addStringAlternative("CalcMode", "Pivot", "", "Pivot");
    indicator.parameters:addStringAlternative("CalcMode", "Camarilla", "", "Camarilla");
    indicator.parameters:addStringAlternative("CalcMode", "Woodie", "", "Woodie");
    indicator.parameters:addStringAlternative("CalcMode", "Fibonacci", "", "Fibonacci");
    indicator.parameters:addStringAlternative("CalcMode", "Floor", "", "Floor");
    indicator.parameters:addStringAlternative("CalcMode", "FibonacciR", "", "FibonacciR");
	
    indicator.parameters:addGroup("Channel Calculatin");
	 indicator.parameters:addString("Mode", "Pivot Mode", "", "PIP");
    indicator.parameters:addStringAlternative("Mode", "Pip", "", "PIP");
    indicator.parameters:addStringAlternative("Mode", "ATR", "", "ATR");	
    indicator.parameters:addInteger("Width", "Width In Pips", "", 40);
	indicator.parameters:addInteger("AP", "ATR Period", "", 14);
	indicator.parameters:addDouble("AM", "ATR Multiplier", "", 1);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Top_color", "Color of Top", "Color of Top", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("widthTop", "Top Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleTop", "Top Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleTop", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Pivot_color", "Color of Pivot", "Color of Pivot", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("widthPivot", "Pivot Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("stylePivot", "Pivot Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("stylePivot", core.FLAG_LINE_STYLE);	
	
    indicator.parameters:addColor("Bottom_color", "Color of Bottom", "Color of Bottom", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("widthBottom", "Bottom Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleBottom", "Bottom Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleBottom", core.FLAG_LINE_STYLE);	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local CalcMode;
local BS;
local Width;
local first;
local source = nil;
local Indicator;
-- Streams block
local Top = nil;
local Central = nil;
local Bottom = nil;
local AP, AM, Mode;
local ATR;
local Value;
-- Routine
function Prepare(nameOnly)
    CalcMode = instance.parameters.CalcMode;
	BS = instance.parameters.BS;
    source = instance.source;
    AP = instance.parameters.AP;
    AM = instance.parameters.AM;
    Mode= instance.parameters.Mode;
	Width = instance.parameters.Width;
	
	Value =  Width*source:pipSize();	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(CalcMode).. ", " .. tostring(BS) .. ", " .. tostring(Mode).. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	Indicator = core.indicators:create("PIVOT", source, BS, CalcMode , "HIST"  );
	 ATR = core.indicators:create("ATR", source, AP  );
	 first = math.max(Indicator.DATA:first(), ATR.DATA:first() );

    if (not (nameOnly)) then
        Top = instance:addStream("Top", core.Line, name .. ".Top", "Top", instance.parameters.Top_color, first);
		Top:setWidth(instance.parameters.widthTop);
        Top:setStyle(instance.parameters.styleTop);
		Central = instance:addStream("Pivot", core.Line, name .. ".Pivot", "Pivot", instance.parameters.Pivot_color, first);
		Central:setWidth(instance.parameters.widthPivot);
        Central:setStyle(instance.parameters.stylePivot);
        Bottom = instance:addStream("Bottom", core.Line, name .. ".Bottom", "Bottom", instance.parameters.Bottom_color, first);
		Bottom:setWidth(instance.parameters.widthBottom);
        Bottom:setStyle(instance.parameters.styleBottom);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    Indicator:update(mode);
  
	
	
	
	if period <  first + 1 then
    return;
    end	

	
	 
        if Mode ~= "PIP" then	 
 		    ATR:update(mode);
		    Value =  ATR.DATA[period]*AM;	
        end		
	
		
		Central[period]= Indicator.DATA[period];	
		Top[period] = Central[period] + Value ;
		Bottom[period] = Central[period] - Value;
		
end		


