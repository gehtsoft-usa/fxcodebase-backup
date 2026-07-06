-- Id: 25345
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68585

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

function Init()
    indicator:name("Market Phase");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");   
 
	
	indicator.parameters:addInteger("SignalPeriod" , "SignalPeriod", "", 34, 1, 2000);
	
     Add(1, "Chart", 25, "MVA");
	 Add(2, "Chart", 50, "MVA");
	 Add(3, "Chart", 100, "MVA");
	 Add(4, "Chart", 200, "MVA");
  
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Bar Color", "", core.rgb(0, 255, 0));  
	indicator.parameters:addColor("Down", "Down Bar Color", "", core.rgb(255,  0, 0)); 
	
	 indicator.parameters:addColor("color", "Signal Line Color", "", core.rgb(0, 0, 255)); 
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

function Add(id, TF, Period, Method)



indicator.parameters:addGroup(id..". Slot");   

indicator.parameters:addBoolean("On".. id , "Show This Slot", "",true);	 
indicator.parameters:addBoolean("P1".. id , "Use Price/MA", "",true);	 
indicator.parameters:addBoolean("P2".. id , "Use MA/MA", "",true);	 

  local iTF={"m1","m5", "m15","H1","H2","H3","H4","H6","H8","D1","W1", "M1","Chart"};
	indicator.parameters:addString("TF".. id, "Time Frame", "", TF);
	
	for i = 1, 13, 1 do
	indicator.parameters:addStringAlternative("TF".. id, iTF[i], "", iTF[i]);
    end
	

indicator.parameters:addInteger("Period"..id, "Period", "", Period, 1, 2000);


indicator.parameters:addString("Method"..id, "MA Method", "Method" , "MVA");
indicator.parameters:addStringAlternative("Method"..id, "MVA", "MVA" , "MVA");
indicator.parameters:addStringAlternative("Method"..id, "EMA", "EMA" , "EMA");
indicator.parameters:addStringAlternative("Method"..id, "LWMA", "LWMA" , "LWMA");
indicator.parameters:addStringAlternative("Method"..id, "TMA", "TMA" , "TMA");
indicator.parameters:addStringAlternative("Method"..id, "SMMA", "SMMA" , "SMMA");
indicator.parameters:addStringAlternative("Method"..id, "KAMA", "KAMA" , "KAMA");
indicator.parameters:addStringAlternative("Method"..id, "VIDYA", "VIDYA" , "VIDYA");
indicator.parameters:addStringAlternative("Method"..id, "WMA", "WMA" , "WMA");
end


local weekoffset;
local dayoffset;
	
	
local TF={};
local Period={}; 
local Method={};  
local Source={}; 
local loading={};
local Indicator={};
local source = nil;
local Number;
local Oscillator;
local P1={};
local P2={};
local Signal;
local SignalPeriod;
-- Routine
 function Prepare(nameOnly) 
 
 
    source = instance.source; 
    first=source:first() ;
	
	dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	
 
    Number=0;
	
    for i= 1, 4 ,1 do
	   if  instance.parameters:getBoolean("On" .. i)  then
	   Number=Number+1;
	   Method[Number]=instance.parameters:getString("Method" .. i);	
	   TF[Number]=instance.parameters:getString("TF" .. i);	
	   if TF[Number] == "Chart" then
	   TF[Number]=source:barSize();
	   end
	   
	   Period[Number]=instance.parameters:getInteger("Period" .. i);	
	   P1[Number]=instance.parameters:getBoolean("P1" .. i);	
	   P2[Number]=instance.parameters:getBoolean("P2" .. i);	
	   end
	
	end
	
	
	SignalPeriod=instance.parameters.SignalPeriod;
 
    local name = profile:id() .. "(" ..  instance.source:name() .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
  
	local Id=0;
	 for i= 1, Number ,1 do
	
	   Id=Id+1;
				 Source[i]  = core.host:execute("getSyncHistory",  source:instrument(),  TF[i], source:isBid(),math.min(300,Period[i]*2), 2000 + Id , 1000 +Id);	 	 
				 loading[i]  = true;  	 
    assert(core.indicators:findIndicator(Method[i]) ~= nil, Method[i] .. " indicator must be installed");
				 Indicator[i] = core.indicators:create(Method[i], Source[i].close ,  Period[i]);  
	 end			 
	
	-- Average= instance:addInternalStream(0, 0);
   
 
	Oscillator = instance:addStream("Oscillator" , core.Bar, " Oscillator"," Oscillator",instance.parameters.Up, first );
    Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
	
	Signal = instance:addStream("Signal" , core.Line, " Signal"," Signal",instance.parameters.color, first );
	Signal:setWidth(instance.parameters.width);
    Signal:setStyle(instance.parameters.style);
    Signal:setPrecision(math.max(2, source:getPrecision()));
	
	
end


function   Initialization(id, period)

    local Candle;
    Candle = core.getcandle(TF[id], source:date(period), dayoffset, weekoffset);

  
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


if period < first then
return;
end


 
	local FLAG=false; 

    for j = 1, Number, 1 do
		     
                 if loading[j] 
				 then
				 FLAG= true;
				 end
				 
	end    
    
	
	if FLAG then
	return;	 
	end
   
     FLAG=false;  
	 
	local p={false,false,false,false};
	 for i= 1, Number , 1 do
	 p[i]= Initialization(i, period);
		 if p[i]== false  then
		 FLAG=true;
		 end
	 
	 end
	 
    
	 if FLAG then
	return;	 
	end
    
        for i= 1, Number , 1 do
			  Indicator[i]:update(mode );
			  
			  if Indicator[i].DATA:hasData(p[i]) and (i== 1 or Indicator[i-1].DATA:hasData(p[i-1]) ) then
				  if P1[i] then
					  if Source[i].close[p[i]] > Indicator[i].DATA [p[i]] then
					  Oscillator[period]= Oscillator[period]+1;
					  elseif Source[i].close[p[i]] < Indicator[i].DATA [p[i]] then
					  Oscillator[period]= Oscillator[period]-1;
					  end				  
				  end
				  
				   if P2[i]  and i >= 2 then
					  if Indicator[i-1].DATA [p[i-1]] > Indicator[i].DATA [p[i]] then
					  Oscillator[period]= Oscillator[period]+1;
					  elseif Indicator[i-1].DATA [p[i-1]] < Indicator[i].DATA [p[i]] then
					  Oscillator[period]= Oscillator[period]-1;
					  end				  
				  end
			  end
		end
		
		if period < source:first()+SignalPeriod then
		return;
		end
		
		Signal[period]= mathex.avg(Oscillator,period-SignalPeriod+1, period );
		
		if Oscillator[period] > Signal[period] then 
		Oscillator:setColor(period, instance.parameters.Up); 
		elseif Oscillator[period] < Signal[period] then
		Oscillator:setColor(period, instance.parameters.Down); 
		end
		
	 
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
   
 
	
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Number) - Num) .. " / " .. (Number) );	 
	else
	core.host:execute ("setStatus", "Loaded");	 
    instance:updateFrom(0);    
	end
	
	
   
        
    return core.ASYNC_REDRAW ;
	
	
end