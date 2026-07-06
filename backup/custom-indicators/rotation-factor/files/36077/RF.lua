-- Id: 6897
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
    indicator:name("Rotation Factor");
    indicator:description("Rotation Factor");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
	
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
local o = nil;
local c = nil;
local h = nil;
local l = nil;
local RF;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
    if (not (nameOnly)) then
		RF = instance:addInternalStream(first, 0);
        o = instance:addStream("o", core.Line, name .. ".o", "o",  core.rgb(0, 0, 0), first);
        c = instance:addStream("c", core.Line, name .. ".c", "c", core.rgb(0, 0, 0), first);
        h = instance:addStream("h", core.Line, name .. ".h", "h", core.rgb(0, 0, 0), first);
        l = instance:addStream("l", core.Line, name .. ".l", "l", core.rgb(0, 0, 0), first);
		 instance:createCandleGroup("RF", "RF", o, h, l, c);
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
	
        o[period] = source.open[period];
        c[period] = source.close[period];
        h[period] = source.high[period];
        l[period] = source.low[period];
		
		if  RF[period] > RF[period-1] then		
		o:setColor(period, instance.parameters.Up);
        elseif RF[period] < RF[period-1]  then
		o:setColor(period, instance.parameters.Dn);
		else
		o:setColor(period, instance.parameters.No);			

		end
		
		
	
end

