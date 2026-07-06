-- Id: 1276

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1855

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
    indicator:name("DSS Bressert");
    indicator:description("DSS Bressert");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Frame", "Stochastic Period", "Stochastic Period", 13);
    indicator.parameters:addInteger("EMAFrame", "Smooth Period", "Smooth Period", 8);
	indicator.parameters:addInteger("SignalFrame", "Signal Period", "Signal Period", 8);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Stochastic_color", "Color of Stochastic", "Color of Stochastic", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("Signal_color", "Color of Signal", "Color of Signal", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 80);
    indicator.parameters:addDouble("oversold","Oversold Level","", 20);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	indicator.parameters:addGroup("OB/OS Zone");	
	indicator.parameters:addBoolean("Show" , "Show Overlay", "", true);	
	indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 75, 0, 100);
	indicator.parameters:addColor("OBColor", "Overbought Zone Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("OSColor", "Oversold Zone Color","", core.rgb(0, 255, 0));

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Frame;
local EMAFrame;
local SignalFrame;

local first;
local source = nil;

-- Streams block
local DSS= nil;
local EMA = nil;
local Show;
local HIGH=nil;
local LOW=nil;

local DELTA=nil;
local MIT=nil;
local SmoothCoefficient=nil;

local Buffer=nil;
local Signal=nil;
local OUT=nil;
local transparency; 
local OBColor, OSColor;
-- Routine
function Prepare(nameOnly) 
    Frame = instance.parameters.Frame;
    EMAFrame = instance.parameters.EMAFrame;
	SignalFrame = instance.parameters.SignalFrame;
	Show = instance.parameters.Show; 
	OBColor = instance.parameters.OBColor;
	OSColor = instance.parameters.OSColor;

    source = instance.source;
    first = source:first()+Frame;
	

	

    local name = profile:id() .. "(" .. source:name() .. ", " .. Frame .. ", " .. EMAFrame ..", ".. SignalFrame.. ")";
    instance:name(name);
	
	 if   (nameOnly) then
        return;
    end
	
	
		Buffer=instance:addInternalStream(0, 0);
	OUT=instance:addInternalStream(0, 0);
	
    DSS = instance:addStream("DSS", core.Line, name .. ".DSS", "DSS", instance.parameters.Stochastic_color, 3*Frame + EMAFrame);
	DSS:setWidth(instance.parameters.width1);
    DSS:setStyle(instance.parameters.style1);
	if not Show then
	DSS:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	DSS:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
	end

	
	EMA = core.indicators:create("EMA", OUT, SignalFrame);
	
    Signal = instance:addStream("SIGNAL", core.Line, name .. ".Signal", "Signal", instance.parameters.Signal_color, EMA.DATA:first());
	Signal:setWidth(instance.parameters.width2);
    Signal:setStyle(instance.parameters.style2);
	
	DSS:setPrecision(math.max(2, instance.source:getPrecision()));
	Signal:setPrecision(math.max(2, instance.source:getPrecision()));
	
	SmoothCoefficient= 2.0 / (1.0 + EMAFrame); 
	
	instance:ownerDrawn(Show);
	
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
	
    if period < first or not source:hasData(period) then
	return;
	end 
	
	
			HIGH = mathex.max(source.high, period-Frame+1, period);
			LOW = mathex.min(source.low, period-Frame+1, period);
			DELTA = source.close[period] - LOW;
			MIT = DELTA/(HIGH - LOW)*100.0;
			Buffer[period] = SmoothCoefficient * (MIT - Buffer[period-1]) + Buffer[period-1];
			
			if period < 2*Frame  then
			return;
			end
			
					LOW, HIGH = mathex.minmax(Buffer , period-Frame-1, period);
					DELTA= Buffer[period] -LOW; 
					MIT = DELTA/(HIGH - LOW)*100.0;
					OUT[period] = SmoothCoefficient * (MIT - OUT[period-1]) + OUT[period-1];
					
					if period < 3*Frame + EMAFrame then
					return;
					end
					
					
					DSS[period]=OUT[period];
					 
					
							 	
							EMA:update(mode);
							
							if period < EMA.DATA:first() then
							return;
							end
							
							Signal[period] = EMA.DATA[period];
							 
		 
 
end


local init = false;
 
function Draw(stage, context)
    if stage ~= 0 then
	return;
	end 
	
	Height= context:bottom()-context:top();
	
        if not init then
            context:createSolidBrush(1, OBColor);
			context:createSolidBrush(2, OSColor);			 
            transparency =context:convertTransparency ( instance.parameters.transparency ) 

            init = true;
        end
		
		visible, y1 = context:pointOfPrice (instance.parameters.overbought);
		visible, y2 =  context:pointOfPrice (instance.parameters.oversold);

	context:drawRectangle (-1, 1, context:left (), context:top (), context:right (), y1, transparency);
	context:drawRectangle (-1, 2, context:left (),  y2,context:right (), context:bottom (), transparency);
	
end		

