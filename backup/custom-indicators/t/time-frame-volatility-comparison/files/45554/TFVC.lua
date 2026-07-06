-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=26549

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


function AddParam(id, frame )


    indicator.parameters:addGroup(id.. ". Time Frame");
	 
	
	indicator.parameters:addBoolean("USE".. id, "Use this Slot", "", true);	
	
    indicator.parameters:addString("TF" .. id,  "Time frame", "", frame);
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);
	
	indicator.parameters:addString("Pair" .. id, "Pair", "", "EUR/USD");
    indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS);

end


function Init()
    indicator:name("Time Frame Volatility Compariso");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
    indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addBoolean("Chart" , "Use Chart Price Source", "", true); 
	
	indicator.parameters:addString("Type", "Price Type", "", "Open/Close");
    indicator.parameters:addStringAlternative("Type", "Open/Close", "", "Open/Close");
    indicator.parameters:addStringAlternative("Type", "High/Low", "", "High/Low");
	indicator.parameters:addBoolean("Rainbow", "Use Rainbow Coloring", "", true);
	indicator.parameters:addBoolean("Show", "Show Values", "", true);
	
	
		indicator.parameters:addString("Method", "Projection Time Frame", "Method" , "Chart");
    indicator.parameters:addStringAlternative("Method", "Chart", "Chart" , "Chart");
	local TF={"m1","m5","m15","m30","H1","H2","H3","H4","H6","H8" ,"D1","W1","M1"};
	local i;
	for i= 1, 13 , 1 do
    indicator.parameters:addStringAlternative("Method", TF[i], TF[i] , TF[i]);
	end
	
	
	
    AddParam(1, "m1");	
    AddParam(2, "m5");	
    AddParam(3, "m15");	
    AddParam(4, "m30");
    AddParam(5, "H1");
	AddParam(6, "H2");	
    AddParam(7, "H3");	
    AddParam(8, "H4");	
    AddParam(9, "H6");
    AddParam(10, "H8");
	AddParam(11, "D1");	
    AddParam(12, "W1");
    AddParam(13, "M1");
	
	
    indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addDouble("CSize", "As % of Cell", "", 90);
	indicator.parameters:addDouble("Shift", "Vertical Shift", "", 25);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
    local UP, DN, NO;
	local source = nil;
	local TF={};
	local Pair={};
	local L={};	
	local host;
	local offset;
	local weekoffset;
	local SourceData={};
	local loading={};  
	local Max={ };
	local Lab={ };
	local  xPair={};
	local CSize;
	local Shift;
	local Size={};
	local USE={};
	local Count=13;
    local Number;
	local Chart ;
	local Label;
    local Out={};
   local Rainbow, Type,Method;
    	local TF={"m1","m5","m15","m30","H1","H2","H3","H4","H6","H8" ,"D1","W1","M1"};
   local Show;
   

function Convert (value)

	if value == "m1" then
	return 1 ;
	elseif value == "m1" then
	return 2 ;
	elseif value == "m5" then
	return 3 ;
	elseif value == "m30" then
	return 4 ;
	elseif value == "H1" then
	return 5 ;
	elseif value == "H2" then
	return 6 ;
	elseif value == "H3" then
	return 7 ;
	elseif value == "H4" then
	return 8 ;
	elseif value == "H6" then
	return 9 ;
	elseif value == "H8" then
	return 10 ;
	elseif value == "D1" then
	return 11 ;
	elseif value == "W1" then
	return 12 ;
	elseif value == "M1" then
	return 13 ;
	end 

end


--[[
function Sort(i)

  local j;
  local max=-1;
  local Flag=nil;
  
  for j = 1, 13 ,1 do
    
	   if max < Out[j] then
		  max = Out[j] ;
		  Flag = j;
	   end   
  
  end 
  
  if Flag == nil then
  Max[i]= 0;
  Lab[i]= "";
  return;
  end
  
  xPair[i]=Pair[Flag];
  Max[i]= Out[Flag];
  Lab[i]= TF[Flag];
  Out[Flag] =-1;

end]]


function Sort(i)

  local j;
  local max=-1;
  local Flag=nil;
  
  for j = 1, 13 ,1 do
    
	   if max < Out[j] then
		  max = Out[j] ;
		  Flag = j;
	   end   
  
  end 
  
  if Flag == nil then
  Max[i]= 0;
  Lab[i]= "";
  return;
  end
  
  
  Max[i]= Out[Flag];
  Lab[i]= TF[Flag];
  xPair[i]= Pair[Flag];
  Out[Flag] =-1;

end



