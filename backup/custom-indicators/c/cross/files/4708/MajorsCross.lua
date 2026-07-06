-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2243

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

 
  function AddTF(id, TF )
   
    indicator.parameters:addGroup(id..". Slot" );
 
	
	indicator.parameters:addString("TF"..id, id.. ".Time frame", "", TF);
	indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);
 
    
end

function Init()
    indicator:name("Majors Cross");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	 
	
 
    AddTF(1,  "H1"); 
	AddTF(2,  "D1");
	AddTF(3,  "W1");
 
    indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Color", "Label Color","", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Trend Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Trend Color","", core.rgb(255, 0, 0));
 
  -- indicator.parameters:addDouble("Size", "Font Size (%)","",90, 50, 200);
   
   
end

local source;
local day_offset, week_offset;
 
local Currency={"USD","EUR","JPY", "GBP", "CHF"};
local In= {"EUR/USD" ,"USD/JPY", "GBP/USD","USD/CHF", "EUR/JPY", "EUR/GBP", "EUR/CHF","GBP/JPY","CHF/JPY", "GBP/CHF"};
 


local VSpace,HSpace;
local Color;
local Size;
local Index={};
Index[1]={};
Index[2]={};
Index[3]={};
Index[4]={};
Index[5]={};

Index[1][1]=0;
Index[1][2]=-1;
Index[1][3]=2;
Index[1][4]=-3;
Index[1][5]=4;

Index[2][1]=1;
Index[2][2]=0;
Index[2][3]=5;
Index[2][4]=6;
Index[2][5]=7;

Index[3][1]=-2;
Index[3][2]=-5;
Index[3][3]=0;
Index[3][4]=8;
Index[3][5]=9;

Index[4][1]=3;
Index[4][2]=-6;
Index[4][3]=-8;
Index[4][4]=0;
Index[4][5]=-10;

Index[5][1]=-4;
Index[5][2]=-7;
Index[5][3]=-9;
Index[5][4]=10;
Index[5][5]=0;

local SourceData={};
local loading={};
 

local xNumber=5;
local yNumber=3;

local host;

local Up,Down ;

local Instrument={};
local Slope={};
 
 

 function Prepare(nameOnly)  
 
    source = instance.source;	
	 
	local name = profile:id() .. " " .. source:name()  .. " : " .. source:barSize();
	instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;

	
	 host = core.host;

    Color=instance.parameters.Color;

   

    
     day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");
	
    local Id=0;
  
    
	
	local ifirst;
	 local s1, e1, s2, e2;
	  s1, e1 = core.getcandle(source:barSize(), 0, 0, 0);
	 
    for i = 1, 3, 1 do
	Slope[i]={};
	     for x= 1, 5, 1 do
	     Slope[i][x]={};
		 end
	end
	
	local InstrumentFlag=nil;
	for i = 1, 10, 1 do
	InstrumentFlag = core.host:findTable("offers"):find("Instrument", In[i]);
	assert(InstrumentFlag ~= nil, "Subscribed to " ..  In[i] );    
	end
	
	
	AlertNumber=0;
	  for i = 1, 10, 1 do
	        SourceData[i]={};
			loading[i]={};			
	        for j = 1, 3, 1 do			
		     	Id=Id+1;				 
				 SourceData[i][j]  = core.host:execute("getSyncHistory",  In[i],  instance.parameters:getString("TF" .. j), source:isBid(),0, 2000 + Id , 1000 +Id);	 	 
				 loading[i][j]  = true;  	
            end  				 
				 	 
    end
  
	
 		
		core.host:execute ("setTimer", 1, 1);
		
		
	 instance:setLabelColor(Color);
     instance:ownerDrawn(true);
		 
end


function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

 

