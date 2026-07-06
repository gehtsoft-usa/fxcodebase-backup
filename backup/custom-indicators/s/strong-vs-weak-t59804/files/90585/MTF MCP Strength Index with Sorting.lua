-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59804

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
    indicator:name("MTF MCP Strength Index with Sorting");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
 
	
	indicator.parameters:addGroup("Selector");	 
    indicator.parameters:addBoolean("On"  .. 1, "USD", "", true);
	indicator.parameters:addBoolean("On"  .. 2, "EUR", "", true);
	indicator.parameters:addBoolean("On"  .. 3, "GBP", "", true);
	indicator.parameters:addBoolean("On"  .. 4, "CHF", "", true);
	indicator.parameters:addBoolean("On"  .. 5, "JPY", "", true);
	indicator.parameters:addBoolean("On"  .. 6, "AUD", "", true);
	indicator.parameters:addBoolean("On"  .. 7, "NZD", "", true);
	indicator.parameters:addBoolean("On"  .. 8, "CAD", "", true);
	
	indicator.parameters:addGroup("Time Frame Selector");	 
	Parameters (1 , "m1", false  );
	Parameters (2 , "m5", false   );
	Parameters (3 , "m15", false  );
	Parameters (4 , "m30", false    );
    Parameters (5 , "H1", true  );
	Parameters (6 , "H2", false   );
	Parameters (7 , "H3", false  );
	Parameters (8 , "H4", false    );
    Parameters (9 , "H6", false    );
    Parameters (10 , "H8", true  );
	Parameters (11 , "D1", true   );
	Parameters (12 , "W1", false  );
	 
	
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addInteger("Shift", "Vertical Shift", " " , 0);
    indicator.parameters:addColor("Color", "Label Color", " " , core.rgb(0, 0, 0));
    indicator.parameters:addInteger("Size", "Font Size", " " , 10);
	indicator.parameters:addBoolean("Rainbow"  , "Use Rainbow Coloring", "", true);
end



function Parameters (id , TF, flag )
	 
	 
	indicator.parameters:addGroup(id ..". Time Frame");
	indicator.parameters:addBoolean("TFOn"..id , "Show  This Time Frame", "", flag);	

	indicator.parameters:addString("TF"..id, "Time frame", "", TF);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS); 
	 
 
	end


function ReleaseInstance()
         	  core.host:execute ("killTimer", 1);  
	     core.host:execute("deleteFont", Bold);
 end  

 
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block 

local first;
local source = nil;
local Method={};
local  Price={};
local Period={};
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
--local Use;
local MA={};
local iNum={};
local Both;

local TF={};
local TFOn={};
local TfCount;
local Sorted;
local Rainbow;
local PS={ };


function Coloring (value, mid)

local color;

if value <= mid then
color = core.rgb(255 * (value / mid), 255, 0) 
else 
color = core.rgb(255, 255 - 255 * ((value - mid) / mid), 0)
end


return  color;

end


 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 
	
	 
	 
	Size = instance.parameters.Size;
	Color = instance.parameters.Color;
	Shift = instance.parameters.Shift;
	Rainbow = instance.parameters.Rainbow;
	
	local i,j;
	
	TfCount=0;
	
	
	for i= 1, 12, 1 do
	TFOn[i] = instance.parameters:getBoolean("TFOn" .. i);	
	if TFOn[i] then
	TfCount=TfCount+1;
	TF[TfCount]= instance.parameters:getString("TF" .. i);	
	end
	
	end

    Bold  = core.host:execute("createFont", "Courier", Size +1, false, true);   
	Mode = instance.parameters.Mode;
	
	 host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	
    source = instance.source;
   
 
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
			 if  (Check(crncy1) and (Check(crncy2)) ) 			 
			 then
			 FLAG= true;
			 end
		   end 
		   
		 if FLAG then
		 Count = Count+ 1;		
		 List[Count]= RawList[i]; 
		 PS[Count]= core.host:findTable("offers"):find("Instrument", RawList[i]).PointSize;	
		 end
	
	end
	local Temp;
	local k=0;	 
	for j= 1 , TfCount, 1 do
	SourceData[j]={};
	Indicator[j]={};
	loading[j]={};
	
		 
	   for i = 1, Count, 1 do		
		 k=k+1;
		 SourceData[j][i] = core.host:execute("getSyncHistory", List[i], TF[j], source:isBid(), 0 , 200+k , 100+k);
		 loading[j][i] = true;  	 
	     
	   end
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
 
	
	
	
 
end	


function Sort(old, index, raw, columns)
 
 local new=old;
 local i,j,k, temp;
 local SortFlag=true;
 
 
   while SortFlag do
    SortFlag=false;

   
        for j = 2, columns , 1 do
                
                  if new[index][j] >  new[index][j-1] then
                    SortFlag=true                             
                           
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


