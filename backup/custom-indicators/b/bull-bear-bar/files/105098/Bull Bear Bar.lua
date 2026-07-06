-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63211


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
    indicator:name("Bull Bear Bar");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator); 
   
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Top", "Top 1/4 Color", "", core.rgb(0, 255, 0));	
	indicator.parameters:addColor("Mid1", "Top Third Color", "", core.rgb(0, 200, 0));
	indicator.parameters:addColor("Mid2", "Mid Third Color", "", core.rgb(255, 128, 64));
	indicator.parameters:addColor("Mid3", "Bottom Third Color", "", core.rgb(200, 0, 0));	
	indicator.parameters:addColor("Bottom", "Bottom 1/4 color", "", core.rgb(255, 0, 0));
	 
	
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Top, Bottom, Mid1, Mid2,Mid3;
local first;
local source = nil; 
local Price;

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil; 

function Prepare(nameOnly) 

    Top = instance.parameters.Top;
    Bottom= instance.parameters.Bottom;
	Mid1= instance.parameters.Mid1;
	Mid2= instance.parameters.Mid2;
	Mid3= instance.parameters.Mid3; 
	
	source = instance.source;
	first= source:first();
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. source:barSize() ..  ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	open = instance:addStream("open", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("high", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("low", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("close", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
		
end

-- Indicator calculation routine
function Update(period, mode)
	
    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
			if period < first then
			return;
			end
	
     
    local Percentage=(source.high[period]-source.low[period])/100;	
	local Position=math.abs(source.close[period]-source.low[period])/Percentage;
	 
	 
	 if Position>= 75 then
	 open:setColor(period, Top);
	 elseif Position<= 25  then	
	 open:setColor(period, Bottom);
	 elseif Position>= 66 then
	 open:setColor(period, Mid1);
	 elseif Position<= 33 then
	 open:setColor(period, Mid3);
     else
	 open:setColor(period, Mid2);
     end
	

		
 end


