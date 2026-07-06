-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1659
-- Id: 1404

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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
    indicator:name("Hull Moving Average");
    indicator:description("Hull Moving Average");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Frame", "Period", "Period", 20, 1 , 2000);
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("HMA_Up", "Color of HMA Up", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("HMA_Down", "Color of HMA Down", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("HMA_Neutral", "Color of HMA Neutral", "", core.rgb(0, 0, 255));
	 
	indicator.parameters:addInteger("S", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("S", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("W", "Line Width", "", 1, 1, 5);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Frame;

local first;
local source = nil;



-- Streams block
local HMA = nil;

local FULL=nil;
local HALF=nil;
local SQRT = nil;

local RAW=nil;

-- Routine
function Prepare(nameOnly)
    Frame = instance.parameters.Frame;
    source = instance.source;
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. Frame .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	RAW=instance:addInternalStream(0, 0);
   
	FULL= core.indicators:create("LWMA", source, Frame);
	HALF= core.indicators:create("LWMA", source, Frame/2);
	first = math.max(FULL.DATA:first(),  HALF.DATA:first());
	
	SQRT= core.indicators:create("LWMA", RAW, math.sqrt(Frame));
    HMA = instance:addStream("HMA", core.Line, name, "HMA", instance.parameters.HMA_Up, SQRT.DATA:first());
	HMA:setPrecision(math.max(2, source:getPrecision()));
	
	 HMA:setStyle(instance.parameters.S);
    HMA:setWidth(instance.parameters.W);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    
	
	
	HALF:update(mode);
	FULL:update(mode);
	
	if period < first then
	return;
	end
			
	RAW[period]= 2*HALF.DATA[period]-FULL.DATA[period];
			
	if period <SQRT.DATA:first() then
	return;
	end				
	
	SQRT:update(mode);
					
						HMA[period] = SQRT.DATA[period];
						
						 if HMA[period] >   HMA[period-1] then
						 HMA:setColor(period, instance.parameters.HMA_Up);	
						 elseif HMA[period] <   HMA[period-1] then
						 HMA:setColor(period, instance.parameters.HMA_Down);	
						 else
						 HMA:setColor(period, instance.parameters.HMA_Neutral);	
						 end
						 
					 
					 
		 
end

