-- Id: 9449
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=42392

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
    indicator:name("Session Cumulative Volume");
    indicator:description("Session Cumulative Volume");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
  
	indicator.parameters:addGroup("Calculation");
	 indicator.parameters:addInteger("hour", "Reeset Hour", "Hour", 0);
	 indicator.parameters:addBoolean("Cumulative", "Combined", "Combined" ,  true);
	 indicator.parameters:addBoolean("Relative", "Relative", "Relative" ,  false);
	indicator.parameters:addGroup("Style");	
	 indicator.parameters:addColor("Pozitiv", "Color Pozitiv", " ", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Negativ", "Color of Negativ", " ", core.rgb(0, 255, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local first;
local source = nil;
 
local Pos, Neg;
local pos,neg;
local Cumulative,Relative;
local dayoffset, weekoffset;
 local hour;

-- Routine
	 function Prepare(nameOnly)    
	Relative = instance.parameters.Relative;
	Cumulative = instance.parameters.Cumulative;
    source = instance.source;
    first = source:first() ;
	hour = instance.parameters.hour;

 
      local name = profile:id() .. "(" ..  (Relative and "Relative" or "Absolute") .. ", " .. (Cumulative and "Combined" or "Separated") .. ")";
    instance:name(name);


    if   (nameOnly) then
        return;
    end

   dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
 
	pos = instance:addInternalStream(0, 0);
	neg = instance:addInternalStream(0, 0);
        if Cumulative    then
		 Cum = instance:addStream("C", core.Bar, name .. ".Cumulative", "Cumulative", instance.parameters.Pozitiv, first);
    Cum:setPrecision(math.max(2, instance.source:getPrecision()));
		else		
        Pos = instance:addStream("P", core.Bar, name .. ".Pozitiv", "Pozitiv", instance.parameters.Pozitiv, first);
    Pos:setPrecision(math.max(2, instance.source:getPrecision()));
        Neg = instance:addStream("N", core.Bar, name .. ".Negativ", "Negativ", instance.parameters.Negativ, first);	
    Neg:setPrecision(math.max(2, instance.source:getPrecision()));
        end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    	      if source.close[period]>source.close[period-1] then
			  pos[period]=source.volume[period];
			  neg[period]=0;
			  else
			  neg[period]=source.volume[period];
			  pos[period]=0;
			  end
			  
			  
			  
			  
		local date_table = core.dateToTable (source:date(period));
		local date_time=core.datetime (date_table.year, date_table.month, date_table.day, hour, 0, 0);

        if date_time > 	source:date(period) then
		date_time=date_time-1;
		end
 
	Candle=source:date(period-3);
	 local Start_Date = core.findDate(source, Candle, false);
	 
	 
     if   Start_Date <= source:first()+1
	 or  Start_Date > period
	  then
	 return;
	 end
    local p,n, denominator;

					 if Start_Date == period then
					 
					   denominator =  source.volume[period] / 100; 
					   p =  pos[period] / 100;
					  n = neg [period] / 100;
					 
					 else
					   denominator = mathex.sum(source.volume, Start_Date, period) / 100; 
					   p = mathex.sum(pos, Start_Date, period) / 100;
					   n = mathex.sum(neg , Start_Date, period) / 100;
					 end
					 
					 
					 
					 
					 
			 
				  if Cumulative then
					 if Relative then				
					 Cum[period]=((p-n)/denominator)*100;
					 else
					  Cum[period]=(p-n);
					 end
				  else
					   if Relative then
					  Pos[period]= (p/denominator)*100;
					  Neg[period]= -(n/denominator)*100;
					  else
					   Pos[period]= p;
					  Neg[period]= -n;
					  end
				  end
			 
  
end

