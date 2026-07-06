-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66106

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


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Non-standard time Time Frame MACD");
    indicator:description("Non-standard time Time Frame MACD");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Selector");
	indicator.parameters:addBoolean("S1", "Show MACD", "", true);
	indicator.parameters:addBoolean("S2", "Show Signal", "", true);
	indicator.parameters:addBoolean("S3", "Show HIstogram", "", true);
	
	
	indicator.parameters:addString("Type", "MACD Type", "", "Bar");
    indicator.parameters:addStringAlternative("Type", "Bar", "", "Bar");
    indicator.parameters:addStringAlternative("Type", "Line", "", "Line");
	
	indicator.parameters:addGroup("Calculation");
	
	 
	
	indicator.parameters:addString("TF", "Time frame", "", "Chart");
	
 
	
    indicator.parameters:addInteger("SN", "Short MA", "", 12, 2, 1000);
     indicator.parameters:addInteger("LN", "Long MA", "", 26, 2, 1000);
    indicator.parameters:addInteger("IN", "1. Signal Line MA", "", 9, 2, 1000); 
	
    indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("color1", "MACD Color", "", core.rgb(0, 0, 0));
    indicator.parameters:addInteger("width1", "Signal Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Signal Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("color2", "Signal Color" , "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width2", "Signal Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Signal Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color3", "Histogram Color" , "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("width3", "Histogram Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Histogram Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
 
	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local SN,LN,IN;

local first;
local source = nil; 
local MACD, HISTOGRAM,SIGNAL;
local macd;
local TF;
local weekoffset, dayoffset;
local loading;
local SourceData;
local S1, S2, S3;

local Type;
-- Routine
function Prepare(nameOnly)  

    source = instance.source;
   
    Type=instance.parameters.Type;
	TF=instance.parameters.TF; 
	SN = instance.parameters.SN;
    LN = instance.parameters.LN;
    IN = instance.parameters.IN; 
	
	S1= instance.parameters.S1;
	S2= instance.parameters.S2;
	S3= instance.parameters.S3;
	
	
	TF= instance.parameters.TF;
	if TF=="Chart" then
	TF=source:barSize();
	end
		 
     local name = profile:id() .. "(" .. source:name() .. ", " .. TF.. ", " .. SN .. ", " .. LN .. ", " .. IN.. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	if (LN <= SN) then
       error("The short MA period must be smaller than long MA period");
    end	
 
 
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	

    local precision = math.max(2, source:getPrecision());

	if TF ~= "Chart"then
	local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle(TF, 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");
	end
	
	if TF ~= source:barSize() then 
    SourceData = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), 0, 100, 101);
    loading=true;
	
	macd = core.indicators:create("MACD", SourceData.close, SN,LN,IN);  	
	first = macd.HISTOGRAM:first();
	
	else
	
	macd = core.indicators:create("MACD", source, SN,LN,IN);  	
	first = macd.HISTOGRAM:first();
	
	end
    if S1 then
			if Type == "Bar" then
			MACD = instance:addStream("MACD", core.Bar, name .. ".MACD", "MACD", instance.parameters.color1, first); 
			else
			MACD = instance:addStream("MACD", core.Line, name .. ".MACD", "MACD", instance.parameters.color1, first); 
			MACD:setWidth(instance.parameters.width1);
			MACD:setStyle(instance.parameters.style1);
			end
    MACD:setPrecision(precision);
    else
	MACD = instance:addInternalStream(0, 0);
	end
	
    if S2 then
    SIGNAL = instance:addStream("SIGNAL", core.Line, name .. "SIGNAL", "SIGNAL", instance.parameters.color2, first);
    SIGNAL:setWidth(instance.parameters.width2);
    SIGNAL:setStyle(instance.parameters.style2);
    SIGNAL:setPrecision(precision);
	else
	SIGNAL = instance:addInternalStream(0, 0);
	end
	
	if S3 then
    HISTOGRAM = instance:addStream("HISTOGRAM", core.Line, name .. "HISTOGRAM", "HISTOGRAM", instance.parameters.color3, first);
    HISTOGRAM:setWidth(instance.parameters.width3);
    HISTOGRAM:setStyle(instance.parameters.style3);
    HISTOGRAM:setPrecision(precision); 
	else
	HISTOGRAM = instance:addInternalStream(0, 0);
	end
	
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
  
	
    macd:update(mode); 
	
	if period <first then
	return;
	end
	
	 if TF ~= "Chart" and  TF ~=  source:barSize()  then
	 local p =  Initialization(period) 
     
        if not p then
        return;
        end
		
		
			MACD[period]=macd.DATA[p] ;
			SIGNAL[period]=macd.SIGNAL[p] ;
			HISTOGRAM[period]=macd.HISTOGRAM[p] ;
	 
	 else
	    
		
		 
			MACD[period]=macd.DATA[period] ;
			SIGNAL[period]=macd.SIGNAL[period] ;
			HISTOGRAM[period]=macd.HISTOGRAM[period] ;
			
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


