-- Id: 15208
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62956

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
    indicator:name("Price Action Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);


	
	indicator.parameters:addGroup("Placement");
	indicator.parameters:addString("Y", " Y Placement","" , "Top");
    indicator.parameters:addStringAlternative("Y", "Top", "Top" , "Top");
    indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom" , "Bottom"); 
	
	indicator.parameters:addString("X", " X Placement","" , "Right");
    indicator.parameters:addStringAlternative("X", "Right", "Right" , "Right");
    indicator.parameters:addStringAlternative("X", "Left", "Left" , "Left"); 
   indicator.parameters:addInteger("yShift", "Shift", "Shift" , 0); 
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",5, 0, 50);
   indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0)); 
   indicator.parameters:addInteger("Size", "Font Size", "", 20);
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	
	
	indicator.parameters:addColor("StrongUp", "Color of Strong Up", "", core.rgb(0, 200, 0)); 
	indicator.parameters:addColor("StrongDown", "Color of Strong Down", "", core.rgb(200, 0, 0)); 
	
	indicator.parameters:addColor("WeakUp", "Color of Weak Up", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("WeakDown", "Color of Weak Down", "", core.rgb(255, 0, 0)); 
	
	indicator.parameters:addColor("NoMove", "Color of No Move", "", core.rgb(150, 150, 150));
	
	indicator.parameters:addColor("Neutral", "Color of Neutral", "", core.rgb(128, 128, 128)); 
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local X,Y;
local font;
local Label;
local Size;
local yShift;
local StrongUp, StrongDown, Neutral;
local WeakUp, WeakDown,NoMove;
local HSpace;
-- Routine
function Prepare(nameOnly)
    Y=instance.parameters.Y;
	X=instance.parameters.X;  
    Label=instance.parameters.Label;
	Size=instance.parameters.Size;   
	yShift=instance.parameters.yShift;
	StrongUp=instance.parameters.StrongUp;
	StrongDown=instance.parameters.StrongDown;
	
	WeakUp=instance.parameters.WeakUp;
	WeakDown=instance.parameters.WeakDown;
	
	NoMove=instance.parameters.NoMove;
	
	Neutral=instance.parameters.Neutral;
    
	HSpace=(instance.parameters.HSpace/100);
	
	source = instance.source;
    first=source:first();
	
    local name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	
	Signal = instance:addInternalStream(0, 0);
   	
    instance:ownerDrawn(true);

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
 
function Update(period)   


    if source.close[period]> source.high[period-1] then
	Signal[period]= 1;
	elseif source.close[period]< source.low[period-1] then
	Signal[period]= 2;
	elseif source.close[period]> source.close[period-1] and source.close[period]<= source.high[period-1]  then
	Signal[period]= 3;
	elseif source.close[period]< source.close[period-1] and source.close[period]>= source.low[period-1] then
	Signal[period]= 4;
	
	elseif source.close[period]== source.close[period-1] then
	Signal[period]= 5;
	else 
	Signal[period]=6;
	end
  
end
 
local init = false;
 
function Draw(stage, context)
 
	if stage~= 2 then
	return;
	end
	
        if not init then
           context:createFont (1, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
		   
		    context:createPen (1*5, context.SOLID, 1, StrongUp)       
			context:createSolidBrush(1*5+1, StrongUp);
			
			 context:createPen (2*5, context.SOLID, 1,StrongDown)       
			context:createSolidBrush(2*5+1, StrongDown);
			
			
			context:createPen (3*5, context.SOLID, 1, WeakUp)       
			context:createSolidBrush(3*5+1, WeakUp);
			
			 context:createPen (4*5, context.SOLID, 1,WeakDown)       
			context:createSolidBrush(4*5+1, WeakDown);
			
			context:createPen (5*5, context.SOLID, 1, NoMove)       
			context:createSolidBrush(5*5+1, NoMove);
			
			context:createPen (6*5, context.SOLID, 1, Neutral)       
			context:createSolidBrush(6*5+1, Neutral);
			
            init = true;
        end
	

	
   local first = math.max(source:first(), context:firstBar ());
   local last = math.min (context:lastBar (), source:size()-1);
	
   X0, X1, X2 = context:positionOfBar (source:size()-1); 
   HCellSize =((X2-X1)/100)*HSpace;
		 
    local period;
		
			 for period= first, last, 1 do	   
			   x0, x1, x2 = context:positionOfBar (period);
			    
									         	        		 
															 
																C1=Signal[period]*5;
																C2=Signal[period]*5+1;
															 
																 	 
									   
									   
			          	X1= x1+HCellSize;
                        X2= x2-HCellSize;
						
						if X1> x0 then
						X1= x0; 
						end
						
						if X2< x0 then
						X2= x0; 
						end
						
			           context:drawRectangle (C1, C2, X1, context:top(), X2, context:bottom()  );
			end						
	
	local Text1=  "";
	
	period= source:size()-1;
	if Signal[period]==1 then
	Text1= "Strong Up";
	elseif Signal[period]==2 then
	Text1= "Strong Down";	
	elseif Signal[period]==3  then
	Text1= "Weak Up";
	elseif Signal[period]==4 then
	Text1= "Weak Down";
	
	elseif Signal[period]==5 then
	Text1= "No Move";
	end
	
   width, height = context:measureText (1, Text1, 0);
   context:drawText (1,  Text1, Label, -1,  iX(context,width,0,1) ,  iY(context,height,1+yShift,1) ,iX(context,width,0,2),iY(context,height,1+yShift,2), 0 );	
   

end		
 
 

function iX(context, width,Shift,x)

	if X== "Left" then
	return  context:left()+ Shift*width +  width*(x-1) ;
	else
	return context:right() - width*Shift -  width*(1-(x-1));
	end
end



function iY(context, height,Shift,x)

	if Y== "Top" then
		return context:top()+Shift* height + height*(x-1) ;
	else
	return context:bottom()-Shift* height + height*(x-1) ;
	end
end
