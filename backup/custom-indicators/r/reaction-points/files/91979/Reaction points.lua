-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60199
-- Id: 10865

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
    indicator:name("Reaction points");
    indicator:description("Reaction points");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	 indicator.parameters:addGroup("Calculation");
	 indicator.parameters:addBoolean("Shift", "", "", true);
	 indicator.parameters:addInteger("LookBack", "Look Back Period", "Look Back Period", 0);
	 indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("C5", "Label Color", "Label Color", core.rgb(0, 0, 0));
    indicator.parameters:addColor("C1", "Color of B1", "Color of B1", core.rgb(0, 255, 0));
    indicator.parameters:addColor("C2", "Color of S1", "Color of S1", core.rgb(255, 0, 0));
    indicator.parameters:addColor("C3", "Color of HBOP", "Color of HBOP", core.rgb(0, 255, 255));
    indicator.parameters:addColor("C4", "Color of LBOP", "Color of LBOP", core.rgb(255, 0, 255));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Shift;
local LookBack;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
	Shift=instance.parameters.Shift;
	LookBack=instance.parameters.LookBack; 
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    instance:setLabelColor(   instance.parameters.C5);
    instance:ownerDrawn(true);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
   	
end

local init = false;

function Draw(stage, context)



    if stage ~= 2 then
        return ;
    end
	
	  if not init then
	  
            context:createPen(	5, context.SOLID, 1, instance.parameters.C5);
            context:createPen(1, context.SOLID, 1, instance.parameters.C1);
            context:createPen(2, context.SOLID, 1, instance.parameters.C2);
            context:createPen(3, context.SOLID, 1, instance.parameters.C3);
            context:createPen(4, context.SOLID, 1, instance.parameters.C4);
 
            init = true;
        end
	
	    local firstBar, lastBar = context:firstBar(), context:lastBar();
		
		 if LookBack ~= 0 then
	     firstBar= lastBar-math.abs(LookBack);
		
        firstBar=math.max(firstBar, first);
        lastBar=math.min(lastBar, source:size()-1);
	 
	
	 end
	 
	 local period;
     local x1,x2;
		
	for period= firstBar+1, lastBar, 1 do	
	
	 x, x1, x2 = context:positionOfBar (period);

	if Shift then
	period=period-1;
	end
	
			
	local X= (source.high[period]+source.low[period]+source.close[period])/3

    
      visible, y1  = context:pointOfPrice ( 2*X-source.high[period]);
	  visible, y2  = context:pointOfPrice ( 2*X-source.low[period]);
	  visible, y3  = context:pointOfPrice (2*X-2*source.low[period]+source.high[period]);
	  visible, y4  = context:pointOfPrice (2*X-2*source.high[period]+source.low[period]);
	
	
       
    
	context:drawLine (1, x1, y1, x2, y1);
	context:drawLine (2, x1, y2, x2, y2);
	context:drawLine (3, x1, y3, x2, y3);
	context:drawLine (4, x1, y4, x2, y4);
	
	
    end     
		
end		

