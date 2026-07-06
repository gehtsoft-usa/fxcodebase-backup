-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73206

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
    indicator:name("On Balance Volume with candles");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

 	indicator.parameters:addGroup("Source Selector");	
    indicator.parameters:addString("Source", "Source", "", "Regular");
    indicator.parameters:addStringAlternative("Source", "Regular Candles", "", "Regular");
    indicator.parameters:addStringAlternative("Source", "Heikin Ashi Candles", "", "HeikinAshi");
    
	indicator.parameters:addString("linestyle", "Line Style", "", "Candle");
    indicator.parameters:addStringAlternative("linestyle", "Candle", "", "Candle");
    indicator.parameters:addStringAlternative("linestyle", "Line", "", "Line");
 
 
 	indicator.parameters:addGroup("1. Calculation");	
 	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
    indicator.parameters:addInteger("Period1", "Period", "", 50, 1, 2000);
 
 	indicator.parameters:addGroup("2. Calculation");	
 	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
    indicator.parameters:addInteger("Period2", "Period", "", 200, 1, 2000);



 	indicator.parameters:addGroup("3. Calculation");	
 	indicator.parameters:addString("Method3", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");
    indicator.parameters:addInteger("Period3", "Period", "", 13, 1, 2000);

 	indicator.parameters:addGroup("4. Calculation");	
 	indicator.parameters:addString("Method4", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method4", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method4", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method4", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method4", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method4", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method4", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method4", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method4", "WMA", "WMA" , "WMA");
    indicator.parameters:addInteger("Period4", "Period", "", 50, 1, 2000);

 	indicator.parameters:addGroup("5. Calculation");	
 	indicator.parameters:addString("Method5", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method5", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method5", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method5", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method5", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method5", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method5", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method5", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method5", "WMA", "WMA" , "WMA");
    indicator.parameters:addInteger("Period5", "Period", "", 200, 1, 2000);
	
	indicator.parameters:addGroup("Cumulative Delta Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("CDV", "Line Color", "", core.rgb(128, 128, 128)); 
	 

	indicator.parameters:addGroup("1. Line");	
    indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0 )); 
	
	
	indicator.parameters:addGroup("2. Line");	
    indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 0, 0 )); 	
	

	indicator.parameters:addGroup("3. Line");	
    indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("color3", "Line Color", "", core.rgb(0, 255, 255 )); 
	
	
	indicator.parameters:addGroup("4. Line");	
    indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("color4", "Line Color", "", core.rgb(255, 0, 255 )); 	

	indicator.parameters:addGroup("5. Line");	
    indicator.parameters:addInteger("width5", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style5", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style5", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("color5", "Line Color", "", core.rgb(0, 0, 255 )); 	
	
	indicator.parameters:addGroup("Candle Style");
	indicator.parameters:addColor("Up", "Up color", "", core.COLOR_UPCANDLE );
	indicator.parameters:addColor("Down", "Down color", "", core.COLOR_UPCANDLE );
	indicator.parameters:addColor("Neutral", "Neutral color", "", core.rgb(128, 128, 128));	 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Source; 
 
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Source=instance.parameters.Source;
	linestyle=instance.parameters.linestyle; 
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Source.. "," ..  linestyle  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	

 	close = instance:addInternalStream(0, 0);
	open = instance:addInternalStream(0, 0);
	high = instance:addInternalStream(0, 0);
	low = instance:addInternalStream(0, 0);	
	
	cumdelta = instance:addInternalStream(0, 0);
	
	haclose = instance:addInternalStream(0, 0);
	haopen = instance:addInternalStream(0, 0);
	hahigh = instance:addInternalStream(0, 0);
	halow = instance:addInternalStream(0, 0);
 

	
 
	Open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), source:first()+1);
    High = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), source:first()+1);
    Low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), source:first()+1);
    Close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), source:first()+1);
    instance:createCandleGroup("Candles", "Candles", Open, High, Low, Close);
	
	
	MA1= core.indicators:create(instance.parameters.Method1, Close, instance.parameters.Period1 );
	MA2= core.indicators:create(instance.parameters.Method2, Close, instance.parameters.Period2 );
	MA3= core.indicators:create(instance.parameters.Method3, Close, instance.parameters.Period3 );
	MA4= core.indicators:create(instance.parameters.Method4, Close, instance.parameters.Period4 );
	MA5= core.indicators:create(instance.parameters.Method5, Close, instance.parameters.Period5 );	
	first=math.max(MA1.DATA:first(),MA2.DATA:first(),MA3.DATA:first(),MA4.DATA:first(),MA5.DATA:first()) ; 	
 
    cumdelta = instance:addStream("CDV", core.Line, name, "Cumulative Delta Line", instance.parameters.CDV, source:first()+1 );
    cumdelta:setPrecision(math.max(2, instance.source:getPrecision()));
    cumdelta:setWidth(instance.parameters.width);
    cumdelta:setStyle(instance.parameters.style);
 		
	 
    Line1 = instance:addStream("Line1", core.Line, name, "1. Line", instance.parameters.color1, first );
    Line1:setPrecision(math.max(2, instance.source:getPrecision()));
    Line1:setWidth(instance.parameters.width1);
    Line1:setStyle(instance.parameters.style1);	
	
    Line2 = instance:addStream("Line2", core.Line, name, "2. Line", instance.parameters.color2, first );
    Line2:setPrecision(math.max(2, instance.source:getPrecision()));
    Line2:setWidth(instance.parameters.width2);
    Line2:setStyle(instance.parameters.style2);
	
	Line3 = instance:addStream("Line3", core.Line, name, "3. Line", instance.parameters.color3, first );
    Line3:setPrecision(math.max(2, instance.source:getPrecision()));
    Line3:setWidth(instance.parameters.width3);
    Line3:setStyle(instance.parameters.style3);
	
	
	Line4 = instance:addStream("Line4", core.Line, name, "4. Line", instance.parameters.color4, first );
    Line4:setPrecision(math.max(2, instance.source:getPrecision()));
    Line4:setWidth(instance.parameters.width4);
    Line4:setStyle(instance.parameters.style4);

	Line5 = instance:addStream("Line5", core.Line, name, "5. Line", instance.parameters.color5, first );
    Line5:setPrecision(math.max(2, instance.source:getPrecision()));
    Line5:setWidth(instance.parameters.width5);
    Line5:setStyle(instance.parameters.style5);	
 
