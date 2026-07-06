-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65175

--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Price Action Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Selector");
    Add(1, "m1"); 
    Add(2, "m5"); 
    Add(3, "m15"); 
    Add(4, "m30"); 
    Add(5, "H1"); 
    Add(6, "H2"); 
    Add(7, "H3"); 
    Add(8, "H4" ); 
    Add(9, "H6" ); 
    Add(10, "H8"); 
    Add(11, "D1"); 
    Add(12, "W1"); 
    Add(13, "M1");
	Add(14, "W6"); 
    Add(15, "M12");
	
	indicator.parameters:addGroup("Style");
   indicator.parameters:addColor("Label_Color", "Label Color", "", core.COLOR_LABEL);  
   indicator.parameters:addColor("Background_Color", "Background Color", "", core.COLOR_BACKGROUND );  
    indicator.parameters:addDouble("XSize", "X Font Size (%)","",5, 0, 100);
	    indicator.parameters:addDouble("YSize", "Y Font Size (%)","",50, 0, 100)
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

 function Add(id, TF)
   
 
	indicator.parameters:addBoolean("On".. id , "Show " .. TF , "",true);	  
end	

local first;
local source = nil;
 
local Count=0;
local iLabel={"m1", "m15","m30", "H1","H2", "H3","H4", "H6", "H8","D1", "W1", "M1","M6", "M12" };
local XLabel={"Change", "Low", "High"};
local Label={};
local Source={};
local loading={};
local Label_Color;
local Background_Color;
local XSize,YSize;
local Data1={0,0,0,0,0,0,0,0,0,0,0,0,0,0};
local Data2={0,0,0,0,0,0,0,0,0,0,0,0,0,0};
local Data3={0,0,0,0,0,0,0,0,0,0,0,0,0,0};

local iData= {1,1 ,1 ,2,2,2,2,2,2,3,3,4,4,4};
local iShift={1,15,30,1,2,3,4,6,8,1,7,1,6,12};

local X1=(1/24)/60;
local X2=1/24;
local iTime={X1,X1,X1,X2,X2,X2,X2,X2,X2,1,1,30,30,30}


local Data={};
local Shift={};
local Time={};


local TF={"m1", "H1", "D1", "M1"  };
local FIRST={30, 8,  7, 12  }; 

-- Routine
function Prepare()
 
	 
    Label_Color=instance.parameters.Label_Color; 
	Background_Color=instance.parameters.Background_Color;
	XSize=instance.parameters.XSize/100;
	YSize=instance.parameters.YSize/100;
    source = instance.source;
    first=source:first();
	
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	  Number=0;
	  
	  for i = 1, 14, 1 do
	 
		   if  instance.parameters:getBoolean("On" .. i)  then
			  Number=Number+1;
			  Label[Number]=iLabel[i];
			  Data[Number]=iData[i];
			  Shift[Number]=iShift[i];
			  Time[Number]=iTime[i];
		   end
      end
	  
	 for k= 1, 4, 1  do
	 
	             Source[k]  = core.host:execute("getSyncHistory",  source:instrument(),  TF[k], source:isBid(), math.min(300,FIRST[k]), 2000 + k , 1000 +k);	 	 
				 loading[k]  = true;  	 
	 end
	  
 
    instance:ownerDrawn(true);
     core.host:execute ("setTimer", 1, 1);
	
end


function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 



-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

local k;
local FLAG=false; 
local Num=0;

    for k = 1, 4, 1 do
		      
			  if cookie == (1000 + k) then
			  loading[k]  = true;
		      elseif  cookie == (2000 + k ) then
			  loading[k]  = false;         
			  end
		 
		       
                 if loading[k] then
				 FLAG= true;
				 Num=Num+1;
				 end
	end    
     

    if not FLAG and cookie== 1 then
	
	Data1={0,0,0,0,0,0,0,0,0,0,0,0,0,0};
	Data2={0,0,0,0,0,0,0,0,0,0,0,0,0,0};
	Data3={0,0,0,0,0,0,0,0,0,0,0,0,0,0};
 
	
	local Current =source.close[source.close:size()-1];
	
	    
 
