-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=22965
-- Id: 7267

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Average True Range vs Standard Deviation");
    indicator:description("Average True Range vs Standard Deviation");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("AP", "ATR Period", "ATR Period", 14);
    indicator.parameters:addInteger("SP", "SD Period", "SP Period", 14);
	
	indicator.parameters:addString("Price" , "SD Data Source", "", "close");
    indicator.parameters:addStringAlternative("Price" , "Open", "", "open");
    indicator.parameters:addStringAlternative("Price", "High", "", "high");
    indicator.parameters:addStringAlternative("Price" , "Low", "", "low");
	indicator.parameters:addStringAlternative("Price" , "Close", "", "close");
	indicator.parameters:addStringAlternative("Price", "Median", "", "median");
    indicator.parameters:addStringAlternative("Price" , "Typical", "", "typical");
	indicator.parameters:addStringAlternative("Price" , "Weighted ", "", "weighted");	
	 indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Tranding", "Tranding Market", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Ranging", "Ranging/Sideways market", "", core.rgb(255,0, 0));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Value;
local Price;
local first;
local source = nil;


-- Routine
function Prepare(nameOnly)
    AP = instance.parameters.AP;
    SP = instance.parameters.SP;
    source = instance.source;
    Price = instance.parameters.Price;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(AP) .. ", " .. tostring(SP) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
	
        A= core.indicators:create("ATR", source, AP);
        
         first = math.max(A.DATA:first(), SP);
      --  Value = instance:addStream("Value", core.Bar, name .. ".ATR vs SD", "ATR vs SD", core.rgb(128, 128,128), first);
	    open = instance:addStream("open", core.Line, name, "open", core.rgb(128, 128,128), first);    
        close = instance:addStream("close", core.Line, name, "close", core.rgb(128, 128,128), first); 
	    instance:createChannelGroup ("ZONE", "ZONE", open, close, core.rgb(128, 128,128), 100)
		
		open:setPrecision(math.max(2, instance.source:getPrecision()));
	    close:setPrecision(math.max(2, instance.source:getPrecision()));
 
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period >= first and source:hasData(period) then
	
	 close[period]= 1;
	 open[period]= 0;
	
	    A:update(mode); 
	    if A.DATA[period] > mathex.stdev(source[Price], period - SP + 1, period) then
		open:setColor(period, instance.parameters.Ranging);	  
		else
		open:setColor(period, instance.parameters.Tranding);	 
		end
	   
       
    end
end

