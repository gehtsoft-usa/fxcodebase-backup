-- Id: 9422
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

-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=41822

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("MA Difference");
    indicator:description("MA Difference");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Selector");	
	indicator.parameters:addBoolean("U1", "Show MA1 / Price Difference ", "", true);
	indicator.parameters:addBoolean("U2", "Show MA2 / Price Difference ", "", true);
	indicator.parameters:addBoolean("U3", "Show MA1 / MA2 Difference ", "", true);
	
	
    indicator.parameters:addGroup("First MA Calculation");	
    indicator.parameters:addInteger("P1", "First MA Period", "", 14);
 
	indicator.parameters:addString("Method1", "First MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
    indicator.parameters:addGroup("Second MA Calculation");	
    indicator.parameters:addInteger("P2", "Second MA Period", "", 14);	
	indicator.parameters:addString("Method2", "Second MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
   
    indicator.parameters:addGroup("Style");
	

    indicator.parameters:addColor("PM1_color", "Color of MA1 / Price Difference", "Color of MA1 / Price Difference", core.rgb(0, 255, 0));
	indicator.parameters:addString("Type1", "Bar/Line", "Method" , "Line");
    indicator.parameters:addStringAlternative("Type1", "Line", "Line" , "Line");
    indicator.parameters:addStringAlternative("Type1", "Bar", "Bar" , "Bar");
	
	
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	
	
    indicator.parameters:addColor("PM2_color", "Color of MA2 / Price Difference", "Color of MA2 / Price Difference", core.rgb(255, 0, 0));	
	indicator.parameters:addString("Type2", "Bar/Line", "Method" , "Line");
    indicator.parameters:addStringAlternative("Type2", "Line", "Line" , "Line");
    indicator.parameters:addStringAlternative("Type2", "Bar", "Bar" , "Bar");
	
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
    indicator.parameters:addColor("M1M2_color", "Color of MA1 / MA2 Difference", "Color of MA1 / MA2 Difference", core.rgb(0, 0, 255));
	indicator.parameters:addString("Type3", "Bar/Line", "Method" , "Line");
    indicator.parameters:addStringAlternative("Type3", "Line", "Line" , "Line");
    indicator.parameters:addStringAlternative("Type3", "Bar", "Bar" , "Bar");
	
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first;
local source = nil;
local P1, P2;
-- Streams block
local PM1 = nil;
local PM2 = nil;
local M1M2 = nil;
local One,Two;
local U1, U2,U3;
local Type3, Type2, Type1;
local Method1, Method2;
-- Routine
function Prepare(nameOnly)
    Method1 = instance.parameters.Method1;
	 Method2 = instance.parameters.Method2;
	 P1 = instance.parameters.P1;
	 P2 = instance.parameters.P2;
	 U1 = instance.parameters.U1;
	 U2 = instance.parameters.U2;
	 U3 = instance.parameters.U3;
	 Type3 = instance.parameters.Type3;
	 Type2 = instance.parameters.Type2;
	 Type1 = instance.parameters.Type1;
    source = instance.source;
    

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Method1).. ", " .. tostring(P1).. ", " .. tostring(Method2).. ", " .. tostring(P2) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	One= core.indicators:create( Method1, source, P1);
    Two = core.indicators:create( Method2, source, P2);

	 
	first = math.max(One.DATA:first(), Two.DATA:first());

     
	    if U1 then
			if Type1 == "Bar" then
			PM1 = instance:addStream("PM1", core.Bar, name .. ". Price / MA1 ", " Price / MA1 ", instance.parameters.PM1_color, first);
    		else		
			PM1 = instance:addStream("PM1", core.Line, name .. ". Price / MA1 ", " Price / MA1 ", instance.parameters.PM1_color, first);
			PM1:setWidth(instance.parameters.width1);
			PM1:setStyle(instance.parameters.style1);
			end
			PM1:setPrecision(math.max(2, instance.source:getPrecision()));
    	else
		PM1 = instance:addInternalStream(0, 0);
		end
		
		 if U2 then
				 if Type2 == "Bar" then
				 PM2 = instance:addStream("PM2", core.Bar, name .. ". Price / MA2 ", " Price / MA2 ", instance.parameters.PM2_color, first);
				 else
				PM2 = instance:addStream("PM2", core.Line, name .. ". Price / MA2 ", " Price / MA2 ", instance.parameters.PM2_color, first);
				PM2:setWidth(instance.parameters.width2);
				PM2:setStyle(instance.parameters.style2);
				end
		else
		PM2 = instance:addInternalStream(0, 0);
		end
		 if U3 then
			 if Type3 == "Bar" then
			 M1M2 = instance:addStream("M1M2", core.Bar, name .. ". MA1 / MA2 ", " MA1 / MA2 ", instance.parameters.M1M2_color, first);
			 else
			M1M2 = instance:addStream("M1M2", core.Line, name .. ". MA1 / MA2 ", " MA1 / MA2 ", instance.parameters.M1M2_color, first);
			M1M2:setWidth(instance.parameters.width3);
			M1M2:setStyle(instance.parameters.style3);
			end
		else
		M1M2 = instance:addInternalStream(0, 0);
		end
		
		
	PM1 :setPrecision(math.max(2, instance.source:getPrecision())); 
	PM2:setPrecision(math.max(2, instance.source:getPrecision()));
	M1M2:setPrecision(math.max(2, instance.source:getPrecision()));
     
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    One:update(mode);
	Two:update(mode);
	
    if period < first   then
	return;
	end
	
        PM1[period] = (math.max(source[period],One.DATA[period]) - math.min(source[period],One.DATA[period]))/ source:pipSize();
        PM2[period] = (math.max(source[period],Two.DATA[period]) - math.min(source[period],Two.DATA[period]))/ source:pipSize();
        M1M2[period] = (math.max(Two.DATA[period],One.DATA[period]) - math.min(Two.DATA[period],One.DATA[period]))/ source:pipSize();
     
end

