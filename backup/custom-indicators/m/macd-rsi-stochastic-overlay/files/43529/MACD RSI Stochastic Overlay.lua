-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=25319 

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
    indicator:name("MACD RSI Stochastic Overlay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("MACD Calculation");
	indicator.parameters:addString("Price1" , "Data Source", "", "close");
    indicator.parameters:addStringAlternative("Price1" , "Open", "", "open");
    indicator.parameters:addStringAlternative("Price1", "High", "", "high");
    indicator.parameters:addStringAlternative("Price1" , "Low", "", "low");
	indicator.parameters:addStringAlternative("Price1" , "Close", "", "close");
	indicator.parameters:addStringAlternative("Price1", "Median", "", "median");
    indicator.parameters:addStringAlternative("Price1" , "Typical", "", "typical");
	indicator.parameters:addStringAlternative("Price1" , "Weighted ", "", "weighted");	
	
	indicator.parameters:addInteger("SN", "Short EMA", "", 12, 2, 1000);
    indicator.parameters:addInteger("LN", "Long EMA", "", 26, 2, 1000);
    indicator.parameters:addInteger("IN", "Signal Line", "", 9, 2, 1000);
	
		indicator.parameters:addGroup("RSI Calculation");
	indicator.parameters:addString("Price2" , "Data Source", "", "close");
    indicator.parameters:addStringAlternative("Price2" , "Open", "", "open");
    indicator.parameters:addStringAlternative("Price2", "High", "", "high");
    indicator.parameters:addStringAlternative("Price2" , "Low", "", "low");
	indicator.parameters:addStringAlternative("Price2" , "Close", "", "close");
	indicator.parameters:addStringAlternative("Price2", "Median", "", "median");
    indicator.parameters:addStringAlternative("Price2" , "Typical", "", "typical");
	indicator.parameters:addStringAlternative("Price2" , "Weighted ", "", "weighted");		
	indicator.parameters:addInteger("RP", "Period", "", 14, 2, 1000);	
		
	indicator.parameters:addGroup("Stochastic Calculation");
	
	indicator.parameters:addInteger("K", "Number of periods for %K", "The number of periods for %K.", 5, 2, 1000);
    indicator.parameters:addInteger("SD", "%D slowing periods", "The number of periods for slow %D.", 3, 2, 1000);
    indicator.parameters:addInteger("D", "Number of periods for %D", "The number of periods for %D.", 3, 2, 1000);

    indicator.parameters:addString("MVAT_K", "Smoothing type for %K", "The type of smoothing algorithm for %K.", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K", "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K", "EMA", "EMA", "EMA");
    indicator.parameters:addStringAlternative("MVAT_K", "MetaTrader", "The MetaTrader algorithm.", "MT");
	indicator.parameters:addStringAlternative("MVAT_K" , "LWMA", "", "LWMA");	
	indicator.parameters:addStringAlternative("MVAT_K" , "KAMA", "", "KAMA");	
	indicator.parameters:addStringAlternative("MVAT_K" , "SMMA", "", "SMMA");	
	indicator.parameters:addStringAlternative("MVAT_K" , "TMA", "", "TMA");	
	indicator.parameters:addStringAlternative("MVAT_K" , "VIDYA", "", "VIDYA");	
	indicator.parameters:addStringAlternative("MVAT_K" , "WMA", "", "WMA");	
    
    indicator.parameters:addString("MVAT_D", "Smoothing type for %D", "The type of smoothing algorithm for %D.", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D", "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D", "EMA", "EMA", "EMA");
	indicator.parameters:addStringAlternative("MVAT_D" , "LWMA", "", "LWMA");	
	indicator.parameters:addStringAlternative("MVAT_D" , "KAMA", "", "KAMA");	
	indicator.parameters:addStringAlternative("MVAT_D" , "SMMA", "", "SMMA");	
	indicator.parameters:addStringAlternative("MVAT_D" , "TMA", "", "TMA");	
	indicator.parameters:addStringAlternative("MVAT_D" , "VIDYA", "", "VIDYA");	
	indicator.parameters:addStringAlternative("MVAT_D" , "WMA", "", "WMA");	
	
	 
   indicator.parameters:addGroup("ADX Calculation");
     indicator.parameters:addInteger("Period", "Period", "", 14);
    indicator.parameters:addDouble("Alpha1", "Alpha1", "", 0.25);
    indicator.parameters:addDouble("Alpha2", "Alpha2", "", 0.33);
	indicator.parameters:addDouble("Level", "Level", "", 20);
	
	
	indicator.parameters:addGroup("CCI Calculation");
	indicator.parameters:addInteger("CCIPeriod", "Period", "", 14, 2, 1000);
	
	indicator.parameters:addGroup("SAR Calculation");
	 indicator.parameters:addDouble("Step", "Step", "", 0.02 );
    indicator.parameters:addDouble("Max", "Max", "", 0.2 );
	
	indicator.parameters:addGroup("Selector");
    indicator.parameters:addBoolean("One", "Use MACD Filter", "", true);
	indicator.parameters:addBoolean("Two", "Use RSI Filter", "", true);
	indicator.parameters:addBoolean("Three", "Use Stochastic Filter", "", true);
	indicator.parameters:addBoolean("Four", "Use CCI Filter", "", true);
	indicator.parameters:addBoolean("Fifth", "Use ADX Filter", "", true);
	indicator.parameters:addBoolean("Sixth", "Use PSAR Filter", "", true);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Dn", "Down color", "", core.rgb(255, 0, 0));
		indicator.parameters:addColor("No", "Neutral color", "", core.rgb(128, 128, 128));

   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;

local Price1,Price2;

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

local SN, LN, IN= nil;
local MACD;

local RSI;
local RP;

local SAR, Step,Max;

local k;
local d;
local sd;
local averageTypeK = nil;
local averageTypeD = nil;

local STOCHASTIC;

local CCI, CCIPeriod;
local One, Two, Three,Four,Fifth,Sixth;
local Alpha1, Alpha2, Period, ADX,Level;

 function Prepare(nameOnly)  
    k = instance.parameters.K;
    d = instance.parameters.D;
    sd = instance.parameters.SD;
	CCIPeriod= instance.parameters.CCIPeriod;
	
	averageTypeK = instance.parameters.MVAT_K;
    averageTypeD = instance.parameters.MVAT_D;
	
    RP= instance.parameters.RP;	
    IN = instance.parameters.IN;
	SN = instance.parameters.SN;
    LN = instance.parameters.LN;
	Price1 = instance.parameters.Price1;
	Price2 = instance.parameters.Price2;
	
	Alpha1 = instance.parameters.Alpha1;
	Alpha2 = instance.parameters.Alpha2;
	Period = instance.parameters.Period;
    Level= instance.parameters.Level;
	
	One= instance.parameters.One;
	Two= instance.parameters.Two;
	Three= instance.parameters.Three;
	Four= instance.parameters.Four;
	Fifth= instance.parameters.Fifth;
	Sixth= instance.parameters.Sixth;
	
	Step= instance.parameters.Step;
	Max= instance.parameters.Max;
	
	if (LN <= SN) then
       error("The short EMA period must be smaller than long EMA period");
    end
	
	
	assert(core.indicators:findIndicator("SMOOTHED_ADX") ~= nil, "Please, download and install SMOOTHED_ADX.LUA indicator");

	source = instance.source;
	

   
    local name = profile:id() .. "(" .. source:name() .. ", "..source:barSize() 
	.." MACD:  ".. Price1 .. ", " .. SN..", " .. LN .. ", " .. IN 
	.." RSI: ".. Price2..", ".. RP
	.. " Stochastic: " .. k .. ", " .. sd .. ", " .. d .. ", " .. averageTypeK .. ", " .. averageTypeD
	.. " CCI: " .. CCIPeriod
	.. " ADX: " .. Period	 .. ", "  .. Alpha1 .. ", "..   Alpha2
	.. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
		
	
		MACD=core.indicators:create("MACD",  source[Price1], SN, LN, IN);
	    RSI=core.indicators:create("RSI",  source[Price2], RP);
		STOCHASTIC=core.indicators:create("STOCHASTIC",  source, k , sd ,d , averageTypeK , averageTypeD);
        CCI=core.indicators:create("CCI",  source,CCIPeriod);
	    ADX=core.indicators:create("SMOOTHED_ADX",  source,Period, Alpha1,Alpha2);
	    SAR= core.indicators:create("SAR", source,Step,  Max);
	first= math.max(RSI.DATA:first(), MACD.SIGNAL:first(),STOCHASTIC.D:first(), CCI.DATA:first(), ADX.DATA:first());

    	
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
	RSI:update(mode);
	STOCHASTIC:update(mode);
	CCI:update(mode);
	ADX:update(mode);
	SAR:update(mode);
	
			if period < first then
			return;
			end
	

    local ONE=nil;
	local TWO=nil;
	local THREE=nil;
	local FOUR=nil;
	local FIVE=0;	
    local SIX=nil;			  
			   
		if One then
			if MACD.MACD[period] > MACD.SIGNAL[period] then
			ONE = true;
			elseif MACD.MACD[period] < MACD.SIGNAL[period] then
			ONE = false;
			end
        end
		
		if Two then
		   if RSI.DATA[period] > 50 then
			TWO = true;
			elseif RSI.DATA[period] < 50 then
			TWO = false;
			end  
		end
		
		if Three then
		    if STOCHASTIC.K[period] > STOCHASTIC.D[period] then
			THREE = true;
			elseif STOCHASTIC.K[period] < STOCHASTIC.D[period] then
			THREE = false;
			end  
		end
 		
		if Four then
		    if CCI.DATA[period] > 0 then
			FOUR = true;
			elseif CCI.DATA[period] < 0 then
			FOUR = false;
			end  
		end
		 
		
		if Fifth then
				 if ADX.ADX[period] > Level then
							if   ADX.DIP[period] > Level
							and  ADX.DIP[period] >ADX.DIM[period]
							then
							FIVE = 1;
							elseif   ADX.DIM[period] > Level
							and  ADX.DIP[period] <ADX.DIM[period]
							then
							FIVE = -1;
							else
							FIVE = 0;
							end  
					else
					FIVE = 0;
					end
		else	
		FIVE = 0;	
		end
		 
	    if Sixth then
			 
		   if SAR.DN:hasData(period) then
			SIX = true;
			elseif SAR.UP:hasData(period) then
			SIX = false;
			end  
			
		end
		 
		 
		 
		
		if One == false   and  Two == false  and Three == false  and Four == false and Fifth== false and Sixth== false then
		open:setColor(period, instance.parameters.No);	  
		elseif  (ONE == true or One == false)  and  ( TWO == true or Two == false) and ( THREE == true or Three == false)   and ( FOUR == true or Four == false)   and ( FIVE == 1 or Fifth == false)  and ( SIX == true or Sixth == false)    then		
		open:setColor(period, instance.parameters.Up);	  
        elseif (ONE == false or One == false)  and  ( TWO == false or Two == false) and ( THREE == false or Three == false)  and ( FOUR == false or Four == false)   and ( FIVE == -1 or Fifth == false)  and ( SIX == false or Sixth == false)   then
		open:setColor(period, instance.parameters.Dn);	  
		else
		open:setColor(period, instance.parameters.No);	  	
		end
		
				

		
 end


