-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73656

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Pi Cycle");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Period");	 
    indicator.parameters:addInteger("Period1", "1. Period", "", 472, 1, 2000);
    indicator.parameters:addInteger("Period2", "2. Period", "", 150, 1, 2000);
    indicator.parameters:addInteger("Period3", "3. Period", "", 355, 1, 2000);
    indicator.parameters:addInteger("Period4", "4. Period", "", 111, 1, 2000);
	
    indicator.parameters:addDouble("M1", "1. Multiplier", "", 0.75);
    indicator.parameters:addDouble("M2", "2. Multiplier", "", 1.5);	
	
 	indicator.parameters:addGroup("Method");	  
	
	indicator.parameters:addString("Method1", "1. MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");

	indicator.parameters:addString("Method2", "2. MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addString("Method3", "3. MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");

	indicator.parameters:addString("Method4", "4. MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method4", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method4", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method4", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method4", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method4", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method4", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method4", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method4", "WMA", "WMA" , "WMA");	
	
 	indicator.parameters:addGroup("Show");	 	
    indicator.parameters:addBoolean("Show1", "1. Line", "", true);
    indicator.parameters:addBoolean("Show2", "2. Line", "", true);
    indicator.parameters:addBoolean("Show3", "3. Line", "", true);
    indicator.parameters:addBoolean("Show4", "4. Line", "", true);	
    indicator.parameters:addBoolean("Halving", "Show Halving", "", true); 	
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "1.Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "2.Line Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("color3", "3.Line Color", "", core.rgb(0, 0, 255)); 
	 indicator.parameters:addColor("color4", "4.Line Color", "", core.rgb(128, 128, 128)); 	 
	 
	 

	
	indicator.parameters:addGroup("Arrow Style");
    indicator.parameters:addBoolean("Signal", "Signal Mode", "", false); 
	indicator.parameters:addInteger("Size", "Arrow Size", "", 20); 
    indicator.parameters:addColor("clrUP", "Up Arrow", "" ,  core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN",  "Down Arrow", "" , core.COLOR_DOWNCANDLE);	 
	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period1, Period2,TF; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Period3=instance.parameters.Period3;
	Period4=instance.parameters.Period4;
	
	Method1=instance.parameters.Method1;
	Method2=instance.parameters.Method2;
	Method3=instance.parameters.Method3;
	Method4=instance.parameters.Method4;

	
	Show1=instance.parameters.Show1;
	Show2=instance.parameters.Show2;
	Show3=instance.parameters.Show3;
	Show4=instance.parameters.Show4;
	
	M1=instance.parameters.M1;
	M2=instance.parameters.M2;
	
	Halving=instance.parameters.Halving;
	
	Signal=instance.parameters.Signal;
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Period2 .. "," ..  Period3.. "," ..  Period4 .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Indicator1= core.indicators:create(Method1, source, Period1);
	Indicator2= core.indicators:create(Method2, source, Period2);
	Indicator3= core.indicators:create(Method3, source, Period3);
	Indicator4= core.indicators:create(Method4, source, Period4);
 
    FIRST =math.max(Indicator1.DATA:first(), Indicator2.DATA:first(), Indicator3.DATA:first(), Indicator4.DATA:first())
	
	if Show1 then
    Line1 = instance:addStream("Line1", core.Line, name, "1. Line", instance.parameters.color1, Indicator1.DATA:first() );
    Line1:setPrecision(math.max(2, instance.source:getPrecision()));
    Line1:setWidth(instance.parameters.width);
    Line1:setStyle(instance.parameters.style);
    else
	Line1 = instance:addInternalStream(0, 0);
    end	
 
	if Show2 then 
    Line2 = instance:addStream("Line2", core.Line, name, "2. Line", instance.parameters.color2, Indicator2.DATA:first() );
    Line2:setPrecision(math.max(2, instance.source:getPrecision()));
    Line2:setWidth(instance.parameters.width);
    Line2:setStyle(instance.parameters.style);
    else
	Line2 = instance:addInternalStream(0, 0);
    end	
	
	if Show3 then
    Line3 = instance:addStream("Line3", core.Line, name, "3. Line", instance.parameters.color3, Indicator3.DATA:first() );
    Line3:setPrecision(math.max(2, instance.source:getPrecision()));
    Line3:setWidth(instance.parameters.width);
    Line3:setStyle(instance.parameters.style);
    else
	Line3 = instance:addInternalStream(0, 0);
    end	
	
	if Show4 then
    Line4 = instance:addStream("Line4", core.Line, name, "4. Line", instance.parameters.color4, Indicator4.DATA:first() );
    Line4:setPrecision(math.max(2, instance.source:getPrecision()));
    Line4:setWidth(instance.parameters.width);
    Line4:setStyle(instance.parameters.style);
    else
	Line4 = instance:addInternalStream(0, 0);
    end		
	
	
	if Signal then
    Bar = instance:addStream("Bar", core.Bar, name, "Bar", instance.parameters.color, first );
    Bar:setPrecision(math.max(2, instance.source:getPrecision())); 
    Bar:addLevel(0);	
	else
    Bar = instance:addInternalStream(0, 0);	
	end
	
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top , instance.parameters.clrDN, 0);
 
    s1, e1 = core.getcandle("H1", core.now(), 0, 0);
    s2, e2 = core.getcandle(source:barSize(), core.now(), 0, 0);
 
end


function Update(period, mode)

	Indicator1:update(mode); 
	Indicator2:update(mode);
	Indicator3:update(mode);
	Indicator4:update(mode);
	
    up:setNoData(period);
    down:setNoData(period);	
	
	if not source:hasData(period) 
	then
	return;
	end
	
	
	
	  
	if Indicator1.DATA:hasData(period) then  	
	Line1[period]= Indicator1.DATA[period]*M1; 		
	end
	
	if Indicator2.DATA:hasData(period) then  	
	Line2[period]= Indicator2.DATA[period]; 	
	end

	if Indicator3.DATA:hasData(period) then  	
	Line3[period]= Indicator3.DATA[period]*M2; 	
	end

	if Indicator4.DATA:hasData(period) then  	
	Line4[period]= Indicator4.DATA[period]; 	
	end	
 
    if not Indicator1.DATA:hasData(period) 
	or not Indicator2.DATA:hasData(period)
	or not Indicator3.DATA:hasData(period)
	or not Indicator4.DATA:hasData(period)
	then
	return;
	end
	
	if period <= FIRST then
    return;
    end	

	    if core.crossesUnder(Line2, Line1 , period) then
	    Low=source[period] + (source[period]/100 * 10);	   
        Bar[period]= 1;
        up:set(period, Low, "\217");	   
	    end
   
		if core.crossesUnder(Line3, Line4 , period) then
		High=source[period] + (source[period]/100 * 10)
        down:set(period, High, "\218");	
	    Bar[period]= -1;		
		end  
		
		
	if period<source:size()-1  or not Halving or (e2-s2) < (e1-s1) then
	return	
    end
    
	Date1=core.datetime (2012, 11, 28, 0, 0, 0)
	Date2=core.datetime (2016, 7, 9, 0, 0, 0)
	Date3=core.datetime (2020, 5, 11, 0, 0, 0)
	Date4=core.datetime (2024, 3, 26, 0, 0, 0)
	
	core.host:execute("drawLine", 1, Date1, 0, Date1, math.huge, core.COLOR_LABEL );
	core.host:execute("drawLine", 2, Date2, 0, Date2, math.huge, core.COLOR_LABEL );
	core.host:execute("drawLine", 3, Date3, 0, Date3, math.huge, core.COLOR_LABEL );
	core.host:execute("drawLine", 4, Date4, 0, Date4, math.huge, core.COLOR_LABEL );
	
end

 


--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+


--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+