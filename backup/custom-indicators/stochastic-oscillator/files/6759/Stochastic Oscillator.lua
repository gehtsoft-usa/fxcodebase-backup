-- Id: 2651
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2952

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Stochastic Oscillator");
    indicator:description("Stochastic Oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation");
	
	 indicator.parameters:addString("MVAT_K", "Smoothing type for %K", "", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MVAT_K", "MT", "", "FS");

   
	indicator.parameters:addGroup("1. Component");
    indicator.parameters:addInteger("K1", "Number of periods for %K", "", 30, 2, 1000);
    indicator.parameters:addInteger("D1", "%D slowing periods", "", 15, 2, 1000);
    indicator.parameters:addGroup("2. Component");
	indicator.parameters:addInteger("K2", "Number of periods for %K", "", 60, 2, 1000);
    indicator.parameters:addInteger("D2", "%D slowing periods", "", 30, 2, 1000);
	indicator.parameters:addGroup("3. Component");
	indicator.parameters:addInteger("K3", "Number of periods for %K", "", 90, 2, 1000);
    indicator.parameters:addInteger("D3", "%D slowing periods", "", 45, 2, 1000);

   
    indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
     indicator.parameters:addInteger("style", "DEMA Line Style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
    indicator.parameters:addColor("Output_color", "Color of Output", "Color of Output", core.rgb(255, 0, 0));
	
	
	indicator.parameters:addGroup("Overbought / Oversold Levels ");
	 indicator.parameters:addInteger("overbought","Overbought Level", "", 80, 0, 100);
    indicator.parameters:addInteger("oversold", "Oversold Level", "", 20, 0, 100);
    indicator.parameters:addInteger("level_overboughtsold_width", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:addColor("level_overboughtsold_color", "Line Color", "", core.rgb(255, 255, 0));
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;

-- Streams block
local Output = nil;
local Indicator={};

-- Routine
function Prepare(nameOnly)    
    source = instance.source;
    
	local name = profile:id() .. "(" .. source:name() .. " (" .. instance.parameters.K1 ..", ".. instance.parameters.D1 .. 
	"), (" .. instance.parameters.K2..", ".. instance.parameters.D2 ..
	"), (" .. instance.parameters.K3..", ".. instance.parameters.D3 ..
	"), " .. instance.parameters.MVAT_K.. ")"
    instance:name(name);
    if nameOnly then
        return;
    end
	Indicator[1] = core.indicators:create("STOCHASTIC", source, instance.parameters.K1, instance.parameters.D1, 15,  instance.parameters.MVAT_K );
	Indicator[2] = core.indicators:create("STOCHASTIC", source, instance.parameters.K2, instance.parameters.D2, 15,  instance.parameters.MVAT_K );
	Indicator[3] = core.indicators:create("STOCHASTIC", source, instance.parameters.K3, instance.parameters.D3, 15,  instance.parameters.MVAT_K );
    first = math.max(Indicator[1].DATA:first(),Indicator[2].DATA:first(),Indicator[3].DATA:first()); 
    
    Output = instance:addStream("Output", core.Line, name, "Output", instance.parameters.Output_color, first);
    Output:setPrecision(math.max(2, instance.source:getPrecision()));
	Output:setWidth(instance.parameters.width);
	Output:setStyle(instance.parameters.style);
	
	Output:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    Output:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    if period >= first and source:hasData(period) then
	
	Indicator[1]:update(mode); 
    Indicator[2]:update(mode);
    Indicator[3]:update(mode);	  
	 
	
        Output[period] = (Indicator[1].DATA[period] + Indicator[2].DATA[period] +Indicator[3].DATA[period])/3;
    end
end

