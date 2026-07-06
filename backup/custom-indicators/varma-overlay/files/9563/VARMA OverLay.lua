-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3881

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
--+------------------------------------------------------------------+f


function Init()
    indicator:name("VARMA OverLay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Fast VARMA"); 
    indicator.parameters:addInteger("FP", "Period", "", 9, 2, 2000);
	indicator.parameters:addInteger("FS", "Smoothing", "", 2, 1, 200);
	indicator.parameters:addString("Fast_Price", "Power Price", "", "close");
	indicator.parameters:addStringAlternative("Fast_Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Fast_Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Fast_Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Fast_Price", "LOW", "", "low");    
    indicator.parameters:addStringAlternative("Fast_Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Fast_Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Fast_Price", "WEIGHTED", "", "weighted");
	
	indicator.parameters:addGroup("Slow VARMA"); 
    indicator.parameters:addInteger("SP", "Period", "", 27, 2, 2000);
	indicator.parameters:addInteger("SS", "Smoothing", "", 5, 1, 200);
	indicator.parameters:addString("Slow_Price", "Power Price", "", "close");
	indicator.parameters:addStringAlternative("Slow_Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Slow_Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Slow_Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Slow_Price", "LOW", "", "low");    
    indicator.parameters:addStringAlternative("Slow_Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Slow_Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Slow_Price", "WEIGHTED", "", "weighted");
	indicator.parameters:addGroup("Style"); 
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128));
	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local FP, FS, SP, SS;
local Fast_Price, Slow_Price;

local first;
local source = nil;

-- Streams block
local HZU = nil;
local HZL = nil;

local open=nil;
local close=nil;
local high=nil;
local low=nil;
local Up, Down,Neutral;
local indicator={};

-- Routine
function Prepare(nameOnly)
    Fast_Price= instance.parameters.Fast_Price;
    Slow_Price= instance.parameters.Slow_Price;	
    FP = instance.parameters.FP;
    FS = instance.parameters.FS;
    SP = instance.parameters.SP;
	SS = instance.parameters.SS;
	
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	Neutral = instance.parameters.Neutral;
		
    source = instance.source;
    
	
	assert(core.indicators:findIndicator("VARMA") ~= nil, "Please, download and install VARMA.LUA indicator");

    local name = profile:id() .. "(" .. source:name() .. ", "  .. FP .. ", " .. FS .. ", " .. Fast_Price
	                                                  .. ", "  .. SP .. ", " .. SS .. ", " .. Slow_Price .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    indicator["Fast"] = core.indicators:create("VARMA", source[Fast_Price], FP, FS);
    indicator["Slow"] = core.indicators:create("VARMA",  source[Slow_Price], SP, SS);
   
   first = math.max(source:first(),indicator["Fast"].DATA:first(), indicator["Slow"].DATA:first()   );	
	
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("ZONE", "", open, high, low, close);
	
	
end

-- Indicator calculation routine
function Update(period, mode)
     
	if period < first  or not source:hasData(period) then
    return;
    end 
 
    indicator["Fast"]:update(mode);
    indicator["Slow"]:update(mode);
	
	high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];	
	
	if  not indicator["Fast"].DATA:hasData(period) or  not indicator["Slow"].DATA:hasData(period-1) then
	    open:setColor(period, Neutral);	
		return;
	end
	
		
      
				if indicator["Fast"].DATA[period] > indicator["Slow"].DATA[period] then 
				open:setColor(period, Up);
				elseif  indicator["Fast"].DATA[period] < indicator["Slow"].DATA[period] then
				open:setColor(period,Down);	
				else
				open:setColor(period, Neutral);
				end
		
				  
end