end


function Update(period, mode)
 
	
	if period <= source:first()+1
	or  not source:hasData(period) 
	then
	return;
	end
	 
	if source.open[period] <= source.close[period] then  
	deltaup =  source.volume[period] * Rate(period, true); 
	else
	deltaup =  source.volume[period] * Rate(period, false);	
	end
	
	if source.open[period] > source.close[period] then	 
	deltadown = source.volume[period] * Rate(period,true);
	else
	deltadown = source.volume[period] * Rate(period,false);	
	end
	
	if source.close[period] >= source.open[period] then
	delta = deltaup
	else
	delta = -deltadown
	end
	
	cumdelta[period] =cumdelta[period-1] + delta;	  
	  	

    open[period]= cumdelta[period-1]
    high[period]= math.max(cumdelta[period], cumdelta[period-1])
    low[period]= math.min(cumdelta[period], cumdelta[period-1])
    close[period]= cumdelta[period]  
	
 


	haclose[period]= (open[period] + high[period] + low[period] + close[period]) / 4
	if haopen[period-1] == nil then
	haopen[period]= (open[period] +  close[period]) / 2
	else
	haopen[period]= (haopen[period-1] + haclose[period-1]) / 2
	end
	hahigh[period]= math.max(high[period], math.max(haopen[period], haclose[period]))
	halow[period]= math.min(low[period],  math.min(haopen[period], haclose[period]))	
	
	
	
	if Source == "Regular" then
    Open[period] = open[period];
    Close[period] = close[period];
	High[period] = high[period];
	Low[period] = low[period];	
	else
    Open[period] = haopen[period];
    Close[period] = haclose[period];
	High[period] = hahigh[period];
	Low[period] = halow[period]
	end
	
	MA1:update(mode);
	MA2:update(mode);
	MA3:update(mode);
	MA4:update(mode);
	MA5:update(mode);		

    if period < first then
	return;
	end
	
	Line1[period]= MA1.DATA[period];
	Line2[period]= MA2.DATA[period];
	Line3[period]= MA3.DATA[period];
	Line4[period]= MA4.DATA[period];
	Line5[period]= MA5.DATA[period];	
end

function Rate(period, cond) 

	tw = source.high[period] -  math.max(source.open[period], source.close[period]) 
	bw = math.min(source.open[period], source.close[period]) - source.low[period] 
	body =  math.abs(source.close[period] - source.open[period]) 
    
	
	if  (tw + bw + body) == 0  then
    return 0.5;	
	end
	
	if cond then
    ret = 0.5 * (tw + bw + (  2 * body  )) / (tw + bw + body) 
	else
    ret = 0.5 * (tw + bw +  0 ) / (tw + bw + body) 	
	end
	

    
	if ret== nil   then
    return 0.5;	
	else
    return ret;
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