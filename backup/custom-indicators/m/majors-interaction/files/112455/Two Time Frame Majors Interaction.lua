-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64660

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
    indicator:name("Majors Interaction");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "Period", 1);
	indicator.parameters:addString("TF1",  "Time frame", "", "D1");
    indicator.parameters:setFlag("TF1", core.FLAG_PERIODS);
	
	indicator.parameters:addString("TF2",  "Time frame", "", "W1");
    indicator.parameters:setFlag("TF2", core.FLAG_PERIODS);

	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("LabelSize", "Font Size", "", 20, 0, 100); 
    indicator.parameters:addColor("Label", "Label Color", "Label Color", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Color", "Label Color", core.rgb(0, 255, 0));
     indicator.parameters:addColor("Down", "Down Color", "Label Color", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;
local loading1={};
local loading2={};
local  List={};
local  Count;
local  RawList, RawCount;
local TF1, TF2;
local Label;
local SourceData1={};
local SourceData2={};
--local Shift;
local host;
local offset;
local weekoffset;
local pauto =  "(%a%a%a)/(%a%a%a)";
local Majors={"USD", "EUR", "JPY", "GBP", "CHF", "AUD"};
local For1={};
local For2={};
local Value1={};
local Value2={};
local Pip1={};
local Pip2={};
local X1={};
local X2={};
local xKey1={};
local xKey2={};
local Up, Down;
-- Routine
function Prepare(nameOnly)
    TF1 = instance.parameters.TF1;
    TF2 = instance.parameters.TF2;
	
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;

	Label = instance.parameters.Label;
	LabelSize = instance.parameters.LabelSize;
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first();
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	
	RawList, RawCount=getInstrumentList();
	
	
	Count=0;
	
	
	for i=1,   RawCount, 1 do
	
	crncy1, crncy2 = string.match(RawList[i], pauto);	
	
	  ItIs =false;
	  
	  for j=1, #Majors, 1 do
	  
		  if crncy1==Majors[j]
		  or crncy2==Majors[j]		  
		  then
		  ItIs=true;
		  break;
		  end
	  
	  end
	  
	  if ItIs 
	  then
	  Count=Count+1;
	  List[Count]=RawList[i];
	  end
	  
	  
	
	end
	
 
	
	local i; 
	for i = 1, Count, 1 do
	SourceData1[i] = core.host:execute("getSyncHistory", List[i], TF1, source:isBid(), math.min(300,Period*2), 200+i, 100+i);
	Pip1[i]   = core.host:findTable("offers"):find("Instrument", List[i]).PipCost;	
	loading1[i]= true;
	end
	for i = 1, Count, 1 do
	SourceData2[i] = core.host:execute("getSyncHistory", List[i], TF2, source:isBid(), math.min(300,Period*2), 400+i, 300+i);
	Pip2[i]   = core.host:findTable("offers"):find("Instrument", List[i]).PipCost;	
	loading2[i]= true;
	end

	 core.host:execute ("setTimer", 1, 5);
	
	instance:ownerDrawn(true);

   
end


function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 

 local init = false;


-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
 
	
	

end
function Draw(stage, context)

   if stage  ~= 2 then
	return;
	end
	
 
     if not init then
		-- transparency = context:convertTransparency(instance.parameters.transparency); 
		   init = true;
         end

	local i, j;
	
	local FLAG=false;
	
	for i = 1, Count, 1 do
	   if loading1[i] or loading2[i] then
	   FLAG= true;
	   end
	end
	
	
	  
	
	if FLAG   then	
	return;	
	end
	
 	top, bottom = context:top(), context:bottom();
	mid=  top+(bottom-top)/2;
    left, right = context:left(), context:right(); 
	xSize= (right-left)/#Majors;
	
	context:createFont (1, "Arial",LabelSize, LabelSize , 0);
	
	
	
		 for j= 1, #Majors, 1 do			
		 --X
         P=0;
         N=0;
		 MIN=0;            	if  X1[j]~= nil then
							   for i= 1,  X1[j], 1 do
							   
									   if Value1[j][xKey1[j][i] ] < 0  then
										 MIN=MIN+1;
										 end
								 end 
		                    end
		 width, height = context:measureText (1, Majors[j], context.CENTER  ); 
		 context:drawText (1, Majors[j], Label, -1, left+(j-1)*xSize, mid-height ,  left+(j-1)*xSize+width, mid, context.CENTER, 0);
		 
		 
					if  X1[j]~= nil then
							 for i= 1,  X1[j], 1 do
							 
							 if  Value1[j][xKey1[j][i] ] > 0 then
							 P=P+1;
							 else
							 N=N+1;
							 end
						 
							 
							 
							 if  Value1[j][xKey1[j][i] ] > 0 then
							 width, height = context:measureText (1, For1[j][xKey1[j][i]], context.CENTER  ); 
							 context:drawText (1, For1[j][xKey1[j][i]], Label, Up, left+(j-1)*xSize, mid-height-(P-1)*height-height ,  left+(j-1)*xSize+width, mid-height-(P-1)*height, context.CENTER, 0);
							 else
							 
							  width, height = context:measureText (1, For1[j][xKey1[j][i]], context.CENTER  ); 
							 context:drawText (1, For1[j][xKey1[j][i]], Label, Down, left+(j-1)*xSize, mid+(MIN)*height-(N-1)*height-height,  left+(j-1)*xSize+width, mid+(MIN)*height-(N-1)*height , context.CENTER, 0);
							 end
							 
							 
					 end
			 end
		
		 
		 end
		 
	
	    for j= 1, #Majors, 1 do			
		 --X
         P=0;
         N=0;
		 MIN=0;            	if  X2[j]~= nil then
							   for i= 1,  X2[j], 1 do
							   
									   if Value2[j][xKey2[j][i] ] < 0  then
										 MIN=MIN+1;
										 end
								 end 
		                    end
		 width, height = context:measureText (1, Majors[j], context.CENTER  ); 
		 context:drawText (1, Majors[j], Label, -1, left+xSize/2+(j-1)*xSize, mid-height ,  left+xSize/2+(j-1)*xSize+width, mid, context.CENTER, 0);
		 
		 
					if  X2[j]~= nil then
							 for i= 1,  X2[j], 1 do
							 
							 if  Value2[j][xKey2[j][i] ] > 0 then
							 P=P+1;
							 else
							 N=N+1;
							 end
						 
							 
							 
							 if  Value2[j][xKey2[j][i] ] > 0 then
							 width, height = context:measureText (1, For2[j][xKey2[j][i]], context.CENTER  ); 
							 context:drawText (1, For2[j][xKey2[j][i]], Label, Up, left+xSize/2+(j-1)*xSize, mid-height-(P-1)*height-height ,  left+xSize/2+(j-1)*xSize+width, mid-height-(P-1)*height, context.CENTER, 0);
							 else
							 
							  width, height = context:measureText (1, For2[j][xKey2[j][i]], context.CENTER  ); 
							 context:drawText (1, For2[j][xKey2[j][i]], Label, Down, left+xSize/2+(j-1)*xSize, mid+(MIN)*height-(N-1)*height-height,  left+xSize/2+(j-1)*xSize+width, mid+(MIN)*height-(N-1)*height , context.CENTER, 0);
							 end
							 
							 
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

   local i;
   local ItIs=false;
   local Num=0;
    for i = 1, Count, 1 do
		 
			  if cookie == 100+i then
			  loading1[i] = true;
			  Num=Num+1;
			  ItIs=true;
		      elseif  cookie == 200+i then
			  loading1[i] = false;  
			  end
		     
			  if cookie == 300+i then
			  loading2[i] = true;
			  Num=Num+1;
			  ItIs=true;
		      elseif  cookie == 400+i then 
			  loading2[i] = false;  
			  end
	end    
	
--loadin	
	if not ItIs and cookie== 1 then
	
				 for j= 1, #Majors, 1 do
				 X1[j]=0;
				 X2[j]=0;
				 For1[j]={};
				 For2[j]={};
				 Value1[j]={};
				 Value2[j]={};
				 end
				
				for i=1, Count,  1 do
				 
				  if  SourceData1[i]:hasData(SourceData1[i]:size()-1-Period+1)
				  and SourceData2[i]:hasData(SourceData2[i]:size()-1-Period+1)
				  then
				 
				  for j= 1, #Majors, 1 do
				  
					 crncy1, crncy2 = string.match(List[i], pauto);	
					  
					  if crncy1== Majors[j] then
					  X1[j]= X1[j]+1;
					  X2[j]= X2[j]+1;
					  For1[j][X1[j]]=crncy2;
					  For2[j][X1[j]]=crncy2;
					  Value1[j][X1[j]]=-( SourceData1[i].close[SourceData1[i]:size()-1] - SourceData1[i].close[SourceData1[i]:size()-1-Period]  )/Pip1[i];
					  Value2[j][X2[j]]=-( SourceData2[i].close[SourceData2[i]:size()-1] - SourceData2[i].close[SourceData2[i]:size()-1-Period]  )/Pip2[i];
					  elseif crncy2== Majors[j] then
					  X1[j]= X1[j]+1;
					  X2[j]= X2[j]+1;
					  For1[j][X1[j]]=crncy1;
					  For2[j][X1[j]]=crncy1;
					  Value1[j][X1[j]]= (  SourceData1[i].close[SourceData1[i]:size()-1] -SourceData1[i].close[SourceData1[i]:size()-1-Period] )/Pip1[i];
					  Value2[j][X2[j]]= (  SourceData2[i].close[SourceData2[i]:size()-1] -SourceData2[i].close[SourceData2[i]:size()-1-Period] )/Pip2[i];					  
					  end
					  
					  
					  
				  
				  end
				  
				  end
				end
	
	
	       for j= 1, #Majors, 1 do
	       xKey1[j]= BubbleSortKey1(j);
		   end
		   
	       for j= 1, #Majors, 1 do
	       xKey2[j]= BubbleSortKey2(j);
		   end	
	end
	
 
   
   if not ItIs then
   instance:updateFrom(0);
   core.host:execute ("setStatus", "");
   else
    core.host:execute ("setStatus", "  Loading "..((Count) - Num) .. " / " .. (Count) );	 
   end
   
  
   
        
     return core.ASYNC_REDRAW;
end



--X
function BubbleSortKey1(j)
 
 local Key={};
 local Temp;
 local Sort=true;
   
   
   for i=1, X1[j], 1 do
   Key[i]=i;
   end
   
   

     while Sort do
    Sort=false;
   
            for i = 2,  X1[j] , 1 do
                  
                    if Value1[j][Key[i]] <  Value1[j][Key[i-1]] then
                     Sort=true;                  
                     
                            Temp= Key[i];                     
                     Key[i]=Key[i-1];
                     Key[i-1]=Temp;                       
                    end
           
          end
    
    end
  
  return Key;
end


function BubbleSortKey2(j)
 
 local Key={};
 local Temp;
 local Sort=true;
   
 
   for i=1, X2[j], 1 do
   Key[i]=i;
   end
   
   

     while Sort do
    Sort=false;
   
            for i = 2,  X2[j] , 1 do
                  
                    if Value2[j][Key[i]] <  Value2[j][Key[i-1]] then
                     Sort=true;                  
                     
                            Temp= Key[i];                     
                     Key[i]=Key[i-1];
                     Key[i-1]=Temp;                       
                    end
           
          end
    
    end
  
  return Key;
end
 
