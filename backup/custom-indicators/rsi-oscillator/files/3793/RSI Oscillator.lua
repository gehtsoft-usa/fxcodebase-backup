-- Id: 1313
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1882&sid=e771a98f6d78bea9bee97875e3ca9bbb

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
    indicator:name("RSI Oscillator");
    indicator:description("RSI Oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    
	indicator.parameters:addGroup("RSI Calculation");
    indicator.parameters:addInteger("ShortFrame", "Short RSI Period", "Short RSI Period", 10);
    indicator.parameters:addInteger("LongFrame", "Long RSI Period", "Long RSI Period", 25);
	indicator.parameters:addGroup("MVA Smoothing");
    indicator.parameters:addInteger("MVAFrame", "MVA Period", "MVA Period", 5);	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("RSI_UP", "Color of UP" , "Color of UP", core.rgb(0, 255, 0));
	indicator.parameters:addColor("RSI_DOWN", "Color of DOWN" , "Color of DOWN", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local ShortFrame;
local LongFrame;
local MVAFrame;

local Short=nil;
local Long=nil;
local MVA=nil;

local first;
local source = nil;

-- Streams block
local Buffer=nil;

local UP=nil;
local DOWN = nil;

-- Routine
function Prepare(nameOnly)
    ShortFrame = instance.parameters.ShortFrame;
    LongFrame = instance.parameters.LongFrame;
    MVAFrame = instance.parameters.MVAFrame;
    source = instance.source;
    
	
	Long = core.indicators:create("RSI", source, LongFrame);
	Short = core.indicators:create("RSI", source, ShortFrame);
	
	 first = math.max(Long.DATA:first(), Short.DATA:first());
	 local name = profile:id() .. "(" .. source:name() .. ", " .. ShortFrame .. ", " .. LongFrame .. ", " .. MVAFrame .. ")";
	 instance:name(name);
	if nameOnly then
		return;
	end
	Buffer=instance:addInternalStream(first, 0);
	
	MVA = core.indicators:create("MVA", Buffer, MVAFrame);


	
	UP = instance:addStream("UP", core.Bar, name, "UP", instance.parameters.RSI_UP, MVA.DATA:first());
    UP:setPrecision(math.max(2, instance.source:getPrecision()));
	DOWN = instance:addStream("DOWN", core.Bar, name, "DOWN", instance.parameters.RSI_DOWN, MVA.DATA:first());
    DOWN:setPrecision(math.max(2, instance.source:getPrecision()));
	DOWN:addLevel(0);    
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
	

	
	Long:update(mode);
	Short:update(mode);	
	
	if period < first or not source:hasData(period) then
	return;
	end
	
	Buffer[period]=Short.DATA[period]-Long.DATA[period];
	

			
				MVA:update(mode);	
				
				
	if period< MVA.DATA:first() then
	return;
	end 			
			
				
							if MVA.DATA[period]> MVA.DATA[period-1] then
							UP[period] = MVA.DATA[period];
							else
							DOWN[period] = MVA.DATA[period];
							end
				
			
   
end

