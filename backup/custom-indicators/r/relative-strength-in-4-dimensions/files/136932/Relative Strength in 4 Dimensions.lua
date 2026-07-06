-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70309

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
    indicator:name("Relative Strength in 4 Dimensions");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "Period", "", 10, 1, 2000);
    indicator.parameters:addInteger("Period2", "Fast Period", "", 7, 1, 2000);
	
    indicator.parameters:addInteger("Period3", "Medium Period", "", 15, 1, 2000);
	 indicator.parameters:addInteger("Period4", "Slow Slow Period", "", 30, 1, 2000);
	 
	  indicator.parameters:addInteger("Period5", "Output 1. MA Period", "", 3, 1, 2000);
	 indicator.parameters:addInteger("Period6", "Output 2. MA Period", "", 5, 1, 2000);
    
	indicator.parameters:addGroup("Add Instruments"); 
	
	Add(1, "EUSTX50");
	Add(2, "ESP35");
	Add(3, "NAS100");
	Add(4, "SPX500");
	Add(5, "HKG33");
	Add(6, "UK100");
	Add(7, "GER30");
	Add(8, "FRA40");
	Add(9, "CHN50");
	Add(10, "AUS200");
	Add(11, "JPN225");
	
	indicator.parameters:addGroup("1. Line Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addGroup("2. Line Style"); 	
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
end

function Add(id, Instrument)

  indicator.parameters:addString("Instrument" .. id, id .. ". Instrument", " Instrument", Instrument)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period={}; 
local first;
local source = nil;
local Instrument={};
local Oscillator;  
local SourceData={};
local loading={};
local Data={};
local Output={};
local Oscillator_Data1,Oscillator_Data2;
local dayoffset, weekoffset;
local FIRST;
local Fast={};
local Med={};
local Slow={};
local VSlow={};
-- Routine
 function Prepare(nameOnly)   
 
 
    for i= 1, 6, 1 do
    Period[i]= instance.parameters:getInteger("Period" .. i);
    end
	for i= 1, 11, 1 do
	Instrument[i]= instance.parameters:getString("Instrument" .. i);
	end
	
	
	
	local Parameters= Period[1]..", "..Period[2]..", "..Period[3]..", "..Period[4]..", "..Period[5]..", "..Period[6];
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    dayoffset = core.host:execute("getTradingDayOffset")
	weekoffset = core.host:execute("getTradingWeekOffset")
			
    source = instance.source; 
    first=source:first() ;
	FIRST=math.max(Period[1],Period[2],Period[3],Period[4])
	
	for i = 1,11, 1 do
	
	     Data[i]= instance:addInternalStream(0, 0);
		 Output[i]= instance:addInternalStream(0, 0);
		 
		SourceData[i] = core.host:execute("getSyncHistory", Instrument[i], source:barSize(), source:isBid(), 300, 200 + i, 100 + i)
		loading[i] = true
		
		Fast[i] = core.indicators:create("EMA",SourceData[i].close, Period[1]);
		Med[i] = core.indicators:create("MVA",Fast[i].DATA, Period[2]);
		Slow[i] = core.indicators:create("MVA",Fast[i].DATA, Period[3]);
		VSlow[i] = core.indicators:create("MVA",Slow[i].DATA, Period[4]);
 
 
	end
	
	
   Oscillator = instance:addInternalStream(0, 0);
 
	Oscillator_Data1 = instance:addStream("Oscillator_Data1" , core.Line, " Oscillator_Data1"," Oscillator_Data1",instance.parameters.color1, first );
	Oscillator_Data1:setWidth(instance.parameters.width1);
    Oscillator_Data1:setStyle(instance.parameters.style1);
    Oscillator_Data1:setPrecision(math.max(2, source:getPrecision()));
	
	Oscillator_Data2 = instance:addStream("Oscillator_Data2" , core.Line, " Oscillator_Data2"," Oscillator_Data2",instance.parameters.color2, first );
	Oscillator_Data2:setWidth(instance.parameters.width2);
    Oscillator_Data2:setStyle(instance.parameters.style2);
    Oscillator_Data2:setPrecision(math.max(2, source:getPrecision()));
	
	
end

function Initialization(period, id)
	local Candle
	Candle = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset)

	if loading[id] or SourceData[id]:size() == 0 then
		return false
	end

	if period < source:first() then
		return false
	end

	local P = core.findDate(SourceData[id], Candle, false)

	-- candle is not found
	if P < 0 then
		return false
	else
		return P
	end
