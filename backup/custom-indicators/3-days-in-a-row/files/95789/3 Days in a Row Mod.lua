-- Id: 12426
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61113

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
    indicator:name("3 days in a row");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addBoolean("Shift"  , "Previous Period Calculation", "", false);	 
	indicator.parameters:addBoolean("Range"  , "Range Filter", "", true);	 
	indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("Size", "Arrow Size", "", 10);   
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Dn", "Down color", "", core.rgb(255, 0, 0));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Size; 
local Shift;
local up, down;
local Range;
function Prepare(nameOnly)
    Size = instance.parameters.Size;
	Shift = instance.parameters.Shift;
	Range = instance.parameters.Range;
	source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ", "..source:barSize() .. ")";
	instance:name(name);	
	if nameOnly then
		return;
	end
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Up, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Dn, 0);
	
	first=source:first()+3;

end

-- Indicator calculation routine
function Update(period )

         if Shift then
         period=period-1;
         end		 

        up:setNoData(period);
		down:setNoData(period);
		
		
			if period < first then
			return;
			end
			
		local Up= false;
        local Down =false;

		if source.close[period-2]< source.open[period-2]
        and source.close[period-1]< source.open[period-1]
		and source.close[period]< source.open[period]
		--/\--
		and source.high[period]<= source.high[period-1]
		and source.low[period]>= source.low[period-1]
		--/\--
		and ( source.high[period-2]<= source.high[period-3]  or not Range)
		and (source.high[period-1]<= source.high[period-2]  or not Range)
		and (source.low[period-2]<= source.low[period-3]  or not Range)
		and (source.low[period-1]<= source.low[period-2]  or not Range)
        then
        Up=true;
        elseif source.close[period-2]> source.open[period-2]
        and source.close[period-1]> source.open[period-1]
		and source.close[period]> source.open[period]
		--/\--
		and source.high[period]<= source.high[period-1]
		and source.low[period]>= source.low[period-1]
		--/\--
		and( source.high[period-2]>= source.high[period-3] or not Range)
		and( source.high[period-1]>= source.high[period-2]  or not Range)
		and( source.low[period-2]>= source.low[period-3]  or not Range)
		and( source.low[period-1]>= source.low[period-2]  or not Range)
        then     		
		 Down=true;	
		end
		
		if Up then
		up:set(period, source.high[period], "\217", source.high[period]);
		elseif Down then
		down:set(period, source.low[period], "\218", source.low[period]);
		end
 end


