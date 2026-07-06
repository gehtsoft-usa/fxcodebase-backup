-- Id: 15852

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63358

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
    indicator:name("Multiple indicator combination Overlay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	--MACD/RSI/SSD/MVA50/MVA20

 

	 indicator.parameters:addGroup("Price Selection");
	indicator.parameters:addString("Price" , "Data Source", "", "close");
    indicator.parameters:addStringAlternative("Price" , "Open", "", "open");
    indicator.parameters:addStringAlternative("Price", "High", "", "high");
    indicator.parameters:addStringAlternative("Price" , "Low", "", "low");
	indicator.parameters:addStringAlternative("Price" , "Close", "", "close");
	indicator.parameters:addStringAlternative("Price", "Median", "", "median");
    indicator.parameters:addStringAlternative("Price" , "Typical", "", "typical");
	indicator.parameters:addStringAlternative("Price" , "Weighted ", "", "weighted");	

	
	indicator.parameters:addGroup("1.MA Calculation");	
	indicator.parameters:addInteger("Period1", "MA Period", "Period" , 20);
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	 
	 indicator.parameters:addGroup("2.MA Calculation");	
	indicator.parameters:addInteger("Period2", "MA Period", "Period" , 50);
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	 
   	indicator.parameters:addGroup("MACD Calculation");
	 indicator.parameters:addInteger("SN", "Short EMA", "", 12, 2, 1000);
    indicator.parameters:addInteger("LN", "Long EMA", "", 26, 2, 1000);
    indicator.parameters:addInteger("IN", "Signal Line", "", 9, 2, 1000);
	
	  	indicator.parameters:addGroup("RSI Calculation");
	 indicator.parameters:addInteger("RSI_Period", "Period", "", 14, 2, 1000);
	 
	 	indicator.parameters:addGroup("SSD Calculation");
	 indicator.parameters:addInteger("SSD1", "K Period", "", 5, 2, 1000);
    indicator.parameters:addInteger("SSD2", "D Slowing Period", "", 3, 2, 1000);
    indicator.parameters:addInteger("SSD3", "D Period", "", 3, 2, 1000);
	
	indicator.parameters:addGroup("Selector");
	
	 indicator.parameters:addBoolean("F16", "Use Price Filter", "", false);
    indicator.parameters:addBoolean("F1", "Use 1. Price/MA Filter", "", false);
	indicator.parameters:addBoolean("F2", "Use 1. MA Slope Filer", "", false);
	indicator.parameters:addBoolean("F3", "Use 2. Price/MA Filter", "", false);
	indicator.parameters:addBoolean("F4", "Use 2. MA Slope Filer", "", false);
	
	indicator.parameters:addBoolean("F5", "Use 1.MA / 2.MA Filer", "", false);
	
	indicator.parameters:addBoolean("F6", "Use MACD/Signal Filter", "", false);
	indicator.parameters:addBoolean("F7", "Use MACD/Zero Filter", "", false);
	indicator.parameters:addBoolean("F8", "Use MACD Slope Filter", "", false);
	indicator.parameters:addBoolean("F9", "Use MACD Histogram/Zero Filter", "", false);
	indicator.parameters:addBoolean("F10", "Use MACD Histogram Slope Filter", "", false);
	
	indicator.parameters:addBoolean("F11", "Use RSI / Central Line Filter", "", false);
	indicator.parameters:addBoolean("F12", "Use RSI Slope Filter", "", false);
	
	
	indicator.parameters:addBoolean("F13", "Use SSD K Line/ D Line Filter", "", false);
	indicator.parameters:addBoolean("F14", "Use SSD K Line/Zero Line Filter", "", false);
	indicator.parameters:addBoolean("F15", "Use SSD K Line Slope Filter", "", false);
  
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral color", "", core.rgb(0, 0, 255));
	
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Up,Down, Neutral;
local first;
local source = nil;

local Price;
local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

local SN, LN, IN= nil;
local MACD, MA1, MA2;
local Period1, Period2,Method1,Method2;
local RSI, RSI_Period;
local SSD, SSD1, SSD2, SSD3;
local F={};


function Prepare(nameOnly)  

    Up = instance.parameters.Up;
    Down= instance.parameters.Down;
    Neutral= instance.parameters.Neutral;
   
    
    IN = instance.parameters.IN;
	SN = instance.parameters.SN;
    LN = instance.parameters.LN;
	Price = instance.parameters.Price;
	
	Period1 = instance.parameters.Period1;
	Period2 = instance.parameters.Period2;
	Method1 = instance.parameters.Method1;	
	Method2 = instance.parameters.Method2;
	
	RSI_Period = instance.parameters.RSI_Period;
    SSD1 = instance.parameters. SSD1;
	SSD2 = instance.parameters. SSD2;
	SSD3 = instance.parameters. SSD3;

	F[1] = instance.parameters.F1;
	F[2] = instance.parameters.F2;
	F[3] = instance.parameters.F3;
	F[4] = instance.parameters.F4;
	F[5] = instance.parameters.F5;
	F[6] = instance.parameters.F6;
	F[7] = instance.parameters.F7;
	F[8] = instance.parameters.F8;
	F[9] = instance.parameters.F9;
	F[10] = instance.parameters.F10;
	F[11] = instance.parameters.F11;
	F[12] = instance.parameters.F12;
	F[13] = instance.parameters.F13;
	F[14] = instance.parameters.F14;
	F[15] = instance.parameters.F15;
	F[16] = instance.parameters.F16;
	 

	source = instance.source;
	 
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. source:barSize()..  ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	
		
	
		MACD=core.indicators:create("MACD",  source[Price], SN, LN, IN);
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
	    MA1=core.indicators:create(Method1,  source[Price], Period1);
		MA2=core.indicators:create( Method2,  source[Price], Period2);
        RSI=core.indicators:create("RSI",  source[Price], RSI_Period);
		SSD=core.indicators:create("SSD",  source, SSD1, SSD2, SSD3);
	
	if (LN <= SN) then
       error("The short EMA period must be smaller than long EMA period");
    end
	
	first= math.max(MA1.DATA:first(), MA2.DATA:first(), MACD.HISTOGRAM:first(), RSI.DATA:first(), SSD.D:first());

    	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
		
end

-- Indicator calculation routine
function Update(period, mode)
	
    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
	
			   MACD:update(mode);
			   MA1:update(mode);
			   MA2:update(mode);
			   RSI:update(mode);
			   SSD:update(mode);
	
			if period < first then
			open:setColor(period, Neutral);	
			return;
			end
	
    local Flag={};
    
	
	 

	
        --"Use 1. Price/MA Filter"  	
		if F[1] then
			if source.close[period] > MA1.DATA[period] then
			Flag[1] = 1;
			elseif source.close[period] < MA1.DATA[period] then
			Flag[1] = -1;
			else
			Flag[1] = 0;
			end	 
		else	
		Flag[1] = 0;	
        end
		
		--"Use 1. MA Slope Filer"
		if F[2] then
			if  MA1.DATA[period] > MA1.DATA[period-1] then
			Flag[2] = 1;
			elseif  MA1.DATA[period]  < MA1.DATA[period-1] then
			Flag[2] = -1;
			else
			Flag[2] = 0;
			end	 
		else	
		Flag[2] = 0;	
        end
		
		
		
		   --"Use 2. Price/MA Filter"  	
		if F[3] then
			if source.close[period] > MA2.DATA[period] then
			Flag[3] = 1;
			elseif source.close[period] < MA2.DATA[period] then
			Flag[3] = -1;
			else
			Flag[3] = 0;
			end	 
		else	
		Flag[3] = 0;	
        end
		
		--"Use 2. MA Slope Filer"
		if F[4] then
			if  MA2.DATA[period] > MA2.DATA[period-1] then
			Flag[4] = 1;
			elseif  MA2.DATA[period]  < MA2.DATA[period-1] then
			Flag[4] = -1;
			else
			Flag[4] = 0;
			end	 
		else	
		Flag[4] = 0;	
        end
	  
 
			--"Use 1.MA /2.MA Filer"
		if F[5] then
			if  MA1.DATA[period] > MA2.DATA[period-1] then
			Flag[5] = 1;
			elseif  MA1.DATA[period] < MA2.DATA[period-1] then
			Flag[5] = -1;
			else
			Flag[5] = 0;
			end	 
		else	
		Flag[5] = 0;	
        end
		 
	
	--"Use MACD/Signal Filter"
	
	 
		if F[6] then
			if  MACD.MACD[period] > MACD.SIGNAL[period] then
			Flag[6] = 1;
			elseif  MACD.MACD[period] < MACD.SIGNAL[period] then
			Flag[6] = -1;
			else
			Flag[6] = 0;
			end	 
		else	
		Flag[6] = 0;	
        end
		
		
		
	
	--"Use MACD/Zero Filter"
	
	if F[7] then
			if  MACD.MACD[period] > 0 then
			Flag[7] = 1;
			elseif  MACD.MACD[period] < 0 then
			Flag[7] = -1;
			else
			Flag[7] = 0;
			end	 
		else	
		Flag[7] = 0;	
        end
	
	--"Use MACD Slope Filter"
	
	if F[8] then
			if  MACD.MACD[period] > MACD.MACD[period-1]  then
			Flag[8] = 1;
			elseif  MACD.MACD[period]  < MACD.MACD[period-1]  then
			Flag[8] = -1;
			else
			Flag[8] = 0;
			end	 
		else	
		Flag[8] = 0;	
        end
	
	-- "Use MACD Histogram/Zero Filter"
	
	if F[9] then
			if  MACD.HISTOGRAM[period] > 0 then
			Flag[9] = 1;
			elseif  MACD.HISTOGRAM[period] < 0 then
			Flag[9] = -1;
			else
			Flag[9] = 0;
			end	 
		else	
		Flag[9] = 0;	
        end
		
		
	
	--"Use MACD Histogram Slope Filter"
			   
	 if F[10] then
			if  MACD.HISTOGRAM[period] > MACD.HISTOGRAM[period-1]  then
			Flag[10] = 1;
			elseif  MACD.HISTOGRAM[period]  < MACD.HISTOGRAM[period-1]  then
			Flag[10] = -1;
			else
			Flag[10] = 0;
			end	 
		else	
		Flag[10] = 0;	
        end
		
		
--"Use RSI / Central Line Filter"

      if F[11] then
			if  RSI.DATA[period] > 50  then
			Flag[11] = 1;
			elseif   RSI.DATA[period] < 50  then
			Flag[11] = -1;
			else
			Flag[11] = 0;
			end	 
		else	
		Flag[11] = 0;	
        end
		
--"Use RSI Slope Filter"

      if F[12] then
			if  RSI.DATA[period] > RSI.DATA[period-1]  then
			Flag[12] = 1;
			elseif   RSI.DATA[period] < RSI.DATA[period-1]  then
			Flag[12] = -1;
			else
			Flag[12] = 0;
			end	 
		else	
		Flag[12] = 0;	
        end
		
		
	--"Use SSD/Signal Filter"
	    if F[13] then
			if  SSD.K[period] > SSD.D[period-1]  then
			Flag[13] = 1;
			elseif  SSD.K[period] < SSD.D[period-1]  then
			Flag[13] = -1;
			else
			Flag[13] = 0;
			end	 
		else	
		Flag[13] = 0;	
        end
	
	--"Use SSD/Zero Filter"
	if F[14] then
			if  SSD.K[period] > 0 then
			Flag[14] = 1;
			elseif  SSD.K[period] < 0  then
			Flag[14] = -1;
			else
			Flag[14] = 0;
			end	 
		else	
		Flag[14] = 0;	
        end
	
	--"Use SSD Slope Filter"
		if F[15] then
			if  SSD.K[period] > SSD.K[period-1]  then
			Flag[15] = 1;
			elseif  SSD.K[period] < SSD.K[period-1]  then
			Flag[15] = -1;
			else
			Flag[15] = 0;
			end	 
		else	
		Flag[15] = 0;	
        end
		
		--"Price Filter"
		if F[16] then
			if  source.close[period] > source.open[period]  then
			Flag[16] = 1;
			elseif  source.close[period] < source.open[period]  then
			Flag[16] = -1;
			else
			Flag[16] = 0;
			end	 
		else	
		Flag[16] = 0;	
        end
		 
		
		if not F[1]
		and not F[2]
		and  not F[3]
		and not F[4]
		and not F[5] 
		and not F[6]
		and not F[7]
		and not F[8]
		and not F[9] 
		and not F[10] 
		and not F[11] 
		and not F[12] 
		and not F[13] 
		and not F[14] 
		and not F[15]
        and not F[16] 		
		then
		open:setColor(period,Neutral);	   
		elseif (Flag[1] == 1  or not F[1])
		and  (Flag[2] == 1 or not F[2])
		and  (Flag[3] == 1 or not F[3])
		and  (Flag[4] == 1 or not F[4])
		and  (Flag[5] == 1 or not F[5])
		and  (Flag[6] == 1 or not F[6]) 
		and  (Flag[7] == 1 or not F[7])  
		and  (Flag[8] == 1 or not F[8]) 
		and  (Flag[9] == 1 or not F[9]) 
		and  (Flag[10] == 1 or not F[10])
		and  (Flag[11] == 1 or not F[11]) 
		and  (Flag[12] == 1 or not F[12])
		and  (Flag[13] == 1 or not F[13])
		and  (Flag[14] == 1 or not F[14]) 
		and  (Flag[15] == 1 or not F[15])
		and  (Flag[16] == 1 or not F[16])
		then	
		open:setColor(period,  Up);
        elseif (Flag[1] == -1 or not F[1])  
		and  (Flag[2] == -1 or not F[2])
		and  (Flag[3] ==- 1 or not F[3]) 
		and  (Flag[4] == -1 or not F[4])
		and  (Flag[5] ==- 1 or not F[5]) 
		and  (Flag[6] == -1 or not F[6]) 
		and  (Flag[7] == -1 or not F[7])  
		and  (Flag[8] ==- 1 or not F[8]) 
		and  (Flag[9] ==- 1 or not F[9]) 
		and  (Flag[10] ==- 1 or not F[10]) 
		and  (Flag[11] ==- 1 or not F[11]) 
		and  (Flag[12] ==- 1 or not F[12]) 
		and  (Flag[13] ==- 1 or not F[13]) 
		and  (Flag[14] ==- 1 or not F[14]) 
		and  (Flag[15] ==- 1 or not F[15]) 
		and  (Flag[16] ==- 1 or not F[16]) 
		then	
		open:setColor(period,  Down);
		else
		open:setColor(period, Neutral);			
		end
		
		
				

		
 end


