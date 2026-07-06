-- Id: 7304
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23054

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
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Ichimoku Index");
    indicator:description("Ichimoku Index");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 26);
	
	indicator.parameters:addInteger("Number", "Select Component ", "", 1);
    indicator.parameters:addIntegerAlternative("Number", "SL", "", 1);
    indicator.parameters:addIntegerAlternative("Number", "TL", "", 2);
	indicator.parameters:addIntegerAlternative("Number", "CS", "", 3);
    indicator.parameters:addIntegerAlternative("Number", "SA", "", 4);
	indicator.parameters:addIntegerAlternative("Number", "SB", "", 5);

	
	indicator.parameters:addGroup("Ichimoku Calculation");	
	indicator.parameters:addInteger("TS", "Tenkan-sen period", "Tenkan-sen period", 9, 1, 1000);
    indicator.parameters:addInteger("KS", "Kijun-sen period", "Kijun-sen period", 26, 1, 1000);
    indicator.parameters:addInteger("SS", "Senkou Span B period", "Senkou Span B period", 52, 1, 1000);
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Up_color", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Dn_color", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("Levels Style" ); 
    indicator.parameters:addInteger("level_overboughtsold_width", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Sryle", "", core.LINE_SOLID);
	indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("level_overboughtsold_color", "Color", "", core.rgb(0, 0, 255));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local TS, KS,SS;
local first;
local source = nil;
local ICH;
-- Streams block
local Up,Dn;
local Stream;
local Number;
local Short={"SL", "TL", "CS", "SA", "SB"};
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Number = instance.parameters.Number;
    source = instance.source;
	KS = instance.parameters.KS;
	TS = instance.parameters.TS;
	SS = instance.parameters.SS;
	
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period)  .. ", " .. tostring(KS) .. ", " .. tostring(TS) .. ", " .. tostring(SS).. ", " .. tostring(Short[Number]).. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	ICH = core.indicators:create("ICH", source,  TS , KS , SS);
 
	Stream = ICH:getStream(Number-1);
	
	first= Stream:first() + Period ;

        Up = instance:addStream("Up", core.Line, name, "Up", instance.parameters.Up_color, first);
		Up:setWidth(instance.parameters.width);
        Up:setStyle(instance.parameters.style);
		Dn = instance:addStream("Dn", core.Line, name, "Dn", instance.parameters.Dn_color, first);
		Dn:setWidth(instance.parameters.width);
        Dn:setStyle(instance.parameters.style);
		
		Up:addLevel(Period, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
        Up:addLevel(0, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		Up:addLevel(Period/2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		
		Up:setPrecision(math.max(2, instance.source:getPrecision()));
		Dn:setPrecision(math.max(2, instance.source:getPrecision()));
  
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
 	
	ICH:update(mode);	
	
	if period < first or not source:hasData(period) then
	return;
	end
	
	local i;
	local UP =0;
	local DN =0;
	
	 
	
		for i=  period-Period+1, period, 1 do
		
				if Stream:hasData(i) then
				
					if source.close[i] > Stream[i] then
					UP=UP+1;
					end
					
					if source.close[i] < Stream[i] then
					DN=DN+1;
					end
				end	
		
		end
		
	
        Up[period] = UP;
        Dn[period] = DN;
end

