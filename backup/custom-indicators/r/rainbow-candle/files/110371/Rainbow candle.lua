-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64270

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Rainbow candle");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Levels");
	indicator.parameters:addDouble("Level1", "1. Level", "", 75);
	indicator.parameters:addDouble("Level2", "2. Level", "", 50);
	indicator.parameters:addDouble("Level3", "3. Level", "", 25);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addBoolean("Rainbow", "Use Rainbow Option", "", false);
	indicator.parameters:addColor("Color1", "Color of Top Sections", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Color2", "Color of Middle Top Sections", "", core.rgb(200, 100, 0));
	indicator.parameters:addColor("Color3", "Color of Middle Bottom Sections", "", core.rgb(100, 200, 0));
	indicator.parameters:addColor("Color4", "Color of Bottom Sections", "", core.rgb(0, 255, 0));
 
	
 
	
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Color1, Color2, Color3,Color4;
local first;
local source = nil;
local Level1, Level2, Level3;
 
local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

local Rainbow
 


function Prepare(nameOnly)

    Color1 = instance.parameters.Color1;
    Color2 = instance.parameters.Color2;
    Color3 = instance.parameters.Color3;
	Color4 = instance.parameters.Color4;
	Rainbow = instance.parameters.Rainbow;
   
    Level1= instance.parameters.Level1;
	Level2= instance.parameters.Level2;
	Level3= instance.parameters.Level3;
	
	source = instance.source; 
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. source:barSize() 
	 
    instance:name(name);
	if nameOnly then
		return;
	end
	
	first=source:first() ;

    	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
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
	   
	   local  Value = (source.close[period]-source.low[period])/Percentage;
		 
		if Rainbow then		
		open:setColor(period,  Coloring ( Value, 50));
		else
		
			if  Value < Level3 then
			open:setColor(period, Color4);
			elseif Value < Level2 then
			open:setColor(period,  Color3);
			elseif Value < Level1 then
			open:setColor(period,  Color2);
			else
			open:setColor(period,  Color1);
			end
		
		end
 
		
				

		
 end
 
 
function Coloring (value, mid)

local color;

if value <= mid then
color = core.rgb(255 * (value / mid), 255, 0) 
else 
color = core.rgb(255, 255 - 255 * ((value - mid) / mid), 0)
end


return  color;

end


