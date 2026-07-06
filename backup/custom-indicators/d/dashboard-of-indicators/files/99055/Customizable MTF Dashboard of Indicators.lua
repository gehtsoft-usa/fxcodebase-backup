-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61967

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("MTF Dashboard of Indicators");
    indicator:description("MTF Dashboard of Indicators");
     indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
  
	
    
	for i= 1 ,10, 1 do
	AddIndicator(i);
	end
	
	indicator.parameters:addGroup("Style");	 
	indicator.parameters:addColor("Color", "Label Color", "Label Color", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color","", core.rgb(0, 0, 255));


    indicator.parameters:addDouble("minusX", "Vertical spacing", "", 10 , 0, 50);
	indicator.parameters:addDouble("minusY", "Horizontal spacing", "", 10 , 0, 50);
 
 
	indicator.parameters:addInteger("Size", "Font Size (As % of Cell)", "", 70 , 0, 100);
 


end

function AddIndicator (id)
    indicator.parameters:addGroup( id..". Slot");
    indicator.parameters:addBoolean("On"..id , "Use  This Slot", "", true);	
    indicator.parameters:addString("Method"..id, "Indicator", "", "MVA");
    indicator.parameters:setFlag("Method"..id,core.FLAG_INDICATOR);  
end




-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local pauto =  "(%a%a%a)/(%a%a%a)";
local Color;
local Source={};
local Size;
local transparency; 
local loading={}; 
local source; 
local  Count=13;
local TF={"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6","H8","D1", "W1", "M1"};
 
local Type;  
local Dodaj={};   
local Point={};
local Num=9; 
local Up,  Down,Neutral ;
local minusX, minusY;  


local Indicator={}; 
local iprofile = {};	
local iparams= {}; 

local Test={};
local tprofile = {};	
local tparams= {}; 
local Precision={};
local Max={};
local Method={};  
-- Routine
function Prepare(nameOnly)   
    Color= instance.parameters.Color; 
	Size= instance.parameters.Size;
	Mode= instance.parameters.Mode;    
	Type= instance.parameters.Type;  
	Up= instance.parameters.Up;
	Down= instance.parameters.Down; 
	Neutral= instance.parameters.Neutral;
	minusX= (instance.parameters.minusX/100);
	minusY= (instance.parameters.minusY/100);
	source = instance.source; 
	
	
	 local name = profile:id() .. "("  .. tostring(source:barSize())  .. ")";
    instance:name(name);
	if   (nameOnly) then
        return;
    end
	
	Num=0;
    first=source:first();

   
	 	

	
	for j = 1, 10, 1 do	

	            if instance.parameters:getBoolean ("On"..j) then
				
				Num=Num+1;
				
				        Method[Num]=  instance.parameters:getString ("Method"..j);
	
					   tprofile[Num] = core.indicators:findIndicator(instance.parameters:getString("Method"..j));
					   tparams[Num] = instance.parameters:getCustomParameters("Method"..j);
					   
					   if  tprofile[Num]:requiredSource() == core.Tick then
					   Test[Num] = tprofile[Num]:createInstance(source.close, tparams[Num]);
					   else
					   Test[Num] = tprofile[Num]:createInstance(source, tparams[Num]);
					   end  
					   
					   Max[Num] = Test[Num]:getStreamCount ();
					   first= math.max(first, math.max(Test[Num]:getStream(Max[Num]-1):first(), Test[Num].DATA:first()));	
					   
	            end
	end
		
	
	 for i = 1, Count, 1 do	
	  
	  Indicator[i]={};
	  iprofile[i]={};
	  iparams[i]={};
	  
	  Source[i]= core.host:execute("getSyncHistory", source:instrument(), TF[i], source:isBid(),first*3+1,20000 + i , 10000 +i);
	  loading [i]=true;
	  	   
     
	     Num=0; 
			 
			    for j= 1 , 10, 1 do
					  if instance.parameters:getBoolean ("On"..j) then						
						Num=Num+1; 				 
			
							   iprofile[i][Num] = core.indicators:findIndicator(instance.parameters:getString("Method"..j));
							   iparams[i][Num] = instance.parameters:getCustomParameters("Method"..j);
							   
							   if  iprofile[i][Num]:requiredSource() == core.Tick then
							   Indicator[i][Num] = iprofile[i][Num]:createInstance(Source[i].close, iparams[i][Num]);
							   else
							   Indicator[i][Num] = iprofile[i][Num]:createInstance(Source[i], iparams[i][Num]);
							   end  
							   
							   
							   
						end
	  	    
		   	 end	   
		
	 end 
	  

    
	 instance:ownerDrawn(true); 
   
end



-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)


 local i ;
 
 
		 for i = 1, Count, 1 do	
		     
			  if cookie == ( 10000 +  i) then
			  loading[i]  = true;
		      elseif  cookie == (20000+ i) then
			  loading[i]  = false;  
			  end
			  
		      
          end

	
	
    local FLAG=false; 
	local Number=0;
	
	for i = 1, Count, 1 do
		 

                 if loading [i] then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
       
    end
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..(Count - Number) .. " / " ..  Count );	 
	else
	core.host:execute ("setStatus", "Loaded") 
	 instance:updateFrom(0);	
	end
   
        
    return core.ASYNC_REDRAW ;
