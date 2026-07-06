-- Id: 6898
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=20592

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Cumulativ Rotation Factor");
    indicator:description("Cumulativ Rotation Factor");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Dn", "Down color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No", "Neutral color", "", core.rgb(0, 0, 255));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;

-- Streams block
local RF;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
    if (not (nameOnly)) then
       	RF = instance:addStream("o", core.Bar, name .. ".o", "o",  core.rgb(0, 0, 0), first);
    RF:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period <  first or not source:hasData(period) then
	o:setColor(period, instance.parameters.No);		
	return;
	end
	
	   RF[period]= RF[period-1];
	   
	   if source.high[period] > source.high[period-1] then
	   RF[period]=RF[period]+1;
	   elseif source.high[period]  <  source.high[period-1] then
	   RF[period]=RF[period]-1;
       end
	   
	   if source.low[period] > source.low[period-1] then
	   RF[period]=RF[period]+1;
	   elseif source.low[period]  <  source.low[period-1] then
	   RF[period]=RF[period]-1;
       end	   	
        
		
		if  RF[period] > RF[period-1] then		
		RF:setColor(period, instance.parameters.Up);
        elseif RF[period] < RF[period-1]  then
		RF:setColor(period, instance.parameters.Dn);
		else
		RF:setColor(period, instance.parameters.No);			

		end
		
		
	
end

