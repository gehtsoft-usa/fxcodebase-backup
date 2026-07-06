-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69782

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Generic Lower Time Frame Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	
	T={"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"};
	

    indicator.parameters:addGroup("Indicator Selection");	
	indicator.parameters:addString("INDICATOR1", "Indicator", "", "");
    indicator.parameters:setFlag("INDICATOR1",core.FLAG_INDICATOR);
	indicator.parameters:addInteger("Number1", "Data Stream Number", "", 1, 1 , 100);
	
	indicator.parameters:addGroup("Selector");
	
	indicator.parameters:addString("Type", "Method", "Method" , "Lower");
    indicator.parameters:addStringAlternative("Type", "Lower", "Lower" , "Lower");
    indicator.parameters:addStringAlternative("Type", "Higher", "Higher" , "Higher");
	indicator.parameters:addStringAlternative("Type", "All", "All" , "All");
	indicator.parameters:addStringAlternative("Type", "Selection", "" , "Selection")
	
	local i;
	for i = 1, 13 ,  1 do 
	indicator.parameters:addBoolean("ON".. i, "Use " .. T[i] .. " Time Frame", "", false);
	end

	

	indicator.parameters:addGroup("Style");
	
	indicator.parameters:addBoolean("Bar", "Use Bars" ,   "", false);
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Dn", "Down color", "", core.rgb(255, 0, 0));

 
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;
local Period;
 local Type;

local SourceData = {} ;
local Indicator={};
local loading={};

local day_offset, week_offset;
 
local host;
local TF={};
local iTF={"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"};
local Up, Down;
local Bar;
local Number=0;

local Count1;
local INDEX={};
local INDICATOR1, Number1;
function Prepare(nameOnly) 
   
	Type= instance.parameters.Type;
	Bar= instance.parameters.Bar;
	Up= instance.parameters.Up;
	Down= instance.parameters.Dn;
	source = instance.source;
	first = source:first();
	
	
	INDICATOR1=instance.parameters.INDICATOR1;    
   	Number1=instance.parameters.Number1;
	Number1=Number1-1;
	

	
	host = core.host;
    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");
	
	Number=0;
	 
	local i;
	if Type == "Selection" then
		for i = 1, 13 , 1 do
		   if instance.parameters:getBoolean("ON" .. i) then
		   Number=Number+1;
		   TF[Number]=iTF[i]
		   end
		end
	elseif Type == "All" then	
	Number=13;
	TF=iTF;
	else
	
	    for i = 1, 13 ,  1 do
	     CheckBarSize(i);
	    end
	 
	end
	
	
	 
 
	
    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);	
	if   (nameOnly) then
        return;
    end
   
	
	
	if Bar then
	high = instance:addStream("high", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("low", core.Line, name, "", core.rgb(0, 0, 0), first);	
	open = instance:addStream("open", core.Line, name, "", core.rgb(0, 0, 0), first);    
    open:setPrecision(math.max(2, instance.source:getPrecision()));
    close = instance:addStream("close", core.Line, name, "", core.rgb(0, 0, 0), first);
    close:setPrecision(math.max(2, instance.source:getPrecision()));
    instance:createCandleGroup("STF", "STF", open, high, low, close);
   
   
    else
	high = instance:addStream("high", core.Line, name, "", Up, first);
    low = instance:addStream("low", core.Line, name, "", Down, first);	
	end
    high:setPrecision(math.max(2, instance.source:getPrecision()));
    low:setPrecision(math.max(2, instance.source:getPrecision()));
	
	
 
	 
	 
	 local iprofile1 = core.indicators:findIndicator(instance.parameters:getString("INDICATOR1"));
	 local iparams1 = instance.parameters:getCustomParameters("INDICATOR1");
	 
	
	 for i = 1, Number ,  1 do
	 SourceData[i]  = core.host:execute("getSyncHistory",  source:instrument(),  TF[i], source:isBid(),300, 2000 + i , 1000 +i);	 	 
	 loading[i]  = true;  	 
	 
	 
	
	
	
	   if  iprofile1:requiredSource() == core.Tick then			
			 Indicator[i] = iprofile1:createInstance(  SourceData[i].close, iparams1);
		else
			 Indicator[i] = iprofile1:createInstance( SourceData[i], iparams1);
		end
		
				
				 
				 Count1= Indicator[i]:getStreamCount ();
			 
				  
				 if Number1 >= Count1 then
				 Number1 = Count1;
				  assert( false, "Incorrect index of stream. The indicator has only ".. Count1  .. " stream(s).");
	              end
	 
	  
 
	 
	      INDEX[i]=  Indicator[i]:getStream (Number1);	
		  
		     

	 
		
	 
  
	 end	
core.host:execute ("setTimer", 1, 1);

		 
end


function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

 

local j;
local FLAG=false; 
local Num=0;
local Id=0;
    for j = 1, Number, 1 do
		      Id=Id+1;
			  if cookie == (1000 + Id) then
			  loading[j]  = true;
		      elseif  cookie == (2000 + Id ) then
			  loading[j]  = false;
			  end
		 
		       
                 if loading[j] then
				 FLAG= true;
				 Num=Num+1;
				 end
	end    
   
    
   if not FLAG and cookie== 1 then
		for i= 1, Number , 1 do
			  Indicator[i]:update(core.UpdateLast );
		end
		
	end
	
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Number) - Num) .. " / " .. (Number) );	 
	else
	core.host:execute ("setStatus", "Loaded");	 
     instance:updateFrom(0);    
	end
	
	
   
        
    return core.ASYNC_REDRAW ;
	
	
