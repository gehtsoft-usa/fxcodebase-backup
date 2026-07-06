-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=43376

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
 
 
function Init()
    indicator:name("Multi Time Frame Multi Currency Pair Inside Bar List");
    indicator:description(" ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
	indicator.parameters:addGroup("Calculation"); 
 
	indicator.parameters:addBoolean("Both", "Majors Only", "", true); 
	
	indicator.parameters:addGroup(" Date Selector (If Majors Only is Set to Yes)");	 
    indicator.parameters:addBoolean("On"  .. 1, "USD", "", true);
	indicator.parameters:addBoolean("On"  .. 2, "EUR", "", true);
	indicator.parameters:addBoolean("On"  .. 3, "GBP", "", true);
	indicator.parameters:addBoolean("On"  .. 4, "CHF", "", true);
	indicator.parameters:addBoolean("On"  .. 5, "JPY", "", true);
	indicator.parameters:addBoolean("On"  .. 6, "AUD", "", true);
	indicator.parameters:addBoolean("On"  .. 7, "NZD", "", true);
	indicator.parameters:addBoolean("On"  .. 8, "CAD", "", true);
	
	 
	indicator.parameters:addGroup("Time Frame Selector"); 
 
	AddTF(1, "m1"  );
	AddTF(2, "m5"  );
	AddTF(3, "m15"  );
	AddTF(4, "m30"  );
	AddTF(5, "H1"  );
	AddTF(6, "H2"  );
	AddTF(7, "H3"  );
	AddTF(8, "H4"  );
	AddTF(9, "H6"  );
	AddTF(10, "H8"  );
	AddTF(11, "D1"  );
	AddTF(12, "W1"  );
	AddTF(13, "M1"  );
	 
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Inside Bar Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Inside Bar Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Flat", "Inside Bar Flat Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("Size", "Font Size", "", 10);
	indicator.parameters:addDouble("VSpace", "Vertical Spacing (%)","",25, 0, 100);
  
end


function AddTF(id, TF) 
indicator.parameters:addString("TF".. id, id.. ". Time Frame", "", TF);
end


 
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block 
local Period={};
local TF={};
local first;
local source = nil; 
local Pair = {"USD","EUR","GBP","CHF","JPY" ,"AUD" ,"NZD","CAD"}
local On={};
local loading={};
local List={};
local  Count;
local RawList, RawCount;
local SourceData={};
local pauto =  "(%a%a%a)/(%a%a%a)"; 
local  Size;
local id; 
	local host;
	local offset;
	local weekoffset;
local Color,Up, Down,Neutral;
local iNum={};
local Both;
local Indicator={};
local VSpace;
local Flat;
-- Routine
function Prepare(nameOnly)
    Size = instance.parameters.Size;
	Both = instance.parameters.Both; 
	Color = instance.parameters.Color;
	Down = instance.parameters.Down;
	Up = instance.parameters.Up;
	Neutral = instance.parameters.Neutral;
	Flat= instance.parameters.Flat;
	VSpace=1+(instance.parameters.VSpace/100);
	 
	 
	for i= 1, 13  , 1 do
	TF[i]=   instance.parameters:getString("TF" .. i);
	end
	

	Mode = instance.parameters.Mode;
	
	 host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	
    source = instance.source;
   

    local name = profile:id() .. "(" .. source:name()   .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	local crncy1, crncy2;
	 
	RawList, RawCount= getInstrumentList();
	
	 

	local FLAG= false;
	Count=0;
	 
	for j= 1 , 8 , 1 do
	On[j] = instance.parameters:getBoolean("On" .. j); 
	end
	
	
	for i = 1, RawCount, 1 do
	
	
	FLAG= false;
	
	crncy1, crncy2 = string.match(RawList[i], pauto);
	
		   for j = 1, 8 , 1 do
		   
		   
		   
			 if not  Both or
			 ( (Check(crncy1) and (Check(crncy2)) ) and Both)			 
			 then
			 FLAG= true;
			 end
		   end 
		   
		 if FLAG then
		 Count = Count+ 1;
		
		 List[Count]= RawList[i]; 
		 end
	
	end

	 id = 0;
	 
	for i = 1, Count, 1 do
	SourceData[i]={};
	loading[i]={};
	 
		  for j= 1 , 13, 1 do		   
		  id=id+1;
		  SourceData[i][j] = core.host:execute("getSyncHistory", List[i],TF[j], source:isBid(), 2 , 2000+id , 1000+id);		  
		  loading[i][j] = true;
				 
		  end
	end
	
	 
	  instance:ownerDrawn(true);

end


 


function Check(Find)
 local FLAG= false;
            for j = 1, 8 , 1 do
			 if  (Find==Pair[j] and On[j])then
			 FLAG= true;
			 end
		   end 
return FLAG;		   
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


local init = false;
 
function Draw(stage, context)
    if stage ~= 2 then
	return;
	end
	 local iSize = context:pointsToPixels( Size);
	context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
 
	 
  
	
	
        if not init then
          
			context:createFont(1, "Arial",  Size,  Size, context.NORMAL);
			context:createFont(2, "Wingdings",  Size,  Size, context.BOLD);
			
			context:createSolidBrush(11, Color); 
            context:createSolidBrush(21, Up);
			context:createSolidBrush(31, Down);
            context:createSolidBrush(41, Neutral);  			
  			
	        context:createPen (12, context.SOLID, 1, Color);
            context:createPen (22, context.SOLID, 1, Up);
			  context:createPen (32, context.SOLID, 1, Down);
			context:createPen (42, context.SOLID, 1, Neutral);			 

            init = true;
        end
		
		
		   
		local style = context.SINGLELINE + context.CENTER + context.VCENTER;
	 width, height = context:measureText (1, "X", style)		
     local width1=Size*10;
     local height1= height*VSpace; 
	 local VS=(Size*VSpace);
	 
     for i= 1, Count , 1 do 
     	 
	
     
	   x11=context:left()+25   ;
	   y11=context:top()+25+ height1*i +VS*i+height1*2;
	   x12=context:left()+ 25+  width1 ;
	   y12=context:top()+25+height1*(i+1)+VS*i+height1*2;        
	 context:drawText (1, List[i], Color, -1, x11, y11, x12,y12, style) ;	 
	 
			 for j= 1, 13 ,1 do
			       x21=(j-1)*iSize*3 + iSize*3+ x12+(j-1)*5  ;
				   x22=(j-1)*iSize*3 + iSize*3+x12+(j-1)*5+iSize*3;
				   if i== 1 then
			       context:drawText (1, TF[j], Color, -1, x21, y11-height1*3, x22,y12-height1*2, style) ;	
				   end
				   
				 
				 
                        
                  Add( context,i,j , y11,x21  )	;					
			 
			end
	 
	 end
	 
	

end		


function Add( context,i,j , y11,x21  )	
 
 if not  (SourceData[i][j].close:hasData(SourceData[i][j].close:size()-1) 
 or  SourceData[i][j].close:hasData(SourceData[i][j].close:size()-2) )
 then
 return;
 end
 
 
 local style = context.CENTER + context.VCENTER;
 local High1 = SourceData[i][j].high[SourceData[i][j].high:size()-1];
 local High2 = SourceData[i][j].high[SourceData[i][j].high:size()-2];
 local Low1 = SourceData[i][j].low[SourceData[i][j].low:size()-1];
 local Low2 = SourceData[i][j].low[SourceData[i][j].low:size()-2];
 
  if High1 < High2 and  Low1 > Low2 then
     if SourceData[i][j].close[SourceData[i][j].close:size()-1] > SourceData[i][j].open[SourceData[i][j].open:size()-1] then
    color=Up;
	elseif SourceData[i][j].close[SourceData[i][j].close:size()-1] < SourceData[i][j].open[SourceData[i][j].open:size()-1] then
	color=Down;
	else
	color=Flat;
	end
 else
 color=Neutral
 end
 
  Value = "\108";
  
 width, height = context:measureText (2, Value, style)	

 context:drawText (2, Value, color, -1, x21+width, y11 , x21+2*width, y11+ height, style) ;
end		

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
   
	
	
end	

 
function   Initialization(period,i,j)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), offset, weekoffset);
  
    if loading[i][j] or SourceData[i][j]:size() <= 0  then
        return false;
    end
	
	
    
    if period <= source:first()+Period then
        return false;
    end

    local P = core.findDate(SourceData[i], Candle, true);
	 

    if P < 0 	
	or SourceData[i][j].close:first()  >= P
    or SourceData[i][j].close:size()<= P
    then
        return false;
	end
	 
	return P;	 
end	

 

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

   local i;
    local FLAG=false; 
	local Number=0;
    local id=0;
	
    for i = 1, Count, 1 do
		 for j = 1, 13, 1 do
		      id=id+1;
			  
			  if cookie == 1000+id then
			  loading[i][j] = true;
			  FLAG= true;
			  Number=Number+1;
		      elseif  cookie == 2000+id then
			  loading[i][j] = false;            
			  instance:updateFrom(0);
			  
			  end
		 end 
	end    
	
	
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..(Count*13 - Number) .. " / " .. Count*13 );
    else
	 core.host:execute ("setStatus",    "Loaded" );
	end
   
        
     return core.ASYNC_REDRAW;
end
 