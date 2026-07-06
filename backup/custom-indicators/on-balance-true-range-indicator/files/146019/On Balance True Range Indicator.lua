-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72183

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
    indicator:name("On Balance True Range Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
	
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	

	
    indicator.parameters:addInteger("Fast_MA_Period", "Fast_MA_Period", "", 1, 1, 2000);
    

	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	
	
	
	indicator.parameters:addInteger("Slow_MA_Period", "Slow_MA_Period", "", 26, 1, 2000);
    indicator.parameters:addInteger("Proximity", "Proximity", "", 11, 1, 2000);
    indicator.parameters:addInteger("Distance_Max", "Distance_Max", "", 126, 1, 2000);	
	
 

	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	
 
	 indicator.parameters:addGroup("1. Line Style");	
    indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 255));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 255));
	indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128));
	
 
	 indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);
	 
	 indicator.parameters:addGroup("2. Line Style");		
    indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);	 
	 indicator.parameters:addColor("color1", "Up Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Down Line Color", "", core.rgb(255, 0, 0)); 	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Fast_MA_Period, Slow_MA_Period,Proximity,Distance_Max; 
local Price,  Method1,Method2 ;
local multiplier;	
-- Routine
 function Prepare(nameOnly)   
 
    
	Fast_MA_Period=instance.parameters.Fast_MA_Period;
	Slow_MA_Period=instance.parameters.Slow_MA_Period;
	Distance_Max=instance.parameters.Distance_Max;
	Proximity=instance.parameters.Proximity;
	
	Price=instance.parameters.Price;
	Method1=instance.parameters.Method1;
	Method2=instance.parameters.Method2;
	
   Up = instance.parameters.Up;
   Down= instance.parameters.Down;
   Neutral= instance.parameters.Neutral;
   
   Lines= instance.parameters.Lines;
   Transparency= instance.parameters.Transparency;
   Transparency= 100-Transparency;	
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Fast_MA_Period.. "," ..  Slow_MA_Period .. "," ..    Proximity .. "," .. Distance_Max  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	multiplier = 1 / source:pipSize();
	
	Indicator= core.indicators:create("ATR", source, 1);
	first=Indicator.DATA:first() ; 
	
	
	 
	OBTRBuffer = instance:addInternalStream(0, 0);
 	Zero = instance:addInternalStream(0, 0);
	
	Slow= core.indicators:create(Method1, OBTRBuffer, Fast_MA_Period);
	Fast= core.indicators:create(Method2, OBTRBuffer, Slow_MA_Period);	
	
    Line1 = instance:addStream("Line1", core.Line, name, "1. Line", instance.parameters.Up, first );
    Line1:setPrecision(math.max(2, instance.source:getPrecision()));
    Line1:setWidth(instance.parameters.width1);
    Line1:setStyle(instance.parameters.style1);
    Line1:addLevel(0);	
	
	instance:createChannelGroup("Group","Group" , Line1, Zero, Neutral, Transparency);	
 
 
    Line2 = instance:addStream("Line2", core.Line, name, "2. Line", instance.parameters.color1, first );
    Line2:setPrecision(math.max(2, instance.source:getPrecision()));
    Line2:setWidth(instance.parameters.width2);
    Line2:setStyle(instance.parameters.style2);
    Line2:addLevel(0);	
end


function Update(period, mode)

	Indicator:update(mode); 
	
	Zero[period]=0;

	 if period <= first then
	 return;
	 end
	 
	 local TR=Indicator.DATA[period]*multiplier;
	 
	 
	if(source[Price][period]<source[Price][period-1]) then
               OBTRBuffer[period]=OBTRBuffer[period-1]+TR;  
    elseif(source[Price][period]>source[Price][period-1]) then
               OBTRBuffer[period]=OBTRBuffer[period-1]-TR;
	else	   
	 OBTRBuffer[period]= OBTRBuffer[period-1];
    end
	 
	Fast:update(mode);
	Slow:update(mode);
	  
    if period < math.max(Fast.DATA:first(),Slow.DATA:first()  ) then
    return;
    end	
	
	Line1[period]= Fast.DATA[period];
	Line2[period]= Slow.DATA[period];	
	
	if Line2[period]> Line2[period-1] then
	Line2:setColor(period, instance.parameters.color1);	
	else
	Line2:setColor(period, instance.parameters.color2);		
	end
	
	
	
	if Line1[period]> Line2[period] then
	Line1:setColor(period, instance.parameters.Up);	
	elseif Line1[period]< Line2[period] then
	Line1:setColor(period, instance.parameters.Down);		
	end
	
	if not (math.abs(Line1[period]- Line2[period]) < Proximity or  math.abs(Line1[period]- Line2[period])  > Distance_Max) then
	Line1:setColor(period, instance.parameters.Neutral);
    end	
	
	
end