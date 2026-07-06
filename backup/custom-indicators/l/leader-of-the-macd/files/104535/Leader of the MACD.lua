-- Id: 15353

-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=63089

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
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


function Init()
    indicator:name("Leader of the MACD");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("SN", "Short EMA", "(SN)", 12, 2, 1000);
    indicator.parameters:addInteger("LN", "Long EMA", "(LN)", 26, 2, 1000);
    indicator.parameters:addInteger("IN", "Signal Line", "(IN)", 9, 2, 1000);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MACD_color", "MACD color", "(MACD Color)", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("MACD_width", "MACD Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("MACD_style", "MACD Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("MACD_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("SIGNAL_color", "Signal color", "(Signal Color)", core.rgb(0, 255,0));
	indicator.parameters:addInteger("SIGNAL_width", "SIGNAL Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("SIGNAL_style", "SIGNAL Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("SIGNAL_style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Leader_color", "Leader color", "(Leader Color)", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Leader_width", "Leader Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("Leader_style", "Leader Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("Leader_style", core.FLAG_LINE_STYLE);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local SN;
local LN;
local IN;

local firstPeriodMACD;
local firstPeriodSIGNAL;
local source = nil;

local EMAS = nil;
local EMAL = nil;
local MVAI = nil;

-- Streams block
local MACD = nil;
local SIGNAL = nil;
local Leader = nil;

local MAS_Data = nil;
local MAL_Data = nil;
local MAS = nil;
local MAL = nil;
local last;
-- Routine
function Prepare(nameOnly)
    SN = instance.parameters.SN;
    LN = instance.parameters.LN;
    IN = instance.parameters.IN;
    source = instance.source;

   

    local name = profile:id() .. "(" .. source:name() .. ", " .. SN .. ", " .. LN .. ", " .. IN .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	 if (LN <= SN) then
       error("The short EMA period must be smaller than long EMA period");
    end

    EMAS = core.indicators:create("EMA", source, SN);
    EMAL = core.indicators:create("EMA", source, LN);

    firstPeriodMACD = EMAL.DATA:first();
    MACD = instance:addStream("MACD", core.Line, name .. ".MACD", "MACD", instance.parameters.MACD_color, firstPeriodMACD);
	MACD:setWidth(instance.parameters.MACD_width);
    MACD:setStyle(instance.parameters.MACD_style);

    MVAI = core.indicators:create("MVA", MACD, IN);
    

    firstPeriodSIGNAL = MVAI.DATA:first();
    SIGNAL = instance:addStream("SIGNAL", core.Line, name .. ".SIGNAL", "SIGNAL", instance.parameters.SIGNAL_color, firstPeriodSIGNAL);
	SIGNAL:setWidth(instance.parameters.SIGNAL_width);
    SIGNAL:setStyle(instance.parameters.SIGNAL_style);
	
	MAS_Data = instance:addInternalStream(firstPeriodSIGNAL, 0);
	MAL_Data = instance:addInternalStream(firstPeriodSIGNAL, 0);
	MAS = core.indicators:create("MVA", MAS_Data, SN);
	MAL = core.indicators:create("MVA", MAL_Data, LN);
	
	last=math.max(MAS.DATA:first(),MAL.DATA:first());
	
	Leader = instance:addStream("LEADER", core.Line, name .. ".LEADER", "LEADER", instance.parameters.Leader_color, last);
	Leader:setWidth(instance.parameters.Leader_width);
    Leader:setStyle(instance.parameters.Leader_style);
	
	MACD:setPrecision(math.max(2, instance.source:getPrecision()));
	SIGNAL:setPrecision(math.max(2, instance.source:getPrecision()));
	Leader:setPrecision(math.max(2, instance.source:getPrecision()));
  
end

-- Indicator calculation routine
function Update(period, mode)
 
    EMAS:update(mode);
    EMAL:update(mode);

    if (period < firstPeriodMACD) then
	return;
	end	
	
        -- calculate MACD output
         MACD[period] = EMAS.DATA[period] - EMAL.DATA[period];
         	
	     MAS_Data[period]=source[period] - EMAS.DATA[period];
	     MAL_Data[period]=source[period] - EMAL.DATA[period];

    -- update MVA on the MACD
    MVAI:update(mode);
	MAS:update(mode);
	MAL:update(mode);
	
	if (period< firstPeriodSIGNAL) then
	return;
	end
	
        SIGNAL[period] = MVAI.DATA[period];
    
     if period < last then
	 return;
	 end
	 
     local  i1 = EMAS.DATA[period] + MAS.DATA[period]; 
     local  i2 = EMAL.DATA[period] + MAL.DATA[period]; 
     Leader[period] = i1 - i2     
  
 
end



--[[
//
// @author LazyBear 
// List of all my indicators: 
// https://docs.google.com/document/d/15AGCufJZ8CIUvwFJ9W-IKns88gkWOKBCvByMEvm5MLo/edit?usp=sharing
//
study("MACD Leader [LazyBear]", shorttitle="MACDL_LB")
src=close
shortLength = input(12, title="Fast Length")
longLength = input(26, title="Slow Length")
sigLength = input(9, title="Signal Length")
showMACD=input(false)
showMACDSignal=input(false)
ma(s,l) => ema(s,l)
sema = ma( src, shortLength )
lema = ma( src, longLength )
i1 = sema + ma( src - sema, shortLength )
i2 = lema + ma( src - lema, longLength )
macdl = i1 - i2
macd=sema-lema

hline(0)
plot( macdl, title="MACDLeader", color=maroon, linewidth=2)
plot(showMACD?macd:na, title="MACD", color=green)
plot(showMACDSignal?sma(macd, sigLength):na, title="Signal", color=red)
]]


