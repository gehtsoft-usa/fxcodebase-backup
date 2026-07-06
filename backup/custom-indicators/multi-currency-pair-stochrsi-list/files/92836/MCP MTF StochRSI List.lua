-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60341
-- Id: 14864

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("MCP StochRSI List");
    indicator:description("MCP StochRSI List");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	   

	
	Parameters (1, 14,14,5,3 , "H8");
	Parameters (2, 28,28,10,6 , "D1");
	Parameters (3, 36,36,20,12,"W1"  );

	
	
	indicator.parameters:addGroup("Common Parameters");	
	indicator.parameters:addInteger("Size", "Size", "", 10);
	--indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0 , 10000);
	indicator.parameters:addColor("Color", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No", "Neutral Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addDouble("VSpace", "Vertical Spacing (%)","",50, 0, 100);
end


function Parameters (id , a1, a2, a3, a4, frame )
   
	
	indicator.parameters:addGroup(id.. ". StochRSI");
	
	indicator.parameters:addString("TF" .. id,  "Time frame", "", frame);
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);	
	
    indicator.parameters:addInteger("N"..id, "Number of periods for RSI", "", a1, 1, 200);
    indicator.parameters:addInteger("K"..id, "%K Stochastic Periods", "", a2, 1, 200);
    indicator.parameters:addInteger("KS"..id, "%K Slowing Periods", "", a3, 1, 200);
    indicator.parameters:addInteger("D"..id, "%D Slowing Stochastic Periods", "", a4, 1, 200);
	
    indicator.parameters:addDouble("OB"..id, "OB Level", "", 80);
    indicator.parameters:addDouble("OS"..id, "OS Level", "", 20);
	
end
local VSpace;
local loading={};
local SourceData={};
local Indicator={};
local N={};
local K={};
local KS={};
local D={};
local Pair;
local  iSize;
local source;
 
local host;
local first={};
local Test={};
local Count;
local Up, Down, No, Color;
--local Shift;
local On={};
local Num;
local Lock={};
local OB={};
local OS={};
local TF={};
function Prepare(nameOnly)
    source = instance.source;
	 
    host = core.host;	
	
    iSize=instance.parameters.Size;   
    local name =  "(" .. profile:id() .. ","  .. instance.source:name().. ","  .. source:barSize().. ")"
	instance:name(name);
	if nameOnly then
		return;
	end
	local i,j ;
	
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	No = instance.parameters.No;
	Color = instance.parameters.Color;
	VSpace=(instance.parameters.VSpace/100);
	
	
	 
	 Pair, Count = getInstrumentList();
	  

	Num=0;
	assert(core.indicators:findIndicator("STOCHRSI") ~= nil, "Please, download and install STOCHRSI.LUA indicator");	
		 
		 
 
	
	for i = 1 , 3 , 1 do 
	  
	   TF[i]=  instance.parameters:getString ("TF"..i);
	   N[i]=  instance.parameters:getInteger ("N"..i);
	   K[i]=  instance.parameters:getInteger ("K"..i);
	   KS[i]=  instance.parameters:getInteger ("KS"..i);
	   D[i]=  instance.parameters:getInteger ("D"..i);	  
	   OB[i]=  instance.parameters:getDouble ("OB"..i);
	   OS[i]=  instance.parameters:getDouble ("OS"..i);	  
	       
			   Test[i] =core.indicators:create("STOCHRSI",source.close,  N[i],K[i],KS[i],D[i] );			   
	           first[i]=  math.max( Test[i].DATA:first(),1 ) *2+1;	
	
	  
	end	
	
	instance:ownerDrawn(true);


	 
	local iCount=0;
	for j = 1, Count, 1 do
	
	 		 Indicator[j] = {};	 
             loading[j]={}; 
             SourceData[j]={}; 			 
		 for i = 1, 3, 1 do		 
               iCount=iCount+1;		 
			   SourceData[j][i]  = core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(), first[i] , 20000 + iCount , 10000 + iCount);
			   loading[j][i]  = true;   		   
			   Indicator[j][i] = core.indicators:create("STOCHRSI",SourceData[j][i].close,  N[i],K[i],KS[i],D[i] );		
             			  
			  
		end
	end    
	
	
	  core.host:execute ("setTimer", 100, 1);
	
end


function ReleaseInstance()
core.host:execute ("killTimer", 100);
end 

function Update(period, mode)

 
 

    
end

local init = false;

function Draw(stage, context)


 if stage ~= 0 then
 return;
 end
 

 local FLAG=false;
 
 
for j = 1, Count, 1 do
	 	 
		 for i = 1, 3, 1 do		 
	

                 if loading[j][i] then
				 FLAG= true;				  
				 end
		 end
      
    end
	
	if FLAG then	 
	return;
	end
	 
	
 

  local Max=0;  
	
 local Size = context:pointsToPixels(iSize);	
  context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
  local CellSize = math.floor(Size  * 0.9);
  local VS=(Size*VSpace);
 
        if not init then
            context:createPen (1, context.SOLID, 1, Color)       
			context:createSolidBrush(2, Color);
			context:createFont(3, "Arial", Size, CellSize, context.NORMAL);
			context:createFont(4, "Wingdings", Size, CellSize, context.BOLD);
            init = true;
        end
 
       
		local style = context.SINGLELINE + context.CENTER + context.VCENTER;
		
	 local x2=100;	
	 local width, height;
     for j= 1, Count , 1 do 
     width, height = context:measureText (3, Pair[j], style)	 
	
      Max=math.max(width, Max);
	
	 end
	 
 for j= 1, Count , 1 do 
     width, height = context:measureText (3, Pair[j], style)	 
      local x1=context:left()+Max ;
	  local y1=context:top()+CellSize*j +VS*j+height*2;
	  local x2=context:left()+Max*2;
	  local y2=context:top()+CellSize*(j+1)+VS*j+height*2;	        
	 context:drawText (3, Pair[j], Color, -1, x1, y1, x2,y2, style) ;	 
