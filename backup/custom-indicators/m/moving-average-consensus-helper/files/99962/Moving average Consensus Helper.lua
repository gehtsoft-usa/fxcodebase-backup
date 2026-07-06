-- Id: 14025
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62134


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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Moving average Consensus Helper");
    indicator:description("Moving average Consensus Helper");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    
	indicator.parameters:addGroup("Selector");
	
	indicator.parameters:addBoolean("Shift", "End of Turn", "End of Turn", false);
	indicator.parameters:addBoolean("Show", "Show Pop Up", "Show Pop Up", false);
	indicator.parameters:addBoolean("Historical", "Show Historical", "Show Historical", false);
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period1", "1. Period", "1. Period", 7);
	indicator.parameters:addString("Method1", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	
    indicator.parameters:addInteger("Period2", "2. Period", "2. Period", 14);
	indicator.parameters:addString("Method2", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	
	
    indicator.parameters:addInteger("Period3", "3. Period", "3. Period", 21);
	indicator.parameters:addString("Method3", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Label", "Color of Label", "Color of Label", core.COLOR_LABEL);
	indicator.parameters:addColor("Long", "Color of Long", "Color of Long", core.rgb(0,255,0));
	indicator.parameters:addColor("Short", "Color of Short", "Color of Short", core.rgb(255,0,0));
	indicator.parameters:addInteger("Size", "Font Size", "Font Size", 10);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period1;
local Period2;
local Period3;
local Method1;
local Method2;
local Method3;
local Show;
local first;
local source = nil;
local Shift;
local Label;
local Size;
-- Streams block
local Signal = nil;
local MA={};
local font ;
local Long,Short;
local Historical;
-- Routine
function Prepare(nameOnly) 
    Period1 = instance.parameters.Period1;
    Period2 = instance.parameters.Period2;
    Period3 = instance.parameters.Period3;
	Method1 = instance.parameters.Method1;
	Method2 = instance.parameters.Method2;
	Method3 = instance.parameters.Method3;
	Historical = instance.parameters.Historical;
	Long = instance.parameters.Long;
	Short = instance.parameters.Short;
	Show = instance.parameters.Show;
	Shift = instance.parameters.Shift;
	Label = instance.parameters.Label;
	Size = instance.parameters.Size;
    source = instance.source;
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period1).. ", " .. tostring(Method1)  .. ", " .. tostring(Period2).. ", " .. tostring(Method2) .. ", " .. tostring(Period3).. ", " .. tostring(Method3) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    font = core.host:execute("createFont", "Arial", Size, false, false); 
	
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
	MA[1]= core.indicators:create(Method1, source, Period1);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
	MA[2]= core.indicators:create(Method2, source, Period2);
    assert(core.indicators:findIndicator(Method3) ~= nil, Method3 .. " indicator must be installed");
	MA[3]= core.indicators:create(Method3, source, Period3);
	
	first = math.max(MA[1].DATA:first(),MA[2].DATA:first(),MA[3].DATA:first());

  

    
        Signal = instance:addInternalStream(0, 0);
  
end

local Last;
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)


    if Shift then
	period=period-1;
	end

    MA[1]:update(mode);
	MA[2]:update(mode);
	MA[3]:update(mode);
	
	core.host:execute ("removeLabel", 1);
	core.host:execute ("removeLabel", 2);
	core.host:execute ("removeLabel", source:serial(period));
	
    if period < first or not source:hasData(period) then
	return;
	end
	
	
	local Price= win32.formatNumber(source[period], false, source:getPrecision());
	
	local Active=nil;
	local Status=nil;
	
 
	

	
	
	Signal[period]=Signal[period-1];
	
	-- when to go long
	  if MA[1].DATA[period]> MA[2].DATA[period]
	  and MA[1].DATA[period]> MA[3].DATA[period]
	  and MA[2].DATA[period]> MA[3].DATA[period]
	  then
	  Signal[period]= 1	
	  end
	   
   -- when to exit long
    if   MA[1].DATA[period] < MA[2].DATA[period]  
	and Signal[period]== 1	
	then
	Signal[period]=0;
    end
	 
	
  ---// when to go short
      if MA[1].DATA[period]< MA[2].DATA[period]
	  and MA[1].DATA[period]< MA[3].DATA[period]
	  and MA[2].DATA[period]< MA[3].DATA[period] 
	  then
	  Signal[period]= -1;
	  end
  
	  
	 -- //when to exit short	 
	if   MA[1].DATA[period] > MA[2].DATA[period]
    and Signal[period]== -1	
	then
	Signal[period]=0;	
    end
 
 
 
    if Historical  then
		if Signal[period]== 1 and Signal[period-1]~= 1 then
		Active= "Go Long @ " .. Price;
		core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source[period], core.CR_CHART, core.H_Center, core.V_Bottom,  font, Long, "Go Long");   
		end
		
		
		
		if Signal[period]== -1 and Signal[period-1]~= -1 then
		Active= "Go Short @ " .. Price;
		core.host:execute("drawLabel1",  source:serial(period), source:date(period), core.CR_CHART,source[period], core.CR_CHART, core.H_Center, core.V_Top, font, Short, "Go Short");
		end
		
		
		
		if Signal[period]== 0  and Signal[period-1]~= 0 then	
			if Signal[period-1]== -1 then
			Active=  "Exit short @ " .. Price;
			core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source[period], core.CR_CHART, core.H_Center, core.V_Bottom,  font, Short, "Exit short");   
			elseif Signal[period-1]== 1 then 
			core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source[period], core.CR_CHART, core.H_Center, core.V_Bottom,  font, Long, "Exit long");   
			Active=  "Exit long @ " .. Price;  
			end	 
		end
	
	end
	
	if Signal[period]== 1 then
	Status="Long";
	elseif Signal[period]== -1 then
	Status="Short";
	else
	Status="Neutral";
	end
	
	core.host:execute("drawLabel1", 1, -Size*15, core.CR_RIGHT, Size*2, core.CR_TOP, core.H_Right, core.V_Top, font, Label, "Trend : " .. Status);
	if Active ~= nil then
    core.host:execute("drawLabel1", 2, -Size*15, core.CR_RIGHT, Size*3, core.CR_TOP, core.H_Right, core.V_Top, font, Label,  "Signal : " .. Active);	   
	Pop("Moving average Consensus" , "Signal : " .. Active);
	end
 end
 
 
 function Pop(label , note)
  
   if not Show then
   return;
   end
   
   if Last == source:serial(source:size()-1) then
   return;
   end
   
   Last = source:serial(source:size()-1);
   
   
    local date = source:date(source:size()-1);
	local DATA = core.dateToTable (date);
	
    
   local delim = "\013\010";  
   local Note=   " Indicator : " ..label  .. delim .. " Alert : " .. note ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   local text = Note  .. delim ..  Symbol   .. delim .. Time;

  core.host:execute ("prompt", 3, label ,   text );


end

 function ReleaseInstance()
       core.host:execute("deleteFont", font);
end	   


function AsyncOperationFinished (cookie, success, message)
end
