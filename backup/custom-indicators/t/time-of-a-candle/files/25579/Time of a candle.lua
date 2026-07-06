-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=11079&p=116472#p116472

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


function Init()
    indicator:name("Time of a candle");
    indicator:description("The indicator draws three vertical lines at the specified times");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("1. Line Parameters");
    indicator.parameters:addInteger("hour1", "Hour (EST)", "Hour at start of which the line must be drawn", 8, 0, 23);
	 indicator.parameters:addBoolean("On1", "Use 1. Line", "",  true);
	indicator.parameters:addInteger("minute1", "Minutes", "Minute at start of which the line must be drawn", 0, 0, 59);
	
	 	 
	indicator.parameters:addGroup("2. Line Parameters");
	 indicator.parameters:addBoolean("On2", "Use 2. Line", "",  true);
	indicator.parameters:addInteger("hour2", "Hour (EST)", "Hour at start of which the line must be drawn", 14, 0, 23);	
	indicator.parameters:addInteger("minute2", "Minutes", "Minute at start of which the line must be drawn", 0, 0, 59);
		 
	indicator.parameters:addGroup("3. Line Parameters");
	 indicator.parameters:addBoolean("On3", "Use 3. Line", "",  true);
	indicator.parameters:addInteger("hour3", "Hour (EST)", "Hour at start of which the line must be drawn", 21, 0, 23);
	indicator.parameters:addInteger("minute3", "Minutes", "Minute at start of which the line must be drawn", 0, 0, 59);	  
	  
	indicator.parameters:addGroup("Price Type"); 
   	indicator.parameters:addString("Method", "PriceType", "", "close");
    indicator.parameters:addStringAlternative("Method", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Method", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Method", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Method","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Method", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Method", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Method", "WEIGHTED", "", "weighted");
	
	
	indicator.parameters:addGroup("Tools");  
	 indicator.parameters:addBoolean("Horizontal", "Use Slope lines", "",  true);
	  indicator.parameters:addBoolean("Vertical", "Use Vertical lines", "",  true);
	  
    indicator.parameters:addGroup("1. Vertical Line Style");
    indicator.parameters:addColor("clr1", "Color", "", core.rgb(0, 127, 0));
    indicator.parameters:addInteger("width1", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Style", "", core.LINE_DOT);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);
	 indicator.parameters:addGroup("2. Vertical Line Style");
    indicator.parameters:addColor("clr2", "Color", "", core.rgb(0, 127, 0));
    indicator.parameters:addInteger("width2", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Style", "", core.LINE_DOT);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);
	 indicator.parameters:addGroup("3. Vertical Line Style");
    indicator.parameters:addColor("clr3", "Color", "", core.rgb(0, 127, 0));
    indicator.parameters:addInteger("width3", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Style", "", core.LINE_DOT);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addGroup("Slope Line Style");
	indicator.parameters:addColor("clr4", "Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("width4", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Style", "", core.LINE_SOLID );
    indicator.parameters:setFlag("style4", core.FLAG_LEVEL_STYLE);
	
end
local ON={};
local Vertical;
local source;
local dummy, host;
local hour1, hour2, hour3, clr1, width1, style1, clr2, width2, style2, clr3, width3, style3, clr4, width4, style4;
local canwork, error;
local minute1, minute2, minute3;
local Size;
local Horizontal;
local Method;

local OLD=nil;
local NEW=nil;
function Prepare(onlyname)
    Vertical= instance.parameters.Vertical;
     Horizontal= instance.parameters.Horizontal;
	 Method= instance.parameters.Method;
    source = instance.source;
    clr1 = instance.parameters.clr1;
    width1 = instance.parameters.width1;
    style1 = instance.parameters.style1;
	
	minute1 = instance.parameters.minute1;
	minute2 = instance.parameters.minute2;
	minute3 = instance.parameters.minute3;
	
	ON[1] = instance.parameters.On1;
	ON[2] = instance.parameters.On2;
	ON[3] = instance.parameters.On3;
	
	clr2 = instance.parameters.clr2;
    width2 = instance.parameters.width2;
    style2 = instance.parameters.style2;
	
	clr3 = instance.parameters.clr3;
    width3 = instance.parameters.width3;
    style3 = instance.parameters.style3;
	
	clr4 = instance.parameters.clr4;
    width4 = instance.parameters.width4;
    style4 = instance.parameters.style4;
	
    hour1 = instance.parameters.hour1;
	hour2 = instance.parameters.hour2;
	hour3 = instance.parameters.hour3;
	
    host = core.host;

    local s, e = core.getcandle(source:barSize(), 0, host:execute("getTradingDayOffset"), 0);
    canwork = not(math.floor(e - s) >= 1);
	
	local s1, e1
	 s1, e1 = core.getcandle("D1", 0, 0, 0);
	 Size = e1-s1;

    if not canwork then
        errtext = "The indicator must be applied on intraday charts";
        if onlyname then
            assert(false, errtext);
        else
            core.host:execute("setStatus", "error:" .. errtext);
        end
    end

    local name;
    name = profile:id() .. "(" .. source:name() .. "," .. hour1 .. "," .. hour2 .. "," .. hour3 .. ")";
    instance:name(name);

    if onlyname then
        return ;
    end


    dummy = instance:addStream("D", core.Line, name .. ".D", "D", clr1, 0);
end

local last_s = nil;
local id = 0;

function Update(period, mode)
    if not canwork then
        return ;
    end

    -- calculation restarted
    if period == 0 then
        host:execute("removeAll");
        id = 0;
		core.host:execute ("removeAll");
    end

    local s = source:serial(period);

    if last_s ~= nil and s == last_s then
        return ;
    end
	
	local FIRST, SECOND;

    last_s = s;

    local date = source:date(period);
    local t = core.dateToTable(date);
    if t.min == minute1 and t.hour == hour1 and ON[1] then
        id = id + 1;
		
		if   Vertical  then
        host:execute("drawLine", id, date, 0, date, 100000, clr1, style1, width1, core.formatDate(host:execute("convertTime", core.TZ_EST, core.TZ_TS, date)));
		host:execute("drawLine", 10+id, date +Size, 0, date +Size, 100000, clr1, style2, width3);
		end
		 OLD = NEW;
		 NEW = date;
		 
		 
		 if OLD ~= nil and NEW ~= nil and Horizontal then
					 if Method == "open" or   Method == "close" then
					  FIRST=source.open[core.findDate (source,OLD, false)];
					  SECOND=source.close[core.findDate (source,NEW, false)];
					  
					 --elseif Method == "high" or   Method == "low" then
					 
					--  if source.low[core.findDate (source,OLD, false)] ==  math.min();
					--  source.high[core.findDate (source,NEW, false)];
					 
					 else
					  FIRST=source[Method][core.findDate (source,OLD, false)];
					  SECOND=source[Method][core.findDate (source,NEW, false)];
					
					 end	
            host:execute("drawLine", 10000+id, OLD, FIRST, NEW, SECOND, clr4, style4, width4);					 
			end
    end
	
	 if t.min == minute2 and t.hour == hour2  and ON[2] then
        id = id + 1;
		if   Vertical  then
        host:execute("drawLine", id, date, 0, date, 100000, clr2, style2, width2, core.formatDate(host:execute("convertTime", core.TZ_EST, core.TZ_TS, date)));
		host:execute("drawLine", 10+id, date +Size, 0, date +Size, 100000, clr2, style2, width2);
		end
		 OLD = NEW;
		 NEW = date;
		 
		 if OLD ~= nil and NEW ~= nil  and Horizontal then
			       if Method == "open" or   Method == "close" then
					  FIRST=source.open[core.findDate (source,OLD, false)];
					  SECOND=source.close[core.findDate (source,NEW, false)];
					  
					 --elseif Method == "high" or   Method == "low" then
					 
					--  if source.low[core.findDate (source,OLD, false)] ==  math.min();
					--  source.high[core.findDate (source,NEW, false)];
					 
					 else
					  FIRST=source[Method][core.findDate (source,OLD, false)];
					  SECOND=source[Method][core.findDate (source,NEW, false)];
					
					 end	
			  host:execute("drawLine", 10000+id, OLD, FIRST, NEW, SECOND, clr4, style4, width4);					 
		 end
		
    end
	
	if t.min == minute3 and t.hour == hour3  and ON[3] then
        id = id + 1;
		if   Vertical  then
        host:execute("drawLine", id, date, 0, date, 100000, clr3, style3, width3, core.formatDate(host:execute("convertTime", core.TZ_EST, core.TZ_TS, date)));
		 host:execute("drawLine", 10+ id, date +Size , 0, date +Size, 100000, clr3, style3, width3);
		 end
		  OLD = NEW;
		 NEW = date;
		 
		 if OLD ~= nil and NEW ~= nil  and Horizontal then
		            if Method == "open" or   Method == "close" then
					  FIRST=source.open[core.findDate (source,OLD, false)];
					  SECOND=source.close[core.findDate (source,NEW, false)];
					  
					 --elseif Method == "high" or   Method == "low" then
					 
					--  if source.low[core.findDate (source,OLD, false)] ==  math.min();
					--  source.high[core.findDate (source,NEW, false)];
					 
					 else
					  FIRST=source[Method][core.findDate (source,OLD, false)];
					  SECOND=source[Method][core.findDate (source,NEW, false)];
					
					 end
                 host:execute("drawLine", 10000+id, OLD, FIRST, NEW, SECOND, clr4, style4, width4);								 
		 end
		 
    end
		
end



