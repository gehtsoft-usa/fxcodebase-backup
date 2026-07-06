-- Id: 15300

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1044

--+------------------------------------------------------------------+
--|                               Copyright ? 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
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
    indicator:name("SHIFT MA Paint Bar");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");
	
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
	
    indicator.parameters:addInteger("N", "Periods", "", 14);
    indicator.parameters:addString("MA", "Smoothing Method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "MVA");
    indicator.parameters:addStringAlternative("MA", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA", "TMA", "", "TMA");
    indicator.parameters:addStringAlternative("MA", "SMMA*", "", "SMMA");
    indicator.parameters:addStringAlternative("MA", "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("MA", "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("MA", "Wilders*", "", "WMA");
    indicator.parameters:addInteger("SX", "Shift in periods", "Postive is future, negative is past", 0);
    indicator.parameters:addInteger("SY", "Shift in points", "", 0);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up Trend Color","Up Trend Color", core.rgb(0,255,0));
	indicator.parameters:addColor("Down", "Down Trend Color","Down Trend Color", core.rgb(255,0,0));
	indicator.parameters:addColor("Neutral", "Neutral Trend Color","Neutral Trend Color", core.rgb(0,0,0));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local MA;
local AVG;
local first1, first2;
local SX, SY;

local first;
local source = nil;
local Price;
 

local open=nil;
local close=nil;
local high=nil;
local low=nil;
local Up, Down, Neutral;
-- Routine
function Prepare(nameOnly)  
    Fast = instance.parameters.Fast;
	Price= instance.parameters.Price;
    Slow= instance.parameters.Slow;
	Method1= instance.parameters.Method1;
	Method2= instance.parameters.Method2;
	Price1= instance.parameters.Price1;
	Price2= instance.parameters.Price2;
	
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	Neutral = instance.parameters.Neutral; 
	
    source = instance.source;
   
	   local name;
    name = profile:id() .. "(" .. instance.source:name() .. "," .. instance.parameters.MA .. "(" .. instance.parameters.N  .. ")," .. instance.parameters.SX .. " bars," .. instance.parameters.SY .. " points)";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	assert (core.indicators:findIndicator(instance.parameters.MA )~= nil , "Please download " .. instance.parameters.MA.. " from the FxCodeBase.com")
	
	
	SX = instance.parameters.SX;
    SY = instance.parameters.SY * source:pipSize();

    assert(core.indicators:findIndicator(instance.parameters.MA) ~= nil, instance.parameters.MA .. " indicator must be installed");
    MA = core.indicators:create(instance.parameters.MA, source[Price], instance.parameters.N);
    first1 = MA.DATA:first();
    first2 = first1 + SX;
    if first2 < 0 then
        first2 = 0;
    end
    AVG  = instance:addInternalStream(first2, SX);  
	
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), source:first())
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), source:first())
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), source:first())
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), source:first())
    instance:createCandleGroup("ZONE", "", open, high, low, close);
	
	
end

-- Indicator calculation routine
function Update(period, mode)


    high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];

   MA:update(mode);

    local p1 = period + SX;
	
    if p1 < 0 or  period < first1 then
	open:setColor(period, Neutral); 
	return;
	end
	
	
        AVG[p1] = MA.DATA[period] + SY;
    
		    
if source.close[period] > AVG[period] then
open:setColor(period, Up); 
elseif source.close[period] < AVG[period] then
open:setColor(period, Down); 
else 
open:setColor(period, Neutral); 
end	
 		  
 end

