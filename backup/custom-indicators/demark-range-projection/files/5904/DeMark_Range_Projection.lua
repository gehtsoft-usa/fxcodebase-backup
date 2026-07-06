-- Id: 2229
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2623

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
    indicator:name("DeMark Range Projection");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	indicator.parameters:addDouble("Width", "Line Width", "", 1);
    indicator.parameters:addColor("UP", "Color of Projected High", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DOWN", "Color of Projected Low", "", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first;
local source = nil;
 
 
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
	local s,e;
	local host = core.host;
	s, e = core.getcandle(source:barSize(), 0, host:execute("getTradingDayOffset"), host:execute("getTradingWeekOffset"));
	--s, e = core.getcandle(source:barSize(), 0, 0, 0);
	SIZE=e-s;	
	
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	
	instance:ownerDrawn(true);
 

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values

 
function Update(period)
   
	

 
end

local init = false;
 
function Draw(stage, context)
    if stage ~= 2 then
	return;
	end
	
	
        if not init then
            context:createPen (1, context.SOLID,  instance.parameters.Width, instance.parameters.UP)
			context:createPen (2, context.SOLID,  instance.parameters.Width, instance.parameters.DOWN)
            init = true;
        end
 
 
   local X;
	local HIGH;
	local LOW;
	
	for period= math.max(first,context:firstBar ()), math.min(source:size()-1,context:lastBar ()), 1 do
	
		if source.close[period] >  source.open[period] then
		X=(2*source.high[period]+ source.low[period]+source.close[period])/2;
		elseif source.close[period] <  source.open[period] then
		X=(source.high[period]+ 2*source.low[period]+source.close[period])/2;
		else
		X=(source.high[period]+ source.low[period]+2*source.close[period])/2;
		end
		
	LOW = X-source.high[period];
	HIGH = X-source.low[period];
	
	visible, y1= context:pointOfPrice (LOW);
	visible, y2= context:pointOfPrice (HIGH);
	
	x, x1, x2= context:positionOfBar (period);
	
	Delta=x2-x1;
	
	context:drawLine (2, x1+Delta, y1, x2+Delta, y1, 0);
	context:drawLine (1, x1+Delta, y2, x2+Delta, y2, 0);
	
	end

 
 end

