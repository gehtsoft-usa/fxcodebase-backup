-- Id: 11768

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60705

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
    indicator:name("Range StrongWeak ");
    indicator:description(" ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
	
	indicator.parameters:addBoolean("Use", "Use Percentage", "", true);
	indicator.parameters:addBoolean("Both", "Majors Only", "", true); 
	
	indicator.parameters:addGroup("Date Selector");	 
    indicator.parameters:addBoolean("On"  .. 1, "USD", "", true);
	indicator.parameters:addBoolean("On"  .. 2, "EUR", "", true);
	indicator.parameters:addBoolean("On"  .. 3, "GBP", "", true);
	indicator.parameters:addBoolean("On"  .. 4, "CHF", "", true);
	indicator.parameters:addBoolean("On"  .. 5, "JPY", "", true);
	indicator.parameters:addBoolean("On"  .. 6, "AUD", "", true);
	indicator.parameters:addBoolean("On"  .. 7, "NZD", "", true);
	indicator.parameters:addBoolean("On"  .. 8, "CAD", "", true);
	
	indicator.parameters:addGroup("Output Selector");	 
    indicator.parameters:addBoolean("Out"  .. 1, "USD", "", true);
	indicator.parameters:addBoolean("Out"  .. 2, "EUR", "", true);
	indicator.parameters:addBoolean("Out"  .. 3, "GBP", "", true);
	indicator.parameters:addBoolean("Out"  .. 4, "CHF", "", true);
	indicator.parameters:addBoolean("Out"  .. 5, "JPY", "", true);
	indicator.parameters:addBoolean("Out"  .. 6, "AUD", "", true);
	indicator.parameters:addBoolean("Out"  .. 7, "NZD", "", true);
	indicator.parameters:addBoolean("Out"  .. 8, "CAD", "", true);

	
	indicator.parameters:addGroup("Parameters");
	
	indicator.parameters:addInteger("Period", "Period", " " , 50);
   
   
   indicator.parameters:addGroup("Style Parameters");
   
   local Pair = {"USD","EUR","GBP","CHF","JPY" ,"AUD" ,"NZD","CAD"}
    local Coloring= {core.rgb(255, 0, 0), core.rgb(255, 128, 0), core.rgb(128, 255, 0),   core.rgb(0, 255, 0), core.rgb(0, 255, 128), core.rgb(0, 128, 255),    core.rgb(0, 0, 255),    core.rgb(128, 128, 128)}
     local i;
	 for i=1, 8 , 1 do
	 AddStyle(i , Pair[i], Coloring[i]);
	 end
end




function AddStyle(id , Label, color)
indicator.parameters:addColor("color" ..id, Label ..  " Line Color","", color);
indicator.parameters:addInteger("width" .. id, "Line width", "", 1, 1, 5);
indicator.parameters:addInteger("style".. id, "Line style", "", core.LINE_SOLID);
indicator.parameters:setFlag("style".. id, core.FLAG_LINE_STYLE);
end

function ReleaseInstance()

	     core.host:execute("deleteFont", Bold);
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
local One={};
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
local Color={};
local Style={};
local Width={};
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
local SW={};
-- Routine
function Prepare(nameOnly)
   
	Both = instance.parameters.Both;
	Use = instance.parameters.Use; 
	Period = instance.parameters.Period;
	local i,j;
	

	Mode = instance.parameters.Mode;
	
	
	
    source = instance.source;
   

    local name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	 host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	
	local crncy1, crncy2;
	 
	RawList, RawCount= getInstrumentList();
	
	 

	local FLAG= false;
	Count=0;
	 
	for j= 1 , 8 , 1 do
	On[j] = instance.parameters:getBoolean("On" .. j);	 
	One[j] = instance.parameters:getBoolean("Out" .. j);
	end
	
	
	for i = 1, RawCount, 1 do
	
	
	FLAG= false;
	
	crncy1, crncy2 = string.match(RawList[i], pauto);
	
		   for j = 1, 8 , 1 do
		   
		   Width[j]= instance.parameters:getDouble("width" .. j);	
		   Style[j]= instance.parameters:getDouble("style" .. j);	
		   Color[j]= instance.parameters:getDouble("color" .. j);	
		   
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

	for i = 1, Count, 1 do
	 SourceData[i] = core.host:execute("getSyncHistory", List[i], source:barSize(), source:isBid(), Period , 200+i , 100+i);
	 loading[i] = true;  
	 
	  
	end
	for j = 1, 8 , 1 do
		if On[j] and One [j] then
		SW[j] = instance:addStream(Pair[j], core.Line, name, Pair[j], Color[j], source:first()+Period);
    SW[j]:setPrecision(math.max(2, instance.source:getPrecision()));
		SW[j]:setWidth(Width[j]);
        SW[j]:setStyle(Style[j]);
		
		else
		SW[j] = instance:addInternalStream(0, 0);
		end
	end
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
    if period < source:first()+Period or not source:hasData(period) then
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
	   
				   		   
				    Calculate(i , period);				  
					
	end
	
 

	for i = 1, 8, 1 do	
	Out (i, period );
    end	
	   
end	


function Out (j, period )
            
            if Use then			
			SW[j][period]= Num[2][j]/(Num[3][j]/100);	 
			else
			SW[j][period]= Num[2][j];	
            end
		 

end
		
function   Initialization(period,id)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), offset, weekoffset);
  
    if loading[id] or SourceData[id]:size() <= Period  then
        return false;
    end
	
	
    
    if period <= source:first()+Period then
        return false;
    end

    local P = core.findDate(SourceData[id], Candle, true);
	 

    if P < Period 	
	or SourceData[id].close:first()+Period >= P
    or SourceData[id].close:size()<= P
    then
        return false;
	end
	
	Flag= false;
	for i= P, P-Period, -1 do
	
	   if not SourceData[id].close:hasData(i)
	   then
	   Flag=true;
	   break;
	   end
	   
	end
	
	if Flag== false then
	return P;	
	else
	return false;	
	end
   
			
end	



		
		
		
function Calculate(i, x )
 
  period =Initialization(x,i);
  
  if  period == false then
  return 
  end



local j;
local crncy1, crncy2;

	 for j= 1, 8 , 1 do  
	 
	 
     
        if On[j] then
		
                local min,max= mathex.minmax(SourceData[i], period-Period+1,period );
		
				 crncy1, crncy2 = string.match(List[i], pauto);
					
					if crncy1 == Pair[j] then					
					  --  (Close - PMin)/(PMax-PMin) 					 
					 
						Num[2][j] = Num[2][j] +( SourceData[i].close[period]-min )/(max-min);	
						Num[3][j]=Num[3][j]+1;                    					
					end
					
					if crncy2 == Pair[j] then
					   
					 --(PMax - Close)/(PMax-PMin)
					    Num[2][j] = Num[2][j] +( max-SourceData[i].close[period] )/(max-min);	
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
			  instance:updateFrom(0);
			  
			  end
		  
	end    
	
	
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..(Count - Number) .. " / " .. Count );
     else
	instance:updateFrom(0);	
	core.host:execute ("setStatus",    "Loaded" );
	end
   
        
     return core.ASYNC_REDRAW;
end
 