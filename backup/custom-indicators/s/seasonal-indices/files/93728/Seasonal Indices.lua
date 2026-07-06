-- Id: 11615

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60599

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
    indicator:name("Seasonal Indices");
    indicator:description("Seasonal Indices");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
    indicator.parameters:addColor("AdjustedColor", "Color of Adjusted ", "Color of Adjusted", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("SeasonallyAdjustedColor", "Color of Seasonally Adjusted", "Color of Seasonally Adjusted", core.rgb(0, 0, 255));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local AdjustedColor;

local first;
local source = nil;
local Date={};
-- Streams block
local SI = nil;
local Average={};
local Adjusted; 
local SeasonallyAdjusted, SeasonallyAdjustedColor;
local  SeasonalIndex={};
local Shift;
-- Routine
function Prepare(nameOnly)
    AdjustedColor = instance.parameters.AdjustedColor;
	 SeasonallyAdjustedColor = instance.parameters. SeasonallyAdjustedColor;
    source = instance.source;
    first = source:first();
	
	

    local name = profile:id() .. "(" .. source:name()   .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	assert(source:barSize() == "M1", "Please select M1 Time frame");
	
	Adjusted = instance:addStream("SeasonalIndex", core.Line, name .. "." .. "Seasonal Index", "Seasonal Index", AdjustedColor, first,24);
    Adjusted:setPrecision(math.max(2, instance.source:getPrecision()));
    SeasonallyAdjusted = instance:addStream("Deseasonalised", core.Line, name .. "." .. "Deseasonalised", "Deseasonalised", SeasonallyAdjustedColor, first,24);
    SeasonallyAdjusted:setPrecision(math.max(2, instance.source:getPrecision()));
	core.host:execute ("attachOuputToChart", "Deseasonalised");
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < source:size()-1 then
	return;
	end
	
	
	
	
	local Date={};
	Date["First"]= core.dateToTable(source:date(first)); 
	Date["Last"]= core.dateToTable(source:date(source:size()-1)); 
	  
	if Date["First"].year+1 >=  Date["Last"].year-1 then
	return;
	end
	
	local Year;
	for Year= Date["First"].year+1, Date["Last"].year-1, 1 do
	  
		Average[tostring(Year)]= Avg(Year);
		Adjust(Year);
		 
		 
	end
	 
 
	for i= 1, 12, 1 do
	SeasonalIndex[i]= SeasonalIndex[i]/(  Date["Last"].year -Date["First"].year  );	
	end
		
	for Year= Date["First"].year+1, Date["Last"].year-1, 1 do
				 
		 Deseasonalised(Year);		 
	end
	
	
	local date=  core.datetime (Date["First"].year+1, 1, 1, 1, 1, 1)
    period= core.findDate (source, date, false);
	local from= period;
	
	date=  core.datetime (Date["Last"].year-1, 12, 1, 1, 1, 1)
    period= core.findDate (source, date, false);	
	local to= period;
	
	
	local a, b, dev, raff = mathex.regChannel (SeasonallyAdjusted, from, to);
	
	date=  core.datetime (Date["Last"].year, 1, 1, 1, 1, 1)
	 period= core.findDate (source, date, false);
	 Shift=0;
	for i= 0, 23, 1 do
	if i==0 then
	Shift=source.close[period+i]-( a * (period+i) + b)*Adjusted[period+i];
	end
	
   	SeasonallyAdjusted[period+i]=( a * (period+i) + b)*Adjusted[period+i]+Shift;
	
	 
	end
	
	
end	
function Deseasonalised(Year)
local i;
 local period;
 local date;
 
	 for i= 1 , 12, 1 do
	 
	   date=  core.datetime (Year, i, 1, 1, 1, 1)
		period= core.findDate (source, date, false);
				
	SeasonallyAdjusted[period]= source.close[period]/ SeasonalIndex[i];
	Adjusted[period]= SeasonalIndex[i];
    Adjusted[period+12]= SeasonalIndex[i];
	Adjusted[period+24]= SeasonalIndex[i];
	end
	
	
end
function Adjust(Year)

 local i;
 local period;
 local date;
 
 for i= 1 , 12, 1 do
 
   date=  core.datetime (Year, i, 1, 1, 1, 1)
    period= core.findDate (source, date, false);
  
  if SeasonalIndex[i]== nil then
  SeasonalIndex[i]=0;
  end
  SeasonalIndex[i]=  SeasonalIndex[i]+ source.close[period]/ Average[tostring(Year)];
  
 end


end
	
function Avg(Year) 

 local i;
 local period;
 local date;
 local Sum=0;
 local Count=0;
 
 for i= 1 , 12, 1 do
  date=  core.datetime (Year, i, 1, 1, 1, 1)  
  period= core.findDate (source, date, false);
   
    if source:hasData(period) then
	Sum= Sum+source.close[period];
	Count=Count+1;
	end
 end 
  
return Sum/Count;
end

 