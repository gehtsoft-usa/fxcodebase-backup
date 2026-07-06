-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3301

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
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



function Init()
    indicator:name("MTF STOCHASTIC");
    indicator:description("MTF STOCHASTIC");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);	

	indicator.parameters:addGroup("Placement");
	indicator.parameters:addString("Y", " Y Placement","" , "Top");
    indicator.parameters:addStringAlternative("Y", "Top", "Top" , "Top");
    indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom" , "Bottom"); 
	
	indicator.parameters:addString("X", " X Placement","" , "Right");
    indicator.parameters:addStringAlternative("X", "Right", "Right" , "Right");
    indicator.parameters:addStringAlternative("X", "Left", "Left" , "Left"); 

	
	
	Parameters (1 , "H1" );
	Parameters (2 , "H4" );
	Parameters (3 , "H8" );
    Parameters (4 , "D1" );
	Parameters (5 , "W1" );
	
	indicator.parameters:addGroup("Common Parameters");	
	indicator.parameters:addInteger("Size", "Size", "", 10);
	indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "No Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	
	
	
	
end


function Parameters (id , FRAME )

  
  
  
  	indicator.parameters:addGroup(id..". STOCHASTIC TIME FRAME");
  
    indicator.parameters:addBoolean("On"..id, "Use this slot", "", true);
	
    indicator.parameters:addInteger("K"..id, "Number of periods for %K", "", 5, 2, 1000);
    indicator.parameters:addInteger("SD"..id, "%D slowing periods", "", 3, 2, 1000);
    indicator.parameters:addInteger("D"..id, "The number of periods for %D.", "", 3, 2, 1000);

    indicator.parameters:addString("KS"..id, "Smoothing type for %K", "", "MVA");
    indicator.parameters:addStringAlternative("KS"..id, "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("KS"..id, "EMA","", "EMA");
    indicator.parameters:addStringAlternative("KS"..id, "MT4","", "FS");
    
    indicator.parameters:addString("DS"..id, "Smoothing type for %D", "", "MVA");
    indicator.parameters:addStringAlternative("DS"..id, "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("DS"..id, "EMA", "", "EMA"); 	
  
    indicator.parameters:addString("TF"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);
end

local DS={};
local KS={};
local K={};
local SD={};
local D={};
 
local X,Y;

local source;
local Indicator={};
local stream={};
local loading={};
local TF={};
--local alive;
local first;
local Up, Down, Neutral, Label;
local Size;
local Count;
function Prepare(nameOnly)  

    Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
	Label=instance.parameters.Label;
	
	Y=instance.parameters.Y;
	X=instance.parameters.X; 

    	local i;
	Count=0;
    for i= 1, 5, 1 do	
	       
			if instance.parameters:getBoolean ("On"..i) then
			Count=Count+1;
			DS[Count]=instance.parameters:getString ("DS"..i);
			KS[Count]=instance.parameters:getString ("KS"..i);
			K[Count]=instance.parameters:getInteger ("K"..i);
			SD[Count]=instance.parameters:getInteger ("SD"..i);
			D[Count]=instance.parameters:getInteger ("D"..i);
			TF[Count]=instance.parameters:getString ("TF"..i);
			end 
	end
  
      
    Size=instance.parameters.Size; 
	
	
	source = instance.source;
	
    local name =  profile:id() .. ","  .. instance.source:name() ;
	instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
  

 
	
	
	  
	  
	  	local i;
 	   
			
		for i = 1, Count , 1 do	
            Test = core.indicators:create("STOCHASTIC", source,  K[i],SD[i],D[i],KS[i],DS[i] );  			
			first= Test.DATA:first()*2+1 ; 				
			stream[i] = core.host:execute("getSyncHistory",source:instrument(), TF[i], source:isBid(), math.min(300,first), 200+i, 100+i);
			Indicator[i] = core.indicators:create("STOCHASTIC", stream[i], K[i],SD[i],D[i],KS[i],DS[i]); 
			loading[i]=true;
	    end
	
	  core.host:execute ("setTimer", 1, 1);
	  
	   instance:ownerDrawn(true);
end


function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 

local init = false;
 
function Draw(stage, context)
 
		local Flag= false;
	
	for i= 1, Count, 1 do
	
		if loading[i] then		
		Flag=true;
		end
	end
		
	
	if Flag then
	return;
	end	
	
	
        if not init then
           context:createFont (1, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
		   context:createFont (2,  "Wingdings", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
		  
            init = true;
        end
	
	width, height = context:measureText (1,"123456", 0);
	
	for i= 1, Count, 1 do
	
    context:drawText (1,  TF[i], Label, -1,  iX(context,width,0,i) ,  iY(context,height,0,2) ,iX(context,width,1,i),iY(context,height,1,2), 0 );	
	
		if  Indicator[i].DATA:hasData(Indicator[i].DATA:size()-1) then
		
		
		       
			     if Indicator[i].DATA[Indicator[i].DATA:size()-1] > Indicator[i].DATA[Indicator[i].DATA:size()-2] then 
												
				 context:drawText (2,  "\225", Up, -1,  iX(context,width,0,i) ,  iY(context,height,0,3) ,iX(context,width,1,i),iY(context,height,1,3), 0 );	
												
				elseif Indicator[i].DATA[Indicator[i].DATA:size()-1] < Indicator[i].DATA[Indicator[i].DATA:size()-2] then
												
                                              
                context:drawText (2,  "\226", Down, -1,  iX(context,width,0,i) ,  iY(context,height,0,3) ,iX(context,width,1,i),iY(context,height,1,3), 0 );	
												
				else
								 												
				context:drawText (2,  "\223", Neutral, -1,  iX(context,width,0,i) ,  iY(context,height,0,3) ,iX(context,width,1,i),iY(context,height,1,3), 0 );									
				end 		
			   
		       Value = string.format("%." .. 2 .. "f", Indicator[i].DATA[Indicator[i].DATA:size()-1]);
		       context:drawText (1,  Value, Label, -1,  iX(context,width,0,i) ,  iY(context,height,0,4) ,iX(context,width,1,i),iY(context,height,1,4), 0 );	
		
			 
		
		end
	
	end
			
 
	 
  
   

end		




function Update(period, mode)
 
 
end


function iX(context, width,Shift,x)

	if X== "Left" then
	return  context:left()+ Shift*width +  width*(x-1) ;
	else
	return context:right() + width*Shift -  width*(x);
	end
end



function iY(context, height,Shift,x)

	if Y== "Top" then
		return context:top()+Shift* height + height*(x-1) ;
	else
	return context:bottom()+Shift* height - height*(x) ;
	end
end
   
   
   
   -- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
     local j;	 
	local Flag = false;	
	local Number=0;	
	
	
	
    for j = 1, Count, 1 do
		
			  if cookie == (100+j) then
			  loading[j] = true;
		      elseif  cookie == (200+j) then
			  loading[j] = false;  		 
              end
			  
		if loading[j] then
		Number=Number+1;
		Flag=true;
		end	 

	end

     if not FLAG and cookie== 1 then
     	for i= 1, Count, 1 do
	
 
		Indicator[i]:update(core.UpdateLast);
		end 
	end
	
      	 
		if Flag then
		core.host:execute ("setStatus", " Loading ".. (Count-Number) .."/" .. Count);
		else
		core.host:execute ("setStatus", " Loaded ".. (Count-Number) .."/" .. Count);		
		instance:updateFrom(0);
		end
			  
   
   
        
		return core.ASYNC_REDRAW ;
end
 
