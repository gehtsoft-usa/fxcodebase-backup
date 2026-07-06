
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60755


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

function Init()
    indicator:name("Candle Precision Correction");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator:setTag("replaceSource", "t");
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Type", "Precision Type", "", "ReduceBy");
    indicator.parameters:addStringAlternative("Type", "Reduce By", "", "ReduceBy");
    indicator.parameters:addStringAlternative("Type", "Set To", "", "SetTo");
    indicator.parameters:addInteger("Set", "Precision", "", 1,1,5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
 
local first;
local source = nil;
local Type;
-- Streams block 
local open=nil;
local close=nil;
local high=nil;
local low=nil;
local Set;
 local format;
-- Routine
function Prepare(nameOnly) 
    
    source = instance.source; 
	Type = instance.parameters.Type;
	Set = instance.parameters.Set;
    first = source:first() ;	

    local name = profile:id() .. "(" .. source:name().. ", " .. Type.. ", " .. Set  .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    local Precision;
	
	if Type =="ReduceBy" then
	Precision= source:getPrecision ()- math.min(math.abs(Set),source:getPrecision () );
	else
	Precision= math.min( math.abs(Set),source:getPrecision () );
	end
	 format = "%." .. Precision .. "f";
	
	open  = instance:addStream("open", core.Line, "" , "", 0, 0, 0); 
	open:setPrecision (Precision);
    close  = instance:addStream("close", core.Line, "" , "", 0, 0, 0); 
	close:setPrecision (Precision);
	low  = instance:addStream("low", core.Line, "" , "", 0, 0, 0); 
	low:setPrecision (Precision);
    high  = instance:addStream("high", core.Line, "" , "", 0, 0, 0); 
	high:setPrecision (Precision);
    instance:createCandleGroup("Candle", "", open, high, low, close);
	
	
	 
end

-- Indicator calculation routine
function Update(period )

 
	high[period]=string.format(format, source.high[period]);
	low[period]= string.format(format, source.low[period]); 
	close[period] =string.format(format, source.close[period]);
	open[period]  = string.format(format, source.open[period]);
				  
 end

