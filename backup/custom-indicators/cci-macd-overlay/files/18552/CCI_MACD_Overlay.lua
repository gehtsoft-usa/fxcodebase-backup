-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=8389
-- Id: 5097

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("CCI_MACD_Overlay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");
	
	indicator.parameters:addGroup("CCI Calculation");
    indicator.parameters:addInteger("CP", "CCI Period", "", 14, 2, 1000);
	
	  
	  indicator.parameters:addGroup("MACD Calculation");
	indicator.parameters:addInteger("SN", "Short Period", "", 12, 1, 2000);
    indicator.parameters:addInteger("LN", "Long Period", "", 26, 1, 2000);
    indicator.parameters:addInteger("IN", "Signal Period", "", 9, 1, 2000);
	
	 indicator.parameters:addGroup("Style Options");
	 indicator.parameters:addColor("UT", "Up Trend", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DT", "Down Trend", "", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("NT", "No Trend", "", core.rgb(128, 128, 128));
	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local CP, SN,LN, IN;
local UT, DT, NT;
local first;
local source = nil;

-- Streams block
local Price;

local open=nil;
local close=nil;
local high=nil;
local low=nil;

local MACD, CCI;

-- Routine
function Prepare(nameOnly)
    UT = instance.parameters.UT;
	DT = instance.parameters.DT;
	NT = instance.parameters.NT;
	CP = instance.parameters.CP;	
	Price = instance.parameters.Price;
	IN = instance.parameters.IN;
	LN = instance.parameters.LN;
	SN = instance.parameters.SN;
	
	
    source = instance.source;
    first = source:first();	

    local name = profile:id() .. "(" .. source:name() .. ", "  ..CP .. ", " .. SN .. ", " .. LN .. ", " .. IN .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
    MACD = core.indicators:create("MACD", source[Price], SN, LN, IN);
    CCI = core.indicators:create("CCI", source, CP);
   
	first= source:first();
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("ZONE", "", open, high, low, close);
	
	first = math.max(MACD.SIGNAL:first() , CCI.DATA:first());
	
	
end

-- Indicator calculation routine
function Update(period, mode)


    high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];	
     
	if period < first  or not source:hasData(period) then	
	 open:setColor(period, NT);	
    return;
    end 
 
    MACD:update(mode);
    CCI:update(mode);
	
	
	
	if  CCI.DATA[period] > 0 
	and MACD.MACD[period] > MACD.SIGNAL[period] 
    then
	    open:setColor(period, UT);	
	elseif  CCI.DATA[period] < 0 
	and MACD.MACD[period] < MACD.SIGNAL[period] 
    then
	    open:setColor(period, DT);
    else
	    open:setColor(period, NT);	
	end

	
				   
    
				   
				  
    end

