-- Id: 3599
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
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- If the current bars of AC and AO are green, it shows that the zone is green.
-- If the current bars of �� and �� red, it shows that the zone is red.
-- If the bars of AC and AO are differently directed then the bar is colored grey (grey zone).
function Init()
    indicator:name("VARMA / Signal Line Overlay");
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
	
	indicator.parameters:addGroup("Signal VARMA Line"); 
    indicator.parameters:addInteger("SP", "Period", "", 27, 2, 2000);
	indicator.parameters:addString("Mode", "Signal Line MA Mode", "", "EMA");
	indicator.parameters:addStringAlternative("Mode", "(EMA) Exponential Moving Average", "", "EMA");
    indicator.parameters:addStringAlternative("Mode", "(SMA) Simple Moving Average", "", "MVA");   
    indicator.parameters:addStringAlternative("Mode", "(LWMA) Linear-weighted Moving Average", "", "LWMA");
    indicator.parameters:addStringAlternative("Mode", "(LSMA) Least Square Moving Average (Regression)", "", "REGRESSION");
    indicator.parameters:addStringAlternative("Mode", "(SMMA) Smoothed Moving Average", "", "SMMA");
    indicator.parameters:addStringAlternative("Mode", "(WMA) Wilders Smooth", "", "WMA");
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local FP, FS, SP;
local Fast_Price;

local Mode;

local first;
local source = nil;

-- Streams block
local HZU = nil;
local HZL = nil;

local open=nil;
local close=nil;
local high=nil;
local low=nil;

local indicator={};

-- Routine
function Prepare(nameOnly)
    Fast_Price= instance.parameters.Fast_Price;
    Mode = instance.parameters.Mode;
    FP = instance.parameters.FP;
    FS = instance.parameters.FS;
    SP = instance.parameters.SP;
			
    source = instance.source;
	assert(core.indicators:findIndicator("VARMA") ~= nil, "Please, download and install VARMA.LUA indicator");
    local name = profile:id() .. "(" .. source:name() .. ", "  .. FP .. ", " .. FS .. ", " .. Fast_Price
	                                                  .. ", "  .. SP .. ", " .. Mode .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    indicator["Fast"] = core.indicators:create("VARMA", source[Fast_Price], FP, FS);
    assert(core.indicators:findIndicator(Mode) ~= nil, Mode .. " indicator must be installed");
    indicator["Slow"] = core.indicators:create(Mode, indicator["Fast"].DATA, SP);
   
   first = math.max( indicator["Slow"].DATA:first()   );	
	
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("ZONE", "", open, high, low, close);
	
	
end

-- Indicator calculation routine
function Update(period, mode)
     
	high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];
	
	if period < first  or not source:hasData(period) then
	open:setColor(period, core.rgb(128, 128, 128));
    return;
    end 
 
    indicator["Fast"]:update(mode);
    indicator["Slow"]:update(mode);
	
		
	if  not indicator["Fast"].DATA:hasData(period) or  not indicator["Slow"].DATA:hasData(period-1) then
	    open:setColor(period, core.rgb(128, 128, 128));	
		return;
	end
	
		
      
				if indicator["Fast"].DATA[period] > indicator["Slow"].DATA[period] then 
				open:setColor(period, core.rgb(0, 255, 0));
				elseif  indicator["Fast"].DATA[period] < indicator["Slow"].DATA[period] then
				open:setColor(period, core.rgb(255, 0, 0));	
				else
				open:setColor(period, core.rgb(128, 128, 128));
				end
		
				  
end

