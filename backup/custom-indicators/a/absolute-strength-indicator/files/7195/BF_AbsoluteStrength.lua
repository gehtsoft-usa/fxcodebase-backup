-- Id: 2780
--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Bigger AbsoluteStrengthIndicator.");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Method", "Method", "", "RSI");
    indicator.parameters:addStringAlternative("Method", "RSI", "", "RSI");
    indicator.parameters:addStringAlternative("Method", "Stoch", "", "Stoch");
    indicator.parameters:addStringAlternative("Method", "ADX", "", "ADX");
	
	indicator.parameters:addString("Method1", "Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");   
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
	
	
	indicator.parameters:addString("Type1", "CLOSE", "", "C");
    indicator.parameters:addStringAlternative("Type1", "OPEN", "", "O");
    indicator.parameters:addStringAlternative("Type1", "HIGH", "", "H");
    indicator.parameters:addStringAlternative("Type1", "LOW", "", "L");
    indicator.parameters:addStringAlternative("Type1","CLOSE", "", "C");
    indicator.parameters:addStringAlternative("Type1", "MEDIAN", "", "M");
    indicator.parameters:addStringAlternative("Type1", "TYPICAL", "", "T");
    indicator.parameters:addStringAlternative("Type1", "WEIGHTED", "", "W");
	
	
	 indicator.parameters:addInteger("Length", "Period for Evaluation", "", 10);
	 indicator.parameters:addInteger("Signal", "Period for Signal", "", 5);
	 indicator.parameters:addInteger("Smoothing", "Period for Smoothing", "", 5);
	 
	  indicator.parameters:addInteger("OverBought", "OverBought", "", 0);
	   indicator.parameters:addInteger("OverSold", "OverSold", "", 0);
	
		
    indicator.parameters:addString("BS", "Time frame to calculate stochastic", "", "D1");
    indicator.parameters:setFlag("BS", core.FLAG_PERIODS);
   
    indicator.parameters:addGroup("Display");
	
	indicator.parameters:addGroup("Selector");   
	 indicator.parameters:addBoolean("ShowBulls", "Show Bulls", "" , true);
	 indicator.parameters:addBoolean("ShowBears", "Show Bears", "" , true);
	
	 indicator.parameters:addGroup("Bulls Style");   
    indicator.parameters:addColor("Bulls_color", "Color of Bulls", "Color of Bulls", core.rgb(0, 255, 0));
		indicator.parameters:addInteger("Bullswidth", "Line Width", "", 1, 1, 5);
     indicator.parameters:addInteger("Bullsstyle", "Line Style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("Bullsstyle", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addGroup("Bears Style");
    indicator.parameters:addColor("Bears_color", "Color of Bears", "Color of Bears", core.rgb(255, 0, 0));
		indicator.parameters:addInteger("Bearswidth", "Line Width", "", 1, 1, 5);
     indicator.parameters:addInteger("Bearsstyle", "Line Style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("Bearsstyle", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addGroup("Bulls Signal Style");
    indicator.parameters:addColor("SignalBulls_color", "Color of SignalBulls", "Color of SignalBulls", core.rgb(0, 255, 128));
		indicator.parameters:addInteger("SignalBullswidth", "Line Width", "", 1, 1, 5);
     indicator.parameters:addInteger("SignalBullsstyle", "Line Style", "", core.LINE_DASH);
	indicator.parameters:setFlag("SignalBullsstyle", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addGroup("Bears Signal Style");
    indicator.parameters:addColor("SignalBears_color", "Color of SignalBears", "Color of SignalBears", core.rgb(255, 0, 128));	
	indicator.parameters:addInteger("SignalBearswidth", "Line Width", "", 1, 1, 5);
     indicator.parameters:addInteger("SignalBearsstyle", "Line Style", "", core.LINE_DASH);
	indicator.parameters:setFlag("SignalBearsstyle", core.FLAG_LINE_STYLE);	
	

end



local source;                   -- the source
local bf_data = nil;          -- the high/low data

local Smoothing, Signal, Length,Type1, OverBought, OverSold, Method, Method1;
local ShowBulls,  ShowBears;

local BS;
local bf_length;                 -- length of the bigger frame in seconds
local dates;                    -- candle dates
local host;
local Indicator;
local Output={};
--local SK, SD;
local day_offset;
local week_offset;
local extent;

local first;

function Prepare(nameOnly)
    source = instance.source;
    host = core.host;
	first = source:first();

    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");
	
	
	assert(core.indicators:findIndicator("ABSOLUTESTRENGTHINDICATOR") ~= nil, "Please, download and install ABSOLUTESTRENGTHINDICATOR.LUA indicator");

    BS = instance.parameters.BS;
	
    Smoothing = instance.parameters.Smoothing;
	Signal = instance.parameters.Signal;  
    Type1=instance.parameters.Type1;
    OverBought = instance.parameters.OverBought;
	OverSold = instance.parameters.OverSold;
    Length = instance.parameters.Length;
    Method = instance.parameters.Method;
	Method1= instance.parameters.Method1;
	
	ShowBulls= instance.parameters.ShowBulls;
	 ShowBears= instance.parameters.ShowBears;    

   

    local name = profile:id() .. "(" .. source:name()  ..", " ..Length .. ", ".. Smoothing .. "," .. Signal .. "," .. Type1 .. "," .. Method .. ", " .. Method1 ..")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	 local s, e, s1, e1;

    s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
    s1, e1 = core.getcandle(BS, core.now(), 0, 0);
    assert ((e - s) < (e1 - s1), "The chosen time frame must be bigger than the chart time frame!");
    bf_length = math.floor((e1 - s1) * 86400 + 0.5);
   
	if ShowBulls then
     Output[1] = instance:addStream("Bulls", core.Line, name .. ".Bulls", "Bulls", instance.parameters.Bulls_color, first);
    Output[1]:setPrecision(math.max(2, instance.source:getPrecision()));
	 Output[1]:setWidth(instance.parameters.Bullswidth);
	 Output[1]:setStyle(instance.parameters.Bullsstyle);
	 Output[2] = instance:addStream("SignalBulls", core.Line, name .. ".SignalBulls", "SignalBulls", instance.parameters.SignalBulls_color, first);
    Output[2]:setPrecision(math.max(2, instance.source:getPrecision()));
	 Output[2]:setWidth(instance.parameters.SignalBullswidth);
	 Output[2]:setStyle(instance.parameters.SignalBullsstyle);
	else
	 Output[1]= instance:addInternalStream(0, 0);
	 Output[2]= instance:addInternalStream(0, 0);
	end
	
	extent = (Length +Smoothing+Signal) * 2;
	
	if ShowBears then 
     Output[3] = instance:addStream("Bears", core.Line, name .. ".Bears", "Bears", instance.parameters.Bears_color, first);
    Output[3]:setPrecision(math.max(2, instance.source:getPrecision()));
	 Output[3]:setWidth(instance.parameters.Bearswidth);
	 Output[3]:setStyle(instance.parameters.Bearsstyle);   
     Output[4] = instance:addStream("SignalBears", core.Line, name .. ".SignalBears", "SignalBears", instance.parameters.SignalBears_color, first);
    Output[4]:setPrecision(math.max(2, instance.source:getPrecision()));
	 Output[4]:setWidth(instance.parameters.SignalBearswidth);
	 Output[4]:setStyle(instance.parameters.SignalBearsstyle);
	else
	 Output[3]= instance:addInternalStream(0, 0);
	 Output[4]= instance:addInternalStream(0, 0);
	end
   
    for i=1, 4, 1 do
    Output[i]:setPrecision(math.max(2, instance.source:getPrecision()));
	end 
end


local loading = false;
local loadingFrom, loadingTo;
local pday = nil;

-- the function which is called to calculate the period
function Update(period, mode)
    -- get date and time of the hi/lo candle in the reference data
    local bf_candle;
    bf_candle = core.getcandle(BS, source:date(period), day_offset, week_offset);

    -- if data for the specific candle are still loading
    -- then do nothing
    if loading and bf_candle >= loadingFrom and (loadingTo == 0 or bf_candle <= loadingTo) then
        return ;
    end

    -- if the period is before the source start
    -- the do nothing
    if period < source:first() then
        return ;
    end

    -- if data is not loaded yet at all
    -- load the data
    if bf_data == nil then
        -- there is no data at all, load initial data
        local to, t;
        local from;

        if (source:isAlive()) then
            -- if the source is subscribed for updates
            -- then subscribe the current collection as well
            to = 0;
        else
            -- else load up to the last currently available date
            t, to = core.getcandle(BS, source:date(period), day_offset, week_offset);
        end

        from = core.getcandle(BS, source:date(source:first()), day_offset, week_offset);
        Output[1]:setBookmark(1, period);
        -- shift so the bigger frame data is able to provide us with the stoch data at the first period
        from = math.floor(from * 86400 - (bf_length * extent) + 0.5) / 86400;
        local nontrading, nontradingend;
        nontrading, nontradingend = core.isnontrading(from, day_offset);
        if nontrading then
            -- if it is non-trading, shift for two days to skip the non-trading periods
            from = math.floor((from - 2) * 86400 - (bf_length * extent) + 0.5) / 86400;
        end
        loading = true;
        loadingFrom = from;
        loadingTo = to;
        bf_data = host:execute("getHistory", 1, source:instrument(), BS, loadingFrom, to, source:isBid());
        Indicator = core.indicators:create("ABSOLUTESTRENGTHINDICATOR", bf_data,Method,Method1, Type1, Length, Signal, Smoothing,  OverBought , OverSold , true, true);
        return ;
    end

    -- check whether the requested candle is before
    -- the reference collection start
    if (bf_candle < bf_data:date(0)) then
        Output[1]:setBookmark(1, period);
        if loading then
            return ;
        end
        -- shift so the bigger frame data is able to provide us with the stoch data at the first period
        from = math.floor(bf_candle * 86400 - (bf_length * extent) + 0.5) / 86400;
        local nontrading, nontradingend;
        nontrading, nontradingend = core.isnontrading(from, day_offset);
        if nontrading then
            -- if it is non-trading, shift for two days to skip the non-trading periods
            from = math.floor((from - 2) * 86400 - (bf_length * extent) + 0.5) / 86400;
        end
        loading = true;
        loadingFrom = from;
        loadingTo = bf_data:date(0);
        host:execute("extendHistory", 1, bf_data, loadingFrom, loadingTo);
        return ;
    end

    -- check whether the requested candle is after
    -- the reference collection end
    if (not(source:isAlive()) and bf_candle > bf_data:date(bf_data:size() - 1)) then
        Output[1]:setBookmark(1, period);
        if loading then
            return ;
        end
        loading = true;
        loadingFrom = bf_data:date(bf_data:size() - 1);
        loadingTo = bf_candle;
        host:execute("extendHistory", 1, bf_data, loadingFrom, loadingTo);
        return ;
    end

    Indicator:update(mode);
    local p;
    p = core.findDate (bf_data, bf_candle, true);
    if p == -1 then
        return ;
    end
    if Indicator:getStream(0):hasData(p) then
        Output[1][period] = Indicator:getStream(0)[p];
    end
    if Indicator:getStream(1):hasData(p) then
        Output[2][period] = Indicator:getStream(1)[p];
    end
	
	  if Indicator:getStream(2):hasData(p) then
        Output[3][period] = Indicator:getStream(2)[p];
    end
	 if Indicator:getStream(3):hasData(p) then
        Output[4][period] = Indicator:getStream(3)[p];
    end
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    local period;

    pday = nil;
    period = Output[1]:getBookmark(1);

    if (period < 0) then
        period = 0;
    end
    loading = false;
    instance:updateFrom(period);
end 