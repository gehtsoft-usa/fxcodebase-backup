-- Id: 16039

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63472

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
    indicator:name("Bollinger Band divergence indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	
	
    indicator.parameters:addString("Instrument", "Instrument", "", "AUD/JPY");
    indicator.parameters:setFlag("Instrument", core.FLAG_INSTRUMENTS);
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 20);
	indicator.parameters:addInteger("F1", "F1", "", 2);
	indicator.parameters:addInteger("F2", "F2", "", 4);
 
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width", "Indicator Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Indicator Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

 
 
 
local dayoffset,weekoffset;
local Source;
local Instrument; 
local first;
local source = nil;
local loading;  
local Number ; 
local Period, F1,F2;
local DIVERG;
 
-- Routine
function Prepare(nameOnly)   
	  
    source = instance.source; 
	dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");	
    Instrument=  instance.parameters.Instrument;
	Period=  instance.parameters.Period;
	F1=  instance.parameters.F1;
	F2=  instance.parameters.F2;
	
      local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
		 
			
			Source = core.host:execute("getSyncHistory",Instrument, source:barSize(), source:isBid(), math.min(300,Period), 200, 100); 
			loading=true;
	 

  
	
	DIVERG = instance:addStream("DIVERG", core.Line, name, "DIVERG",   instance.parameters.color, source:first());
    DIVERG:setPrecision(math.max(2, instance.source:getPrecision()));
    DIVERG:setWidth(instance.parameters.width);
    DIVERG:setStyle(instance.parameters.style);
  
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period ) 
	
	local p= Initialization(period)	
	
		if loading or not p or p< Period or period < Period then		
		return;		
		end
	
local SD1 = mathex.stdev (source.close,period-Period+1, period);
local SMA1 = mathex.avg(source.close,period-Period+1, period);
local BB1 = 1+(source.close[period]-SMA1+F1*SD1)/(F2*SD1);


local SD2 = mathex.stdev (Source.close,p-Period+1, p);
local SMA2 = mathex.avg(Source.close,p-Period+1, p);
local BB2 = 1+(Source.close[p]-SMA2+F1*SD2)/(F2*SD2);


DIVERG[period] = (BB2-BB1)/BB1*100
end
 


function   Initialization(period)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset);
  
    if loading or Source:size() == 0  then
        return false;
    end

    
    if period < source:first() then
        return false;
    end

    local P = core.findDate(Source, Candle, false);
	 

    -- candle is not found
    if P < 0    then
        return false;
	else return P;	
    end
			
end	




-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
   
			  if cookie == (100) then
			  loading = true;
		      elseif  cookie == (200) then
			  loading = false;  
			  instance:updateFrom(0);		 
              end
			  
		
   
        
		return core.ASYNC_REDRAW ;
end
 


