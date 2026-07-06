-- Id: 6139
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=15046

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
    indicator:name("HLC");
    indicator:description("HLC");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addColor("Up", "Up Candle Color", "",  core.COLOR_UPCANDLE );
	indicator.parameters:addColor("Down", "Down Candle Color", "", core.COLOR_DOWNCANDLE );
	indicator.parameters:addInteger("Width", "Line Width", "", 1, 1 , 5);
	indicator.parameters:addInteger("BarWidth", "Bar interspace as a percentage of bar", "", 10, 10, 40);
	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Width;
local Close,High,Low;
local Up, Down;
local BarWidth;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
	Width= instance.parameters.Width;
	BarWidth= instance.parameters.BarWidth;
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	
    local name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	 Close = instance:addStream("Close", core.Line, name .. ".Close", "Close", core.rgb(255, 0, 0), source:first());
    Close:setPrecision(math.max(2, instance.source:getPrecision()));
     Close:setStyle (core.LINE_NONE);
	 
	  High = instance:addStream("High", core.Line, name .. ".High", "High", core.rgb(255, 0, 0), source:first());
    High:setPrecision(math.max(2, instance.source:getPrecision()));
     High:setStyle (core.LINE_NONE);
	 
	  Low = instance:addStream("Low", core.Line, name .. ".Low", "Low", core.rgb(255, 0, 0), source:first());
    Low:setPrecision(math.max(2, instance.source:getPrecision()));
     Low:setStyle (core.LINE_NONE);
	 
	 instance:ownerDrawn(true);

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

   Close[period]=source.close[period];
   Low[period]=source.low[period];
   High[period]=source.high[period];
     
end


local init = false;
 
function Draw(stage, context)
    if stage ~= 2 then
	return;
	end
	
 
        if not init then             
        context:createPen (1, context.SOLID, Width, Up) ;
		context:createPen (2, context.SOLID, Width, Down) ;

            init = true;
        end
 
 
    for period =  context:firstBar (), context:lastBar (),1  do
	
	x, x1, x2 = context:positionOfBar (period);
	visible, y1= context:pointOfPrice (source.high[period]);
	visible, y2= context:pointOfPrice (source.low[period]);
	visible, y3= context:pointOfPrice (source.close[period]);
	Shift= (x2-x1)/100*BarWidth;
		if source.close[period]> source.open[period] then
		context:drawLine (1, x, y1, x, y2, 0);
		context:drawLine (1, x, y3, x2-Shift, y3, 0);
		else
		context:drawLine (2, x, y1, x, y2, 0);
		context:drawLine (2, x, y3, x2-Shift, y3, 0);
		end
	
	end
 
 end


