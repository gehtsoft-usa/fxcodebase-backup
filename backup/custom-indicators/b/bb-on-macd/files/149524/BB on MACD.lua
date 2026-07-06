-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73340

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
    indicator:name("BB on MACD");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("MACD Calculation");	
 	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
    indicator.parameters:addInteger("Period1", "Fast MA", "", 12, 1, 2000);
    indicator.parameters:addInteger("Period2", "Slow MA", "", 26, 1, 2000);
	
 	indicator.parameters:addString("Method2", "Signal MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");	
	
    indicator.parameters:addInteger("Period3", "Slow MA", "", 9, 1, 2000);	
	
	
 	indicator.parameters:addGroup("BB Calculation");	
 	indicator.parameters:addString("Method3", "BB Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");
	
    indicator.parameters:addInteger("Period", "Period", "", 20, 1, 2000);
    indicator.parameters:addDouble("Deviation", "Deviation", "", 2, 0, 2000);

 	indicator.parameters:addGroup("BB Selector");		
	

 	indicator.parameters:addString("Source", "BB Source", "Source" , "MACD");
    indicator.parameters:addStringAlternative("Source", "Zero Line", "Zero" , "Zero");
    indicator.parameters:addStringAlternative("Source", "MACD Line", "MACD" , "MACD");
    indicator.parameters:addStringAlternative("Source", "Signal Line", "Signal" , "Signal");
    indicator.parameters:addStringAlternative("Source", "Histogram Line", "Histogram" , "Histogram");	
	
 	indicator.parameters:addString("Placement", "BB Placement", "Placement" , "Source");
    indicator.parameters:addStringAlternative("Placement", "It is not applicable", "" , "NonApplicable");
    indicator.parameters:addStringAlternative("Placement", "Source Line", "Source" , "Source");	
    indicator.parameters:addStringAlternative("Placement", "Zero Line", "Zero" , "Zero");
    indicator.parameters:addStringAlternative("Placement", "MACD Line", "MACD" , "MACD");
    indicator.parameters:addStringAlternative("Placement", "Signal Line", "Signal" , "Signal");
    indicator.parameters:addStringAlternative("Placement", "Histogram Line", "Histogram" , "Histogram");		
	
	
	indicator.parameters:addGroup("MACD Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "MACD Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color2", "Signal Line Color", "", core.rgb(255, 0, 0)); 
	indicator.parameters:addColor("color3", "Histogram Color", "", core.rgb(0, 0, 255)); 


	indicator.parameters:addGroup("BB Line Style");	
    indicator.parameters:addInteger("BBwidth", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("BBstyle", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("BBstyle", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("colorA", "Top Line Color", "", core.rgb(128, 128, 128)); 
	indicator.parameters:addColor("colorB", "Bottom Line Color", "", core.rgb(128, 128, 128)); 
	indicator.parameters:addColor("colorC", "Central Color", "", core.rgb(128, 128, 128)); 		
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Method1, Period1, Period2, Method2,Period3; 
 
	
-- Routine
 function Prepare(nameOnly)   
 
    Method1=instance.parameters.Method1;
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
    Method2=instance.parameters.Method2;	
	Period3=instance.parameters.Period3;
	Period=instance.parameters.Period;
	Deviation=instance.parameters.Deviation;
	Source=instance.parameters.Source;
	Placement=instance.parameters.Placement
	if Placement== "Source" then
	Placement=Source;
	end
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Method1.. "," ..  Period1.. "," ..  Period2.. "," ..  Method2.. "," ..   Period3.. "," ..  Period.. "," ..   Deviation.. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Indicator1= core.indicators:create(Method1, source, Period1);
	Indicator2= core.indicators:create(Method1, source, Period2);	
	first=math.max(Indicator1.DATA:first(),Indicator1.DATA:first()) ; 
	
	
	Zero = instance:addInternalStream(0, 0);
 
	
	
    MACD = instance:addStream("MACD", core.Line, name, "MACD", instance.parameters.color1, first );
    MACD:setPrecision(math.max(2, instance.source:getPrecision()));
    MACD:setWidth(instance.parameters.width);
    MACD:setStyle(instance.parameters.style);
    MACD:addLevel(0);	
	
	Indicator3= core.indicators:create(Method2, MACD, Period3);		
	
    SIGNAL = instance:addStream("SIGNAL", core.Line, name, "SIGNAL", instance.parameters.color2, first + Period3 );
    SIGNAL:setPrecision(math.max(2, instance.source:getPrecision()));
    SIGNAL:setWidth(instance.parameters.width);
    SIGNAL:setStyle(instance.parameters.style); 
	

    HISTOGRAM = instance:addStream("HISTOGRAM", core.Bar, name, "HISTOGRAM", instance.parameters.color3, first + Period3 );
    HISTOGRAM:setPrecision(math.max(2, instance.source:getPrecision())); 

    if Source=="Zero" then
	BB= core.indicators:create("BB", Zero, Period, Deviation);			
	elseif Source=="MACD" then
	BB= core.indicators:create("BB", MACD, Period, Deviation);	
	elseif Source=="Signal"	 then
	BB= core.indicators:create("BB", SIGNAL, Period, Deviation);	
	elseif Source=="Histogram" then	 
	BB= core.indicators:create("BB", HISTOGRAM, Period, Deviation);	
    end
	
	
    Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.colorA, first + Period3 + Period );
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
    Top:setWidth(instance.parameters.BBwidth);
    Top:setStyle(instance.parameters.BBstyle);	
	
    Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.colorB, first + Period3 + Period );
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom:setWidth(instance.parameters.BBwidth);
    Bottom:setStyle(instance.parameters.BBstyle);	
 
    Central = instance:addStream("Central", core.Line, name, "Central", instance.parameters.colorC, first + Period3 + Period );
    Central:setPrecision(math.max(2, instance.source:getPrecision()));
    Central:setWidth(instance.parameters.BBwidth);
    Central:setStyle(instance.parameters.BBstyle);	 
end


function Update(period, mode)

	Indicator1:update(mode); 
	Indicator2:update(mode); 
	
	Zero[period]=0;	
	
	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	  
	  	
	MACD[period]= Indicator1.DATA[period]-Indicator2.DATA[period];
	
	
	Indicator3:update(mode); 	
	
	if period <= first + Period3
	then
	return;
	end	
	
    SIGNAL[period]= Indicator3.DATA[period];	
	HISTOGRAM[period]=MACD[period]-SIGNAL[period];
	
	
	BB:update(mode); 	
	
	if period <= first + Period3 + Period
	then
	return;
	end		
	
	local Delta=math.abs(BB.TL[period]-BB.AL[period]); 
	
	if Placement == "Zero" then	
	Central[period]=0;		 
    Top[period]= Central[period]+Delta;	
	Bottom[period]= Central[period]-Delta;		
    elseif Placement == "MACD" then	
	Central[period]=MACD[period];		
    Top[period]= Central[period]+Delta;	
	Bottom[period]= Central[period]-Delta;		
    elseif Placement == "Signal" then	
	Central[period]=SIGNAL[period];	
    Top[period]= Central[period]+Delta;	
	Bottom[period]= Central[period]-Delta;		
    elseif Placement == "Histogram" then	
	Central[period]=HISTOGRAM[period];	 
    Top[period]= Central[period]+Delta;	
	Bottom[period]= Central[period]-Delta; 
	else
	Central[period]=BB.AL[period];	 
    Top[period]= BB.TL[period];	 
	Bottom[period]= BB.BL[period];	 
	end 
	
	
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