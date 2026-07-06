-- Id: 8693
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=32838

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

-- The indicator corresponds to the Ichimoku Kinko Hyo indicator in MetaTrader.

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("MACD / CCI Consensus");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
   
    indicator.parameters:addGroup("Selector");
    indicator.parameters:addBoolean("One", "Use MACD Filter", "", true);
	indicator.parameters:addBoolean("Two", "Use CCI Filter", "", true);

	indicator.parameters:addGroup("MACD Calculation");
		
    indicator.parameters:addString("MACD_Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("MACD_Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("MACD_Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("MACD_Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("MACD_Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("MACD_Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("MACD_Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("MACD_Price", "WEIGHTED", "", "weighted");	
	
	indicator.parameters:addInteger("MACD_Short", "Short Period", "", 144);
	indicator.parameters:addInteger("MACD_Long", "Long Period", "", 233);
	indicator.parameters:addInteger("MACD_Signal", "Signal Period", "", 21);
	
	 indicator.parameters:addInteger("MACD_Selektor", "MACD Component", "",  0);
    indicator.parameters:addIntegerAlternative("MACD_Selektor", "MACD", "", 0);
    indicator.parameters:addIntegerAlternative("MACD_Selektor", "Signal", "", 1);
	indicator.parameters:addIntegerAlternative("MACD_Selektor", "Histogram", "", 2);
	
	indicator.parameters:addGroup("CCI Calculation");
	indicator.parameters:addInteger("CCI", "Period", "", 50);
	
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
 
 


-- Routine
 function Prepare(nameOnly)   
  
   
	Transparency= (100 -instance.parameters.Transparency);
	
	One= instance.parameters.One;
	Two= instance.parameters.Two;

 
	
	Parameters["CCI"] = instance.parameters.CCI;
	
	Parameters["MACD_Short"] = instance.parameters.MACD_Short;
	Parameters["MACD_Long"] = instance.parameters.MACD_Long;
	Parameters["MACD_Signal"] = instance.parameters.MACD_Signal;
    Parameters["MACD_Price"] = instance.parameters.MACD_Price;
	Parameters["MACD_Selektor"] = instance.parameters.MACD_Selektor;
	
	
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    
     if   (nameOnly) then
        return;
    end
	
	if One then
	  Indicator["MACD"]= core.indicators:create("MACD", source[Parameters["MACD_Price"]] ,Parameters["MACD_Short"], Parameters["MACD_Long"], Parameters["MACD_Signal"]);
	 first = math.max(first,Indicator["MACD"].DATA:first() );
	end
	
	if Two then
	 Indicator["CCI"]= core.indicators:create("CCI", source ,Parameters["CCI"]);
	 first = math.max(first,Indicator["CCI"].DATA:first() );
	end
	
	open = instance:addStream("open", core.Line, name, "", core.rgb(0, 0, 0), first);
    open:setPrecision(math.max(2, instance.source:getPrecision()));
    close = instance:addStream("high", core.Line, name, "", core.rgb(0, 0, 0), first);   
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
		
	
		if One then
		
	     Indicator["MACD"]:update(mode);
			
		    if Indicator["MACD"]:getStream(Parameters["MACD_Selektor"])[period]   > Indicator["MACD"]:getStream(Parameters["MACD_Selektor"])[period-1] then
			ONE  = true;
			else
			ONE = false;
			end  
	   
        end
		
		if Two then
		 
		  Indicator["CCI"]:update(mode);
		   
		    if Indicator["CCI"].DATA[period] >  0 then
			TWO = true;
			else
			TWO = false;
			end
			
		end
		
		 
		
		 
		
		if not One and  not Two 
		then
		open:setColor(period, instance.parameters.No);	   
		elseif (ONE == true or not One)  
		and (TWO  == true  or not Two)  		
		then		
		open:setColor(period, instance.parameters.Up);
        elseif(ONE == false or not One) 
		and  (TWO == false or not Two) 
		then
		open:setColor(period, instance.parameters.Dn);
		else
		open:setColor(period, instance.parameters.No);			
		end
        
  
end






