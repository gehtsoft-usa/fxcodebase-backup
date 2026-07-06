-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70840

--+------------------------------------------------------------------+
--|                               Copyright © 2021, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("ZigZag Trend Lines")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("Calculation")
	
	
   indicator.parameters:addInteger("Number", "Number", "", 2)
   indicator.parameters:addInteger("LookBack", "LookBack Period", "", 100)
	
    indicator.parameters:addInteger("Depth", "Depth", "The minimum number of periods used to draw one ZigZag line.", 12)
    indicator.parameters:addInteger(
        "Deviation",
        "Deviation",
        "The maximum distance in pips by which the current high/low must be lower/higher than the previous one to return Backstep periods back to check if the current high/low is a new max/min.",
        5
    )
    indicator.parameters:addInteger(
        "Backstep",
        "Backstep",
        "The number of periods used to define a new min/max if the current high/low is lower/higher than the previous one by Deviation or less.",
        3
    )
    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 255, 0)) 
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)
   -- indicator.parameters:addInteger("transparency", "Line Transparency", "", 50)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Period
local source = nil
local ZigZag
local Depth, Deviation, Backstep
local first
local Cross, Signal;
local LookBack;
local Number;
-- Streams block

-- Routine
function Prepare(nameOnly)
    Depth = instance.parameters.Depth
    Deviation = instance.parameters.Deviation
    Backstep = instance.parameters.Backstep
	LookBack= instance.parameters.LookBack;
    source = instance.source
    ZigZag =
        core.indicators:create("ZIGZAG", source, Depth, Deviation, Backstep, core.rgb(0, 255, 0), core.rgb(255, 0, 0))
    first = ZigZag.DATA:first()+LookBack+1;
    local name = profile:id() .. "(" .. source:name() .. "," .. Depth .. "," .. Deviation .. "," .. Backstep .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end
	
	Cross  = instance:addInternalStream(0, 0);
	Signal  = instance:addInternalStream(0, 0);

   Number = instance.parameters.Number;

    instance:ownerDrawn(true)
end

-- Indicator calculation routine
function Update(period)


Signal[period]=nil;
Cross[period]=nil;


    if period < first 
	or period < source:size()-1-LookBack
	then
        return
    end

    ZigZag:update(core.UpdateAll)
	
 
	 for i= math.max(first, period-LookBack+1), math.min(period, source:size()-2), 1 do
	 
	 
			
			 if  ( ZigZag.DATA:colorI(i) == core.rgb(0, 255, 0) and ZigZag.DATA:colorI(i - 1) ~= core.rgb(0, 255, 0) or
						ZigZag.DATA:colorI(i) == core.rgb(0, 255, 0) and ZigZag.DATA[i + 1] == nil) then
						
						Signal[i]=1;
						Cross[i]=FindCross(i);
			end
			
			 if
					( ZigZag.DATA:colorI(i) == core.rgb(255, 0, 0) and ZigZag.DATA:colorI(i - 1) ~= core.rgb(255, 0, 0) or
						ZigZag.DATA:colorI(i) == core.rgb(255, 0, 0) and ZigZag.DATA[i + 1] == nil
					)	then
					
					  Signal[i]=-1;
					  Cross[i]=FindCross(i);
			 
			  end
   end	  
			
end

function FindCross(period)

    local Return=0;

    for i= period, source:size()-1, 1 do
	
	
			if source.close[i] < source.close[period-2]
			and  source.close[i-1] >= source.close[period-2]
			and source.close[period] >  source.close[period-2]
			then
			Return=i;			
			end
			
			
			if source.close[i] > source.close[period-2]
			and  source.close[i-1] <= source.close[period-2]
			and source.close[period] <  source.close[period-2]
			then
			Return=i;			
			end
			
			if Return ~=0 then
			break;
			end
			
    end
	
	return Return;
	
end


local init = false

function Draw(stage, context)
    if stage ~= 2 then
        return
    end

    local a1, c1;
	local a2, c2;
	
    if not init then
        context:createPen( 1, context:convertPenStyle(instance.parameters.style), context:pointsToPixels(instance.parameters.width), instance.parameters.color)
        context:createPen( 2, context:convertPenStyle(core.LINE_DASH), context:pointsToPixels(instance.parameters.width), instance.parameters.color)
        init = true
    end

    local Last = math.min(context:lastBar(), (ZigZag.DATA:size() - 1));
    local First = math.max(context:firstBar(), first);

    local Count=0;

     for i =  Last, First,  - 1 do
       

        if Signal[i]~=nil and Signal[i]~=0 and  Signal[i]~=nil  then  
        
		 
		    x0, x,x = context:positionOfBar(i-2);
			x1, x,x = context:positionOfBar(Cross[i]);
			 
		    
 
		    visible, y0 = context:pointOfPrice (source.close[i-2])
			visible, y1 = context:pointOfPrice (source.open[Cross[i]])
			visible, y2 = context:pointOfPrice (source.close[Cross[i]])
			
			
			
          
					 
					if x0< x1 then
					context:drawLine (1, x0, y0, x1  , y0 )
					context:drawLine (1, x0, y0, x1  , y1 )			
					context:drawLine (1, x0, y0, x1  , y2 )
					
					
					a1, c1 = math2d.lineEquation (x0, y0, x1, y1);
					a2, c2 = math2d.lineEquation (x0, y0, x1, y2);
					
					
					y3 = a1 * context:right () + c1;
					y4 = a2 * context:right () + c2;
					
					
					 context:drawLine (2, x1  , y0,context:right (), y0  )
					context:drawLine (2, x1  , y1,context:right (), y3 )			
					context:drawLine (2,  x1  , y2,context:right (), y4 )
					
					
					end
			
			
            Count=Count+1;
			
			
			
			
			end
		
		 if Count>= Number then
		 break;		 
		 end
		 
       
    end
end
