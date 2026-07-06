-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60565
-- Id: 11564

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
    indicator:name("Trade Volume Index");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addInteger("MTV", "Minimum Tick Value", "Minimum Tick Value",10);
    indicator.parameters:addColor("TVI_color", "Color of TVI", "Color of TVI", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local MTV;
-- Streams block
local TVI = nil;
local Direction;
local ExtremePrice=0;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
	MTV=instance.parameters.MTV;

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if (not (nameOnly)) then
		Direction = instance:addInternalStream(0, 0);
		ExtremePrice = instance:addInternalStream(0, 0);
        TVI = instance:addStream("TVI", core.Line, name, "TVI", instance.parameters.TVI_color, first);
    TVI:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period  <= first or not  source:hasData(period) then		
	        	ExtremePrice[period]=source.close[period];		
                Direction[period]=0;				
		return;
	end
	 
	
	
	 
	local Change= (source.close[period]-ExtremePrice[period-1])/ source:pipSize()  ;
	
	if  Change > MTV then
	Direction[period]=1;
	ExtremePrice[period]=source.close[period];
	elseif Change < -MTV then	
	Direction[period]=-1;
	ExtremePrice[period]=source.close[period];
	else
	Direction[period]=Direction[period-1];
	ExtremePrice[period]=ExtremePrice[period-1]; 
	end
	
	    if Direction[period]== 1 then
		TVI[period] = TVI[period-1]+source.volume[period];
		elseif Direction[period]== -1 then
		TVI[period] = TVI[period-1]-source.volume[period];
		else
		TVI[period]=TVI[period-1];
		end
        
    
end

