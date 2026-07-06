-- Id: 23526
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67229

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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
    indicator:name("Other Instrument Average");
    indicator:description("Other Instrument Average");
     indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
 
 
    indicator.parameters:addGroup("Calculation");	 
	indicator.parameters:addBoolean("Simple", "Use Simple Mode", "", false);
	indicator.parameters:addGroup("Style");	 
	indicator.parameters:addColor("color1", "1. Line Color", "Line Color", core.rgb(0, 255, 0));
	
	indicator.parameters:addInteger("width1", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("color2", "2. Line Color", "Line Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width2", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
 
	


end






-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 

 
 
local pauto =  "(%a%a%a)/(%a%a%a)";
 
local Source={}; 
local loading={}; 
local source;
local Count;   
local Point={};
local Position1={} 
local Position2={}
local Line1, Line2;
local dayoffset, weekoffset;
local Simple;



function getInstrumentList(First, Second)
    local list={};
	local point={};
	local position1={};
	local position2={};
	
    local count = 0;	
    local row, enum;	
	
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
	
	    first, second= string.match( row.Instrument, pauto);   
		
		if (second== First or first== First or first== Second or second== Second)
		and not (First~= first and second~= Second)
		then
        count = count + 1;
        list[count] = row.Instrument;
		point[count] = row.PointSize;
		
		if First==first then
		position1[count]=1;
		elseif First==second then
		position1[count]=2;
		end
		
		if Second==first then
		position2[count]=1;
		elseif Second==second then
		position2[count]=2;
		end
		
        end
		
		row = enum:next();
		
    end
	
	 
    return list, count,point,position1,position2;
end




-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

	
	Simple= instance.parameters.Simple;
	
	dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
   
	 
	source = instance.source; 
	 
	local First, Second= string.match( source:instrument(), pauto); 
 
	
	          Pair, Count,Point,Position1,Position2 = getInstrumentList(First, Second);
 
	

	local ID=0;
	Color= instance.parameters.Color; 
	
	 
	  
	 for i = 1, Count, 1 do	
	 

		 
		    ID=ID+1;  
			
			 
			 
		   Source[i]= core.host:execute("getSyncHistory", Pair[i], source:barSize(), source:isBid(),1,20000 + ID , 10000 +ID);
		   loading [i]=true;
		   
 
		    		  
		
	 end 
	  

	  
	Line1 = instance:addStream("Line1", core.Line, name .. First, First, instance.parameters.color1 ,source:first());
    Line1:setPrecision(math.max(2, instance.source:getPrecision()));
    Line1:setWidth(instance.parameters.width1);
    Line1:setStyle(instance.parameters.style1);
	
	Line2 = instance:addStream("Line2", core.Line, name .. Second, Second, instance.parameters.color2 ,source:first());
    Line2:setPrecision(math.max(2, instance.source:getPrecision()));
    Line2:setWidth(instance.parameters.width2);
    Line2:setStyle(instance.parameters.style2);
   
end



-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)


 local i ;
 local ID=0;
 
		 for i = 1, Count, 1 do	
		  
			  ID=ID+1;
			  if cookie == ( 10000 +  ID) then
			  loading[i] = true;
		      elseif  cookie == (20000+ ID) then
			  loading[i] = false;  
			  end
			  
		     
          end

	
	
    local FLAG=false; 
	local Number=0;
	
	for i = 1, Count, 1 do
	

                 if loading [i] then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
       
    end
	

	
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..(Count - Number) .. " / " ..  Count );	 
	else
	core.host:execute ("setStatus", "Loaded") 
	instance:updateFrom(0);	
	end
   
        
    return core.ASYNC_REDRAW ;
end





-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period) 


     if period < source:first() then
 return
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

	
	local Value1=0;
	local Count1=0;
	
	local Value2=0;
	local Count2=0;
   
    local p={};
    for i = 1, Count, 1 do	
			p[i]=Initialization(i, period);	
			
			
			if p[i]~= false and Source[i].close:hasData(p[i]) then
			
			
			
			
			            if Simple then
				
							 if  Position1[1]==1  or   Position1[2]==2 then
							 Value1= Value1+Source[i].close[p[i]];
							 Count1=Count1+1;
							 end
							 
							 
							 if Position2[1]==1  or   Position2[2]==2 then
							 Value2= Value2+Source[i].close[p[i]];
							 Count2=Count1+1;
							 end
						else

						     if  Position1[1]==1 then
							 Value1= Value1+Source[i].close[p[i]];
							 Count1=Count1+1;
							 elseif  Position1[1]==2 then
							 Value1= Value1+(1/Source[i].close[p[i]]);
							 Count1=Count1+1;
							 end
							 
							 
							 if Position2[1]==1  then
							 Value2= Value2+Source[i].close[p[i]];
							 Count2=Count1+1;
							 elseif   Position2[2]==2 then
							 Value2= Value2+(1/Source[i].close[p[i]]);
							 Count2=Count1+1;
							 end
							 
						
						
                        end						
			 
			end
	 
	end
	
	
	
	
	if Count1~=0 then
	Line1[period]= Value1/Count1;
	end
	
	if Count2~=0 then
	Line2[period]= Value2/Count2;
	end
	 
end

function   Initialization(id, period)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset);

  
    if loading[id] or Source[id]:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(Source[id], Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	

 