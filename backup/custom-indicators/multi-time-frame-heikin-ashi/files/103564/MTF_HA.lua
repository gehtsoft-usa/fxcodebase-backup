-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3934

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

function Init()
    indicator:name("Multi Time Frame Heikin-Ashi");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);	

    
	
	Parameters (1 , "H1" );
	Parameters (2 , "H4" );
	Parameters (3 , "H8" );
    Parameters (4 , "D1" );
	Parameters (5 , "W1" );
	
	indicator.parameters:addGroup("Placement");
	indicator.parameters:addString("Y", " Y Placement","" , "Top");
    indicator.parameters:addStringAlternative("Y", "Top", "Top" , "Top");
    indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom" , "Bottom"); 
	
	indicator.parameters:addString("X", " X Placement","" , "Right");
    indicator.parameters:addStringAlternative("X", "Right", "Right" , "Right");
    indicator.parameters:addStringAlternative("X", "Left", "Left" , "Left"); 
	
	indicator.parameters:addGroup("Common Parameters");	
	indicator.parameters:addInteger("ArrowSize", "ArrowSize", "", 10); 
	 
	 indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0)); 
	indicator.parameters:addColor("Up", "Up Arrow Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Arrow Color", "", core.rgb(255, 0, 0));
	
end


function Parameters (id , FRAME )  	  
    indicator.parameters:addString("TF"..id, "Time frame", "", FRAME);
    --indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);
end

local Label;
local Up, Down;

local  ArrowSize;
local source;
local day_offset, week_offset;

local host;
--local alive;
local first;  

local HA={};
local Source={};
local loading={};

local Number=5;

local Y, X;

function Prepare(nameOnly)       
    Label=instance.parameters.Label;
	Up=instance.parameters.Up;
    Down=instance.parameters.Down;
 
	
	Y=instance.parameters.Y
	X=instance.parameters.X;
   
    ArrowSize=instance.parameters.ArrowSize;   
	
    local name =  profile:id() .. ","  .. instance.source:name() ;
	
	instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    source = instance.source;
	first= source:first()+1;
    host = core.host;

    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");   
	
	
    
	local i;
	for i= 1, Number, 1 do
	 
	Source[i] = core.host:execute("getSyncHistory",source:instrument(), instance.parameters:getString ("TF"..i), source:isBid(), 0, 200+i, 100+i); 
	HA[i] = core.indicators:create("HA", Source[i]);			
	loading[i]=true;
	end
	
	instance:ownerDrawn(true);

	 
end



local init = false;
 
function Draw(stage, context)
    
	if stage ~= 2 then
	return;
	end
	
        if not init then
             context:createFont (1, "Arial", context:pointsToPixels (ArrowSize), context:pointsToPixels (ArrowSize), 0);
			 context:createFont (2, "Wingdings", context:pointsToPixels (ArrowSize), context:pointsToPixels (ArrowSize), 0);
            init = true;
        end
 


     local j;	 
	local Flag = false;	
	
	
	
    for j = 1, Number, 1 do
		
						  
		if loading[j] then
		Flag=true;
		end	 
		
 end		
 
 
 if Flag then
 return;
 end
 
 local i;
 local Text;
	       
		   
		   
		    width1, height1 = context:measureText (1, " D1 ", 0); 
			 
			for i = 1, Number, 1  do
		  
		    HA[i]:update(core.UpdateLast);
			
			
			Text=  instance.parameters:getString ("TF"..i);          
           context:drawText (1,  Text, Label, -1,  iX(context,width1*2,0,i) ,  iY(context,height1,2,2) ,iX(context,width1*2,0,i+1),iY(context,height1,2,3), 0 );

				if HA[i].close[HA[i].close:size()-1] >	HA[i].open[HA[i].open:size()-1] then
				Text="\241";
				Color=Up;
				elseif HA[i].close[HA[i].close:size()-1] <	HA[i].open[HA[i].open:size()-1] then
				Text="\242";
				Color=Down;
				else
				Color=Label;
				Text="\243";
				end 			
				
			context:drawText (2,  Text, Color, -1,  iX(context,width1*2,0,i) ,  iY(context,height1,4,3) ,iX(context,width1*2,0,i+1),iY(context,height1,4,4), 0 );	
			
			end
 
 
 end

function Update(period )
 									
 
end


 
function iX(context, width,Shift,x)

	if X== "Left" then
	return  context:left()+ Shift*width +  width*(x-1) ;
	else
	return context:right() - width*Shift - Number* width+  width*(x-1);
	end
end



function iY(context, height,Shift,x)

	if Y== "Top" then
		return context:top()+Shift* height + height*(x-1) ;
	else
	return context:bottom()-Shift* height + height*(x-1) ;
	end
end

 
 

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
     local j;	 
	local Flag = false;	
	local Count=0;	
	
	
	
    for j = 1, Number, 1 do
		
			  if cookie == (100+j) then
			  loading[j] = true;
		      elseif  cookie == (200+j) then
			  loading[j] = false;  
			  instance:updateFrom(0);		 
              end
			  
		if loading[j] then
		Count=Count+1;
		Flag=true;
		end	 

		  
		if Flag then
		core.host:execute ("setStatus", " Loading ".. (Number-Count) .."/" .. Number);
		else
		core.host:execute ("setStatus", " Loaded ".. (Number-Count) .."/" .. Number);
		end
			  
	end    
   
        
		return core.ASYNC_REDRAW ;
end
 




 
 
