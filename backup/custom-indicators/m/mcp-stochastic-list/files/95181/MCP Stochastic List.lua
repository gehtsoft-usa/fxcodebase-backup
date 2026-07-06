-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60997

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
    indicator:name("MCP Stochastic List");
    indicator:description("MCP Stochastic List");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	   

	
	Parameters (1, 5,3,3,"MVA" ,"MVA");
	Parameters (2, 10,6,6,"MVA" ,"MVA" );
	Parameters (3,  50,12,12,"MVA" ,"MVA" );

	
	
	indicator.parameters:addGroup("Common Parameters");	
	indicator.parameters:addInteger("Size", "Size", "", 10);
	--indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0 , 10000);
	indicator.parameters:addColor("Color", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No", "Neutral Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addDouble("VSpace", "Vertical Spacing (%)","",50, 0, 100);
end


function Parameters (id , a1, a2, a3, a4,a5 )
   
	
	indicator.parameters:addInteger("a1"..id, "Number of periods for %K", "The number of periods for %K.", a1, 2, 1000);
    indicator.parameters:addInteger("a2"..id, "%D slowing periods", "The number of periods for slow %D.", a2, 2, 1000);
    indicator.parameters:addInteger("a3"..id, "Number of periods for %D", "The number of periods for %D.", a3, 2, 1000);

    indicator.parameters:addString("a4"..id, "Smoothing type for %K", "The type of smoothing algorithm for %K.", a4);
    indicator.parameters:addStringAlternative("a4"..id, "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("a4"..id, "EMA", "EMA", "EMA");
    indicator.parameters:addStringAlternative("a4"..id, "Fast Smoothed", "Fast Smoothed", "FS");
 
    
    indicator.parameters:addString("a5"..id, "Smoothing type for %D", "The type of smoothing algorithm for %D.", a5);
    indicator.parameters:addStringAlternative("a5"..id, "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("a5"..id, "EMA", "EMA", "EMA");
 
	
    indicator.parameters:addDouble("OB"..id, "OB Level", "", 80);
    indicator.parameters:addDouble("OS"..id, "OS Level", "", 20);
	
end
local VSpace;
local loading={};
local SourceData={};
local Indicator={};

local Pair;
local  iSize;
local source;
local a1={};
local a2={};
local a3={};
local a4={};
local a5={};
local host;
local first;
local Test={};
local Count;
local Up, Down, No, Color;
--local Shift;
local On={};
local Num;
local Lock={};
local OB={};
local OS={};
function Prepare(nameOnly)      
	--Shift=instance.parameters.Shift; 
    source = instance.source;
	 
    host = core.host;	
	
    iSize=instance.parameters.Size;   
    local name =  "(" .. profile:id() .. ","  .. instance.source:name().. ","  .. source:barSize().. ")"
	instance:name(name);
	
	if   (nameOnly) then
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
	 
		 
	first=source:first();	 
	
	for i = 1 , 3 , 1 do 
	
	   a1[i]=  instance.parameters:getInteger ("a1"..i);
	   a2[i]=  instance.parameters:getInteger ("a2"..i);
	   a3[i]=  instance.parameters:getInteger ("a3"..i);
	   a4[i]=  instance.parameters:getString  ("a4"..i);
       a5[i]=  instance.parameters:getString ("a5"..i);	   
	   OB[i]=  instance.parameters:getDouble ("OB"..i);
	   OS[i]=  instance.parameters:getDouble ("OS"..i);	  
	       
			   Test[i] =core.indicators:create("STOCHASTIC",source,  a1[i],a2[i],a3[i],a4[i],a5[i] );			   
	           first=  math.max( Test[i].DATA:first(),first );	
	
	  
	end	
	
	
	
	instance:ownerDrawn(true);


	 
	
	for j = 1, Count, 1 do
	
	 		 Indicator[j] = {};	 
		      SourceData[j]  = core.host:execute("getSyncHistory", Pair[j], source:barSize(), source:isBid(), math.min(300,first*2) , 20000 + j , 10000 + j);
			  loading[j]  = true;   
			  
		 for i = 1, 3, 1 do		   
			 			  
			   Indicator[j][i] = core.indicators:create("STOCHASTIC",SourceData[j], a1[i],a2[i],a3[i],a4[i],a5[i] );		
             			  
			  
		end
	end    
	
	      core.host:execute ("setTimer", 1, 1);
end




function Update(period, mode)

  
end

local init = false;

function Draw(stage, context)
 
 if stage ~= 0 then
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
	  local x1=context:left()+width ;
	  local y1=context:top()+CellSize*j +VS*j+height*2;
	  local x2=context:left()+width*2;
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

    for j = 1, Count, 1 do
	
			  if cookie == (10000 + j) then
			  loading[j] = true;
		      elseif  cookie == (20000 + j) then
			  loading[j] = false;       
		       end
        
	end    
	
	
	
    local FLAG=false; 
	local Number=0;
	
	for j = 1, Count, 1 do
		

                 if loading[j]then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
       
    end
	
	if not FLAG and cookie==1 then
	  for j = 1, Count, 1 do	
		   for i = 1, 3 , 1 do
		  Indicator[j][i]:update(core.UpdateLast);  
		  end
	  end 
	  
	  end
	  
	  
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Count) - Number) .. " / " .. (Count) );	 
	 else
	  core.host:execute ("setStatus", "  Loaded "..((Count) - Number) .. " / " .. (Count) );	
	  instance:updateFrom(0);		  
	  
	end
   
   
  
	
        
    return core.ASYNC_REDRAW ;
end




function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 



