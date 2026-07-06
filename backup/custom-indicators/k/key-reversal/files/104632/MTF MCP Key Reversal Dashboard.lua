-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63114


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
    indicator:name("MTF MCP Key Reversal Dashboard");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
    indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addBoolean("Chart" , "Use Chart Price Source", "", true); 
	
	indicator.parameters:addBoolean("Trend", "Use Trend Filter", "", true);
	indicator.parameters:addInteger("Period", "Trend Period", "", 2);
	
	
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
    indicator.parameters:addColor("UP", "Color for Up Trend", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DN", "Color for Down Trend", "", core.rgb(255, 0, 0));	
	indicator.parameters:addColor("NO", "Color for Unclear Trend", "", core.rgb(255, 128, 0));
	indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addDouble("Size", "As % of Cell", "", 90);
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
	local Source={};
	local loading={};  
	local Size;
	local USE={};
	local Count=13;
    local Number;
	local Chart ;
	local Label;
    local Period;
	local Trend;
	local Indicator={};
	local VerificationData={};
-- Routine
function Prepare(nameOnly)
    	
	Chart=instance.parameters.Chart;
    source = instance.source;
    UP=instance.parameters.UP;
	DN=instance.parameters.DN;
	NO=instance.parameters.NO;
	
	Label=instance.parameters.Label;
    Shift=instance.parameters.Shift;
    Size=instance.parameters.Size;
	
	Period=instance.parameters.Period;
	Trend=instance.parameters.Trend;
	
	
	
	 host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	
	

    local i;
    local name = profile:id() .. "(" .. source:name() ;
	
	    name = name .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	Number=0;
	
    for i = 1, Count, 1 do 
	
	    USE[i]=instance.parameters:getBoolean("USE" .. i);
		
		
	   
	     if USE[i]  then
		 Number=Number+1;
		 
		  
		 
		 		    
		    if  Chart   then		
		    Pair[Number]=source:instrument();	  
            else
            Pair[Number]= instance.parameters:getString("Pair" .. i);
		    end 
			
			  TF[Number]= instance.parameters:getString("TF" .. i);	 
		 
		 
		 end   
		   
	  
    end

   

    for i = 1, Number, 1 do	
	
	  
	    
	    Source[i] = core.host:execute("getSyncHistory", Pair[i], TF[i], source:isBid(),  math.min(300, Period+1) , 200+i, 100+i); 
		loading[i]= true;		
		 
		
		 
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
		
		
        local Symbol;
	    local xCell = (context:right () -context:left ())/(Number+1);		
        local yCell = (context:bottom () -context:top ())/14;		    
		local Color; 
		
		for i = 1, Number, 1 do 	
			
			 
			  
			   if VerificationData[i] == 1 then
			  Color=UP;
			  Symbol="\236";
			  elseif  VerificationData[i]  == -1 then
			  Color=DN;
			  Symbol="\238";
			  else
			  Color=NO
			  Symbol="\160";
			  end  
					    			        		
			context:createFont (1, "Arial", (xCell/10)*(Size/100), yCell*(Size/100), 0);
            context:createFont (2, "Wingdings", (xCell/2)*(Size/100), yCell*(Size/100), 0);				
			
             if not Chart then
			 width, height = context:measureText (1, tostring(Pair[i]), 0)			
			 context:drawText (1, tostring(Pair[i]), Label, -1, context:left ()+(i)*xCell    , context:top ()+yCell/4, context:left ()+(i)*xCell + width, context:top ()+yCell/4 + height, 0);
			 end
			 
			  width, height = context:measureText (1, tostring(TF[i]), 0)				
		     context:drawText (1, tostring(TF[i]), Label, -1, context:left ()+(i)*xCell    , context:top ()+yCell*(5/4), context:left ()+(i)*xCell + width, context:top ()+yCell*(5/4) + height, 0);
			 
			  width, height = context:measureText (2, Symbol, 0)				
		     context:drawText (2, Symbol, Color, -1, context:left ()+(i)*xCell    , context:top ()+yCell*(9/4), context:left ()+(i)*xCell + width, context:top ()+yCell*(9/4) + height, 0);
			
		 end 
end


function Verification(i)

   period=Source[i].close:size()-1;
  
  local Signal=0;
  if  Source[i].close[period]> Source[i].high[period-1]  then
  Signal=1;
  end
  
  if  Source[i].close[period]< Source[i].low[period-1]  then
  Signal=-1;
  end
   
  
  if not Trend then
  return Signal;
  end
  
  for j= 1, Period, 1 do
	  if Signal == 1
	  and Source[i].close[period-j] > Source[i].open[period-j] then
      Signal=0;
	  break;
	  end
	  
	  if Signal == -1
	  and Source[i].close[period-j] < Source[i].open[period-j] then
	  Signal=0;
	  break;
	  end
  end
  
  
  
  return Signal;
  
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
					 
              end
			  
		if loading[j] then
		Count=Count+1;
		Flag=true;
		end	 
 
	end    
	
	
	if not Flag and cookie == 1 then
	
     
		for i = 1, Number, 1 do 	
			
		
			  
			  VerificationData[i]= Verification(i) ;
		end	   
	end
	
     	if Flag then
		core.host:execute ("setStatus", " Loading ".. (Number-Count) .."/" .. Number);
		else
		core.host:execute ("setStatus", " Loaded ".. (Number-Count) .."/" .. Number);
		instance:updateFrom(0);
		end
   
        
		return core.ASYNC_REDRAW ;
   
end

