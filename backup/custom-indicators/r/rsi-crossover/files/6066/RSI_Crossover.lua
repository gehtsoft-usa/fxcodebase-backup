-- Id: 2316

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2675

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
    indicator:name("RSI Crossover");
    indicator:description("RSI Crossover");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("RSIFrame", "RSI Period", "", 14);
    indicator.parameters:addInteger("MAFrame", "MA Period", "", 10);
	
	indicator.parameters:addGroup("RSI Style");
	indicator.parameters:addBoolean("HideRSI", "Hide RSI", "", false);
    indicator.parameters:addInteger("widthRSI", "RSI Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleRSI", "RSI Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleRSI", core.FLAG_LINE_STYLE);		
    indicator.parameters:addColor("RSI_color", "Color of RSI", "Color of RSI", core.rgb(255, 0, 0));
	
	indicator.parameters:addGroup("MA Style");
	indicator.parameters:addBoolean("HideMA", "Hide MA", "", false);
	indicator.parameters:addInteger("widthMA", "MA Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleMA", "MA Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleMA", core.FLAG_LINE_STYLE);		
    indicator.parameters:addColor("MA_color", "Color of MA", "Color of MA", core.rgb(0, 0, 255));
	
	indicator.parameters:addGroup("Histogram Style");
	indicator.parameters:addBoolean("HideHistogram", "Hide Histogram", "", false);
    indicator.parameters:addColor("Histogram_color", "Color of Histogram", "Color of Histogram", core.rgb(0, 255, 0));
	
	indicator.parameters:addGroup("Overbought/oversold Level");
    indicator.parameters:addInteger("overbought", "Overbought Level", "", 20, -50, 50);
    indicator.parameters:addInteger("oversold", "Oversold Level", "", -20, -50, 50);
    indicator.parameters:addInteger("level_overboughtsold_width", "Over Bought/Sold Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Over Bought/Sold Line Style", "", core.LINE_SOLID);
    indicator.parameters:addColor("level_overboughtsold_color", "Over Bought/Sold Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local RSIFrame;
local MAFrame;
local HideRSI, HideHistogram, HideMA;
local first;
local source = nil;

-- Streams block
local RSI = nil;
local MA = nil;
local Histogram = nil;
local Indicator={};


-- Routine
function Prepare(nameOnly)
    
    HideMA = instance.parameters.HideMA;
    RSIFrame = instance.parameters.RSIFrame;
    MAFrame = instance.parameters.MAFrame;
	HideRSI = instance.parameters.HideRSI;
	HideHistogram = instance.parameters.HideHistogram;
    source = instance.source;
    
	local name = profile:id() .. "(" .. source:name() .. ", " .. RSIFrame .. ", " .. MAFrame .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	Indicator[1]= core.indicators:create("RSI", source , RSIFrame);	
	first = Indicator[1].DATA:first();
	
	if HideRSI then
	RSI =instance:addInternalStream (first, 0);
	else
    RSI = instance:addStream("RSI", core.Line, name .. ".RSI", "RSI", instance.parameters.RSI_color, first);	
	RSI:setWidth(instance.parameters.widthRSI);
    RSI:setStyle(instance.parameters.styleRSI);
    RSI:setPrecision(2);  	
	end
	
	
	Indicator[2]= core.indicators:create("MVA", RSI, MAFrame);	

  
	
	if HideHistogram then
	Histogram = instance:addInternalStream (first, 0);
	else
	 Histogram = instance:addStream("Histogram", core.Bar, name .. ".Histogram", "Histogram", instance.parameters.Histogram_color, Indicator[2].DATA:first());
    Histogram:setPrecision(math.max(2, instance.source:getPrecision()));
    end
	

	
	if HideMA then
	MA =instance:addInternalStream (first, 0);
	else
    MA = instance:addStream("MA", core.Line, name .. ".MA", "MA", instance.parameters.MA_color, Indicator[2].DATA:first());	    
    MA:setPrecision(math.max(2, instance.source:getPrecision()));
    end
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    if period < first or not source:hasData(period) then
	return;
	end
	
		Indicator[1]:update(mode);
		Indicator[2]:update(mode);
		if not Indicator[1].DATA:hasData(period)
		or not Indicator[2].DATA:hasData(period)
     	then
		return;
		end
		
		MA[period] = Indicator[2].DATA[period];		
		Histogram[period] = RSI[period] - MA[period]; 		
		RSI[period] = Indicator[1].DATA[period]-50;
						 
		
end
