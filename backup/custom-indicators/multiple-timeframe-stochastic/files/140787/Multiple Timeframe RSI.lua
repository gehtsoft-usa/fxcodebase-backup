-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70592

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
    indicator:name("Multiple RSI");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 21, 1, 2000);
	
 
	
	indicator.parameters:addString("TF1", "1. Time Frame", "", "m30");
	indicator.parameters:setFlag("TF1", core.FLAG_PERIODS);
	
	indicator.parameters:addString("TF2", "2. Time Frame", "", "H1");
	indicator.parameters:setFlag("TF2", core.FLAG_PERIODS);
	
	
	indicator.parameters:addString("TF3", "3. Time Frame", "", "H8");
	indicator.parameters:setFlag("TF3", core.FLAG_PERIODS);
	
	
	indicator.parameters:addString("TF4", "4. Time Frame", "", "D1");
	indicator.parameters:setFlag("TF4", core.FLAG_PERIODS);
	
     
	indicator.parameters:addString("TF5", "5. Time Frame", "", "W1");
	indicator.parameters:setFlag("TF5", core.FLAG_PERIODS);
	
	
	indicator.parameters:addString("TF6", "6. Time Frame", "", "M1");
	indicator.parameters:setFlag("TF6", core.FLAG_PERIODS);
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Buy Pressure Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addColor("color2", "Buy Pressure Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("OB", "OB Level","", 75);
	indicator.parameters:addDouble("OS", "OS Level","", 25); 
 	
	
	
	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period ; 
local first;
local source = nil;
 
local BuyPressure, SellPressure;  
local Indicator={};
local Source={};
local loading={};
local  TF={  };
local dayoffset, weekoffset;
local Number;
local OB,OS;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period= instance.parameters.Period; 
	OB= instance.parameters.OB;
	OS= instance.parameters.OS;
	
	TF[1]= instance.parameters.TF1;
	TF[2]= instance.parameters.TF2;
	TF[3]= instance.parameters.TF3;
	TF[4]= instance.parameters.TF4;
	TF[5]= instance.parameters.TF5;
	TF[6]= instance.parameters.TF6;
	
	local Parameters= Period ;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");   
			
    source = instance.source; 
    first=source:first();
	
	assert(core.indicators:findIndicator("RSI") ~= nil, "Please, download and install RSI.LUA indicator"); 
	
	s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    
	Number=0;
   
	for i= 1, 6, 1 do
	
	 s2, e2 = core.getcandle(TF[i], 0, 0, 0);
	 
	 
			if (e1 - s1) <= (e2 - s2) then			 
			Number=Number+1;
			Source[Number] = core.host:execute("getSyncHistory", source:instrument(), TF[i], source:isBid(), math.min(300,Period), 100*Number, 100*Number+1);
			loading[Number]=true;
			
			Indicator[Number] = core.indicators:create("RSI", Source[Number], Period);
			end
	end
	
   
 
	BuyPressure = instance:addStream("BuyPressure" , core.Line, " BuyPressure"," BuyPressure",instance.parameters.color1, first) ;
	BuyPressure:setWidth(instance.parameters.width1);
    BuyPressure:setStyle(instance.parameters.style1);
    BuyPressure:setPrecision(math.max(2, source:getPrecision())); 
	
	SellPressure = instance:addStream("SellPressure" , core.Line, " SellPressure"," SellPressure",instance.parameters.color2, first) ;
	SellPressure:setWidth(instance.parameters.width2);
    SellPressure:setStyle(instance.parameters.style2);
    SellPressure:setPrecision(math.max(2, source:getPrecision()));
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

    local Flag=false;
	BuyPressure[period]= 0;
	SellPressure[period]= 0;		
	
	if period < source:first()  
	then
	return;
	end
	
	local p={};
	for i= 1, Number, 1 do
	   p[i] =  Initialization(i, period) 
	   Indicator[i]:update(mode); 

       if  p[i] ~= false then
	     if Indicator[i].DATA[p[i]]> OB then
         BuyPressure[period]=BuyPressure[period]+1;
		 end
		  if Indicator[i].DATA[p[i]]< OS then
		 SellPressure[period]=SellPressure[period]+1;
		 end
	   end	   
	   
	   
	end
  		  
end



-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
   
   
   local Flag=false;
   for i= 1, Number, 1 do
	   if cookie == 100*i then
			loading[i] = false;
		elseif cookie  == 100*i+1 then
			loading[i] = true;
			Flag=true;
		end
	end
	
	
	
	
	if not Flag then	
        instance:updateFrom(0);
	end
end

 
