-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66659

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
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
    indicator:name("Time Series Forecasting");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
--	indicator.parameters:addGroup("Calculation"); 
  --  indicator.parameters:addInteger("Period", "Trend Period", "", 50, 2, 2000);
 
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

--local  Period;

local first;
local source = nil;
 
local Forecast;  

local E,F,G,H,I,J,K;
local Quarter;
local Count;

local monthly_data;
local Extend;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	


    --Period = instance.parameters.Period;
    source = instance.source;
	
	
    monthly_data = core.host:execute("getSyncHistory", source:instrument(), "M1", source:isBid(), 120, 200, 100);
	  
  	first=source:first()+2;
    
	s1, e1 = core.getcandle(source:barSize(), 0, 0, 0);
	s2, e2 = core.getcandle("M1", 0, 0, 0);
	
	local Size1=e1-s1;
	local Size2=(e2-s2)*12;
	
	Extend=  (Size2/Size1) ;
	
	E = instance:addInternalStream(0, 0);
	
	F = instance:addInternalStream(0, 0);
	
	G = instance:addInternalStream(0, 0);
	
	H = instance:addInternalStream(0, Extend); 
	
	I = instance:addInternalStream(0, 0);
	
	J = instance:addInternalStream(0, Extend);
	
	--K = instance:addStream("Test" , core.Line, " Test"," Test",instance.parameters.color, first);	 
   
 
	K = instance:addStream("Forecast", core.Line, " Forecast"," Forecast",instance.parameters.color, first, Extend);
	K:setWidth(instance.parameters.width);
    K:setStyle(instance.parameters.style);
end

local loading = true;
function AsyncOperationFinished(cookie)
	if cookie == 100 then
		loading = true
	elseif cookie == 200 then
		loading = false
	end
	if loading then
		core.host:execute("setStatus", "Loading")
	else
		core.host:execute("setStatus", "Loaded")
		instance:updateFrom(0);
	end

	return core.ASYNC_REDRAW
end

local quoterly_data = {};

function GetQuoterlyDate(date)
	Table = core.dateToTable(date);
	if Table.month == 3 or Table.month == 2 or Table.month == 1 then
		Table.month = 1;
	elseif Table.month == 6 or Table.month == 5 or Table.month == 4 then
		Table.month = 4;
	elseif Table.month== 9 or Table.month== 8 or Table.month==  7 then
		Table.month = 7;
	elseif Table.month== 12 or Table.month== 11 or Table.month== 10 then
		Table.month = 10;
	end
	Table.day = 1;
	Table.hour = 0;
	Table.min = 0;
	Table.sec = 0;
	return core.tableToDate(Table);
end

function BuildQuoterlyData()
	if #quoterly_data ~= 0 then
		return;
	end
	for i = 0, monthly_data:size() - 1 do
		date = GetQuoterlyDate(monthly_data:date(i));
		if quoterly_data[#quoterly_data] == nil or quoterly_data[#quoterly_data].Date ~= date then
			local item = {};
			item.Date = date;
			quoterly_data[#quoterly_data + 1] = item;
		end
		quoterly_data[#quoterly_data].Close = monthly_data.close[i];
	end
end

function FindQuoterlyIndex(date)
	date = GetQuoterlyDate(date);
	for i = 1, #quoterly_data do
		if quoterly_data[i].Date == date then
			return i;
		end
	end
	return -1;
end

-- Indicator calculation routine
function Update(period, mode)
	if loading then
		return;
	end
 
 	if period < source:first()+4    then
		return;
	end 

    if period < source:size()-1   then
		return;
	end
--4
	BuildQuoterlyData();
	
	Quarter={0,0,0,0};
	Count={0,0,0,0};
	local ma = {};
	for i= first, source:size()-1, 1 do
		local index = FindQuoterlyIndex(source:date(i));
		if index >= 4 then
			ma[index] = (quoterly_data[index].Close + quoterly_data[index - 1].Close + quoterly_data[index - 2].Close + quoterly_data[index - 3].Close) / 4;
			E[i-2] = ma[index];
		end
	end
	for i= first, source:size()-2, 1 do
		local index = FindQuoterlyIndex(source:date(i));
		if index ~= -1 and ma[index] ~= nil and ma[index + 1] ~= nil then
			F[i-2] = (ma[index] + ma[index + 1]) / 2;
		end
	end
	for i= first, source:size()-1, 1 do
		local index = FindQuoterlyIndex(source:date(i));
		if index ~= -1 and F:hasData(i) then
			G[i] = quoterly_data[index].Close / F[i];
		end
	end
	for _, data in ipairs(quoterly_data) do
		Table= core.dateToTable(data.Date);
	
		if Table.month== 3 or Table.month== 2 or Table.month== 1 then
			Quarter[1] = Quarter[1] + data.Close;
			Count[1]= Count[1]+1;
		elseif Table.month== 6 or Table.month== 5 or Table.month== 4 then
			Quarter[2]=Quarter[2] + data.Close;
			Count[2]= Count[2]+1;
		elseif Table.month== 9 or Table.month== 8 or Table.month==  7 then
			Quarter[3]=Quarter[3] + data.Close;
			Count[3]= Count[3]+1;
		elseif Table.month== 12 or Table.month== 11 or Table.month== 10 then
			Quarter[4]=Quarter[4] + data.Close;
			Count[4]= Count[4]+1;
		end
	end
	Quarter[1]=Quarter[1]/Count[1];
	Quarter[2]=Quarter[2]/Count[2];
	Quarter[3]=Quarter[3]/Count[3];
	Quarter[4]=Quarter[4]/Count[4];
	
	
	 
	for i= first, source:size()-1, 1 do
	  
			Table= core.dateToTable (source:date(i));
			if Table.month== 3 or Table.month== 2 or Table.month== 1 then
				H[i]=Quarter[1]; 
				H[i+Extend]=Quarter[1];				 
			elseif Table.month== 6 or Table.month== 5 or Table.month== 4 then
				H[i]=Quarter[2]; 
				H[i+Extend]=Quarter[2];	
			elseif Table.month== 9 or Table.month== 8 or Table.month==  7 then
				H[i]=Quarter[3]; 
				H[i+Extend]=Quarter[3];	
			elseif Table.month== 12 or Table.month== 11 or Table.month== 10 then 
				H[i]=Quarter[4]; 
				H[i+Extend]=Quarter[4];	
			end 
			
		 
	end
	for i= first, source:size()-1, 1 do
		local index = FindQuoterlyIndex(source:date(i));
		if index ~= -1 then
			I[i] = quoterly_data[index].Close / H[i];
		end
	end
	local Last = mathex.lreg(I, source:first() ,  source:size()-1);
	local Slope = mathex.lregSlope (I, source:first() ,  source:size()-1);
    for i= source:first(), source:size()-1+Extend, 1 do	 
		if i <= source:size()-1 then
			J[i]= Last - (source:size()-1-i)*Slope;	
		else
			J[i]= Last + (i-source:size()-1)*Slope;	
		end
	end
	for i= first, source:size()-1+Extend, 1 do
		K[i] = J[i] * H[i];
	end
end
