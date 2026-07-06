-- More information about this indicator can be found at:
-- http://fxcodebase.com/ 
 
--+------------------------------------------------------------------+
--|                               Copyright © 2021, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Generic Instrument");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 

    indicator.parameters:addGroup("Calculation");
	
	indicator.parameters:addString("Type" , "Type", "", "Value");
indicator.parameters:addStringAlternative("Type" , "Value", "", "Value");
indicator.parameters:addStringAlternative("Type" , "Pip", "", "Pip");

     indicator.parameters:addGroup("Selection");
    Add(1, true, false, 160, "TSLA.us" );
	Add(2, true, false, -10 , "XAU/USD");
	Add(3, true, false, -100 , "NGAS" );
	Add(4, false, false, 1, "EUR/USD"    );
	Add(5, false, false, 1, "EUR/USD"    );
	Add(6, false, false, 1, "EUR/USD"    );
	Add(7, false, false, 1, "EUR/USD"   );
	Add(8, false, false, 1, "EUR/USD"    );
	Add(9, false, false, 1 , "EUR/USD"   );
	Add(10, false, false, 1 , "EUR/USD"   );
 
 

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Line color", "Line Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

function Add(id, use,  inverse, value, Instrument)
indicator.parameters:addGroup(id.. ". Component");
indicator.parameters:addBoolean("Use".. id, "Use this slot", "", use);
indicator.parameters:addBoolean("Inverse".. id, "Inverse", "", inverse);
indicator.parameters:addDouble("Value".. id, "Value", "", value);  

	indicator.parameters:addString("Instrument" .. id, "Instrument", "", Instrument);
    indicator.parameters:setFlag("Instrument" .. id, core.FLAG_INSTRUMENTS);
end

local dayoffset;
local weekoffset;
local Type;
local Inverse={};
local Value={};
local first;
local Stream;
local Number;
local Instrument={};
local loading={};
local Source={};
local Point={};
local PipCost={};
function Prepare(onlyName)
    source = instance.source;
	first=source:first();
    Type=instance.parameters.Type;
	
    Number=0;
	 
	 for i= 1 , 10 , 1 do 
		 if instance.parameters:getBoolean("Use" .. i) then	 
		 Number=Number+1;	 
		 Inverse[Number]=instance.parameters:getBoolean("Inverse" .. i);	
		 Value[Number]=instance.parameters:getDouble("Value" .. i);
		 Instrument[Number]=instance.parameters:getString("Instrument" .. i);
		 end
	 end
	 
	local name; 
    name = profile:id();
    instance:name(name);
	
    if onlyName then
        return ;
    end
	
	dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
    
  
    for i= 1 , Number , 1 do	
    Source[i] = core.host:execute("getSyncHistory", Instrument[i], source:barSize(), source:isBid(),0, i*100, i*100+1);
	loading[i]=true;
	
	
	Point[i]= core.host:findTable("offers"):find("Instrument", Instrument[i]).PointSize;	
	PipCost[i]   = core.host:findTable("offers"):find("Instrument", Instrument[i]).PipCost;	
	end

    Stream = instance:addStream("Stream", core.Line, name .. ".Stream", "Stream", instance.parameters.color, first);
    Stream:setWidth(instance.parameters.width);
    Stream:setStyle(instance.parameters.style);

    
end

function Update(period, mode)


    if period< first then
	return;
	end
	
	local Price;
	
	 Stream[period]=0;
	 
	for i= 1 , Number , 1 do	
 
		       p=  Initialization(i, period) 
			   
			   
			   
			   if p~= false then
		       if Type== "Value"	then		 
			   Price=(Source[i][p]/Point[i])*PipCost[i] ;	
			   else
			   Price=(Source[i][p]/Point[i]) ;	
			   end
			   

            
    
			
						if not Inverse[i] then
						Stream[period]= Stream[period] + Price*Value[i];
						elseif Inverse[i] then
						Stream[period]= Stream[period] - Price*Value[i];		
						end
						
		      end
		
		 
	
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




-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
  
  
    local Flag=true;

   for i= 1 , Number , 1 do	
		if cookie == 100*i then
			loading[i] = false;        
		elseif cookie == 100*i+1 then
			loading[i] = true;
		end
	end
	
	
	 for i= 1 , Number , 1 do	
	   if loading[i] then
	   Flag=false;
	   end
	 end
	 
	if Flag then
	instance:updateFrom(0);
	end
	
	
	  return core.ASYNC_REDRAW ;
end

