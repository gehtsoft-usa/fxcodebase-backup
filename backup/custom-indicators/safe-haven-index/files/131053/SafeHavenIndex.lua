-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69372

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
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


-- Indicator profile initialization routine

function Init()
    indicator:name("Safe Haven Index");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 50, 2, 2000);
     indicator.parameters:addInteger("Smoothing", "Smoothing Period", "", 7, 2, 2000);
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
--	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
  --  indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
--indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period; 
local first;
local source = nil;
local Smoothing;
local Oscillator;  

local dayoffset, weekoffset;
local Source={};
local loading={};
local Instrument={"USD/JPY", "USD/CHF", "EUR/USD"};
local Point={};
local Raw;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period= instance.parameters.Period;
	Smoothing= instance.parameters.Smoothing;
	
	
	local Parameters= Period .. ", ".. Smoothing;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first()+Period;
	
	
	
	dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
  

	
	 Raw= instance:addInternalStream(0, 0);
     PreSmoothing= instance:addInternalStream(0, 0); 
	
	for i= 1, 3, 1 do
	Source[i] = core.host:execute("getSyncHistory", Instrument[i], source:barSize(), source:isBid(), math.min(300,first), 100+i, 200+i);
	loading[i]=true;
	Point[i]= core.host:findTable("offers"):find("Instrument", Instrument[i]).PointSize;	
	end

 
	Oscillator = instance:addStream("Oscillator" , core.Bar, " Oscillator"," Oscillator",instance.parameters.color, first +Smoothing);
	--Oscillator:setWidth(instance.parameters.width);
    --Oscillator:setStyle(instance.parameters.style);
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

 
	if period < source:first() 
	then
	return;
	end
	
	local p={};
	
	for i= 1, 3, 1 do
	p[i] =  Initialization(i,period);
    end

	
     
	if p[1]==false or p[2]==false  or p[3]==false   then
	return;
	end

		
     Raw[period]=0;
	 
	 
	 
	 for i=1, 3, 1 do
	 
	     if Source[i].close:hasData(p[i]) then
			 if i==1 or i== 2 then
			 Raw[period]= Raw[period]-(Source[i].close[p[i]] -Source[i].open[p[i]] )/Point[i];		
			 else
			 Raw[period]= Raw[period]+(Source[i].close[p[i]] -Source[i].open[p[i]] )/Point[i];		
			 end	
         end		 
	 end
	 
	 
	 
	 if period < first
	then
	return;
	end
	
    PreSmoothing[period]=mathex.sum(Raw, period-Period+1, period);
	
	
	 if period < first + Smoothing
	then
	return;
	end
	
	
	Oscillator[period]= mathex.sum( PreSmoothing, period-Smoothing+1, period);
				  
end




-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 101 then
        loading[1] = false;        
    elseif cookie == 201 then
        loading[1] = true;
    end
	
	if cookie == 102 then
        loading[2] = false;        
    elseif cookie == 202 then
        loading[2] = true;
    end
	
    if cookie == 103 then
        loading[3] = false;        
    elseif cookie == 203 then
        loading[3] = true;
    end
	
	
	if not loading[1] and  not loading[2]  and  not loading[3]   then
	instance:updateFrom(0);
	end
end
