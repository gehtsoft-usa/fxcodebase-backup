-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2775
-- Id: 7776

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
    indicator:name("ROC Trend Oscillator");
    indicator:description("ROC Trend Oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    
	
	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("One", "1. ROC Period", " ", 14,2, 2000);
    indicator.parameters:addInteger("Two", "2. ROC Period", " ", 21,2, 2000);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
	    indicator.parameters:addColor("No", "Color od Neutral", "Color of Neutral", core.rgb(128, 128, 128));

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local One;
local Two;

local first;
local source = nil;
local DATA={};

-- Streams block
local TO = nil;
local RAW;
local Up,Down, No;
-- Routine
function Prepare(nameOnly)
    One = instance.parameters.One;
    Two = instance.parameters.Two;
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	No = instance.parameters.No;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. One .. ", " .. Two .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	DATA[1] = core.indicators:create("ROC", source, One);
	DATA[2] = core.indicators:create("ROC", source, Two);
	
	RAW=instance:addInternalStream(source:first(), 0);
	
	first = math.max(DATA[1].DATA:first(),DATA[2].DATA:first())+1;
    TO = instance:addStream("TO", core.Bar, name .. ".ROC TO", "ROC TO", core.rgb(128, 128, 128), first);
    TO:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
   	
	DATA[1]:update(mode);
	DATA[2]:update(mode);
	
	 if period < first or not  source:hasData(period) then
	return;
	end
	
			
			RAW[period]= DATA[1].DATA[period] - (0 - DATA[2].DATA[period]);
			TO[period] = RAW[period];
			
		 
					if  RAW[period] > RAW[period-1] then
				    TO:setColor(period, Up); 
					elseif RAW[period] <RAW[period-1] then
					TO:setColor(period, Down); 
					else
					TO:setColor(period, No);
					end
			
end	
        
 

