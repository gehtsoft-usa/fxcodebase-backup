-- Id: 3391
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3696

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("InBarMotion");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("SignalPeriod", "SignalPeriod", "", 15);
 
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP", "Color for UP", "Color for UP", core.rgb(0,255,0));
    indicator.parameters:addColor("DN", "Color for DN", "Color for DN", core.rgb(255,0,0));
    indicator.parameters:addColor("SignalClr", "Color for Signal line", "Color for Signal line", core.rgb(255,255,0));
end

local source;                   -- the source
local bf_data = nil;          -- the high/low data
local BS;
local bf_length;                 -- length of the bigger frame in seconds
local dates;                    -- candle dates
local host;
local day_offset;
local week_offset;
local extent;
local up;
local down;
local InBarMotion;
local Signal=nil;
 
local SignalPeriod;
local first;
local  SourceData={};
local loading={};
local Count;
local TF={"m1","m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"}
function Prepare(nameOnly)
    source = instance.source;
    host = core.host;
    first=source:first();
    local name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end

    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");
    
     s1, e1 = core.getcandle(source:barSize(), core.now(), 0, 0);
   
     
    SignalPeriod = instance.parameters.SignalPeriod;
     
	 Count=0;
    for i= 1, 13, 1 do
	 s2, e2 = core.getcandle(TF[i], core.now(), 0, 0); 
		if (e1-s1) > (e2-s2) then
		Count=Count+1;
		 
		SourceData[Count]=  core.host:execute("getSyncHistory", source:instrument(), TF[i], source:isBid(), 0 , 20000 + Count , 10000 + Count);
		loading[Count]= true;
		end
	end
    InBarMotion = instance:addStream("InBarMotion", core.Bar, name .. ".InBarMotion", "InBarMotion", instance.parameters.UP, first);
    InBarMotion:setPrecision(math.max(2, instance.source:getPrecision()));
    Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.SignalClr, 0);
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
end


 

-- the function which is called to calculate the period
function Update(period, mode)

    local FLAG=false; 
	local Number=0;
	
	for j = 1, Count, 1 do
 	

                 if loading[j]  then
				 FLAG= true;
				 Number=Number+1;
				 end
		  	
    end
	
	if FLAG then
	return; 
	end
	
	InBarMotion[period]=0;
	
    for j = 1, Count, 1 do
	
	    p = core.findDate (SourceData[j], source:date(period), false)
	   if p > SourceData[j].close:first() then
			if SourceData[j].close[p]>SourceData[j].open[p] then
			InBarMotion[period]=InBarMotion[period]+1;
			else
			InBarMotion[period]=InBarMotion[period]-1;
			end
		end
	end


	if InBarMotion[period]> 0 then
	InBarMotion:setColor(period, instance.parameters.UP);
	else
	InBarMotion:setColor(period, instance.parameters.DN);
	end
	
	 if period>first+SignalPeriod then
     Signal[period]=mathex.avg(InBarMotion,period-SignalPeriod+1, period);
	 end
    
end


function AsyncOperationFinished(cookie)

	
	local i,j;
    
    for j = 1, Count, 1 do
		  
			  if cookie == (10000 + j) then
			  loading[j] = true;
		      elseif  cookie == (20000 + j) then
			  loading[j]  = false;     
			  
			  end
		 
	end    
	
	
	
    local FLAG=false; 
	local Number=0;
	
	for j = 1, Count, 1 do
 	

                 if loading[j]  then
				 FLAG= true;
				 Number=Number+1;
				 end
		  	
    end
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Count ) - Number) .. " / " .. (Count) );	 
	 else
	  core.host:execute ("setStatus", "  Loaded "..((Count ) - Number) .. " / " .. (Count) );
       instance:updateFrom(0);	  
	end
   
        
    return core.ASYNC_REDRAW ;
end










 