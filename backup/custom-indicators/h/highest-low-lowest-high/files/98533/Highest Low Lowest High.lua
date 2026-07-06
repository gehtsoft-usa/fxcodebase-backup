-- Id: 13564
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61794

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
    indicator:name("Highest Low Lowest High");
    indicator:description("Highest Low Lowest High");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period", "Number of Elements", "Number of Elements", 10);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addInteger("Size", "Arrow Size", "Size", 10);
    indicator.parameters:addColor("Up", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Flag;
local Size;
local Down, Up;
local Top, Bottom;
local Period;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
	Size=instance.parameters.Size;
	Down=instance.parameters.Down;
	Up=instance.parameters.Up;
	Period=instance.parameters.Period;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if (not (nameOnly)) then 
		Flag = instance:addInternalStream(0, 0);
		instance:ownerDrawn(true);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)   

if period < 2 then
return;
end

Calculate(period);  

end



function Calculate(period)

 
        local curr = source.high[period - 2];
        if (curr > source.high[period - 4] and curr > source.high[period - 3] and
            curr > source.high[period - 1] and curr > source.high[period]) then
             
            Flag[period-2]=1;
       
        end
        curr = source.low[period - 2];
        if (curr < source.low[period - 4] and curr < source.low[period - 3] and
            curr < source.low[period - 1] and curr < source.low[period]) then
             Flag[period-2]=-1;
        end
end
  
  

local init = false;
 
function Draw(stage, context)
    if stage ~= 2 then
	return;
	end
	
        if not init then
            context:createFont (1, "Wingdings", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
            init = true;
        end

    Find(context:firstBar (), context:lastBar ());
	
	
	for i= 1, math.min(#Top,Period), 1 do
	    x, x1, x2 =context:positionOfBar (Top[i]);
		width, height= context:measureText (1, "\217", 0)
		
		 
		visible, y = context:pointOfPrice (source.high[Top[i]]); 
		context:drawText (1, "\217", Up, -1, x-width/2, y-height, x+width/2, y, 0 );
        
	end	
		
	for i= 1,  math.min( #Bottom,Period), 1 do
	    x, x1, x2 = context:positionOfBar (Bottom[i]);
		width, height= context:measureText (1, "\217", 0)
		
		 
		visible, y = context:pointOfPrice (source.low[Bottom[i]]); 
		context:drawText (1, "\218", Down, -1, x-width/2, y, x+width/2, y+height, 0 );
		 
    end	

		
end

function Find(First, Last) 

    Top={};
	Bottom={}; 

    for period = First, Last, 1 do
	
	   if Flag[period]== 1 then
	   AddUp(period);
	   elseif Flag[period]== -1 then
	   AddDown(period);
	   end
	
	end

end

function AddUp(period) 
    if #Top<=Period then
    Top[#Top+1]= period ;
	else
	 Top[Period+1]=period
	end 
 SortUp();
end


function AddDown(period)  
     if #Bottom<=Period then
     Bottom[#Bottom+1]= period;
     else
	 Bottom[Period+1]=period
	end 
  SortDown();
end

function  SortUp(period)
	for i=  #Top, 1 , - 1 do
	
	    if Top[i]~= nil and Top[i-1 ]~= nil then
			if source.high[Top[i]] < source.high[Top[i-1]]  then
			Temp=Top[i-1];
			Top[i-1]= Top[i];
			Top[i]= Temp;
			end
		end
	end
end

function  SortDown(period)

    for i=  #Bottom, 1 , - 1 do
	    if Bottom[i]~= nil and Bottom[i-1 ]~= nil then   
			if source.low[Bottom[i]] > source.low[ Bottom[i-1] ]  then
			Temp=Bottom[i-1];
			Bottom[i-1]= Bottom[i];
			Bottom[i]= Temp;
			end
		end
	end

end
