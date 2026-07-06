-- Id: 10694
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3598

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Delta Ruler Table");
    indicator:description("Delta");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Style");

	indicator.parameters:addBoolean("On"  .. 1, "USD", "", true);
	indicator.parameters:addBoolean("On"  .. 2, "EUR", "", true);
	indicator.parameters:addBoolean("On"  .. 3, "GBP", "", true);
	indicator.parameters:addBoolean("On"  .. 4, "CHF", "", true);
	indicator.parameters:addBoolean("On"  .. 5, "JPY", "", true);
	indicator.parameters:addBoolean("On"  .. 6, "AUD", "", true);
	indicator.parameters:addBoolean("On"  .. 7, "NZD", "", true);
	indicator.parameters:addBoolean("On"  .. 8, "CAD", "", true);
	
 

   indicator.parameters:addGroup("Style");

   
	indicator.parameters:addColor("Up", "Up Label Color", "Label Color", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Label Color", "Label Color", core.rgb(255, 0, 0));
	
	 indicator.parameters:addInteger("Shift", "Vertical Shift", " " , 0);
	--indicator.parameters:addBoolean("Rainbow"  , "Use Rainbow Coloring", "", true);
	
	indicator.parameters:addGroup("Ruler");
	 indicator.parameters:addInteger("Time", "TimeOut in Seconds", "", 60, 1, 100000);
    indicator.parameters:addColor("Label", "Label Color", "", core.COLOR_LABEL); 
    indicator.parameters:addInteger("Size", "Font Size", "", 10);
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Rainbow,Shift;
local DateOne, LevelOne;
local DateTwo, LevelTwo;
local font;
local Size;
local BAR;
local Time;
local Color;
local Label, Up, Down;

local first;
local source = nil;
local Components={};
local Pair = {"USD","EUR","GBP","CHF","JPY" ,"AUD" ,"NZD","CAD"}
local On={};
local loading={};
local List={};
local  Count;
local RawList, RawCount;
local SourceData={};
local pauto =  "(%a%a%a)/(%a%a%a)";
local Out={};
	local host;
	local offset;
	local weekoffset;
	local RawPoint;
    local Point={};
	local Bold;
	local id;
local Sorted;

local pattern = "([^;]*);([^;]*)";

function Parse(message)

    local level, date;
    level, date = string.match(message, pattern, 0);
	
    if level == nil or date == nil then
        return nil, nil;
    end
	
    return tonumber(date),tonumber(level) ;
end



function ReleaseInstance()
       core.host:execute("deleteFont", font);    
       core.host:execute ("killTimer", 1000)	
        core.host:execute ("killTimer", 10000)	   
       core.host:execute("deleteFont", Bold);	   
 end


	local DB;

-- Routine
function Prepare(nameOnly)
    Label = instance.parameters.Label;
	Color = instance.parameters.Label;
    Up = instance.parameters.Up;	
	Down = instance.parameters.Down;	
    source = instance.source;
	Shift = instance.parameters.Shift;
	
	

	Time=instance.parameters.Time;
	Size=instance.parameters.Size;   
	
	 local s, e;
    s, e = core.getcandle(source:barSize(), 0, 0, 0);
	BAR =e-s;
	
   

	
	 host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	
	
	
    first = source:first();

    local name = profile:id() .. "(" .. source:name()  .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	Bold  = core.host:execute("createFont", "Courier", Size , false, true);   
	
	
	require("storagedb");
	 DB  =storagedb.get_db (name);

    	local crncy1, crncy2;
	 
	RawList, RawCount= getInstrumentList();
	
	RawPoint = getPointSize();
	

	local FLAG= false;
	Count=0;
	
	for j= 1 , 8 , 1 do
	On[j] = instance.parameters:getBoolean("On" .. j);
	Components[j]={};
	end
	
	
	for i = 1, RawCount, 1 do
	
	
	FLAG= false;
	
	crncy1, crncy2 = string.match(RawList[i], pauto);
	
		   
			 if  ItIs(crncy1) and ItIs(crncy2)then
			 FLAG= true;
			 end
		
		   
		 if FLAG then
		 Count = Count+ 1;
		 List[Count]= RawList[i]
		 Point[Count]= RawPoint[i]
		 end
	
	
	   end 
	
	for i = 1, Count, 1 do
	 SourceData[i] = core.host:execute("getSyncHistory", List[i], source:barSize(), source:isBid(), 300 , 200+i , 100+i);
	 loading[i] = true;  
	end
	
	
	   	
	core.host:execute("addCommand", 1001, "First", "");
    core.host:execute("addCommand", 1002, "Second", "");
	core.host:execute("addCommand", 1003, "Set Second as Last", "");	
    core.host:execute("addCommand", 1004, "Reset", "");	

	
	 font = core.host:execute("createFont", "Ariel", Size, true, false);
	  core.host:execute ("setTimer",  1000, Time  );
	  core.host:execute ("setTimer",  10000, 5  );
end

function ItIs (crncy)
local Flag= false;
local j;

      for j = 1, 8 , 1 do
			 if  (crncy== Pair[j] and On[j]) then
			 Flag= true;
			 end
	  end 


return Flag;

end

function Other(i)

local i1, i2;

local crncy1, crncy2;
crncy1, crncy2 = string.match(List[i], pauto);

      for w = 1, 8 , 1 do
			 if  crncy1== Pair[w] then
			 i1=w;
			 end
			 if crncy2== Pair[w] then	
			 i2=w;
			 end			
	  end 
	  
return i1, i2;

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

function Update(period)

		
end


function X()

	
	
    local FLAG=false; 
	local Number=0;
	local i;
	
	for i = 1, Count, 1 do
	             if loading[i] then
				 FLAG= true;
				 Number=Number+1;
				 end
	end
	
	Out[1]={};
	Out[2]={};
		
		local i;
		for i = 1, 8 , 1 do
		  -- if On[i] then  
		    Out[1][i]=Pair[i];		   
		   Out[2][i] = 0;	          
		 --  end
		 
		end
		
		
	if FLAG then
	return false;
	end
	
   local First=tonumber(DB:get("First"));
  local Second=tonumber(DB:get("Second"));
  
  if First == 0 or Second== 0 then
  return;
  end
	 
		  local p1, p2;
		
	for i = 1, Count, 1 do	
			 		   
					p1= Initialization(i,First) ;
					p2= Initialization(i,Second) ;
				    Calculate(i, p1, p2);				  
					
	end
	
	--Sorted=Sort(Out, 2, 2, 8)	
	Sorted=Out;
    
end

function Draw()

local i;
local iCount=0;


	for i = 1, 8, 1 do
		if On[i] then
		
		iCount=iCount+1;
	  
			
				
				if Sorted[2][i]== 0  then
				core.host:execute("drawLabel1", id, 100 +Size*10*(1), core.CR_LEFT, 40+Shift +(iCount-1)*Size*2  +Shift, core.CR_TOP, core.H_Left, core.V_Center, Bold, Color,  "No Data"	);			  
			    id = id+1;	
				else
				core.host:execute("drawLabel1",  id, 100+Size*10*(1) ,  core.CR_LEFT, 40+Shift +(iCount-1)*Size*2  +Shift, core.CR_TOP, core.H_Left, core.V_Center, Bold, Color,  	string.format("%." .. 2 .. "f", Sorted[2][i])	);			  
					id = id+1;	
                
				end
			
				 core.host:execute("drawLabel1", id, 100 +Size*10*(0),  core.CR_LEFT, 40 +Shift +(iCount-1)*Size*2, core.CR_TOP, core.H_Left, core.V_Center, Bold, Color,  Sorted[1][i]);	
			    id = id+1;	
					
					
					 
				end
	 
	 
	end

for i = 1, 8, 1 do
 core.host:execute("drawLabel1", id, 100 +Size*10*(1) + Size*10*(i),  core.CR_LEFT, 40 +Shift +(iCount)*Size*2, core.CR_TOP, core.H_Left, core.V_Center, Bold, Color,  Sorted[1][i]);	
			    id = id+1;		
end

for j = 1, 8, 1 do
	for i = 1, 8, 1 do
	
		if Components[j][i] ~= nil then
		core.host:execute("drawLabel1", id, 100 +Size*10*(1) + Size*10*(i),  core.CR_LEFT,40+Shift +(j-1)*Size*2, core.CR_TOP, core.H_Left, core.V_Center, Bold, Color,  string.format("%." .. 2 .. "f",Components[j][i])) ;	
					id = id+1;	
		end  
	end
end
end



	
function Calculate(i, p1, p2)

if not p1 or not p2 then
 return;
end



local Delta; 
local j;
local crncy1, crncy2;
local i1, i2;
	 for j= 1, 8 , 1 do  
	 
 
     
        if On[j] then
		
		 i1,i2 = Other(i);
			 
		  Delta = math.abs(SourceData[i].close[p1] -SourceData[i].close[p2] )/ Point[i];
		
				 crncy1, crncy2 = string.match(List[i], pauto);
				 
			 
			  Components[i1][i2]=Delta;
			  Components[i2][i1]=-Delta;
		
		  
					
						if crncy1 == Pair[j] then
					
					
					
							if  p1 < p2 then
							Out[2][j] =  Out[2][j] + Delta;
							else
							Out[2][j] =  Out[2][j] - Delta;
                            end
					       
							 		
					end
					
					if crncy2 == Pair[j] then
					  
								 if p1 < p2 then
								 Out[2][j]=  Out[2][j] -Delta;
								 else
								 Out[2][j] =  Out[2][j] + Delta;							
					             end			
					end			 
	    end		
		 
	 end	 
	 
	 
	
		
end		


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie, success, message)

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
	
	
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..(Count - Number) .. " / " .. Count );	 
	 return core.ASYNC_REDRAW;
    else
	 core.host:execute ("setStatus",    "Loaded" );
	  instance:updateFrom(0);
	end
	
   Ruler(cookie, success, message);
     
    id=2;
	
	if cookie == 10000 then	
	  local Flag= X(); 
	  if  Flag ~= false then
	   Draw();
	   end
	end
	
     return core.ASYNC_REDRAW;
	 
	 
