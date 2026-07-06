-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59373
-- Id: 9879

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
    indicator:name("Positiv Negativ Volume");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addString("Method", "Method", "Method" , "Price");
    indicator.parameters:addStringAlternative("Method", "Price", "Price" , "Price");
    indicator.parameters:addStringAlternative("Method", "Heikin Hashi", "Heiken Ashi" , "Heiken Ashi");
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("Size", "Arriw Size", "", 10);
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Dn", "oOwn color", "", core.rgb(255, 0, 0));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local first;
local source = nil;
local volume; 
local Method;
local HA;
function Prepare(nameOnly)
    Method=instance.parameters.Method;
	source = instance.source;
	   
    local name = profile:id() .. "(" .. source:name() .. ", "..source:barSize() .. ", "..Method;
	instance:name(name);
	if nameOnly then
		return;
	end
	
	
	HA = core.indicators:create("HA",source);
	
	first= HA.DATA:first();
	 assert(source:supportsVolume(), "The source must have volume");
	volume = instance:addStream("PNV", core.Bar, name, "PNV", instance.parameters.Up, first );
    volume:setPrecision(math.max(2, instance.source:getPrecision()));
		
end

-- Indicator calculation routine
function Update(period, mode)


    HA:update(mode);
	
			if period < first then
			return;
			end
			
		if Method == "Price" then	
		        if source.close[period]> source.open[period] then
				volume[period]= source.volume[period];
				else
				volume[period]= -source.volume[period];
				end
		else
		         if HA.close[period]> HA.open[period] then
				volume[period]= source.volume[period];
				else
				volume[period]= -source.volume[period];
				end
		end
			
		 if volume[period]> 0 then
		 volume:setColor(period,instance.parameters.Up);
		 else
		 volume:setColor(period, instance.parameters.Dn);
		 end
		
		 
 end


