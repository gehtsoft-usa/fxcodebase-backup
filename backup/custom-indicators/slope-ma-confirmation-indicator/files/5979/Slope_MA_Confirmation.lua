-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2648

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Slope/MA Confirmation");
    indicator:description("Slope/MA Confirmation");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
	indicator.parameters:addGroup("Slope Direction Line Parameters");
	indicator.parameters:addInteger("Frame1", "Slope direction line", " Short Period", 50);
	
    indicator.parameters:addString("Method1", "SDL Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "", "TMA"); 
	
    indicator.parameters:addString("Price1", "Price", "", "close");
    indicator.parameters:addStringAlternative("Price1", "open", "", "open");
    indicator.parameters:addStringAlternative("Price1", "close", "", "close");
    indicator.parameters:addStringAlternative("Price1", "high", "", "high");
    indicator.parameters:addStringAlternative("Price1", "low", "", "low");
	indicator.parameters:addStringAlternative("Price1", "median", "", "median");
    indicator.parameters:addStringAlternative("Price1", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "weighted", "", "weighted");
	
	indicator.parameters:addGroup("Moving Average Parameters");
	indicator.parameters:addInteger("Frame2", "MA Period", "", 50);
	indicator.parameters:addString("Method2", "MA Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "", "TMA");
	indicator.parameters:addString("Price2", "Price", "", "close");
    indicator.parameters:addStringAlternative("Price2", "open", "", "open");
    indicator.parameters:addStringAlternative("Price2", "close", "", "close");
    indicator.parameters:addStringAlternative("Price2", "high", "", "high");
    indicator.parameters:addStringAlternative("Price2", "low", "", "low");
	indicator.parameters:addStringAlternative("Price2", "median", "", "median");
    indicator.parameters:addStringAlternative("Price2", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Price2", "weighted", "", "weighted");
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Price1, Price2,Method1, Method2, Frame1, Frame2 ;

local first;
local source = nil;

-- Streams block
 

local open=nil;
local close=nil;
local high=nil;
local low=nil;

local SDL=nil;
local MA = nil;

local Up, Down, Neutral;

-- Routine
 function Prepare(nameOnly)
     
	Price1=instance.parameters.Price1; 
	Price2=instance.parameters.Price2; 
	Method1=instance.parameters.Method1;
	Method2=instance.parameters.Method2; 
	Frame1=instance.parameters.Frame1;
	Frame2=instance.parameters.Frame2;
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
    
    
    source = instance.source;
	
	  local name = profile:id() .. "(" .. source:name() .. ", " .. Frame1 .. "," .. Price1 .."," .. Method1  .. ", " .. Frame2 .. "," .. Price2 .."," .. Method2 .. ")";
    instance:name(name);
   
   if   (nameOnly) then
        return;
    end
	
 
	assert(core.indicators:findIndicator("SLOPE_DIRECTION_LINE") ~= nil, "Please, download and install SLOPE_DIRECTION_LINE.LUA indicator");   
	
	MA= core.indicators:create( Method2 , source[Price2], Frame2 );
	SDL= core.indicators:create("SLOPE_DIRECTION_LINE", source[Price1], Frame1 , Method1,  true);
	
	first = math.max(MA.DATA:first(),SDL.DATA:first() );

  
	
	open = instance:addStream("open", core.Line, name, "open", core.rgb(127, 127, 127), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(127, 127, 127), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(127, 127, 127), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(127, 127, 127), first)
    instance:createCandleGroup("ZONE", "", open, high, low, close);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)   
	
	MA:update(mode);
	SDL:update(mode);
	
	               high[period]= source.high[period];
				   low[period]= source.low[period];		   
				   close[period] = source.close[period];
				   open[period]  = source.open[period];   
				   
	if period < first+1 then
	 open:setColor(period, Neutral);
    return;
    end	
	
	 
	

				if SDL.DATA[period-1] < SDL.DATA[period] and MA.DATA[period-1] < MA.DATA[period]   then 	
                open:setColor(period, Up);  				
				else				  
                open:setColor(period, Down);				
				end
	 
end

