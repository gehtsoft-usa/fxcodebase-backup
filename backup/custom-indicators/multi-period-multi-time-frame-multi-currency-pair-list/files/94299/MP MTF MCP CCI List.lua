-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60765

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
    indicator:name("Multi Period Multi Time Frame Multi Currency Pair List");
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
 
	AddTF(1, "H1"  );
	AddTF(2, "H8"  );
	AddTF(3, "D1"  );
	AddTF(4, "W1"  );
	AddTF(5, "M1"  );
	
	indicator.parameters:addGroup("CCI Calculation"); 
	AddCCI(1, 5 );
	AddCCI(2, 21  );
	AddCCI(3, 89  );
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Size", "Font Size", "", 10);
	indicator.parameters:addDouble("VSpace", "Vertical Spacing (%)","",25, 0, 100);
  
end


function AddTF(id, TF) 
indicator.parameters:addString("TF".. id, id.. ". Time Frame", "", TF);
end

function AddCCI(id, Period) 
indicator.parameters:addInteger("Period".. id, id.. ". Period", "", Period);
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
local Color,Up,Down;
local iNum={};
local Both;
local Indicator={};
local VSpace;
-- Routine
function Prepare(nameOnly)
    Size = instance.parameters.Size;
	Both = instance.parameters.Both; 
	Color = instance.parameters.Color;
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	VSpace=1+(instance.parameters.VSpace/100);
	 
	for i= 1, 3  , 1 do
	Period[i]=   instance.parameters:getInteger("Period" .. i);
	end
	
	for i= 1, 5  , 1 do
	TF[i]=   instance.parameters:getString("TF" .. i);
	end
	

	Mode = instance.parameters.Mode;
	
	 host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	
    source = instance.source;
   

    local name = profile:id() .. "(" .. source:name()   .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
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
		   
		   
		   
			 if  ( (Check(crncy1) or (Check(crncy2)) ) and not Both)
			 or ( (Check(crncy1) and (Check(crncy2)) ) and Both)			 
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
	Indicator[i]={};
		  for j= 1 , 5, 1 do
		  Indicator[i][j]={};
		  id=id+1;
		  SourceData[i][j] = core.host:execute("getSyncHistory", List[i],TF[j], source:isBid(), math.min(math.max(Period[1],Period[2],Period[3])*2,300) , 2000+id , 1000+id);		  
		  loading[i][j] = true;
				  for k= 1, 3 , 1 do		  
				  Indicator[i][j][k]= core.indicators:create("CCI", SourceData[i][j], Period[k]);
				  end
		  end
	end
	
	 
	  instance:ownerDrawn(true);
            core.host:execute ("setTimer", 1, 1);
end


function ReleaseInstance()
core.host:execute ("killTimer", 1);
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
  			
	        context:createPen (12, context.SOLID, 1, Color);
            context:createPen (22, context.SOLID, 1, Up);
			context:createPen (32, context.SOLID, 1, Up);			 

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
	 
			 for j= 1, 5 ,1 do
			       x21=(j-1)*iSize*3 + iSize*3+ x12+(j-1)*200  ;
				   x22=(j-1)*iSize*3 + iSize*3+x12+(j-1)*200+iSize*3;
				   if i== 1 then
			       context:drawText (1, TF[j], Color, -1, x21, y11-height1*3, x22,y12-height1*2, style) ;	
				   end
				   
				for k= 1,  3, 1 do 
				  
				    x31=x21+(k-1)*75  ;
				   x32=x21+(k-1)*75+iSize*3;
						if i==1   then
					   context:drawText (1, Period[k], Color, -1, x31, y11-height1*2, x32,y12-height1*1, style) ;
					   end	
                        
                      Add( context,i,j,k, y11,x31 )						
				end	
			end
	 
	 end
	 
	

end		


function Add( context,i,j,k, y11,x31 )	
 
 if not  Indicator[i][j][k].DATA:hasData(Indicator[i][j][k].DATA:size()-1) then
 return;
 end
 local style = context.SINGLELINE + context.LEFT + context.VCENTER;
 local Value1 = Indicator[i][j][k].DATA[Indicator[i][j][k].DATA:size()-1];
 local Value2 = Indicator[i][j][k].DATA[Indicator[i][j][k].DATA:size()-2];
 
  if Value1 > Value2 then
 color=Up;
 else
 color=Down
 end
 
  Value1 =string.format("%." .. 0 .. "f", Value1) 
  
 width, height = context:measureText (1, Value1, style)	

 context:drawText (1, Value1, color, -1, x31, y11 , x31+width, y11+ height, style) ;
end		

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
   
	

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
		 for j = 1, 5, 1 do
		      id=id+1;
			  
			  if cookie == 1000+id then
			  loading[i][j] = true;
			  FLAG= true;
			  Number=Number+1;
		      elseif  cookie == 2000+id then
			  loading[i][j] = false;            
			
			  
			  end
		 end 
	end    
	
	if not FLAG and cookie== 1 then
	
	
		for i = 1, Count, 1 do
	 
		  for j= 1 , 5, 1 do
		 
				  for k= 1, 3 , 1 do
				  Indicator[i][j][k]:update(core.UpdateLast );
				  end
	      end
	end 
	
	end
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..(Count*5 - Number) .. " / " .. Count*5 );
    else
	 core.host:execute ("setStatus",    "Loaded" );
	   instance:updateFrom(0);
	end
   
        
     return core.ASYNC_REDRAW;
end
 