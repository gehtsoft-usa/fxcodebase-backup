-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63960
-- Id: 16788

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
    indicator:name("Two MA RSI Signal");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
    indicator.parameters:addGroup("Signal Mode");	
	indicator.parameters:addBoolean("Signal_Mode", "Signal Mode", "", false);
	
    indicator.parameters:addGroup("1. MA Calculation");
	
	indicator.parameters:addString("Price1", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "WEIGHTED", "", "weighted");
	
	
    indicator.parameters:addInteger("Period1", "Period", "", 10);
	
	indicator.parameters:addString("Method1", "Method", "Method" , "EMA");
	indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");    
	indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");   
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addGroup("2. MA Calculation");
	
    indicator.parameters:addString("Price2", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price2", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price2", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price2", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price2","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price2", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price2", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price2", "WEIGHTED", "", "weighted");
	
	
	indicator.parameters:addInteger("Period2", "Period", "", 20);
		
	indicator.parameters:addString("Method2", "Method", "Method" , "EMA");
	indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");    
	indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");   
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("RSI Calculation");
	
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");
	
	 indicator.parameters:addInteger("Period", "Period", "", 30);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Color of Up", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Color of Down", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Size", "Arrow Size", "", 15);
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local first;
local source = nil;
local Size;
-- Streams block
local Signal;
local MA1, MA2, RSI;
local Period, Period1, Period2, Method1,Method2;
local Price1, Price2,Price;
local Up,Down;
local Signal_Mode;
-- Routine
function Prepare(nameOnly)
 
	Period = instance.parameters.Period;
	Period1 = instance.parameters.Period1;
	Period2 = instance.parameters.Period2;
	Method1 = instance.parameters.Method1;
	Method2 = instance.parameters.Method2;
	Price1= instance.parameters.Price1;
	Price2= instance.parameters.Price2;
	Price= instance.parameters.Price;
	Size= instance.parameters.Size;
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	Signal_Mode= instance.parameters.Signal_Mode;
	
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	if nameOnly then
		return;
	end
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
	 MA1= core.indicators:create(Method1, source[Price1], Period1);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
	 MA2= core.indicators:create(Method2, source[Price2], Period2);
	 RSI= core.indicators:create("RSI", source[Price], Period);
	 
	 first =math.max( MA1.DATA:first(), MA2.DATA:first(), RSI.DATA:first());
	 
	
    if Signal_Mode then	
	
	Signal = instance:addStream("Signal", core.Bar, name, "Signal", instance.parameters.Up, first ); 
    Signal:addLevel(0);	
	
	else 
	Signal = instance:addInternalStream(0, 0); 
    instance:ownerDrawn(true);	 
	end
end



local init = false;
 
function Draw(stage, context)
 
	 if stage~= 2 then
	  return;
	  end
	  
	  
	
        if not init then
           context:createFont (1, "Wingdings", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
            init = true;
        end
		
		

		
		for period= math.max(context:firstBar (),first), math.min( context:lastBar (), source:size()-1), 1 do
		
		 
		
		 x, x1, x2= context:positionOfBar (period);
		 
		 
		   if period > 0
		   and period < source:size()-1
		   and Signal:hasData(period)
		   and Signal[period]~=nil
		   then
		   
				   if Signal[period]== 1 and  Signal[period-1]~= 1 then
					
					visible, y = context:pointOfPrice (source.low[period]);
					
					  width, height = context:measureText (1,  "\225", 0);
					  context:drawText (1,   "\225", Up, -1,  x-width/2 ,  y , x+width/2 , y+height, 0 );	
		   
					elseif Signal[period]== -1 and  Signal[period-1]~= -1 then
					
					visible, y = context:pointOfPrice (source.high[period]);
					width, height = context:measureText (1,  "\226", 0);
					 context:drawText (1,   "\226", Down, -1,  x-width/2  ,  y-height , x+width/2 ,y, 0 );	
					end
 
		    
		 
	        end 
		end
		
  
end		

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

      MA1:update(mode);
	  MA2:update(mode);
	  RSI:update(mode);
	  
	  
    if period < first or not source:hasData(period) then
	return;
	end
	
	
	if MA1.DATA[period]> MA2.DATA[period]
	and RSI.DATA[period]> 50
	then
	Signal[period]=1;
	elseif MA1.DATA[period]< MA2.DATA[period]
	and RSI.DATA[period]< 50
	then
	Signal[period]=-1;
	else
	Signal[period]=Signal[period-1];
	end
	   
end

