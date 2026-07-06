-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3971&p=9852#p9852

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


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Fred Tam F1 Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Buy", "Buy Signal Period", "", 4,2,2000);	
	 indicator.parameters:addInteger("Sell", "Sell Signal Period", "", 4,2,2000);	
	
	indicator.parameters:addString("Type", "Cross Type", "", "High/Low");
    indicator.parameters:addStringAlternative("Type", "High/Low", "", "High/Low");
    indicator.parameters:addStringAlternative("Type", "Close", "", "Close");
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up_Color", "Color of Up", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down_Color", "Color of Down", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("SIZE", "Font Size", "", 20);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Buy, Sell;
local SIZE;
local Type;

local first;
local source = nil;

-- Streams block
local  TREND = nil;
local up,down;

-- Routine
function Prepare(nameOnly)
    Type = instance.parameters.Type;     
    SIZE = instance.parameters.SIZE;
    Buy = instance.parameters.Buy;
	Sell = instance.parameters.Sell;
    source = instance.source;
    first = source:first()+math.max(Buy,Sell)+1;	
	 
	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Buy).. ", " .. tostring(Sell) .. ", " .. tostring(Type) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	 

 
    up = instance:createTextOutput ("Up", "Up", "Wingdings", SIZE, core.H_Center, core.V_Bottom, instance.parameters.Up_Color, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", SIZE, core.H_Center, core.V_Top, instance.parameters.Down_Color, 0);
    
end



-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

         
    if period < first or not source:hasData(period) then
	return;
	end
		
		
    local min, max;
	if Type == "High/Low" then
	max=mathex.max (source.high, period- Buy-1, period-1);
	min=mathex.min (source.low, period- Sell-1, period-1);
	else
	min=mathex.min (source.close, period- Sell-1, period-1);
	max=mathex.max (source.close, period- Buy-1, period-1);
	end
	
	
		
	if core.crossesOver (source.close, max, period) and not TREND  then
	TREND = true;
	up:set(period, source.low[period], "\217", source.low[period]);
	elseif core.crossesUnder (source.close, min, period) and TREND then
	TREND = false;
	down:set(period, source.high[period],"\218", source.high[period]);
	end  
	
    
end

