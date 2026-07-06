-- Id: 11960

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
 

	
	indicator.parameters:addGroup("Parameters");
	indicator.parameters:addInteger("Period", "Period", " " , 50); 
	
	
    indicator.parameters:addGroup("Line Style Parameters"); 
	 AddStyle(1 , "First",core.rgb(0,255,0));
	 AddStyle(2 , "Second",core.rgb(255,0,0));
	 
 
end


 

function AddStyle(id , Label, color)
indicator.parameters:addColor("color" ..id, Label ..  " Line Color","", color);
indicator.parameters:addInteger("width" .. id, "Line width", "", 1, 1, 5);
indicator.parameters:addInteger("style".. id, "Line style", "", core.LINE_SOLID);
indicator.parameters:setFlag("style".. id, core.FLAG_LINE_STYLE);
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
 
local MA={};
local iNum={}; 
local SW={};
local crncy1, crncy2;

local Up,Down,Neutral;
-- Routine
function Prepare(nameOnly)
    
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
	 
	RawList, RawCount= getInstrumentList();
	
	    for i= 1, 2, 1 do
	        Width[i]= instance.parameters:getDouble("width" .. i);	
		    Style[i]= instance.parameters:getDouble("style" .. i);	
		    Color[i]= instance.parameters:getDouble("color" .. i);	
 
	    end

	local FLAG= false;
	Count=0;
	   
  
	crncy1, crncy2 = string.match(source:instrument(), pauto);
	
	for i = 1, RawCount, 1 do
	
	crncy3, crncy4 = string.match(RawList[i], pauto);
	
	FLAG= false;
	
		  		   
			 if   ( 
			    crncy1== crncy3
			 or crncy1==crncy4
			 or crncy2== crncy3
			 or crncy2==crncy4
			 and crncy2~= nil
			 )			 
			 then
			 FLAG= true;
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
	
	
	
	 
	 
	 if  crncy2~= nil then
	 SW[1] = instance:addStream("First", core.Line, name, crncy1, Color[1], source:first()+Period);
    SW[1]:setPrecision(math.max(2, instance.source:getPrecision()));
		SW[1]:setWidth(Width[1]);
        SW[1]:setStyle(Style[1]);
		
	    SW[2] = instance:addStream("Second", core.Line, name, crncy2, Color[2], source:first()+Period);
    SW[2]:setPrecision(math.max(2, instance.source:getPrecision()));
		SW[2]:setWidth(Width[2]);
        SW[2]:setStyle(Style[2]);
	 
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

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    
    if period < source:first()+Period or not source:hasData(period) then
	return;
	end
	
	if  crncy2== nil then
	return;
	end
	
    local FLAG=false;  
	local i;
	
	for i = 1, Count, 1 do
	             if loading[i] then
				 FLAG= true; 
				 end
	end
	
	
		
	if FLAG then
	return;
	end
	
	core.host:execute ("setStatus",    "" );
	 
	local p;
	 
	Num[2]={0,0 };
    Num[3]={0,0 };
	
	for i = 1, Count, 1 do			   
	   
				   		   
				    Calculate(i , period);				  
					
	end
	
 

	Out (1, period );
    Out (2, period );	
 
	   
end	

function Out (id, period )
            
           
			SW[id][period]= Num[2][id]/(Num[3][id]/100);	 
			
           

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
local crncy3, crncy3; 
		
				 crncy3, crncy4 = string.match(List[i], pauto);
				 
				 
				  if   not ( 
			     crncy1== crncy3
			 or crncy1==crncy4
			 or crncy2== crncy3
			 or crncy2==crncy4 )
			 then
			 return;
			 end
				 
			j=1;	 
				  local min,max= mathex.minmax(SourceData[i], period-Period+1,period );
					
					if crncy1 == crncy3  then					
					  --  (Close - PMin)/(PMax-PMin) 		 
						Num[2][j] = Num[2][j] +( SourceData[i].close[period]-min )/(max-min);	
						Num[3][j]=Num[3][j]+1;                     					
					end
					
					if crncy1 == crncy4  then					   
					 --(PMax - Close)/(PMax-PMin)
					    Num[2][j] = Num[2][j] +( max-SourceData[i].close[period] )/(max-min);	
                        Num[3][j]=Num[3][j]+1;       						
					end
					
			j=2;	 
				  if crncy2 == crncy3  then					
					  --  (Close - PMin)/(PMax-PMin) 		 
						Num[2][j] = Num[2][j] +( SourceData[i].close[period]-min )/(max-min);	
						Num[3][j]=Num[3][j]+1;                     					
					end
					
					if crncy2 == crncy4  then					   
					 --(PMax - Close)/(PMax-PMin)
					    Num[2][j] = Num[2][j] +( max-SourceData[i].close[period] )/(max-min);	
                        Num[3][j]=Num[3][j]+1;       						
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
	
	
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..(Count - Number) .. " / " .. Count );
	   else
	instance:updateFrom(0);	
	core.host:execute ("setStatus",    "Loaded" )
	 end
   
        
     return core.ASYNC_REDRAW;
end
 