function Calculate(i)



   if SourceData[i].close:hasData(SourceData[i].close:size()-1 ) then   
		if Type ==  "Open/Close" then
		Out[i] = math.abs (SourceData[i].close[SourceData[i].close:size()-1]- SourceData[i].open[SourceData[i].close:size()-1])   * ( Size[1]/Size[i] )  * ( Size[Num]/Size[1] ) ;
		else
		Out[i] =  (SourceData[i].high[SourceData[i].close:size()-1]- SourceData[i].low[SourceData[i].close:size()-1])   * ( Size[1]/Size[i] )  * ( Size[Num]/Size[1] ) ;
		end
   else
   Out[i]=0;
   end
	 
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

	
-- Routine
function Prepare(nameOnly)
    	
	Chart=instance.parameters.Chart;
    source = instance.source;
    Shift=instance.parameters.Shift;
	
	Rainbow=instance.parameters.Rainbow;
	Type=instance.parameters.Type;
	
	Label=instance.parameters.Label;
  --  Shift=instance.parameters.Shift;
    CSize=instance.parameters.CSize;
	Method=instance.parameters.Method;
	
	Show=instance.parameters.Show;
	
	 Out={};
	 
	 if Method == "Chart" then
	Method=source:barSize();
	end
	
	

    local i;
    local name = profile:id() .. "(" .. source:name() ;
	
	Number=0;
	
    for i = 1, Count, 1 do
	
	  
	
	    USE[i]=instance.parameters:getBoolean("USE" .. i);
		
		
	   
	     if USE[i]  then
		 Number=Number+1;
		 
		  
		 
		 		    
		    if  Chart   then		
		    Pair[Number]=source:name();	  
            else
            Pair[Number]= instance.parameters:getString("Pair" .. i);
		    end
	     
		
			
			  TF[Number]= instance.parameters:getString("TF" .. i);	
			  
		      s, e = core.getcandle(TF[Number], core.now(), 0, 0);
	          Size[Number]= e-s;
			 
		   
		   L[Number] = TF[Number] .. ", ".. Pair[Number];
		   name = name ..", " .."(" .. TF[Number] .. ", ".. Pair[Number] ..")";
		 
		 end   
		   
	  
    end
    name = name .. ")";
    instance:name(name);
   	
 	if   (nameOnly) then
        return;
    end
	
	
	
	Num = Convert(Method) ;
	
	 host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	

    for i = 1, Number, 1 do	
	
	    	--local Test = core.indicators:create("CCI", source ,10);   
	        --first= Test.DATA:first()*2 ; 	
	  
	  	
	    if (TF[i] == source:barSize() and   Pair[i] == source:name())     then
		SourceData[i]=source;
		loading[i]= false;
		else 	
	    SourceData[i] = core.host:execute("getSyncHistory", Pair[i], TF[i], source:isBid(),  1 , 200+i, 100+i);	   
		loading[i]= true;		
		end
		
		
		 
    end
    
	instance:ownerDrawn(true);
    core.host:execute ("setTimer", 1, 1);
end


function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 

function   Initialization(id,period)

    local Candle;
    Candle = core.getcandle(TF[id], source:date(period), offset, weekoffset);

  
    if loading[id] or SourceData[id]:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(SourceData[id], Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
 
	    
end




 
function Draw(stage, context)
    if stage ~= 2 then
	return;
	end
	 
	local Flag = false;	

	
	
	
    for j = 1, Number, 1 do			
		if loading[j] then	
		Flag=true;
		end	 
 
	end    
	
     	if Flag then
		return;
		end
		
	if Size[1]== nil then
	return;
	end
	
		 local color;
	 
      
	    local xCell = (context:right () -context:left ())/(Number+1);		
        local yCell = (context:bottom () -context:top ())/15;		    
		
		for i = 1, Number, 1 do 	
			
			
			  if Rainbow then
			  color = Coloring((100/13)*i, 50);
			  else
			  color= Label;
			  end
	  
						 
			 
					    
			        		
			context:createFont (1, "Arial", (xCell/12)*(CSize/100), yCell*(CSize/100), 0);	
           
			 width, height = context:measureText (1, tostring(xPair[i]), 0)			
			 context:drawText (1, tostring(xPair[i]), Label, -1, context:left ()+(i-1)*xCell    , context:top ()+Shift+yCell/4, context:left ()+(i-1)*xCell + width, context:top ()+Shift+yCell/4 + height, 0);
			 
			  width, height = context:measureText (1, tostring(Lab[i]), 0)				
		    context:drawText (1, tostring(Lab[i]), Label, -1, context:left ()+(i-1)*xCell    , context:top ()+Shift+yCell*(5/4), context:left ()+(i-1)*xCell + width, context:top ()+Shift+yCell*(5/4) + height, 0);
			
			if Show then
			local value =(Max[i]/ source:pipSize());
			  width, height = context:measureText (1, string.format("%." .. 4 .. "f", value ) , 0)				
		    context:drawText (1, string.format("%." .. 4 .. "f", value ) , color, -1, context:left ()+(i-1)*xCell    , context:top ()+Shift+yCell*(9/4), context:left ()+(i-1)*xCell + width, context:top ()+Shift+yCell*(9/4) + height, 0);
			end
			
			
		 end
	 
         		 
 
		
end

-- the function is called when the async operation is finished

function AsyncOperationFinished(cookie)

     local j;	 
	local Flag = false;	
	local Count=0;	
	
	
	
    for j = 1, Number, 1 do
		
			  if cookie == (100+j) then
			  loading[j] = true;
		      elseif  cookie == (200+j) then
			  loading[j] = false;  
			  instance:updateFrom(0);		 
              end
			  
		if loading[j] then
		Count=Count+1;
		Flag=true;
		end	 
 
	end    
	
     	if Flag then
		core.host:execute ("setStatus", " Loading ".. (Number-Count) .."/" .. Number);
		else
		core.host:execute ("setStatus", " Loaded ".. (Number-Count) .."/" .. Number);
		end
		
		
	if cookie== 1 and  not FLAG and Size[1]~=nil and Size[Number]~=nil  then
	
 
	 
	for i= 1, Number, 1 do
	Calculate(i);	 
	end
	
    for i= 1, Number, 1 do
	Sort(i );
    end	
   
   
   end
        
		return core.ASYNC_REDRAW ;
   
end

