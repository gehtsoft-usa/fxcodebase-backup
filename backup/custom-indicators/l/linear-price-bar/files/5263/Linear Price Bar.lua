-- Id: 1990
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2427

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Linear Price Bar");
    indicator:description("Linear Price Bar");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	 indicator.parameters:addColor("Up", "Up Color", "", core.COLOR_UPCANDLE );
	indicator.parameters:addColor("Down", "Down Color", "", core.COLOR_DOWNCANDLE );

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;

-- Streams block

local OP = nil;
local HP = nil;
local LP = nil;
local CP = nil;
local Up, Down;
-- Routine
 function Prepare(nameOnly)   
 
    source = instance.source;
    first = source:first();
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    OP = instance:addStream("OP", core.Line, name .. ".OP", "Open", core.rgb(0, 255, 0), first);
    OP:setPrecision(math.max(2, instance.source:getPrecision()));
    HP = instance:addStream("HP", core.Line, name .. ".HP", "High", core.rgb(0, 255, 0), first);
    HP:setPrecision(math.max(2, instance.source:getPrecision()));
    LP = instance:addStream("LP", core.Line, name .. ".LP", "Low", core.rgb(0, 255, 0), first);
    LP:setPrecision(math.max(2, instance.source:getPrecision()));
    CP = instance:addStream("CP", core.Line, name .. ".CP", "Close", core.rgb(0, 255, 0), first);
    CP:setPrecision(math.max(2, instance.source:getPrecision()));
	instance:createCandleGroup("Linear Bar", "Linear Bar", OP, HP, LP, CP);
	

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not  source:hasData(period) then
	return;
	end
	

   	local  BarH = source.high[period]-source.open[period];
    local  BarL = source.low[period]-source.open[period];
    local  BarC = source.close[period]-source.open[period];
	
	OP[period]=0;
	HP[period]=BarH;
	LP[period]=BarL;
	CP[period]=BarC;
	
    
	
	
      if source.close[period]> source.open[period] then
      OP:setColor(period, Up);
      else      
	  OP:setColor(period, Down);	
      end
       
     
end

