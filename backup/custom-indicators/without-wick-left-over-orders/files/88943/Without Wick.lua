-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59312
-- Id: 9816

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
    indicator:name("Without Wick");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Type", "Absolute/Relativ", "", "Absolute");
    indicator.parameters:addStringAlternative("Type", "Absolute", "", "Absolute");
    indicator.parameters:addStringAlternative("Type", "Relativ", "", "Relativ");
	
	indicator.parameters:addDouble("SIZE", "Size Pips/% Body of Candle", "", 0);
	indicator.parameters:addBoolean("Filter", "Candle Direction Filter", "", false);
	
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("Size", "Arriw Size", "", 20);
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Dn", "Down color", "", core.rgb(255, 0, 0));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Filter;
local first;
local source = nil;
local Size;
local Type;
local up, down;
local SIZE;

function Prepare(nameOnly)
    SIZE=instance.parameters.SIZE;
	Size=instance.parameters.Size;
	Type=instance.parameters.Type;
	Filter=instance.parameters.Filter;
	source = instance.source;
	   
    local name = profile:id() .. "(" .. source:name() .. ", "..source:barSize() .. ", "..Type.. ", ".. SIZE;
	instance:name(name);
	if nameOnly then
		return;
	end
	up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Up, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Dn, 0);
	
	
	first= source:first();
		
end

-- Indicator calculation routine
function Update(period)

	
			if period < first then
			return;
			end
			
			up:setNoData(period);
            down:setNoData(period);
			
	    local UP =source.high[period]- math.max(source.open[period], source.close[period]);
		local BODY= (source.open[period]- source.close[period]);		
		local DN = math.min(source.open[period], source.close[period])-source.low[period];
		
		if   Type == "Absolute" then
		
		                       if UP <= SIZE * source:pipSize()  and (not Filter or BODY > 0 )then
								up:set(period, source.high[period], "\217", source.high[period]);
							   end
							    if DN <= SIZE * source:pipSize() and (not Filter or BODY  < 0 ) then
								down:set(period, source.low[period], "\218", source.low[period]);
								end
		else
		                        if UP <= (math.abs(BODY) /100)* SIZE  and (not Filter or BODY  > 0 ) then
								up:set(period, source.high[period], "\217", source.high[period]);
							   end
							    if DN <= (math.abs(BODY)/100) * SIZE and (not Filter or BODY < 0 ) then
								down:set(period, source.low[period], "\218", source.low[period]);
								end
		end
 end


