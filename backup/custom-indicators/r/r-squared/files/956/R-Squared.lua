-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=546
-- Id: 282

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("RSquared");
    indicator:description("RSquared");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("period", "Period", "Period", 14);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("RSquared_color", "Color of RSquared", "Color of RSquared", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("rstyle", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("rstyle", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("rwidth", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addColor("Critical_Line_color", "Color of Critical Line", "Color of Critical Line", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("lstyle", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("lstyle", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("lwidth", "Line Width", "", 3, 1, 5);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;

-- Streams block
local RSquared = nil;
local Hline=nil;

local b =0;
local c =0;
local oldx=0
local oldy=0
local frame=0;
local testreset=0;
local petlja =0;
local test =0;
local y=0;
local x=0;
local xy=0;
local x2=0;
local y2=0;
local line=0;

-- Routine
function Prepare(nameOnly)
    frame = instance.parameters.period;
		
    source = instance.source;
    first = source:first()+frame;

    local name = profile:id() .. "(" .. source:name() .. ", " .. frame .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	    if frame <= 5 then 	line=(0.77); 	end
		if frame > 5  and frame <= 10  then 	line=(0.77); 	end
		if frame > 10  and frame <= 14  then 		line=(0.40); 	end
		if frame > 14  and frame <= 20  then 		line=(0.27); 	end
		if frame > 20  and  frame <= 25  then 		line=(0.20); 	end
		if frame > 25  and frame <= 30   then 		line=(0.16); 	end
		if frame > 30  and frame <= 50   then 		line=(0.13); 	end
		if frame > 50 and  frame <= 60  then  		line=(0.08); 	end
		if frame > 60 and  frame <= 120  then 		line=(0.06); 	end
		if frame > 120 then  	line=(0.03); end



     RSquared = instance:addStream("RSquared", core.Line, name, "RSquared", instance.parameters.RSquared_color, first);
    RSquared:setPrecision(math.max(2, instance.source:getPrecision()));
	 RSquared:addLevel(line, instance.parameters.lstyle, instance.parameters.lstyle, instance.parameters.Critical_Line_color);
	 RSquared:setWidth(instance.parameters.rwidth);
     RSquared:setStyle(instance.parameters.rstyle);
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
 if period < first or not  source:hasData(period) then
 return;
 end
 

 
								for petlja = (period-frame), period, 1 do
										if petlja == (period-frame) then
										test=1;
										y=source.close[petlja];
										xy=source.close[petlja]*test;
										x=test;
										x2=test*test;
										y2= source.close[petlja]* source.close[petlja];
										else
										test=test+1;													
										y = y + source.close[petlja];
										xy=xy+(source.close[petlja]*test);
										x=x+test;
										x2=x2+(test*test);
										y2= y2+ source.close[petlja]* source.close[petlja];
										end
								 end
    
			c=x2*test-x*x;
		    b=(xy*test-x*y)/c;		
			d=y2*test-y*y;
		    div=math.sqrt(c*d);
		    e=(xy*test-x*y)/ div;
            RSquared[period]=e*e;
			
	     
 end