--local iShift={1,15,30,1,2,3,4,6,8,1,7,1,6,12};
--local iTime={(1/24)/60,1/24,1,30} 

			  local p;
			  for i= 1, Number, 1 do  			
			  --- Shift[i]*Time[i]
			   p= core.findDate (Source[Data[i]], core.now() , false);
			   
			   if p~=-1 then
			   Data1[i]=(Current -Source[Data[i]].open[p])/ (Source[Data[i]].open[p]/100)  ;
			   min,max=mathex.minmax(Source[Data[i]], p,  Source[Data[i]]:size()-1);
                 			   
			   Data2[i]=min;
			   Data3[i]=max;
			   
			   
			   Data1[i]=win32.formatNumber(Data1[i], false, 2);
			   Data2[i]=win32.formatNumber(Data2[i], false, source:getPrecision());
			   Data3[i]=win32.formatNumber(Data3[i], false, source:getPrecision());
			   else
			   Data1[i]="";
			   Data2[i]="";
			   Data3[i]="";
			   end
			   
			   
			   

			  end
     end
	
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((4) - Num) .. " / " .. (4) );	 
	else
	core.host:execute ("setStatus", "Loaded");
	  instance:updateFrom(0);
	end
	
 
   
        
    return core.ASYNC_REDRAW ;
	
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
 
function Update(period)   

  
end
 
local init = false;
 
function Draw(stage, context)


       context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
	  context:drawRectangle (-1, 2, context:left(), context:top(), context:right(), context:bottom());
	  
 
	  if stage~= 2 then
	  return;
	  end
	  
	  local k;
     local FLAG=false; 
	 
    for j = 1, 4, 1 do 
		       
                 if loading[j] then
				 FLAG= true; 
				 end
	end   

    if FLAG then
    return;
    end
	
     
	  
	  if not init then
		 context:createSolidBrush (2, Background_Color)
            init = true;
        end
	  
	
	 
	  
	   local YCellSize =((context:bottom() -context:top())/ (Number+3)); 
	   local XCellSize =((context:right() -context:left())/ (4)); 
	     
	
	
           context:createFont (1, "Arial", context:pointsToPixels (XCellSize*XSize), context:pointsToPixels (YCellSize*YSize), 0);

 
	 
   for i= 1, Number, 1 do  
   Text=Label[i];
   
   width, height = context:measureText (1, Text, 0);
   context:drawText (1,  Text, Label_Color, -1,  context:left() ,  context:top()+YCellSize*2+(i-1)*YCellSize ,context:left() + width,context:top()+YCellSize*2+(i-1)*YCellSize+height, 0 );	
   
          
			
           for j= 1, 3 , 1 do
		  
				 if i== 1 then 
				 width, height = context:measureText (1, XLabel[j], 0);
				 context:drawText (1,  XLabel[j], Label_Color, -1,  context:left()+XCellSize+(j-1)*XCellSize ,  context:top()+YCellSize ,context:left()+XCellSize+(j-1)*XCellSize + width,context:top()+YCellSize+height, 0 );		   
				 end
				          if j== 1 then 
						  Text=Data1[i];
				          width, height = context:measureText (1, Text, 0);
                          context:drawText (1,  Text, Label_Color, -1,  context:left()+XCellSize+(j-1)*XCellSize , context:top()+YCellSize*2+(i-1)*YCellSize ,context:left()+XCellSize+(j-1)*XCellSize + width,context:top()+YCellSize*2+(i-1)*YCellSize+height, 0 );	
		                  end
						  
						   if j== 2 then 
						  Text=Data2[i];
				          width, height = context:measureText (1, Text, 0);
                          context:drawText (1,  Text, Label_Color, -1,  context:left()+XCellSize+(j-1)*XCellSize , context:top()+YCellSize*2+(i-1)*YCellSize ,context:left()+XCellSize+(j-1)*XCellSize + width,context:top()+YCellSize*2+(i-1)*YCellSize+height, 0 );	
		                  end
						  
						  
						  if j== 3 then 
						  Text=Data3[i];
				          width, height = context:measureText (1, Text, 0);
                          context:drawText (1,  Text, Label_Color, -1,  context:left()+XCellSize+(j-1)*XCellSize , context:top()+YCellSize*2+(i-1)*YCellSize ,context:left()+XCellSize+(j-1)*XCellSize + width,context:top()+YCellSize*2+(i-1)*YCellSize+height, 0 );	
		                  end
		   end
   
  
   end

end		
 
