-- Id: 14244
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62266


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
    indicator:name("Real Volume Tick volume Ratio");
    indicator:description("Real Volume Tick volume Ratio");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addInteger("Period", "Period", "Period",25);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Ratio_color", "Color of Ratio", "Color of Ratio", core.rgb(255, 0, 0));
	
	
	indicator.parameters:addColor("MA_color", "Color of Central", "Color of Central", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Top_color", "Color of Top", "Color of Top", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("Bottom_color", "Color of Bottom", "Color of Bottom", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local RealVolume;
local EMA;
local Period;
-- Streams block
local Ratio = nil;
local Bottom, Top;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
	
	Period=instance.parameters.Period;

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	
	
	RealVolume  = core.indicators:create("REAL VOLUME", source);
	
	

 
        Ratio = instance:addStream("Ratio", core.Bar, name, "Ratio", instance.parameters.Ratio_color, first);
		
		EMA  = core.indicators:create("EMA", Ratio, Period);
		
		MA = instance:addStream("Central", core.Line, name, "Central", instance.parameters.MA_color, first);
		MA:setWidth(instance.parameters.width);
        MA:setStyle(instance.parameters.style);
		
		Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.Top_color, first);
		Top:setWidth(instance.parameters.width1);
        Top:setStyle(instance.parameters.style1);
		
		
		Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.Bottom_color, first);
		Bottom:setWidth(instance.parameters.width2);
        Bottom:setStyle(instance.parameters.style2);
		
		Ratio:setPrecision(math.max(2, instance.source:getPrecision()));
		MA:setPrecision(math.max(2, instance.source:getPrecision()));
		Top:setPrecision(math.max(2, instance.source:getPrecision()));
		Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,m )
 
	
    if period <source:size()-1 or not  source:hasData(period) then
	return;
	end
	
	RealVolume:update(core.UpdateAll);
 
	
	for i= RealVolume.DATA:first(), RealVolume.DATA:size()-1 , 1 do 
	    if source.volume[i]~=0 then
        Ratio[i] = RealVolume.DATA[i]/source.volume[i]; 
		end
	end	
 
	
		EMA:update(core.UpdateAll);
	
    for i= RealVolume.DATA:first()+Period, RealVolume.DATA:size()-1 , 1 do 	
	    MA[i] = EMA.DATA[i];
		Dev= mathex.stdev(Ratio, i-Period+1, period);
        Top[i]=	MA[i]	+ Dev;
		Bottom[i]=	MA[i]	- Dev;
	end
    
end