end

local top, bottom;
local left, right;
local xGap;	 
local yGap; 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode) 
	 
 end


local init = false;
 
function Draw(stage, context)
    if stage~= 2 then
	 return;
	end
	
	 local Loading=false; 
	
	 
	 for i= 1, Count,1 do 		
                 if loading [i] then
				 Loading= true; 
				 end		  
    end
	
	
	 if Loading then
           return;
     end
	 
	 
	
        if not init then
	
			
			 context:createPen(11, context.SOLID, 1, Up); 
            context:createSolidBrush(12, Up);
			
			 context:createPen(21, context.SOLID, 1, Down); 
            context:createSolidBrush(22, Down);
		 		 			
            init = true;
        end
		
	    
		
    	top, bottom = context:top(), context:bottom();
		left, right = context:left(), context:right();
		
	
		
		xGap=  (right-left)/(Num+1);	 
		yGap=  (bottom-top)/(Count+1);
				--Num
 
		if xGap> 250 then
		xGap= 250;
		end
			   
		
		
		for i= 1, Count,1 do 	
			for j= 1, Num,1 do 

            
			 Calculate (context,i, j);
		 
			end
		end
 
end	


 function Calculate (context,i, j )
   
     
	Indicator[i][j]:update(core.UpdateLast); 
	  
    -- if    not   Indicator[i][j]:getStream(Max[j]-1):hasData(Indicator[i][j]:getStream(Max[j]-1):size()-2)  
     --then
    -- return;
    -- end
	 
	
	     y1=bottom -(i+1)*yGap;
		y2=bottom -(i )*yGap;
	--	y0=y1 +yGap*3/2;
		
		x1=right -(j+1)*xGap;
		x2=right -(j )*xGap;
		
		iwidth = ((xGap/10)/100)*Size ;
		iheight= ((yGap/100)*Size);
		
		context:createFont (8, "Arial",iwidth, iheight , 0);
	
		iwidth = ((xGap/10)/100)*Size ;
		iheight= ((yGap/100)*Size)/Max[j];
		
	
		context:createFont (7, "Arial",iwidth, iheight , 0);
	 
 
		
		if j== Num then 
		width, height = context:measureText (8, TF[i], context.CENTER  ); 
		context:drawText (8, TF[i], Color, -1, x1, y1+yGap , x2, y1+height+yGap, context.CENTER, 0);
		end
		
		
 	  
	    if i== Count then 
		width, height = context:measureText (8, Method[j], 0); 
		context:drawText (8,  Method[j], Color, -1, x1+xGap , y1,x2+xGap,  y2, context.CENTER   );	
		end
    
		
		
			   for k=1, Max[j], 1 do
			   
			   
			   
			       if Indicator[i][j]:getStream(k-1):hasData(Indicator[i][j]:getStream(k-1):size()-1) then 
							Value = Indicator[i][j]:getStream(k-1)[Indicator[i][j]:getStream(k-1):size()-1];
							
							if  Max[j] == 1 then
							Value=   string.format("%." .. source:getPrecision() .. "f", Value); 
							else
							Value= tostring(k) .. ":".. string.format("%." .. source:getPrecision() .. "f", Value); 
							end
							
								width, height = context:measureText (7, Value, context.CENTER  ); 
							 
							if  Indicator[i][j]:getStream(k-1)[Indicator[i][j]:getStream(k-1):size()-1] > Indicator[i][j]:getStream(k-1)[Indicator[i][j]:getStream(k-1):size()-2] then					  
							context:drawText (7, Value, Up, -1, x1+xGap, y1+yGap+iheight*(k-1) , x1+xGap+width,  y1+yGap+iheight*(k-1)+height, context.CENTER,0); 
							elseif  Indicator[i][j]:getStream(k-1)[Indicator[i][j]:getStream(k-1):size()-1] < Indicator[i][j]:getStream(k-1)[Indicator[i][j]:getStream(k-1):size()-2] then
							context:drawText (7, Value, Down, -1, x1+xGap, y1+yGap+iheight*(k-1) ,  x1+xGap+width,   y1+yGap+iheight*(k-1)+height, context.CENTER,0); 
							else		
							context:drawText (7, Value, Neutral, -1, x1+xGap, y1+yGap+iheight*(k-1) , x1+xGap+width,   y1+yGap+iheight*(k-1)+height, context.CENTER,0); 
							end		
			        end
			   end
	
	  --NUm
 end
 
 
 