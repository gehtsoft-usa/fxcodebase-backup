-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71808

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--Your donations will allow the service to continue onward.
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



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("BB Squeeze");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

 
    indicator.parameters:addGroup("Calculation");
	
	indicator.parameters:addString("Type", "Deviation calculation Method", "" , "SD");
    indicator.parameters:addStringAlternative("Type", "Standard deviation", "" , "SD");
    indicator.parameters:addStringAlternative("Type", "Standard error", "" , "SE");
   -- indicator.parameters:addStringAlternative("Type", "Custom Standard deviation - with sample correction", "CSD" , "CSD");
  --  indicator.parameters:addStringAlternative("Type", "Custom Standard deviation - without sample correction", "CSDW" , "CSDW");	
	
	
    indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
	

	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	 indicator.parameters:addInteger("LP", "Linear regression Period", " ", 20);
		
    indicator.parameters:addInteger("BP", "Bollinger Period", " ", 20);
	indicator.parameters:addDouble("BD", "Bollinger Deviations", " ", 2);
	
	indicator.parameters:addInteger("KP", "Keltner Period", " ", 20);
	indicator.parameters:addDouble("KF", "Keltner Factor", " ", 1.5);
	
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(128, 128, 128)); 	
	
	indicator.parameters:addColor("Up", "Up Bar Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("UpDown", "Down in Up Trend Bar Color", "", core.rgb(0, 200, 0)); 	
	indicator.parameters:addColor("Down", "Down Bar Color", "", core.rgb( 200,0, 0)); 
	indicator.parameters:addColor("DownUp", "Up in Down Trend Bar Color", "", core.rgb(255,0, 0)); 
	
	indicator.parameters:addColor("DotUp", "Up Dot Color", "", core.rgb(0, 0, 255));  	
	indicator.parameters:addColor("DotDown", "Down Dot Color", "", core.rgb( 0,0, 0)); 	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local BP, BD, KP,KF,LP, Price ; 
local Indicator;
local ATR, MA,Type;	
local StandardDeviation;
local Line, Bar, Dot;
local Trend;
-- Routine
 function Prepare(nameOnly)   
 
    
    BP = instance.parameters.BP;
    BD = instance.parameters.BD;
	KP = instance.parameters.KP;
	KF = instance.parameters.KF;
	LP= instance.parameters.LP;
	Type= instance.parameters.Type;
	Method = instance.parameters.Method;
	Price = instance.parameters.Price;
	source = instance.source;
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Type.. "," ..  Price.. "," ..  Method .. "," ..  LP .. "," ..  BP.. "," ..  BD .. "," ..  KP.. "," ..  KF .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	ATR= core.indicators:create("ATR", source, KP);
	MA= core.indicators:create(Method, source[Price],BP);	
	first=math.max(MA.DATA:first(), ATR.DATA:first(), LP) ; 
	
    StandardDeviation  = instance:addInternalStream(0, 0);
	Trend  = instance:addInternalStream(0, 0);
	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
	
	Bar = instance:addStream("Bar", core.Bar, name, "Bar", instance.parameters.color, first );
    Bar:setPrecision(math.max(2, instance.source:getPrecision())); 


	Dot = instance:addStream("Dot", core.Dot, name, "Dot", instance.parameters.color, first );
    Dot:setWidth(3);
    Dot:setPrecision(math.max(2, instance.source:getPrecision()));  
end


function Update(period, mode)

	ATR:update(mode); 
	MA:update(mode); 

	if period< first then
	return;
	end
	
	
	Line[period] = mathex.lregSlope (source[Price], period-BP+1, period);
	Bar[period]=Line[period];
	Dot[period]=0;
	
	
    if Type == "SD"	then
	StandardDeviation[period]= mathex.stdev(source, period-BP+1, period)
	elseif Type == "SE"	then
	StandardDeviation[period]=StandardError(period);	
	else
	StandardDeviation[period]= mathex.stdev(source, period-BP+1, period)	
	end
	

	
	


    local keltUp = MA.DATA[period] + KF*ATR.DATA[period];
    local keltDn = MA.DATA[period] - KF*ATR.DATA[period];
 
	
    local  UpMa   = MA.DATA[period] + StandardDeviation[period]*BD;
    local  DnMa   = MA.DATA[period] - StandardDeviation[period]*BD;
	
	if Line[period]> 0 then
	
		if Line[period]< Line[period-1] then
		Bar:setColor(period, instance.parameters.UpDown);
		else	
		Bar:setColor(period, instance.parameters.Up);
		end
	
	else
	
		if Line[period]> Line[period-1] then
		Bar:setColor(period, instance.parameters.DownUp);	
		else
		Bar:setColor(period, instance.parameters.Down);
		end
	
	
	end
	
	
	if (UpMa<keltUp and DnMa>keltDn) then
	Trend[period]=1;
	elseif (UpMa>keltUp and DnMa<keltDn)  then
	Trend[period]=-1;
    else
	Trend[period]=Trend[period-1];	
	end
	
	if Trend[period]== 1 then
	Dot:setColor(period, instance.parameters.DotUp);
	elseif Trend[period]== -1 then	
	Dot:setColor(period, instance.parameters.DotDown);	
	end
end


function StandardError(period)
    
      
         local stdev= mathex.stdev(source, period-BP+1, period)
 
         return stdev/ (math.sqrt(BP));
end		 