end


function CheckBarSize(id)
    local s, e, s1, e1;
    s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
    s1, e1 = core.getcandle(iTF[id], core.now(), 0, 0);  
    
	if Type == "Lower" then
		 if (e-s) > (e1-s1) then
	       Number=Number+1;
		   TF[Number]=iTF[id]
		 end 
	elseif Type == "Higher" then
	
		 if (e-s) < (e1-s1) then
		   Number=Number+1;
		   TF[Number]=iTF[id]
		 end 
    end	
	 
end


function   Initialization(period,id)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), day_offset, week_offset);
  
    if loading[id] or SourceData[id]:size() == 0  then
        return false;
    end

    
    if period < source:first() then
        return false;
    end

    local P = core.findDate(SourceData[id], Candle, false);
	 

    -- candle is not found
    if P < 0    then
        return false;
	else return P;	
    end
			
end	




-- Indicator calculation routine
function Update(period, mode)


 
local FLAG=false; 
 
    for j = 1, Number, 1 do 
		       
                 if loading[j] then
				 FLAG= true; 
				 end
	end    
   
   
   if FLAG then
   return;
   end
   
   
	                            if Bar then
	                            open[period] = 0;
								close[period] = 0;
								end
								
								high[period] = 0;
								low[period] = 0;
	
	
 
 

    for i = 1, Number, 1 do
	
	     
			
 
					
					
						p = Initialization(period, i);		
			
				
				if  p~= false and p>0  then
					
				
							if INDEX[i]:hasData(p) then 
							
							 
										
											if high[period]== 0   or   low[period]== 0  then	
														
												high[period] = INDEX[i][p] ;
												low[period] = INDEX[i][p];
												
												
											else
											   
													if  INDEX[i][p] > high[period] then
													high[period] = INDEX[i][p];
													end
													if  INDEX[i][p] < low[period] then
													low[period] = INDEX[i][p];
													end													
												
												
											end							
								
								end
							
							 
							
				end
		end		
 
   
   if not Bar then
   return;
   end
   
   
   
       if source.close[period] > source.open[period] then
	     open[period] = low[period];
		 close[period] = high[period];
		 open:setColor(period, Up);
	   else	
         open[period] = high[period];
		 close[period] = low[period];
         open:setColor(period, Down);					 
	   end  

		
 end
 

