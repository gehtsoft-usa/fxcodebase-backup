-- Id: 14645
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62518

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
    indicator:name("ConnorsRSI");
    indicator:description("ConnorsRSI");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("LenRSI", "RSI Closes Length", "RSI Closes Length", 3);
    indicator.parameters:addInteger("LenUD", "RSI UpClose Length", "RSI UpClose Length", 2);
    indicator.parameters:addInteger("LenRank", "PerecentRank Length", "PerecentRank Length", 100);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("crsi_color", "Color of crsi", "Color of crsi", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
    
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 70);
    indicator.parameters:addDouble("oversold","Oversold Level","", 30);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
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
-- Routine
 function Prepare(nameOnly)   
    LenRSI = instance.parameters.LenRSI;
    LenUD = instance.parameters.LenUD;
    LenRank = instance.parameters.LenRank;
    source = instance.source;
    first1 = source:first();
	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(LenRSI) .. ", " .. tostring(LenUD) .. ", " .. tostring(LenRank) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	 
	updownDays = instance:addInternalStream(first1, 0);

	
	RSI1 = core.indicators:create("RSI", source, LenRSI);
	RSI2 = core.indicators:create("RSI", updownDays, LenUD);
	RSI3 = core.indicators:create("RSI", source, 1);
	first=math.max(RSI1.DATA:first(), RSI2.DATA:first(), RSI3.DATA:first()+LenRank)
  

 
        crsi = instance:addStream("crsi", core.Line, name, "crsi", instance.parameters.crsi_color, first);
		crsi:setWidth(instance.parameters.width);
        crsi:setStyle(instance.parameters.style);
		crsi:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		crsi:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
        crsi:setPrecision(math.max(2, instance.source:getPrecision())); 
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