end

-- Indicator calculation routine
function Update(period, mode)

 
	if period < first
	then
	return;
	end
    
	local p={};
	
	for i = 1, 11,1 do
	
	p[i] = Initialization(period, i);
			if p[i]~= false then
			Data[period]= source.close[period]/SourceData[i].close[p[i]]
			end
			Fast[i]:update(mode);
			Med[i]:update(mode);
			Slow[i]:update(mode);
			VSlow[i]:update(mode);
	end
	
	
	local Flag =Calculate(period);
    if 	Flag then
	return;
	end
	
 
	 local Sumation=(Output[1][period]+Output[2][period]+Output[3][period]+Output[4][period]+Output[5][period]+Output[6][period]+Output[7][period]+Output[8][period]+Output[9][period]+Output[10][period]+Output[11][period]);
	 
     Oscillator [period ]= ( Sumation / 11 ) * 10 ;
	 Oscillator_Data1[period ]= mathex.avg(Oscillator , period-Period[4]+1, period);
	 Oscillator_Data2[period ]= mathex.avg( Oscillator_Data1, period-Period[5]+1, period);
	 

				  
end

function Calculate(period) 


  	local p={};
	local Flag=false;
	for i = 1, 11,1 do
	
	p[i] = Initialization(period, i);
	
	
		if p[i]== false then
		Flag=true;
		end
		 
    end
	
	
	if Flag then
   return true;
   end


   local Return=false;
   
   if period < FIRST then
   return true;
   end

   local RS2t;
	
   for i= 1, 11, 1 do 
       RS2t=0;
       Output[i][period]=0; 
   
	   if not VSlow[i].DATA:hasData(p[i]) then
	   Return=true;
	   else
	  
	   
	   
					if Fast[i].DATA[p[i]] >= Med[i].DATA[p[i]] and Med[i].DATA[p[i]] >= Slow[i].DATA[p[i]] and Slow[i].DATA[p[i]] >= VSlow[i].DATA[p[i]] then
					RS2t = 10
					elseif Fast[i].DATA[p[i]] >= Med[i].DATA[p[i]] and Med[i].DATA[p[i]] >= Slow[i].DATA[p[i]] and Slow[i].DATA[p[i]] < VSlow[i].DATA[p[i]] then
					RS2t = 9
					elseif Fast[i].DATA[p[i]] < Med[i].DATA[p[i]] and Med[i].DATA[p[i]] >= Slow[i].DATA[p[i]] and Slow[i].DATA[p[i]] >= VSlow[i].DATA[p[i]] then
					RS2t = 9
					elseif Fast[i].DATA[p[i]] < Med[i].DATA[p[i]] and Med[i].DATA[p[i]] >= Slow[i].DATA[p[i]] and Slow[i].DATA[p[i]] < VSlow[i].DATA[p[i]] then
					RS2t = 5
					else
					RS2t = 0 ;
                    end					

					Output[i][period]=RS2t;
					 
	   end
   end
   
  
   
   return Return;
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
	local j
	local Flag = false
	local Count = 0
    local Number=11;
	for j = 1, 11, 1 do
		if cookie == (100 + j) then
			loading[j] = true
		elseif cookie == (200 + j) then
			loading[j] = false
			
		end

		if loading[j] then
			Count = Count + 1
			Flag = true
		end

		if Flag then
			core.host:execute("setStatus", " Loading " .. (Number - Count) .. "/" .. Number);			
		else
			core.host:execute("setStatus", " Loaded " ) ;
			 instance:updateFrom(0);
		end
	end

	return core.ASYNC_REDRAW
end

 