-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64667

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
    indicator:name("Channel Helper");
    indicator:description("Channel Helper");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

 
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addBoolean("Extend" , "Extend", "Extend",true);
	indicator.parameters:addInteger("ID" , "Line ID", "ID",1,1,100);
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("color1", "Color of Line", "Color of Line", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("color2", "Color of Line Extend", "Color of Line", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Level={};
local Date={};
-- Streams block
 
local Extend;
local db;
local pattern = "([^;]*);([^;]*)";
local pauto =  "(%a%a%a)/(%a%a%a)";

local ID;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
	 
	Extend= instance.parameters.Extend;
	ID= instance.parameters.ID;

    local name = profile:id() .. " ID: " .. ID .. " : " .. source:name();
    instance:name(name);
	
	 if   (nameOnly) then
        return;
    end
	
	
	require("storagedb");
    db = storagedb.get_db("Channel Helper"  );	
	
 
	core.host:execute("addCommand", 1, "Add First"); 
	core.host:execute("addCommand", 2, "Add Second"); 
	core.host:execute("addCommand", 3, "Reset Line");
    core.host:execute("addCommand", 4, "Reset All");
	
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)


    local  ItIs= db:get("Instrument".. tostring(ID),  0); 
	
	if ItIs==0 then
	return;
	end
	
	  crncy1, crncy2 = string.match(source:instrument(), pauto); 
	 crncy3, crncy4 = string.match(ItIs, pauto);
	 
	 if crncy1~= crncy3
	 or crncy2~= crncy4
     then
	 return;
	 end
	 

    if period <= first then
	 Level[1]=0;
	 Level[2]=0;
	 end
	 
	 
 	
	
	if period < source:size()-1 then
	return;
	end
	
	
	
		 
		 Level[1]=tonumber(db:get("LevelFirst"..tostring(ID), 0)); 
	     Date[1]= tonumber(db:get("DateFirst".. tostring(ID), 0)); 
		 
		 	 
		 Level[2]=tonumber(db:get("LevelSecond"..tostring(ID), 0)); 
	     Date[2]=tonumber(db:get("DateSecond".. tostring(ID), 0)); 
		 
 	
		 
	if Level[1]==0 or Level[2]==0 then
	return;
	end
	
	
	local p1=core.findDate (source, Date[1], false);
	local p2=core.findDate (source, Date[2], false);
	
	
	 
	if p1==-1
	or p2==-1	
	then
	return;
	end
	
	if p1 > p2 then
	Temp=p1;
	p1= p2;
    p2=Temp;
	Start= Level[2];
	Stop=Level[1];
	else
	Start= Level[1];
	Stop=Level[2];
	end
	
	
 	a= (Stop - Start) / (p2 - p1);
    b= Start - a * p1;
	
	
	
	local Max=0;
	local Min=0;
	for p= p1, source:size()-1, 1  do
	Max=math.max(Max,  source.high[p] - (a * p + b)  );
	
	if Min==0 then
	Min= source.low[p] -(a * p + b)
	end
	
	Min=math.min(Min, source.low[p] -(a * p + b));
	end
	
    
	 if math.abs(Min) > Max then
	Delta= Min;
	else
	Delta=  Max ;
	end
	 
 
	 
	core.host:execute ("drawLine", 1, source:date(p1), Start, source:date(p2), Stop, instance.parameters.color1, instance.parameters.style, instance.parameters.width);
	core.host:execute ("drawLine", 2, source:date(p1), Start+Delta, source:date(p2),Stop+Delta, instance.parameters.color1, instance.parameters.style, instance.parameters.width);
	 
	
	if Extend then
	 
	Level[3]=a * first + b; 
	Level[4]=a * p1 + b; 
	Level[5]=a * p2 + b; 
	Level[6]=a * (source:size()-1)+ b; 
 

 
   
	core.host:execute ("drawLine", 5, source:date(first), Level[3] , source:date(p1), Level[4] , instance.parameters.color2, instance.parameters.style, instance.parameters.width);
	core.host:execute ("drawLine", 6, source:date(p2), Level[5]  , source:date(source:size()-1),Level[6] , instance.parameters.color2, instance.parameters.style, instance.parameters.width);
	
	
	core.host:execute ("drawLine", 3, source:date(first), Level[3]+Delta, source:date(p1), Level[4]+Delta, instance.parameters.color2, instance.parameters.style, instance.parameters.width);
	core.host:execute ("drawLine", 4, source:date(p2), Level[5] +Delta, source:date(source:size()-1),Level[6]+Delta, instance.parameters.color2, instance.parameters.style, instance.parameters.width);
	
	
	end
	
	if period== source:size()-1 then
	core.host:execute ("setStatus", win32.formatNumber((source.close[period] -math.min(  Level[6]  ,  Level[6] +Delta ))/    (math.abs(Level[6]- (Level[6]+Delta))/100), false, 2));
    end
end

function AsyncOperationFinished(cookie, success, message)
    
    local t, c, x, y,y1,y2,x1,x2;
	local i,j;
	local Index,Cell;
	
	
	if cookie == 1 then
		
		 
		iLevel, iDate = string.match(message, pattern, 0);
 
		  
		 
		 db:put("LevelFirst"..tostring(ID),  tostring(iLevel)); 
	     db:put("DateFirst".. tostring(ID),  tostring(iDate)); 
		 db:put("TF".. tostring(ID),  tostring(source:barSize())); 
		 db:put("Instrument".. tostring(ID),  tostring(source:instrument())); 
	end
	
	if cookie == 2 then
		
		 
		iLevel, iDate = string.match(message, pattern, 0);
 
		 
		 db:put("LevelSecond"..tostring(ID),  tostring(iLevel)); 
	     db:put("DateSecond".. tostring(ID),  tostring(iDate));  
	end
	
	 
	 
	if cookie == 3 then  
	db:put("LevelFirst"..tostring(ID), 0); 
	db:put("LevelSecond".. tostring(ID), 0); 
	db:put("TF".. tostring(ID),  tostring(0));
    db:put("Instrument".. tostring(ID),  tostring(0)); 	
	core.host:execute ("removeAll");
	core.host:execute ("setStatus","")	; 
	end
	
	if cookie == 4 then  
	 for i= 1, 100, 1 do
	 
			db:put("LevelFirst"..tostring(i), 0); 
			db:put("LevelSecond".. tostring(i), 0); 
			db:put("TF".. tostring(ID),  tostring(0)); 
			db:put("Instrument".. tostring(ID),  tostring(0)); 
			core.host:execute ("removeAll");
			core.host:execute ("setStatus","")	; 
	 end
	 
	end    

end	

