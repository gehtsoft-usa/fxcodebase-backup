-- Id: 22176
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66602

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
function Init()
    indicator:name("CRSI Signal");
    indicator:description("CRSI");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("LenRSI", "RSI Closes Length", "RSI Closes Length", 3);
    indicator.parameters:addInteger("LenUD", "RSI UpClose Length", "RSI UpClose Length", 2);
    indicator.parameters:addInteger("LenRank", "PerecentRank Length", "PerecentRank Length", 100);
	indicator.parameters:addDouble("Level", "Level", "Level", 3);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Line Color", "Line Color", core.rgb(255, 0, 0));
  
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local LenRSI;
local LenUD;
local LenRank;

local first1;
local source = nil;

-- Streams block
local crsi = nil;
local updownDays;
local RSI1,RSI2,RSI3;
local first;
local Level;
-- Routine
 function Prepare(nameOnly)   
    LenRSI = instance.parameters.LenRSI;
    LenUD = instance.parameters.LenUD;
    LenRank = instance.parameters.LenRank;
	Level= instance.parameters.Level;
    source = instance.source;
    first1 = source:first();
	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(LenRSI) .. ", " .. tostring(LenUD) .. ", " .. tostring(LenRank) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	 
	updownDays = instance:addInternalStream(first1, 0);

	
	RSI1 = core.indicators:create("RSI", source.close, LenRSI);
	RSI2 = core.indicators:create("RSI", updownDays, LenUD);
	RSI3 = core.indicators:create("RSI", source.close, 1);
	first=math.max(RSI1.DATA:first(), RSI2.DATA:first(), RSI3.DATA:first()+LenRank)
  
    crsi = instance:addInternalStream(0, 0);
 
        Signal = instance:addStream("Signal", core.Bar, name, "Signal", instance.parameters.color, first);  
 
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    if period < first1 or not  source:hasData(period) then
	return;
	end
	
	if source[period]> source[period-1] then 
		if  updownDays[period-1]> 0 then
		updownDays[period]=updownDays[period-1]+1;
		else
		updownDays[period]=1;
		end
	elseif source[period]< source[period-1] then	
	  	if  updownDays[period-1]< 0 then
		updownDays[period]=updownDays[period-1]-1;
		else
		updownDays[period]=-1;
		end
	else
	updownDays[period]=0;
	end
	
	RSI1:update(mode)
	RSI2:update(mode)
	RSI3:update(mode)
	
	if period< first then
	return;
	end
	 
	
        crsi[period] = (RSI1.DATA[period] +RSI2.DATA[period] +PercentRank(RSI3.DATA,LenRank ,period))/3;
  
    if source.close[period]>= source.open[period] 
	and  crsi[period]< (crsi[period-1] -Level)
	then
	Signal[period]=1;
	elseif source.close[period]<= source.open[period] 
	and  crsi[period]> (crsi[period-1] +Level)
	then
	Signal[period]=-1;
	else
	Signal[period]=0;
	end
	
 
end


function PercentRank( Data, Periods,period) 
 
   local Count = 0; 
   for  i = 1, Periods, 1  do  
	   if  Data[period] >  Data[period-i] then
	   Count = Count+1;
	   end
   end 
   
  return 100 * Count / Periods; 
end 