end	 
	
	  for i= 1, 3 , 1 do 
	    width, height = context:measureText (3, "1.", style)	
	   context:drawText (3, i.. ".", Color, -1, context:left()+Max*(i+1), context:top()+CellSize*1   , context:left()+Max*(i+2), context:top()+CellSize*2, style) 
	   end
	   
	   
	    for j= 1, Count , 1 do 
		
		
		     local y1=context:top()+CellSize*j +VS*j+height*2;	
	         local y2=context:top()+CellSize*(j+1)+VS*j+height*2;	  
		
		   for i= 1, 3 , 1 do 
		   
		     local x1=context:left()+Max*(i+1);	
	         local x2=context:left()+Max*(i+2);
	         local Note="";
			 local iColor=-1;
		    
		      if Indicator[j][i]:getStream(0):hasData(Indicator[j][i]:getStream(0):size()-1) and Indicator[j][i]:getStream(1):hasData(Indicator[j][i]:getStream(1):size()-1) 
			  and Indicator[j][i]:getStream(0):hasData(Indicator[j][i]:getStream(0):size()-2) and Indicator[j][i]:getStream(1):hasData(Indicator[j][i]:getStream(1):size()-2) 
			  then
			     if Indicator[j][i].K[Indicator[j][i].K:size()-1]  > Indicator[j][i].D[Indicator[j][i].D:size()-1] then
				 Note="\225";
				 elseif Indicator[j][i].K[Indicator[j][i].K:size()-1]  < Indicator[j][i].D[Indicator[j][i].D:size()-1] then
			     Note="\226";
				 else
				  Note="\158";
				 end
				 if (Indicator[j][i]:getStream(0)[Indicator[j][i]:getStream(0):size()-1]  > Indicator[j][i]:getStream(1)[Indicator[j][i]:getStream(1):size()-1] 
				 and Indicator[j][i]:getStream(0)[Indicator[j][i]:getStream(0):size()-2]  < Indicator[j][i]:getStream(1)[Indicator[j][i]:getStream(1):size()-2])
				 or (Indicator[j][i]:getStream(0)[Indicator[j][i]:getStream(0):size()-1]  < Indicator[j][i]:getStream(1)[Indicator[j][i]:getStream(1):size()-1] 
				 and Indicator[j][i]:getStream(0)[Indicator[j][i]:getStream(0):size()-2]   > Indicator[j][i]:getStream(1)[Indicator[j][i]:getStream(1):size()-2])
				 then
				  Note=  Note .. "\108";
				  end
				 
				  if Indicator[j][i]:getStream(0)[Indicator[j][i]:getStream(0):size()-1]  > OB[i] then
				  iColor=Up;
				  elseif Indicator[j][i]:getStream(0)[Indicator[j][i]:getStream(0):size()-1]  < OS[i] then
				   iColor=Down;
				  end
				  
				 width, height = context:measureText (4, Note, style)	  
				 context:drawText (4, Note, Color, iColor, x1, y1, x2+width,y2, style) ;
				 
				
				 
			  else
			  
			      context:drawText (4, "\158", Color, -1, x1, y1, x2,y2, style) ;
			  end		  
		   
		   end
		   
       end
 		
end




function getInstrumentList()
    local list={};
	
    local count = 0;	
    local row, enum;	
	
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
        list[count] = row.Instrument;
        row = enum:next();
    end

    return list, count;
end


function AsyncOperationFinished(cookie)

	
	local i,j;
	local iCount=0;
	for j = 1, Count, 1 do
	 	 
		 for i = 1, 3, 1 do		
             iCount=iCount+1;
			 
		     if cookie == (10000 + iCount) then
			  loading[j][i] = true;
			 elseif cookie == (20000 + iCount) then
			  loading[j][i] = false;
			 end
         end
	end	 
		 
	
local FLAG=false;
 
iCount1=0; 
iCount2=0;
 
for j = 1, Count, 1 do
	 	 
		 for i = 1, 3, 1 do		 
	
                 iCount2=iCount2+1;
				 
                 if loading[j][i] then
				 iCount1=iCount1+1;
				 FLAG= true;				  
				 end
		 end
      
    end
	
	
		
	if not FLAG and cookie == 100 then
	
	 for j = 1, Count, 1 do
		 for i = 1, 3, 1 do		   
			 			  
			   Indicator[j][i]:update(core.UpdateLast);  
	      end
    end	
	
	end
	
	

	 core.host:execute ("setStatus", "  Loading ".. (iCount2 -iCount1) .. " / " ..  iCount2 );	 
	 
	if not FLAG then 
	   instance:updateFrom(0);	
	end
   
        
    return core.ASYNC_REDRAW ;
end