end

function Ruler(cookie, success, message)

 if cookie == 1001 then
         DateOne, LevelOne  = Parse(message);
		  DB:put("First" , DateOne);
		
    
    elseif cookie == 1002 then
      
        DateTwo, LevelTwo  = Parse(message);  
         DB:put("Second" , DateTwo);
	
	elseif cookie == 1004 or cookie == 1000 then
      
        
		LevelOne= nil;
        LevelTwo= nil;
		core.host:execute ("removeLine", 1);
		if cookie ~= 1000  then
		 core.host:execute ("removeAll");
		  DB:put("First" ,0);
          DB:put("Second" , 0);
        end
  
	elseif cookie == 1003 then  

	DateTwo= source:date(source:size()-1);  
    LevelTwo= source.close[source:size()-1];	
	 DB:put("Second" , DateTwo);	
	end	
	
	if LevelOne~= nil and LevelTwo  ~= nil  then
	
			if cookie == 1001 or cookie== 1002 or cookie== 1003  then
			core.host:execute("drawLine", 1, DateOne, LevelOne, DateTwo, LevelTwo,
                              instance.parameters.color, instance.parameters.style, instance.parameters.width);
						
						  
			
			end
			
	end
end


function   Initialization(i,Date)


   if  Date == nil or Date < source:date(source:first())  then
   return false;
   end

    local Candle;
    Candle = core.getcandle(source:barSize(),Date , offset, weekoffset);

  
    if loading[i] or SourceData[i]:size() == 0 then
        return false ;
    end

     

    local p = core.findDate(SourceData[i], Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	


function getPointSize()
    local SIZE = {};
	
    local count = 0;	
    local row, enum;	
	
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
		
        SIZE[count] = row.PointSize;		
		
        row = enum:next();
    end

    return  SIZE;
end


