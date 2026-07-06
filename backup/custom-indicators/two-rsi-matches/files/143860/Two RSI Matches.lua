-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71549

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+

-- The indicator corresponds to the Relative Strength Index indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 6 "Momentum and Oscillators" (page 133-134)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Two RSI Matches");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period1", "1. Period","", 14, 2, 1000);
    indicator.parameters:addInteger("Period2", "2. Period","", 28, 2, 1000);	
	
    indicator.parameters:addGroup("Style");
	
    indicator.parameters:addInteger("Size", "Match Size","", 10);
	
    indicator.parameters:addColor("Up", " Match Top Up Color","", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Match Top Down Color","", core.rgb(255, 0, 0));	
	
   indicator.parameters:addColor("color", "Match Color","", core.COLOR_LABEL );		
    indicator.parameters:addInteger("width", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
    
 
	
	
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Period1, Period2;

local first;
local source = nil;
local Line1 = nil;
local Line2 = nil;
local Size;
 
local RSI1,RSI2; 

-- Routine
function Prepare()
   
   
   Up= instance.parameters.Up;
   Down= instance.parameters.Down;
   Size= instance.parameters.Size;

    Period1 = instance.parameters.Period1;
	Period2 = instance.parameters.Period2;
    source = instance.source;
    first = source:first() + math.max(Period1, Period2);

    local name = profile:id() .. "(" .. source:name() .. ", " .. Period1 .. ", " .. Period2 .. ")";
    instance:name(name);
	
	RSI1 = core.indicators:create("RSI",source,Period1);
	RSI2 = core.indicators:create("RSI",source,Period2);
	
	Line1 = instance:addStream("Line1", core.Line, "", "", Up, 0) 
	Line1:setStyle(core.LINE_NONE);
	Line1:addLevel(0);
	Line1:addLevel(100);
	
	
	Line2= instance:addStream("Line2", core.Line, "", "", Down, 0) 	
    Line2:setStyle(core.LINE_NONE);
	
	instance:ownerDrawn(true);
end

	

-- Indicator calculation routine
function Update(period)
	RSI1:update(mode);
	RSI2:update(mode);
    if period < first then
	return;
    end	 
 
   Line1[period]= RSI1.DATA[period];
   Line2[period]= RSI2.DATA[period];
end



local init = false;
 
function Draw(stage, context)
 
	  if stage~= 2 then
	  return;
	  end
	
       if not init then
         
            init = true;
			

				context:createFont (11, "Wingdings", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
				context:createPen (12, context:convertPenStyle (instance.parameters.style), context:pointsToPixels (instance.parameters.width), instance.parameters.color); 
			
     end
	 
	 
 
	local Start = math.max(context:firstBar(), first );
	local End = math.min(context:lastBar(), source:size() - 1);
 

	for period = Start, End, 1 do --i
 
	x1, x, x = context:positionOfBar (period);
	x2, x, x = context:positionOfBar (period-3);
	
	visible, y1 = context:pointOfPrice (Line1[period]);
	visible, y2 = context:pointOfPrice (Line2[period]);
	
	context:drawLine (12, x2, y2, x1, y1);
	
	width, height = context:measureText (11, "\174" ,  context.CENTER);
	
		if Line1[period] > Line2[period] then
		context:drawText (11, "\174", Up, -1, x1-width/2, y1-height/2 , x1+width/2 , y1+height/2,  context.CENTER);
		else
		context:drawText (11, "\174", Down, -1, x1-width/2, y1-height/2 , x1+width/2 , y1+height/2,  context.CENTER);
		end	
	end
	 
end		
 

 