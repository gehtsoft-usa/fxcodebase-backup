-- Id: 11773

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60706

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
    indicator:name("ADX Strength Indicator");
    indicator:description(" ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
	
	indicator.parameters:addBoolean("Use", "Use Percentage", "", false);
	indicator.parameters:addBoolean("Both", "Majors Only", "", true); 
	
	indicator.parameters:addGroup("Source Selector");	 
    indicator.parameters:addBoolean("On"  .. 1, "USD", "", true);
	indicator.parameters:addBoolean("On"  .. 2, "EUR", "", true);
	indicator.parameters:addBoolean("On"  .. 3, "GBP", "", true);
	indicator.parameters:addBoolean("On"  .. 4, "CHF", "", true);
	indicator.parameters:addBoolean("On"  .. 5, "JPY", "", true);
	indicator.parameters:addBoolean("On"  .. 6, "AUD", "", true);
	indicator.parameters:addBoolean("On"  .. 7, "NZD", "", true);
	indicator.parameters:addBoolean("On"  .. 8, "CAD", "", true);

	
	indicator.parameters:addGroup("ADX Parameters");	
	indicator.parameters:addInteger("Period", "Period", " " , 14);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addInteger("Shift", "Vertical Shift", " " , 0);
    indicator.parameters:addColor("Color", "Label Color", " " ,  core.COLOR_LABEL);
    indicator.parameters:addInteger("Size", "Font Size", " " , 10);
	indicator.parameters:addBoolean("Rainbow"  , "Use Rainbow Coloring", "", true);
	
end


function ReleaseInstance()

	     core.host:execute("deleteFont", Bold);
		 core.host:execute ("killTimer", 1);
 end  

 
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block 

local first;
local source = nil;
local Method, Price, Period;
-- Streams block
local Out={};
local Pair = {"USD","EUR","GBP","CHF","JPY" ,"AUD" ,"NZD","CAD"}
local On={};
local loading={};
local List={};
local  Count;
local RawList, RawCount;
local SourceData={};
local pauto =  "(%a%a%a)/(%a%a%a)";
local Num={};
local Shift;
local Color;
local Indicator={};
local Bold, Size;
local id;
local Final={};
	local host;
	local offset;
	local weekoffset;
	 
    local Point={};
	local Mode; 
local Use;
local MA={};
local iNum={};
local Both;
local Sorted;
local Rainbow;
-- Routine
function Prepare(nameOnly)
     
	Rainbow = instance.parameters.Rainbow;
	Both = instance.parameters.Both;
	Use = instance.parameters.Use;
	Size = instance.parameters.Size;
	Color = instance.parameters.Color;
	Shift = instance.parameters.Shift;
	 
	Period = instance.parameters.Period;
	local i,j;
	

    
	Mode = instance.parameters.Mode;
	
	 host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	
    source = instance.source;
   

    local name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	Bold  = core.host:execute("createFont", "Courier", Size +1, false, true);   
	
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
	local Temp;
	 Temp= core.indicators:create("ADX", source, Period);
	 first = Temp.DATA:first()+1;
	
	for i = 1, Count, 1 do
	 SourceData[i] = core.host:execute("getSyncHistory", List[i], source:barSize(), source:isBid(), math.min(300,first) , 200+i , 100+i);
	 loading[i] = true;  
	 
	  Indicator[i] = core.indicators:create("ADX", SourceData[i], Period);
	end
	
	core.host:execute ("setTimer", 1, 1);
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

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < source:size()-1 or not source:hasData(period) then
	return;
	end
	
	
	
    local FLAG=false; 
	local Number=0;
	local i;
	
	for i = 1, Count, 1 do
	             if loading[i] then
				 FLAG= true;
				 Number=Number+1;
				 end
	end
	
	
		
	if FLAG then
	return;
	end
	
	core.host:execute ("setStatus",    "" );
	 
	local p;
	Num[1]={"USD","EUR","GBP","CHF","JPY" ,"AUD" ,"NZD","CAD"};
	Num[2]={0,0,0,0,0,0,0,0};
	Num[3]={0,0,0,0,0,0,0,0};
	for i = 1, Count, 1 do	
	
	   
	   
				--   Indicator[i]:update(mode); 					   
				    Calculate(i );
				  
					
	end
	
 	Sorted=Sort(Num, 2, 3, 8)
	
	id=0;
	Draw();
		
	   
end	



function Coloring (value, mid)

local color;

if value <= mid then
color = core.rgb(255 * (value / mid), 255, 0) 
else 
color = core.rgb(255, 255 - 255 * ((value - mid) / mid), 0)
end


return  color;

end

function Sort(old, index, raw, columns)
 
 local new=old;
 local  j,k, temp;

 
 local  SortFlag=true;
    while SortFlag do

      SortFlag=false; 
	  
        for j = 2, columns , 1 do
                
                  if new[index][j] >  new[index][j-1] then
                                        
                           SortFlag=true;
						   
                           for k = 1, raw, 1 do
                           temp= new[k][j-1];
                           new[k][j-1]= new[k][j];
                           new[k][j]= temp;
                           end
                      
                  end
            
        end		
      
    end
  
  return new;
end

function Draw()

local i;
local iCount=0;


	for i = 1, 8, 1 do
		if On[i] then
		
		iCount=iCount+1;
	 	core.host:execute("drawLabel1", id, Size*5+(iCount-1)*(Size*5),  core.CR_LEFT, 20  +Shift, core.CR_TOP, core.H_Left, core.V_Center, Bold, Color,  Sorted[1][i]);	
      
			id = id+1;	
			
		
       local Data;
	   
      	if Use then			
		Data= Sorted[2][i]/(Sorted[3][i]/100);	 
		else
		Data= Sorted[2][i];	
		end
		
				if Sorted[3][i]== 0  then
				core.host:execute("drawLabel1", id, Size*5+(iCount-1)*(Size*5) ,  core.CR_LEFT, 20+ Size*2  +Shift, core.CR_TOP, core.H_Left, core.V_Center, Bold, Color,  "No Data"	);			  
			    id = id+1;	
				else
			
					 if Rainbow then					 
					core.host:execute("drawLabel1", id,  Size*5+(iCount-1)*(Size*5) ,  core.CR_LEFT, 20+ Size*2  +Shift, core.CR_TOP, core.H_Left, core.V_Center, Bold,  Coloring (( 100/8)*i, 50),  	string.format("%." .. 2 .. "f", Data)	);			  
					id = id+1;	
					else 
					core.host:execute("drawLabel1", id, Size*5+(iCount-1)*(Size*5) ,  core.CR_LEFT, 20+ Size*2  +Shift, core.CR_TOP, core.H_Left, core.V_Center, Bold, Color,  	string.format("%." .. 2 .. "f", Data)	);			  
					id = id+1;	
					 end
				end
		end	
	end	
		
end
		
		
function Calculate(i )

 

if not Indicator[i].DATA:hasData(Indicator [i].DATA:size()-1) then
 return;
end


local j;
local crncy1, crncy2;

	 for j= 1, 8 , 1 do  
	 
	 
     
        if On[j] then
		
		 
		
				 crncy1, crncy2 = string.match(List[i], pauto);
					
					if crncy1 == Pair[j] then
					
					    
					
							if Indicator[i].DATA[Indicator [i].DATA:size()-1] < Indicator[i].DATA[Indicator [i].DATA:size()-2] then
							Num[2][j]=0;
							elseif Indicator[i].DATA[Indicator [i].DATA:size()-1] > Indicator[i].DATA[Indicator [i].DATA:size()-2] then
							
							            if SourceData[i].close[SourceData[i].close:size()-1]  > SourceData[i].open[SourceData[i].open:size()-1]   then
										Num[2][j] = Num[2][j] + 1;
										elseif SourceData[i].close[SourceData[i].close:size()-1]  < SourceData[i].open[SourceData[i].open:size()-1]   then
										Num[2][j] =  Num[2][j] - 1;
										end
							end
					 	   
						Num[3][j]=Num[3][j]+1;
                    					
					end
					
					if crncy2 == Pair[j] then
					   
					 
					        if  Indicator[i].DATA[Indicator [i].DATA:size()-1] > Indicator[i].DATA[Indicator [i].DATA:size()-2] then
							Num[2][j]=0;
							elseif Indicator[i].DATA[Indicator [i].DATA:size()-1] < Indicator[i].DATA[Indicator [i].DATA:size()-2] then
									   if SourceData[i].close[SourceData[i].close:size()-1]  > SourceData[i].open[SourceData[i].open:size()-1]   then
										Num[2][j] = Num[2][j] - 1;
										elseif SourceData[i].close[SourceData[i].close:size()-1]  < SourceData[i].open[SourceData[i].open:size()-1]   then
										Num[2][j] =  Num[2][j] + 1;
										end
                      		end		
					    Num[3][j]=Num[3][j]+1
					end
	    end		
		 
	 end	 
	 
	  
		
end		
		
 

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

   local i;
    local FLAG=false; 
	local Number=0;
   
    for i = 1, Count, 1 do
		 
			  if cookie == 100+i then
			  loading[i] = true;
			  FLAG= true;
			  Number=Number+1;
		      elseif  cookie == 200+i then
			  loading[i] = false; 
			  
			  end
		  
	end    
	
 
	 if not FLAG and cookie== 1 then
		for i= 1, Count , 1 do
			  Indicator[i]:update(core.UpdateLast );
		end
	end	
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..(Count - Number) .. " / " .. Count );
    else
	 core.host:execute ("setStatus",    "Loaded" );	   
	instance:updateFrom(0);
	end
   
        
     return core.ASYNC_REDRAW;
end
 