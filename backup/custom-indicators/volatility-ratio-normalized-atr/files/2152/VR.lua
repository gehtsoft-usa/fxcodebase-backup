-- Id: 765
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1126

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
    indicator:name("Volatility Ratio");
    indicator:description("Volatility Ratio");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Frame", "Period", "Period", 14, 2, 2000);
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("VR_color", "Color of VR", "Color of VR", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	 indicator.parameters:addGroup("Level");	
  
    indicator.parameters:addDouble("Level","Level","", 2);
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
local Frame;
local source = nil;

-- Streams block
local VR = nil;
local TR=nil;
local EMA=nil;
local Level;
-- Routine
function Prepare(nameOnly)
    Frame = instance.parameters.Frame;
	Level= instance.parameters.Level;
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ", " .. Frame .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	TR=instance:addInternalStream(source:first()+1,0)
	EMA = core.indicators:create("EMA", TR, Frame);
	
    VR = instance:addStream("VR", core.Line, name, "VR", instance.parameters.VR_color, EMA.DATA:first());
	VR:setWidth(instance.parameters.width);
    VR:setStyle(instance.parameters.style);
	
	VR:addLevel(instance.parameters.Level, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	
	VR:addLevel(0);
	
	VR:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    if period < 1 
	or not  source:hasData(period)
	then
	return;
	end
	
	  TR[period]=math.max(source.high[period]-source.low[period],math.abs(source.high[period]-source.close[period-1]),math.abs(source.close[period-1]-source.low[period]));
		
	  EMA:update(mode);
	  
	 if period < EMA.DATA:first()  then
	return;
	end
	
      VR[period] = TR[period]/EMA.DATA[period];
    
	 
end

