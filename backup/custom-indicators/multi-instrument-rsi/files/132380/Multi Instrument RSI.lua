-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69594

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--+------------------------------------------------------------------+
function Init()
    indicator:name("Multi Instrument RSI");
    indicator:description("Multi Instrument RSI");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	   
  
  
    indicator.parameters:addGroup("Caclulation");	
    indicator.parameters:addInteger("Period", "Period", "", 14);
	indicator.parameters:addBoolean("Inverse", "Inverse", "Inverse", false);
	
	indicator.parameters:addGroup("Selector");	
    local i;
	local Default={"USD", "EUR", "GBP","JPY", "CHF",  "AUD" , "CAD"};
	indicator.parameters:addString("Default", "Index  Default", "", "USD");
	for i= 1, 7, 1 do
    indicator.parameters:addStringAlternative("Default", Default[i], Default[i],Default[i]);
    end
	
	 
end


 
local loading={};
local SourceData={};
local Instrument;
 
local Num;
local Period;
local InverseValue; 
 
local Default;
local pdate = "(%a%a%a)/(%a%a%a)";
 local Inverse={};
local RSI={};
local USD={"EUR/USD", "USD/JPY", "GBP/USD", "USD/CHF", "USD/CAD", "AUD/USD"};
local EUR={"EUR/USD", "EUR/JPY", "EUR/GBP", "EUR/CHF", "EUR/CAD", "EUR/AUD"};
local GBP={"GBP/USD", "GBP/JPY", "EUR/GBP", "GBP/CHF", "GBP/CAD", "GBP/AUD"};
local CHF={"USD/CHF", "CHF/JPY", "GBP/CHF", "EUR/CHF", "CAD/CHF", "AUD/CHF"};
local CAD={"USD/CAD", "CAD/JPY", "GBP/CAD", "EUR/CAD", "CAD/CHF", "AUD/CAD"};
local AUD={"EUR/AUD", "AUD/JPY", "GBP/AUD", "AUD/CHF", "AUD/CAD", "AUD/USD"}; 
local JPY={"EUR/JPY", "USD/JPY", "GBP/JPY", "AUD/JPY", "CAD/JPY", "CHF/JPY"}; 

	
local open, high, low, close;
local dayoffset,weekoffset;

function Prepare(nameOnly)      
	
    source = instance.source;
	Default = instance.parameters.Default;
	Period= instance.parameters.Period; 
	InverseValue= instance.parameters.Inverse; 
	 
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	
    local name =  "(" .. profile:id() .. ","  .. instance.source:name().. ","  .. source:barSize().. ")"
	instance:name(name);
	
	if   (nameOnly) then
        return;
    end
		
 
	Num=5;
 
	if Default== "USD" then
	Instrument=USD;
	elseif Default== "EUR" then
	Instrument=EUR;
	elseif Default== "JPY" then
	Instrument=JPY;
	elseif Default== "GBP" then
	Instrument=GBP;
	elseif Default== "CHF" then
	Instrument=CHF;
	elseif Default== "CAD" then
	Instrument=CAD;
	elseif Default== "AUD" then
	Instrument=AUD;
	end
	
		
	local i;
			 
		 for i = 1, Num, 1 do	
		 
		 
		       InstrumentFlag = core.host:findTable("offers"):find("Instrument", Instrument[i]);
            	assert(InstrumentFlag ~= nil, "Subscribed to " ..  Instrument[i] );    
	
			   SourceData[i] = core.host:execute("getSyncHistory", Instrument[i], source:barSize(), source:isBid(), 0  ,20000 +i , 10000 + i);
			   loading[i] = true;  
			  
			   RSI[i] = core.indicators:create("RSI", SourceData[i].close, Period);

		end
 
		for j = 1, Num, 1 do		

		First, Second= string.match( Instrument[j], pdate);
		
              if First== Default then
			   Inverse[j]=0;
			  else
			  Inverse[j]=1;
			  end
		end	  
			  
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), source:first())
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), source:first())
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), source:first())
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), source:first())
    instance:createCandleGroup("ZONE", "", open, high, low, close);
		 					  
	
	 

end




function Update(period,mode)

  if period < source:first()+Period then
  return
  end
 
  
  local p={};
     
    local FLAG=false;	
	local i;
	
		 for i = 1, Num, 1 do	

                 if loading[i] then
				 FLAG= true;				
				 end    
              RSI[i]:update(mode);	

             p[i] =  Initialization(i, period) 			  
         end
	
	if FLAG then 
	return;
	end
	
 
	local j;
	
						
			
    local min=100;
	local max=0;
	local avg=0;
	
			 
							  
	for j = 1, Num, 1 do
	
	    if p[j] ~= false then
			if Inverse[j]==0 then
			   min=math.min(min, RSI[j].DATA[p[j]]);
			   max=math.max(max, RSI[j].DATA[p[j]]);
			   avg=avg + RSI[j].DATA[p[j]];
			else
			
			   min=math.min(min, (100-RSI[j].DATA[p[j]]));
			   max=math.max(max, (100-RSI[j].DATA[p[j]]));
			   avg=avg + (100-RSI[j].DATA[p[j]]);
			
			end
		end
	
									 
	end						  
							  
							
						
                              							  
	if InverseValue then
	    open[period]=close[period-1] ;
		high[period]=100-max;
		low[period]=100-min;
		close[period]=100-(avg/Num);	
    else	
		open[period]=close[period-1] ;
		high[period]=max;
		low[period]=min;
		close[period]=avg/Num;	
	end
end


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)


 local i;
 

		 for i = 1, Num, 1 do	
			  if cookie == ( 10000 +  i) then
			  loading[i] = true;
		      elseif  cookie == (20000+ i) then
			  loading[i] = false;   
			  
			  end
		       
          end
	
	
	
    local FLAG=false; 
	local Number=0;
	
	
		 for i = 1, Num, 1 do	

                 if loading[i] then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
         end  	
    
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Num - Number) .. " / " .. (Num) ));	 
	else
	core.host:execute ("setStatus", "Loaded")
	instance:updateFrom(0);
	end
   
        
    return core.ASYNC_REDRAW ;
end



function   Initialization(id, period)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset);

  
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

