-- Id: 2684
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2997


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
    indicator:name("MAE%");
    indicator:description("MAE%");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

      indicator.parameters:addInteger("N", "Number of periods of Moving Average", "", 10, 2, 300);
    indicator.parameters:addDouble("W", "Band Offset in percent", "", 5, 0.001, 1000);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
     indicator.parameters:addInteger("style", "DEMA Line Style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	
	indicator.parameters:addGroup("Overbought / Oversold Levels ");
	 indicator.parameters:addInteger("overbought","Overbought Level", "", 0, -1000, 1000);
    indicator.parameters:addInteger("oversold", "Oversold Level", "", 100,-1000, 1000);	
    indicator.parameters:addInteger("level_overboughtsold_width", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style", "", core.LINE_SOLID);
	 indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("level_overboughtsold_color", "Line Color", "", core.rgb(255, 255, 0));
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local N,W;

local first;
local source = nil;
local MVA;
local up,down;

-- Streams block
local MAE = nil;

-- Routine
function Prepare(nameOnly)
    N = instance.parameters.N;
	W = instance.parameters.W;
    source = instance.source;
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ", ".. W..")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
  
	
	MVA= core.indicators:create("MVA", source, N);	
	
	  first = MVA.DATA:first();
	
	up = instance:addInternalStream(first,0);
	down = instance:addInternalStream(first,0);

    
	
    MAE = instance:addStream("MAE", core.Line, name, "MAE %", instance.parameters.color, first);
	MAE:setWidth(instance.parameters.width);
	MAE:setStyle(instance.parameters.style);
	MAE:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    MAE:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	
	
	MAE:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    
	
		
	MVA:update(mode);
	
	if period < first or not  source:hasData(period) then
	return;
	end
	   
        up[period] = MVA.DATA[period] * (1 + W / 1000);
        down[period] = MVA.DATA[period] * (1 - W / 1000);
	
        MAE[period] =  ((source[period] - down[period]) / (up[period] - down[period])) * 100;
    
end

