-- Id: 9132
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23071

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
    indicator:name("Price Volume Trend Overlay");
    indicator:description("Price Volume Trend Overlay");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Type" , "Filter Type", "", "Zero");
    indicator.parameters:addStringAlternative("Type" , "Zero", "", "Zero");
    indicator.parameters:addStringAlternative("Type", "Slope", "", "Slope");

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
local PVT = nil;
local Type;
local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

-- Routine
function Prepare(nameOnly)
    
    source = instance.source;
    first = source:first();
	Type=instance.parameters.Type;

    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        PVT = instance:addInternalStream(0, 0);
		
		open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
		high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
		low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
		close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
		instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

    open:setColor(period, instance.parameters.No);		

    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
	
    if period < first or not source:hasData(period) then
	return;
	end
	
	 PVT[period] = ((source.close [period] - source.close [period-1] ) / source.close[period-1]) * source.volume[period] + PVT [period - 1];    

	 
	 if Type== "Zero" then
        if PVT[period] > 0    then		
		open:setColor(period, instance.parameters.Up);
        elseif PVT[period] < 0   then
		open:setColor(period, instance.parameters.Dn);		
		end
	 else
	     if PVT[period] > PVT[period-1]    then		
		open:setColor(period, instance.parameters.Up);
        elseif  PVT[period] < PVT[period-1]  then
		open:setColor(period, instance.parameters.Dn);		
		end
	 end
	 
    
end

