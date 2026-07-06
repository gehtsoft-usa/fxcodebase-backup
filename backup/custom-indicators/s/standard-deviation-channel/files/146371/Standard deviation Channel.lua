-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72387

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
    indicator:name("Standard deviation Channel");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("Calculation");
	 indicator.parameters:addInteger("Period", "Standard deviation Period", "", 14, 1, 1000); 

	indicator.parameters:addGroup("Channel Calculation");
	
	 indicator.parameters:addInteger("Channel_Period", "Channel Period", "", 14, 1, 1000); 
	 indicator.parameters:addDouble("Multiplier", "Multiplier", "", 2, 0, 1000); 
	 
	 
	indicator.parameters:addString("Price" , "Data Source", "", "close");
    indicator.parameters:addStringAlternative("Price" , "Open", "", "open");
    indicator.parameters:addStringAlternative("Price", "High", "", "high");
    indicator.parameters:addStringAlternative("Price" , "Low", "", "low");
	indicator.parameters:addStringAlternative("Price" , "Close", "", "close");
	indicator.parameters:addStringAlternative("Price", "Median", "", "median");
    indicator.parameters:addStringAlternative("Price" , "Typical", "", "typical");
	indicator.parameters:addStringAlternative("Price" , "Weighted ", "", "weighted");		
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	
 
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral color", "", core.rgb(0, 0, 255));
	
	
	indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255)); 
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Up,Down, Neutral;
local first;
local source = nil;

local Price,Method,Channel_Period,Multiplier;

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

local Period;

 


 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end


    Up = instance.parameters.Up;
    Down= instance.parameters.Down;
    Neutral= instance.parameters.Neutral;
	
    Period = instance.parameters.Period;
	Price = instance.parameters.Price;
    Method = instance.parameters.Method;
	Channel_Period= instance.parameters.Channel_Period;
	Multiplier= instance.parameters.Multiplier;

	source = instance.source;
	 
	
	first=source:first()+Period;

    	
	open = instance:addStream("open", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("high", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("low", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("close", core.Line, name, "", core.rgb(0, 0, 0), first);
	median= instance:addInternalStream(0, 0);
	typical= instance:addInternalStream(0, 0);
	weighted= instance:addInternalStream(0, 0);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
	
	if Price == "open" then
	MA=core.indicators:create(Method,  open, Channel_Period);
	elseif Price == "close" then
	MA=core.indicators:create(Method,  close, Channel_Period);		
	elseif Price == "high" then
	MA=core.indicators:create(Method,  high, Channel_Period);
	elseif Price == "low" then
	MA=core.indicators:create(Method,  low, Channel_Period);	
	elseif Price == "median" then
	MA=core.indicators:create(Method,  median, Channel_Period);		
	elseif Price == "typical" then
	MA=core.indicators:create(Method,  typical, Channel_Period);		
	elseif Price == "weighted" then
	MA=core.indicators:create(Method,  weighted, Channel_Period);
    end	

    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, MA.DATA:first() );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
	
    Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.color, MA.DATA:first() );
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
    Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style);
    Top:addLevel(0);
	
    Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.color, MA.DATA:first() );
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style);
    Bottom:addLevel(0);
	
end

-- Indicator calculation routine
function Update(period, mode)
 
	
			if period < first then
			open:setColor(period, Neutral);	
			return;
			end
 

 
		
		 
		
	open[period]=mathex.stdev(source.open, period-Period+1, period);
    high[period]=mathex.stdev(source.high, period-Period+1, period);
    low[period]=mathex.stdev(source.low, period-Period+1, period);
    close[period]=mathex.stdev(source.close, period-Period+1, period);
	median[period]= (high[period] +low[period] )/2;	
	typical[period]= (high[period] +low[period]+close[period] )/3;		
	weighted[period]= (high[period] +low[period]+close[period]+close[period] )/3;
 
 
    if close[period]> open[period] then
				open:setColor(period, Up);		
	elseif close[period]< open[period] then
				open:setColor(period, Down);		
	else
				open:setColor(period, Neutral);	
	end
	
	MA:update(mode);
	
			if period < first +Channel_Period then 
			return;
			end
			
	    Line[period]=MA.DATA[period]; 
	
			if period < first +Channel_Period*2 then 
			return;
			end
			
	local StDev;

	if Price == "open" then
	StDev=mathex.stdev(open, period-Channel_Period+1, period);
	elseif Price == "close" then
	StDev=mathex.stdev(close, period-Channel_Period+1, period);
	elseif Price == "high" then
	StDev=mathex.stdev(high, period-Channel_Period+1, period);
	elseif Price == "low" then
	StDev=mathex.stdev(low, period-Channel_Period+1, period);	
	elseif Price == "median" then
	StDev=mathex.stdev(median, period-Channel_Period+1, period);	
	elseif Price == "typical" then
		StDev=mathex.stdev(typical, period-Channel_Period+1, period);	
	elseif Price == "weighted" then
	StDev=mathex.stdev(weighted, period-Channel_Period+1, period);
    end		
			
	Top[period]=Line[period] + StDev*Multiplier;	
	Bottom[period]=	Line[period] - StDev*Multiplier;


 end


