-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61768


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
    indicator:name("Valid Swing High/Low");
    indicator:description("Valid Swing High/Low");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addBoolean("Broad", "Broad Definition", "", true);
    indicator.parameters:addInteger("Size", "Size", "", 10);
	indicator.parameters:addColor("clrUP", "Up Swing Color", "", core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN", "Down Swing Color", "", core.COLOR_DOWNCANDLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first;
local source = nil;
local clrUP,clrDN ;
local Last;
local Size;
local Broad;
local HL;
-- Routine
function Prepare(nameOnly)
    Size=instance.parameters.Size;
	Broad=instance.parameters.Broad;
    source = instance.source;
	clrUP=instance.parameters.clrUP;
	clrDN=instance.parameters.clrDN;
    first = source:first()+6;
   
    Last= instance:addInternalStream(0, 0);
	HL = instance:addInternalStream(0, 0);
    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	

    instance:ownerDrawn(true);

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
  
 
     if period < first or not source:hasData(period) then
        return;
      end
   
	 local curr = period - 2;
	 
        if (source.high[curr]  > source.high[curr -1]  and source.high[curr] > source.high[curr -2] and
            source.high[curr]  > source.high[curr + 1] and source.high[curr]  > source.high[curr+2]) then
			
			Last[curr]= 1;			
			Previous(curr, 1);
			if Broad then
			Definition(curr,1)
			end 
           
        elseif (source.low[curr]  < source.low[curr -1] and source.low[curr] < source.low[curr -2] and
            source.low[curr] < source.low[curr + 1] and source.low[curr] < source.low[curr+2]) then
			
	     Last[curr]= -1;	
		 Previous(curr, -1);
		 if Broad then
		 Definition(curr,-1)
		 end 
		 
        else
         Last[curr]=0; 		
        end
		
		
end

local init= false;
function Draw(stage, context)


if stage ~= 2 then
return;
end

if not init then
init=true;
context:createFont (1, "Verdana", context:pointsToPixels (Size), context:pointsToPixels (Size), context.CENTER)
end


 
for period= math.max(context:firstBar (),source:first()), math.min( context:lastBar (), source:size()-1), 1 do
  
   if Last[period]== 1    then
            if Broad then
			   if HL[period]== 1 then
			   Note="HH";
			   elseif HL[period]== -1 then
			   Note="LH";
			   else
			   Note="SH";
			   end
			   
			else
			Note="H";
			end
            visible, y =context:pointOfPrice (source.high[period]);
			x, x1, x2 =context:positionOfBar (period);
			width, height =context:measureText (1, Note, context.CENTER)
			context:drawText (1, Note, clrUP, -1, x -width/2, y-height, x +width/2, y , context.CENTER );
			
   elseif Last[period]== -1   then
             if Broad then
			   if HL[period]== 1 then
			   Note="HL";
			   elseif HL[period]== -1 then
			   Note="LL";
			   else
			   Note="SL";
			   end
			else
            Note="L";
			end
            visible, y =context:pointOfPrice (source.low[period]);
			x, x1, x2 =context:positionOfBar (period);
			width, height =context:measureText (1, Note, context.CENTER)
			context:drawText (1, Note, clrDN, -1, x -width/2, y, x +width/2, y+height , context.CENTER );
   
   end
end	

	
  
end

function Definition(period, flag)

 

for i= period-1,first , -1 do
 
  
  if Last[i]==  flag then
  
		  if flag== 1 and source.high[i] < source.high[period] then
		  HL[period]=1;  
		  break;
		  elseif flag== 1 and source.high[i] > source.high[period] then
		  HL[period]=-1;  
		  break; 
		  elseif flag== -1 and source.low[i] < source.low[period] then
		  HL[period]=1;  
		  break;  
		  elseif flag== -1 and source.low[i] > source.low[period] then
		  HL[period]=-1;  
		  break;  
		  elseif flag== -1 or  flag==  1 then
		  HL[period]=0;
		  break;
		  end
    end
end
 
   
			  
end			  

function Previous(period, flag)

 

for i= period-1,first , -1 do
 
  
  if Last[i]==  flag then
  
		  if flag== 1 and source.high[i] < source.high[period] then
		  Last[i]=0;   
		  break;
		  elseif flag== -1 and source.low[i] > source.low[period] then
		  Last[i]=0; 
		  break;  
		  end
    end
end
 
end


