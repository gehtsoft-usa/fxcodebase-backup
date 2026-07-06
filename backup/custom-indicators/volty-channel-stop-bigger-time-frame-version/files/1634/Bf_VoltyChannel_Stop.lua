-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=893

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
 


-- The original indicator VoltyChannel_Stop_v2.1.mq4
--  Copyright © 2007, TrendLaboratory
--  http://finance.groups.yahoo.com/group/TrendLaboratory
--  E-mail: igorad2003@yahoo.co.uk
-- v2.1. Modified by
--  MODIFIED BY AVERY T. HORTON, JR. AKA THERUMPLEDONE@GMAIL.COM
-- ---------------------------------------------------------------------
-- This port to lua is made by http://fxcodebase.com team.
-- ---------------------------------------------------------------------
-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Bigger time frame Volty Channel Stop");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addString("TF", "Time frame", "", "m15");
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS);

    indicator.parameters:addInteger("MA_N", "Moving Average Period", "", 1);
    indicator.parameters:addString("MA_M", "Moving Average Method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "MVA");
    indicator.parameters:addStringAlternative("MA_M", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA_M", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA_M", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA_M", "SMMA*", "", "SMMA");
    indicator.parameters:addStringAlternative("MA_M", "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("MA_M", "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("MA_M", "Wilders*", "", "WMA");
    indicator.parameters:addInteger("ATR_N", "ATR period", "", 10);
    indicator.parameters:addDouble("VF", "Volatility's Factor or Multiplier", "", 4);
    indicator.parameters:addInteger("OF", "Offset factor", "", 0);
    indicator.parameters:addString("P", "Price", "The price to the indicator apply to", "C");
    indicator.parameters:addStringAlternative("P", "Open", "", "O");
    indicator.parameters:addStringAlternative("P", "High", "", "H");
    indicator.parameters:addStringAlternative("P", "Low", "", "L");
    indicator.parameters:addStringAlternative("P", "Close", "", "C");
    indicator.parameters:addStringAlternative("P", "Median", "", "M");
    indicator.parameters:addStringAlternative("P", "Typical", "", "T");
    indicator.parameters:addStringAlternative("P", "Weighted", "", "W");
    indicator.parameters:addBoolean("HiLoE", "Use High/Low envelope", "", false);
    indicator.parameters:addBoolean("HiLoB", "Hi/Lo Break", "", true);

    indicator.parameters:addColor("UpBuffer_color", "Color of UpBuffer", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DnBuffer_color", "Color of DnBuffer", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("UpSignal_color", "Color of UpSignal", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DnSignal_color", "Color of DnSignal", "", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local source = nil;
local bf_source = nil;
local bf_size;
local TF;

local offset;
local weekoffset;
local host;
local loading = false;
local _from = nil;
local volti;


-- Streams block
local UpBuffer = nil;
local DnBuffer = nil;
local UpSignal = nil;
local DnSignal = nil;

-- Routine
function Prepare(onlyName)
    assert(core.indicators:findIndicator("VOLTYCHANNEL_STOP") ~= nil, "Please download and install VoltyChannel_Stop.lua indicator");

    TF = instance.parameters.TF;

    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. "(" .. TF .. ")" .. ", " ..
                                        instance.parameters.MA_N .. ", " ..
                                        instance.parameters.MA_M .. ", " ..
                                        instance.parameters.ATR_N .. ", " ..
                                        instance.parameters.VF .. ", " ..
                                        instance.parameters.OF .. ", " ..
                                        instance.parameters.P .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end
	
	
	
 local s, e, s1, e1;
    s1, e1 = core.getcandle(source:barSize(), core.now(), 0, 0);
    s2, e2 = core.getcandle(TF, core.now(), 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");

    host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");

    local s, e;
    s, e = core.getcandle(TF, core.now(), offset, weekoffset);
    bf_size = e - s;

    UpBuffer = instance:addStream("UpBuffer", core.Line, name .. ".UpBuffer", "UpBuffer", instance.parameters.UpBuffer_color, 0);
    DnBuffer = instance:addStream("DnBuffer", core.Line, name .. ".DnBuffer", "DnBuffer", instance.parameters.DnBuffer_color, 0);
    UpSignal = instance:createTextOutput ("UpSignal", "UpSignal", "Wingdings", 10, core.H_Center, core.V_Bottom, instance.parameters.UpSignal_color, 0);
    DnSignal = instance:createTextOutput ("DnSignal", "DnSignal", "Wingdings", 10, core.H_Center, core.V_Top, instance.parameters.DnSignal_color, 0);
	
	
	local Test = core.indicators:create("VOLTYCHANNEL_STOP", source );   
	first= Test.DATA:first() ; 	
	
	
	bf_source = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), math.min ( first*2, 300), 100, 101);
	loading=true;
	
	
        local profile, params;
        profile = core.indicators:findIndicator("VOLTYCHANNEL_STOP");
        params = profile:parameters();

        params:setInteger("MA_N", instance.parameters:getInteger("MA_N"));
        params:setString("MA_M", instance.parameters:getString("MA_M"));
        params:setInteger("ATR_N", instance.parameters:getInteger("ATR_N"));
        params:setDouble("VF", instance.parameters:getDouble("VF"));
        params:setInteger("OF", instance.parameters:getInteger("OF"));
        params:setString("P", instance.parameters:getString("P"));
        params:setBoolean("HiLoE", instance.parameters:getBoolean("HiLoE"));
        params:setBoolean("HiLoB", instance.parameters:getBoolean("HiLoB"));
        volti = profile:createInstance(bf_source, params);
        loading = true;
        return ;
   
	
end

-- Indicator calculation routine
function Update(period, mode)
   

    if loading then
        return ;
    end


    local bf_period = core.findDate (bf_source, source:date(period), false);


    if bf_period < 0 then
        return ;
    end

    volti:update(mode);

    if volti.UpBuffer:hasData(bf_period) then
        UpBuffer[period] = volti.UpBuffer[bf_period];
    end
    if volti.DnBuffer:hasData(bf_period) then
        DnBuffer[period] = volti.DnBuffer[bf_period];
    end

    if UpBuffer:hasData(period) and DnBuffer:hasData(period - 1) then
        UpSignal:set(period, UpBuffer[period], "\225");
    end
    if DnBuffer:hasData(period) and UpBuffer:hasData(period - 1) then
        UpSignal:set(period, UpBuffer[period], "\225");
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

 