function Draw(j)

local i;
local iCount=0;


	for i = 1, 8, 1 do
		if On[i] then
		
		iCount=iCount+1;
			
			
		 if Rainbow then		
	 	core.host:execute("drawLabel1", id, Size*5+(iCount-1)*Size*5 ,  core.CR_LEFT, Size*2+ (j-1)*Size*2 +Shift, core.CR_TOP, core.H_Left, core.V_Center, Bold,  Coloring (( 100/8)*i, 50),  Sorted[1][i]);	
        id = id+1;	
		else
		core.host:execute("drawLabel1", id,  Size*5+(iCount-1)*Size*5 ,  core.CR_LEFT, Size*2+ (j-1)*Size*2 +Shift, core.CR_TOP, core.H_Left, core.V_Center, Bold, Color,  Sorted[1][i]);	
        id = id+1;	
		end
	  	
	
		
			core.host:execute("drawLabel1", id,  Size*2 ,  core.CR_LEFT, Size*2+ (j-1)*Size*2 +Shift , core.CR_TOP, core.H_Left, core.V_Center, Bold, Color,  TF[j]);	
			id = id+1;	
		
		end
	end
	
end
		
		
function Calculate(j,i )

 


local k;
local crncy1, crncy2;
for k= 1, 8 , 1 do  
	 
	 
     
        if On[k] and  SourceData[j][i]["close"]:hasData(SourceData[j][i]["close"]:size()-1) then
		
		 
		
				 crncy1, crncy2 = string.match(List[i], pauto);
					
					if crncy1 == Pair[k] then
					
					    
					
							if SourceData[j][i]["close"][SourceData[j][i]["close"]:size()-1] >  SourceData[j][i]["open"][SourceData[j][i]["open"]:size()-1] then
							Num[2][k] = Num[2][k] + (( math.abs(SourceData[j][i]["close"][SourceData[j][i]["close"]:size()-1] -  SourceData[j][i]["open"][SourceData[j][i]["open"]:size()-1])) /PS[i]);
							else
							Num[2][k] =  Num[2][k]  - (( math.abs(SourceData[j][i]["close"][SourceData[j][i]["close"]:size()-1] -  SourceData[j][i]["open"][SourceData[j][i]["open"]:size()-1])) /PS[i]);
							end
					 	   
					--	Num[3][k]=Num[3][k]+1;
                    					
					end
					
					if crncy2 == Pair[k] then
					   
					 
					        if SourceData[j][i]["close"][SourceData[j][i]["close"]:size()-1] >  SourceData[j][i]["open"][SourceData[j][i]["open"]:size()-1] then
							Num[2][k] = Num[2][k]  - (( math.abs(SourceData[j][i]["close"][SourceData[j][i]["close"]:size()-1] -  SourceData[j][i]["open"][SourceData[j][i]["open"]:size()-1])) /PS[i]);
							else
							Num[2][k] =  Num[2][k] + (( math.abs(SourceData[j][i]["close"][SourceData[j][i]["close"]:size()-1] -  SourceData[j][i]["open"][SourceData[j][i]["open"]:size()-1])) /PS[i]);
                      		end		
					    --   Num[3][k]=Num[3][k]+1
					end
	    end		
		 
	 end	 
	 
	 
	  
		
end		
		
 

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

   local i, j;
   local l =0;
   
    local FLAG=false; 
	local Number=0;
  for j= 1 , TfCount, 1 do 
  
    for i = 1, Count, 1 do
		 l=l+1;
			  if cookie == 100+l then
			  loading[j][i] = true;
			  FLAG= true;
			  Number=Number+1;
		      elseif  cookie == 200+l then
			  loading[j][i] = false;            
			  
			  
			  end
		  
	end    
	
	end
	
	
	if not FLAG and cookie== 1 then
	
	local Number=0;
	 
	
 
 
	
	core.host:execute ("setStatus",    "" );
	 
	local p;
	id=0;
	
	for j= 1 , TfCount, 1 do
	
	  Num[1]={"USD","EUR","GBP","CHF","JPY" ,"AUD" ,"NZD","CAD"};
		Num[2]={0,0,0,0,0,0,0,0};
	--	Num[3]={0,0,0,0,0,0,0,0};
		
		
		for i = 1, Count, 1 do	
		
		
		   
		    			 
						Calculate(j, i);
				         
					 	
		end
	   	Sorted=Sort(Num, 2, 2, 8)
	    Draw(j);	
	end	
	   
	end
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading ".. ( Count*TfCount -Number) .. " / " .. Count*TfCount );
    else
	 core.host:execute ("setStatus",    "Loaded" );
	 instance:updateFrom(0);
	end
   
        
     return core.ASYNC_REDRAW;
end

 
 
