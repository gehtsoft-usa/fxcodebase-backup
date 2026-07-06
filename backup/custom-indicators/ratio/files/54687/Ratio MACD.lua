-- Id: 8508
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3810

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
    indicator:name("Ratio MACD");
    indicator:description("Ratio MACD");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("1. Instrument");	 
	 
	indicator.parameters:addString("First", "Source stream", "", "close");
    indicator.parameters:addStringAlternative("First", "open", "", "open");
    indicator.parameters:addStringAlternative("First", "high", "", "high");
    indicator.parameters:addStringAlternative("First", "low", "", "low");
    indicator.parameters:addStringAlternative("First", "close", "", "close");
    indicator.parameters:addStringAlternative("First", "median", "", "median");
    indicator.parameters:addStringAlternative("First", "typical", "", "typical");
    indicator.parameters:addStringAlternative("First", "weighted", "", "weighted");
	
	
	indicator.parameters:addGroup("2. Instrument");	

    indicator.parameters:addString("Second", "Source stream", "", "close");
    indicator.parameters:addStringAlternative("Second", "open", "", "open");
    indicator.parameters:addStringAlternative("Second", "high", "", "high");
    indicator.parameters:addStringAlternative("Second", "low", "", "low");
    indicator.parameters:addStringAlternative("Second", "close", "", "close");
    indicator.parameters:addStringAlternative("Second", "median", "", "median");
    indicator.parameters:addStringAlternative("Second", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Second", "weighted", "", "weighted");
	   
    indicator.parameters:addString("Pair" , "Pair", "", "EUR/USD");
    indicator.parameters:setFlag("Pair", core.FLAG_INSTRUMENTS);
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period1", "Short Period", "Short Period" , 5);
     indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");	
	
	
	   indicator.parameters:addInteger("Period2", "Long Period", "Long Period" , 20);
     indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");	
	
	   indicator.parameters:addInteger("Period3", "Signal Period", "Signal Period" , 9);
     indicator.parameters:addString("Method3", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");	

 	indicator.parameters:addString("Inverse", "Inverse", "","Inverse");
	 indicator.parameters:addStringAlternative("Inverse", "Inverse", " " , "Inverse");
    indicator.parameters:addStringAlternative("Inverse", "Direct", " " , "Direct");
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Color1", "MACD Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width1", "Line Width (in pixels)", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addColor("Color2", "Signal Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width2", "Line Width (in pixels)", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);
	
	
	indicator.parameters:addColor("Color3", "Histogram Bar Color", "", core.rgb(0, 0, 255));
    
	
end

local Period3, Period2, Period1;
local Method3, Method2, Method1;
local offset,weekoffset;
local SourceData;
local  Pair;
local host;
local first;
local source;
local loading;
local Last,last;
local p;
local Inverse;
local HISTOGRAM, SIGNAL, MACD;
local DATA;
local First, Second;
local MA1, MA2, MA3;
-- Routine
function Prepare(onlyName)   
	 Period3 = instance.parameters.Period3;
	 Period2 = instance.parameters.Period2;
	 Period1 = instance.parameters.Period1;  
	 Method3 = instance.parameters.Method3;
	 Method2 = instance.parameters.Method2;
	 Method1 = instance.parameters.Method1;
	 Inverse = instance.parameters.Inverse;
	 First= instance.parameters.First;
	 Second= instance.parameters.Second;
	 	Pair= instance.parameters.Pair;
    source = instance.source;
   
	host=core.host;	


	 
    local name = profile:id() .. "(" .. source:name() .."(" .. First .. ")".. "/" .. Pair.."(" .. Second .. ") " .. Period1.. ", ".. Method1.. ", " .. Period2 ..", ".. Method2 .. ", " .. Period3.. ", ".. Method3 .."," .. Inverse.. ")";
    instance:name(name);
    
	if onlyName then
        return ;
    end
	
	
		offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");	

	


	SourceData = core.host:execute("getSyncHistory",Pair, source:barSize(), source:isBid(), 0, 2, 1);
	loading=true;
	 
	
  
   DATA= instance:addInternalStream(0, 0);
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
   MA1= core.indicators:create(Method1, DATA, Period1);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
   MA2 = core.indicators:create(Method2, DATA, Period2);
   
    first = math.max(MA1.DATA:first(), MA2.DATA:first());	
  
    MACD = instance:addStream("Short", core.Line, name, "Short", instance.parameters.Color1,  first);
    MACD:setWidth(instance.parameters.width1);
    MACD:setStyle(instance.parameters.style1);
    MACD:setPrecision(2);
	
    assert(core.indicators:findIndicator(Method3) ~= nil, Method3 .. " indicator must be installed");
	MA3 = core.indicators:create(Method3, MACD, Period3);
	
	SIGNAL = instance:addStream("Signal", core.Line, name, "Signal", instance.parameters.Color2,  MA3.DATA:first());
    SIGNAL:setWidth(instance.parameters.width1);
    SIGNAL:setStyle(instance.parameters.style1);
    SIGNAL:setPrecision(2);
	
	HISTOGRAM = instance:addStream("Histogram", core.Bar, name, "Histogram", instance.parameters.Color3,  MA3.DATA:first()); 
    HISTOGRAM:setPrecision(2);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

	p= Initialization(period)	
	
	if loading 	
    or not p then	
	return;
	end
	

	
	if Inverse == "Inverse" then
	 DATA[period]=  SourceData[Second][p] /source[First][period] ;
	else
    DATA[period]=source[First][period] / SourceData[Second][p];
	end
	
	
	 MA1:update(mode);
	 MA2:update(mode);
	 
	 
	 if period < first then
	 return;
	 end
	 
	 MACD[period] =MA2.DATA[period]-MA1.DATA[period];
	 
	 MA3:update(mode);
	 
	 if period < MA3.DATA:first() then
	 return;
	 end
	 
     SIGNAL[period]= MA3.DATA[period];
	 HISTOGRAM[period]=  MACD[period]- SIGNAL[period];
end




function   Initialization(period,id)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), offset, weekoffset);
  
    if loading or SourceData:size() == 0  then
        return false;
    end

    
    if period < source:first() then
        return false;
    end

    local P = core.findDate(SourceData, Candle, false);
	 

    -- candle is not found
    if P < 0    then
        return false;
	else return P;	
    end
			
end	




-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    
	local Flag = false;	
	
  
		
			  if cookie == (1) then
			  loading  = true;
		      elseif  cookie == (2) then
			  loading  = false;  
			  instance:updateFrom(0);	              			 
              end
			  
		if loading then
		Flag=true;
		end	 

		  
		if Flag then
		core.host:execute ("setStatus", " Loading ");
		else
		core.host:execute ("setStatus", " Loaded ");
		end
			  
	   
   
        
		return core.ASYNC_REDRAW ;
end

function ReleaseInstance()
 
end