local i,j;
local FLAG=false; 
local Num=0;
local Id=0;
    for i = 1, 10, 1 do
	
	      for j = 1, 3, 1 do
					  Id=Id+1;
					  
					  if cookie == (1000 + Id) then
					  loading[i][j]  = true;
					  elseif  cookie == (2000 + Id ) then
					  loading[i][j]   = false;
					  end
					 
					   
						 if loading[i][j] then
						 FLAG= true;
						 Num=Num+1;
						 end
			end 		 
	end    
   
	
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..(30 - Num) .. " / " .. 30 );	 
	else
	core.host:execute ("setStatus", "Loaded");	     
	end
	
	local  Get;
	
	if cookie== 1 and not FLAG  then
	
	
	   
	   for i= 1, 3, 1 do
	            for x = 1, 5, 1 do				
					for y = 1, 5, 1 do
					  Get=math.abs(Index[x][y]);		

 					  if Get~= 0 then
					  
					  
						  if SourceData[Get][i].close[SourceData[Get][i]:size()-1]> SourceData[Get][i].open[SourceData[Get][i]:size()-1] then
						  
							  if Index[x][y] > 0 then
							  Slope[i][x][y]=1;
							  else
							  Slope[i][x][y]=-1;
							  end
						  else
						  
							  if Index[x][y] > 0 then
							  Slope[i][x][y]=-1;
							  else
							  Slope[i][x][y]=1;
							  end
						  end
					  else
					  Slope[i][x][y]=0;
					  end
					
					end
	            end    
	 end
	
	end
	  
	
        
    return core.ASYNC_REDRAW ;
	
	
end

function Update(period)
 
     
end

local init = false;

function Draw (stage, context)

    if stage  ~= 0 then
	return;
	end
	 
	 
	local FLAG=false; 

    for i = 1, 10, 1 do
	
	       for j = 1, 3, 1 do
		     
                 if loading[i][j] 
				 then
				 FLAG= true;
				 end
		  end		 
	end    
    
	
	if FLAG then
	return;	 
	end
   
    local style = context.SINGLELINE + context.CENTER + context.VCENTER;
	 
  
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
        if not init then
		   
			
			 context:createPen (1, context.SOLID, 1, Color)       
			context:createSolidBrush(2, Color);
			
			context:createPen (11, context.SOLID, 1, Up)       
			context:createSolidBrush(12, Up);
			
			context:createPen (21, context.SOLID, 1, Down)       
			context:createSolidBrush(22, Down);
		
		 
		  
            init = true;
        end
     
        
       local Zone= (context:right () - context:left () ) /yNumber;
	   
	   local xRow=Zone/(xNumber+2)
	   local yRow=(context:bottom () - context:top () )/(xNumber+2)
	   
	   
       
		 context:createFont(1, "Wingdings", xRow/4,yRow/4 , 0);
		  context:createFont(2, "Arial", xRow/6,yRow/6 , 0);
		 
		  width, height = context:measureText (1,  "\110" , 0);	 
		  
		     for j = 1, 3, 1 do
			 
			         for x= 1, 5 , 1 do	

                      
						
						for y= 1, 5 , 1 do	
						
						   if Slope[j][x][y]== 1 then
						   iColor = Up;
						   elseif Slope[j][x][y]== -1 then
						   iColor = Down;
						   else
						   iColor = Color;
						   end
						 
						   context:drawText(1, "\110" , iColor, -1, context:left()+ (j-1)*Zone+xRow*x, context:top() +yRow *(y)-  height +yRow/2 , context:left()+ (j-1)*Zone+xRow*x +width , context:top() +yRow *(y)+yRow/2 , 0);
						 
							if x== 5 then
							width2, height2 = context:measureText (2, Currency[y] , 0);	 
							context:drawText(2, Currency[y] , Color, -1, context:left()+ (j-1)*Zone+xRow*x+xRow/2, context:top() +yRow *(y)-  height2 +yRow/2 , context:left()+ (j-1)*Zone+xRow*x+xRow/2 +width2 , context:top() +yRow *(y)+yRow/2 , 0);
							end
							
							if x== 5 then
								width2, height2 = context:measureText (2, Currency[y] , 0);	 
								context:drawText(2, Currency[y] , Color, -1, context:left()+ (j-1)*Zone+xRow*y, context:top()-  height2 +yRow/2, context:left()+ (j-1)*Zone+xRow*y +width2 , context:top()   +yRow/2 , 0);
						   end		          
							
					    end
						
					 end
					 
             end     
          	
				   
				   
			 
					 
					
					 
		 
end
 