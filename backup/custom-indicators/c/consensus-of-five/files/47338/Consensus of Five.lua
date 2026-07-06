-- Id: 7984

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27184

--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Consensus of Five");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
   
    indicator.parameters:addGroup("Selector");
    indicator.parameters:addBoolean("One", "Use DMI Filter", "", true);
	indicator.parameters:addBoolean("Two", "Use ADX Filter", "", true);
	indicator.parameters:addBoolean("Three", "Use CCI Filter", "", true);
	indicator.parameters:addBoolean("Four", "Use MACD Filter", "", true);
	indicator.parameters:addBoolean("Five", "Use Stochastic Filter", "", true);
	
	indicator.parameters:addGroup("DMI Calculation");
	indicator.parameters:addInteger("DMI", "Period", "", 14);
	
	indicator.parameters:addGroup("ADX Calculation");
	indicator.parameters:addInteger("ADX", "Period", "", 14);
	indicator.parameters:addDouble("ADX_Entry", "Entry Level", "", 20);
	indicator.parameters:addDouble("ADX_Exit", "Exit Level", "", 40);
	
	indicator.parameters:addGroup("CCI Calculation");
	indicator.parameters:addInteger("CCI", "Period", "", 14);
	indicator.parameters:addDouble("CCI_Buy", "Buy Level", "", 0);
	indicator.parameters:addDouble("CCI_Sell", "Sell Level", "", 0);
	
	
	indicator.parameters:addGroup("MACD Calculation");
	indicator.parameters:addInteger("MACD_Short", "Short Period", "", 12);
	indicator.parameters:addInteger("MACD_Long", "Long Period", "", 26);
	indicator.parameters:addDouble("MACD_Buy", "Buy Level", "", 0);
	indicator.parameters:addDouble("MACD_Sell", "Sell Level", "", 0);
	
	indicator.parameters:addString("MACD_Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("MACD_Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("MACD_Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("MACD_Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("MACD_Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("MACD_Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("MACD_Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("MACD_Price", "WEIGHTED", "", "weighted");	
	
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
	
	indicator.parameters:addDouble("OB", "OB Level", "", 80);
    indicator.parameters:addDouble("OS", "OS Level", "", 20);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Dn", "Down color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No", "Neutral color", "", core.rgb(0, 0, 255));
	 indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);


end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local first;
local source = nil;
local open, close;
local Parameters={}; 
local Indicator={};
local One, Two, Three, Four, Five;

local k;
local d;
local sd;
local averageTypeK = nil;
local averageTypeD = nil;
local OB, OS;


-- Routine
function Prepare(nameOnly)
   
	Transparency= (100 -instance.parameters.Transparency);
	One= instance.parameters.One;
	Two= instance.parameters.Two;
	Three= instance.parameters.Three;
	Four= instance.parameters.Four;
	Five= instance.parameters.Five;
	
	Parameters["DMI"] = instance.parameters.DMI;
	Parameters["ADX"] = instance.parameters.ADX;
	Parameters["ADX_Entry"] = instance.parameters.ADX_Entry;
	Parameters["ADX_Exit"] = instance.parameters.ADX_Exit;
	
	
	Parameters["CCI"] = instance.parameters.CCI;
	Parameters["CCI_Buy"] = instance.parameters.CCI_Buy;
	Parameters["CCI_Sell"] = instance.parameters.CCI_Sell;
	
	Parameters["MACD_Short"] = instance.parameters.MACD_Short;
	Parameters["MACD_Long"] = instance.parameters.MACD_Long;
	Parameters["MACD_Buy"] = instance.parameters.MACD_Buy;
	Parameters["MACD_Sell"] = instance.parameters.MACD_Sell;
	Parameters["MACD_Price"] = instance.parameters.MACD_Price;
	
	 k = instance.parameters.K;
    d = instance.parameters.D;
    sd = instance.parameters.SD;
	
	averageTypeK = instance.parameters.MVAT_K;
    averageTypeD = instance.parameters.MVAT_D;
	
	 OB = instance.parameters.OB;
   OS = instance.parameters.OS;
	
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if nameOnly then
		return;
	end
    
   
	
	if One then
	 Indicator["DMI"]= core.indicators:create("DMI", source ,Parameters["DMI"]);
	 first = math.max(first,Indicator["DMI"].DATA:first() );
	end
	
	if Two then
	 Indicator["ADX"]= core.indicators:create("ADX", source ,Parameters["ADX"]);
	 first = math.max(first,Indicator["ADX"].DATA:first() );
	end
	
	
		if Three then
	 Indicator["CCI"]= core.indicators:create("CCI", source ,Parameters["CCI"]);
	 first = math.max(first,Indicator["CCI"].DATA:first() );
	end
	
	
	 if Four then
	 Indicator["MACD"]= core.indicators:create("MACD", source[Parameters["MACD_Price"]] ,Parameters["MACD_Short"], Parameters["MACD_Long"]);
	 first = math.max(first,Indicator["MACD"].DATA:first() );
	end
	
	 if Five then
	 Indicator["STO"]= core.indicators:create("STOCHASTIC",  source, k , d ,sd , averageTypeK , averageTypeD);
	 first = math.max(first,Indicator["STO"].D:first() );
	end
   
	open = instance:addStream("open", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("high", core.Line, name, "", core.rgb(0, 0, 0), first);   
	open:setPrecision(math.max(2, instance.source:getPrecision()));
	close:setPrecision(math.max(2, instance.source:getPrecision()));
   instance:createChannelGroup("UpGroup","Up" , open, close, instance.parameters.Up, Transparency);
end

-- Indicator calculation routine
function Update(period, mode)


    open[period] = 1;
	close[period] = 0;

	
	open:setColor(period, instance.parameters.No);	

   
	local ONE=nil;
	local TWO=nil;
	local THREE_B=nil;
	local THREE_S=nil;
	local FOUR_B=nil;
	local FOUR_S=nil;
	local FIVE_B=nil;	
	local FIVE_S=nil;	
	
		if One then
		
		Indicator["DMI"]:update(mode);
		
		   if Indicator["DMI"]:getStream(0)[period] > Indicator["DMI"]:getStream(1)[period] then
			ONE = true;
			else
			ONE = false;
			end
        end
		
		if Two then
		
		  Indicator["ADX"]:update(mode);
		  
		   if Indicator["ADX"].DATA[period] >  Parameters["ADX_Entry"]
		   and Indicator["ADX"].DATA[period] <  Parameters["ADX_Exit"]
		   then
			TWO = true;
			else
			TWO = false;
			end  
		end
		
		if Three then
		   Indicator["CCI"]:update(mode);
		   
		    if Indicator["CCI"].DATA[period] >  Parameters["CCI_Buy"] then
			THREE_B = true;
			else
			THREE_B = false;
			end
			
			if Indicator["CCI"].DATA[period] <  Parameters["CCI_Sell"] then
			THREE_S = false;
			else
			THREE_S = true;
			end  
		end
		
		if Four then
		
		    Indicator["MACD"]:update(mode);
			
		    if Indicator["MACD"].DATA[period] >  Parameters["MACD_Buy"] then
			FOUR_B  = true;
			else
			FOUR_B = false;
			end  
			
			
			if Indicator["MACD"].DATA[period] <  Parameters["MACD_Sell"] then
			FOUR_S  = false;
			else
			FOUR_S = true;
			end  
		end
		
 		if Five then 
		
		    Indicator["STO"]:update(mode);
			 
		    if  Indicator["STO"].K[period] > Indicator["STO"].D[period]
			and Indicator["STO"].D[period] < OB 
			then
			FIVE_B  = true;
			else
			FIVE_B = false;
			end  
			
			if  Indicator["STO"].K[period] < Indicator["STO"].D[period]
			and Indicator["STO"].D[period] > OS 
			then
			FIVE_S  = false;
			else
			FIVE_S = true;
			end  
		end
		
		 
		
		if ONE == nil   and  TWO == nil  and THREE_B == nil  and THREE_S == nil and FOUR_B== nil and FOUR_S== nil and FIVE_B== nil  and FIVE_S== nil  then
		open:setColor(period, instance.parameters.No);	   
		elseif (ONE == true or ONE == nil)  
		and (TWO  == true  or TWO == nil)  
		and (THREE_B  == true  or THREE_B == nil) 
		and (FOUR_B == true   or FOUR_B == nil)  
		and (FIVE_B == true   or FIVE_B == nil) 
		then		
		open:setColor(period, instance.parameters.Up);
        elseif(ONE == false or ONE == nil) 
		and  (TWO == true or TWO == nil) 
		and (THREE_S == false or THREE_S == nil)   
		and (FOUR_S == false or FOUR_S == nil)  
		and (FIVE_S  == false or FIVE_S == nil)  
		then
		open:setColor(period, instance.parameters.Dn);
		else
		open:setColor(period, instance.parameters.No);			
		end
		
		
		
        
  
end






