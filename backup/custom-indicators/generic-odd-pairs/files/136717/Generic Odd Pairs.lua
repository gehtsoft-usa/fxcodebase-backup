-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70273

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
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


-- Indicator profile initialization routine

function Init()
    indicator:name("Generic Odd Pairs");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    
 
	
	indicator.parameters:addString("Instrument1", "1. Instrument", "", "XAU/USD");
    indicator.parameters:setFlag("Instrument1" , core.FLAG_INSTRUMENTS);
	
	indicator.parameters:addString("Instrument2" , "2. Instrument", "", "XAG/USD");
    indicator.parameters:setFlag("Instrument2" , core.FLAG_INSTRUMENTS);
	
	
	indicator.parameters:addBoolean("InverseAll" , "Inverse", "", false);	
	
	
	local Default={"USD", "EUR", "GBP","JPY", "CHF",  "AUD", "NZD", "CAD"};
	indicator.parameters:addString("Default", "Index  Default", "", "USD");
	for i= 1, 8, 1 do
    indicator.parameters:addStringAlternative("Default", Default[i], Default[i],Default[i]);
    end
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local InverseAll;
local Default; 
local first;
local source = nil;
local loading={};
local Source={};
local Oscillator;  
local dayoffset, weekoffset;
local Instrument={};
local pdate = "(%a%a%a)/(%a%a%a)";
local Inverse={};
-- Routine
 function Prepare(nameOnly)   
 
 
    InverseAll= instance.parameters.InverseAll;
	Instrument[1]= instance.parameters.Instrument1;
	Instrument[2]= instance.parameters.Instrument2;
	Default= instance.parameters.Default;
	
	
	local Parameters= Default;
	local Label={};
	  local First, Second;
	
	for i= 1,2, 1 do
	   First, Second= string.match( Instrument[i], pdate);
	  
		if not (First== Default or Second== Default)  then
		error( i.. ". Instrument " ..Instrument[i] .. " does not contain ".. Default);
		
		else
			 if First== Default then
			 Label[i]=Second;
			 elseif Second== Default then
			 Label[i]=First;
			 end
		
		end
	 end 	
		
 
    local name;
    
	if InverseAll then
	name= profile:id() .. "(" ..  Label[2] ..  " / " ..  Label[1] .. ")";
	else
	name= profile:id() .. "(" ..  Label[1] ..  " / " ..  Label[2] .. ")";
	end
    instance:name(name); 
	
	
	dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
			
    source = instance.source; 
    first=source:first() ;
	


    if   (nameOnly) then
        return;
    end

  
  
	
	for i= 1,2, 1 do
	
	  First, Second= string.match( Instrument[i], pdate);
	  
		 
		Source[i] = core.host:execute("getSyncHistory", Instrument[i], source:barSize(), source:isBid(), math.min(300 ), 100*i, 100*i+1); 
		loading[i]=true;
		 
		
		
		if First== Default then
		Inverse[i]=true;
		else
		Inverse[i]=false;
		end
	end
	 
 
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first);
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
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


-- Indicator calculation routine
function Update(period, mode)




    if  loading[1] or  loading[2] then
	return;
	end

 
	if period < source:first()  
	then
	return;
	end
	
	
	local p1=Initialization(1,period);
	local p2=Initialization(2,period);
	
	if not p1 or not p2 then
	return;
	end
	
	local Part1, Part2;
	
	if not Inverse[1] then
	Part1=Source[1].close[p1];
	else
	Part1=1/Source[1].close[p1];
	end
	
	
	if not Inverse[2]  then
	Part2=Source[2].close[p2];
	else
	Part2=1/Source[2].close[p2];
	end
 
    Oscillator[period]= Part1/Part2;
	
	if InverseAll then
	  Oscillator[period]=  1/Oscillator[period];
	end

				  
end





-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading[1] = false;       
    elseif cookie == 101 then
        loading[1] = true;
    end
	
	 if cookie == 200 then
        loading[2] = false;       
    elseif cookie == 201 then
        loading[2] = true;
    end
	  
	  if not loading[1] and  not loading[2] then
      instance:updateFrom(0);	 
	 end
	 
	 
	  return core.ASYNC_REDRAW ;
end
