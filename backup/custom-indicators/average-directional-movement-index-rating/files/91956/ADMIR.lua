-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60198
-- Id: 10846

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
    indicator:name("Average Directional Movement Index Rating");
    indicator:description("Average Directional Movement Index Rating");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	indicator.parameters:addInteger("Difference", "Look Back Period", "Look Back Period", 14);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("ADXMIR_color", "Color of ADXMIR", "Color of ADXMIR", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addDouble("Level2", "2. Level","", 20);
    indicator.parameters:addDouble("Level1",  "1. Level","", 25);
	    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
	
	indicator.parameters:addGroup("Arrows Style");
	
	indicator.parameters:addBoolean("Show1", "Show First Line Cross", "", false);
	indicator.parameters:addBoolean("Show2", "Show Second Line Cross", "", false);
	indicator.parameters:addInteger("Size", "Arrows Size","", 10);	 
	indicator.parameters:addColor("First", "First Line Arrow Color","", core.rgb(128, 128, 128));
	indicator.parameters:addColor("Second", "Second Line Arrow Color","", core.rgb(128, 128, 128));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period,Difference;
local Show1, Show2;
local first;
local source = nil;
local Size;
-- Streams block
local ADXMIR = nil;
local ADX;
local Up1, Down1, Up2, Down2;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Show1 = instance.parameters.Show1;
	Show2 = instance.parameters.Show2;
	Difference = instance.parameters.Difference;
	Size= instance.parameters.Size;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
		ADX = core.indicators:create("ADX", source,Period );
		first = ADX.DATA:first()+Difference;
        ADXMIR = instance:addStream("ADXMIR", core.Line, name, "ADXMIR", instance.parameters.ADXMIR_color, first);
    ADXMIR:setPrecision(math.max(2, instance.source:getPrecision()));
		ADXMIR:setWidth(instance.parameters.width);
        ADXMIR:setStyle(instance.parameters.style);
		ADXMIR:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		ADXMIR:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
    end
	
	
	Up1 = instance:createTextOutput("Up1", "Up1", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.First, 0);
	Down1 = instance:createTextOutput("Down1", "Down1", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.First, 0);
	
	Up2 = instance:createTextOutput("Up2", "Up1", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Second, 0);
	Down2 = instance:createTextOutput("Down2", "Down1", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Second, 0);
	
	core.host:execute ("attachTextToChart", "Up1");
	core.host:execute ("attachTextToChart", "Down1");
	core.host:execute ("attachTextToChart", "Up1");
	core.host:execute ("attachTextToChart", "Down1");
	
	
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    Up1:setNoData (period);
    Down1:setNoData (period);
	Up2:setNoData (period);
    Down2:setNoData (period);

    ADX:update(mode);
    if period < first   then
	return;
	end
    
        ADXMIR[period] = (ADX.DATA[period]+ADX.DATA[period-Difference])/2;
		
		if Show1 then
		
		   if  ADXMIR[period] > instance.parameters.Level1 
		   and ADXMIR[period-1] <= instance.parameters.Level1 
		   then
		   Up1:set(period  , source.high[period ], "\225");
		   elseif  ADXMIR[period] < instance.parameters.Level1 
		   and ADXMIR[period-1] >= instance.parameters.Level1 
		   then		   
		   Down1:set(period  , source.low[period  ], "\226");
           end
		   
		end   
		
		if Show2 then
		   if  ADXMIR[period] > instance.parameters.Level2 
		   and ADXMIR[period-1] <= instance.parameters.Level2 
		   then
		   Up2:set(period  , source.high[period ], "\225");
		   elseif  ADXMIR[period] < instance.parameters.Level2 
		   and ADXMIR[period-1] >= instance.parameters.Level2 
		   then		   
		   Down2:set(period  , source.low[period  ], "\226");
           end
		end   
end

