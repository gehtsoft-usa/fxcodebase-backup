 -- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=895

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("MTF MCP Detrended Price Oscillator (DPO)");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
	
	
	local LTF={"Chart_Time_Frame","m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"}
	
	indicator.parameters:addString("TF", "Bar Size to display High/Low", "", "Chart_Time_Frame" );
	for i = 1, 14, 1 do
	indicator.parameters:addStringAlternative("TF", LTF[i], "", LTF[i]);
    end
	
	
    indicator.parameters:addString("Instrument" , "Instrument", "", "EUR/USD");
    indicator.parameters:setFlag("Instrument", core.FLAG_INSTRUMENTS);
	
	
    indicator.parameters:addInteger("N", "N", "Period", 14);
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
    indicator.parameters:addColor("Up", "Color of Up Candle", "", core.COLOR_UPCANDLE );
	indicator.parameters:addColor("Dn", "Color of Down Color", "", core.COLOR_DOWNCANDLE )
end

local first;
local source = nil;
local MAo, MAc, MAh, MAl;
local N;

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;
local Method;
 

local TF; 
local dayoffset;
local weekoffset;
local SourceData;
local loading = false;   

local Instrument;

function Prepare(nameOnly)   
 
 
    
	Instrument=instance.parameters.Instrument;
	TF=instance.parameters.TF;
	 
	
 
    local name = profile:id() .. "(" ..  instance.source:name()   .. ", " ..   Instrument   .. ", " ..  TF  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
 
	
	 
    source = instance.source;
    N=instance.parameters.N;
	Method=instance.parameters.Method;
	
	if TF== "Chart_Time_Frame" then
	TF=source:barSize();
	end 
	
   
	
	 dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
 
	
	 local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle(TF, 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");
	
	local Test = core.indicators:create("MVA", source ,N);   
	first= Test.DATA:first() ; 		
	
	SourceData = core.host:execute("getSyncHistory", Instrument, TF, source:isBid(), math.min(300,first), 100, 101);
	loading=true;
	
	
	
	
    MAo = core.indicators:create(Method, SourceData.open, N);
	MAc = core.indicators:create(Method, SourceData.close, N);
	MAh = core.indicators:create(Method, SourceData.high, N);
	MAl = core.indicators:create(Method, SourceData.low, N);
    first = MAo.DATA:first();
     
    open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
	
	open:setPrecision(math.max(2, instance.source:getPrecision()));	
	high:setPrecision(math.max(2, instance.source:getPrecision()));
    low:setPrecision(math.max(2, instance.source:getPrecision()));	
	close:setPrecision(math.max(2, instance.source:getPrecision()));
	 
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);    
end

function Update(period, mode)

    MAo:update(mode);
	MAc:update(mode);
	MAh:update(mode);
	MAl:update(mode);
	
	
	 local p =  Initialization(period) 
     
	    if not p then
		return;
		end
	
    if (p <N) then
	return;
	end
	
	open[period] =  SourceData.open[p] - MAo.DATA[p];
	close[period] = SourceData.close[p] -MAc.DATA[p];
	high[period] = math.max(open[period],close[period], SourceData.high[p] -MAh.DATA[p], SourceData.low[p] -MAl.DATA[p] );
	low[period] = math.min(open[period] ,close[period], SourceData.high[p] -MAh.DATA[p], SourceData.low[p] -MAl.DATA[p]);
    
    
end


function   Initialization(period)

    local Candle;
    Candle = core.getcandle(TF, source:date(period), dayoffset, weekoffset);

  
    if loading or SourceData:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(SourceData, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	




-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
       instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end

