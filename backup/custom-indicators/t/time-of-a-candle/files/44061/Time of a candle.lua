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
	
	--local Labels={ "EST", "UTC","Local","Chart", "Server", "Financial"};
	

	--local i;	 
	--indicator.parameters:addInteger("Referent"  , "Referent Time", "" , 4);	
   
  --  for i = 1, 6, 1 do	
   --  indicator.parameters:addIntegerAlternative("Referent" ,  Labels[i], "",  i);	
	--end 

    indicator.parameters:addGroup("1. Line Parameters");
    indicator.parameters:addInteger("hour1", "Hour (EST)", "Hour at start of which the line must be drawn", 8, 0, 23);
	indicator.parameters:addInteger("minute1", "Minutes", "Minute at start of which the line must be drawn", 0, 0, 59);
	indicator.parameters:addInteger("day1", "Day", "", 0);
	indicator.parameters:addIntegerAlternative("day1", "No Line", "", 0);
	indicator.parameters:addIntegerAlternative("day1", "Any Day", "", -1);	
    indicator.parameters:addIntegerAlternative("day1", "Monday", "", 2);
	indicator.parameters:addIntegerAlternative("day1", "Tuesday", "", 3);
	indicator.parameters:addIntegerAlternative("day1", "Wednesday", "", 4);
	indicator.parameters:addIntegerAlternative("day1", "Thursday", "", 5);
	indicator.parameters:addIntegerAlternative("day1", "Friday", "", 6);
	indicator.parameters:addIntegerAlternative("day1", "Sunday", "", 1);
	
	
	 	 
	indicator.parameters:addGroup("2. Line Parameters"); 
	indicator.parameters:addInteger("hour2", "Hour (EST)", "Hour at start of which the line must be drawn", 14, 0, 23);
	indicator.parameters:addInteger("minute2", "Minutes", "Minute at start of which the line must be drawn", 0, 0, 59);
	
	indicator.parameters:addInteger("day2", "Day", "", 0);
	indicator.parameters:addIntegerAlternative("day2", "No Line", "", 0);
	indicator.parameters:addIntegerAlternative("day2", "Any Day", "", -1);	
    indicator.parameters:addIntegerAlternative("day2", "Monday", "", 2);
	indicator.parameters:addIntegerAlternative("day2", "Tuesday", "", 3);
	indicator.parameters:addIntegerAlternative("day2", "Wednesday", "", 4);
	indicator.parameters:addIntegerAlternative("day2", "Thursday", "", 5);
	indicator.parameters:addIntegerAlternative("day2", "Friday", "", 6);
	indicator.parameters:addIntegerAlternative("day2", "Sunday", "", 1);
	
		 
	indicator.parameters:addGroup("3. Line Parameters");
	indicator.parameters:addInteger("hour3", "Hour (EST)", "Hour at start of which the line must be drawn", 21, 0, 23);
	indicator.parameters:addInteger("minute3", "Minutes", "Minute at start of which the line must be drawn", 0, 0, 59);

   indicator.parameters:addInteger("day3", "Day", "", 0);
   indicator.parameters:addIntegerAlternative("day3", "No Line", "", 0);
	indicator.parameters:addIntegerAlternative("day3", "Any Day", "", -1);	
    indicator.parameters:addIntegerAlternative("day3", "Monday", "", 2);
	indicator.parameters:addIntegerAlternative("day3", "Tuesday", "", 3);
	indicator.parameters:addIntegerAlternative("day3", "Wednesday", "", 4);
	indicator.parameters:addIntegerAlternative("day3", "Thursday", "", 5);
	indicator.parameters:addIntegerAlternative("day3", "Friday", "", 6);	
	indicator.parameters:addIntegerAlternative("day3", "Sunday", "", 1);
	
	indicator.parameters:addGroup("Selector");
	indicator.parameters:addBoolean("Day", "Daily Line", "", false);
	indicator.parameters:addBoolean("Weekly", "Weekly Line", "", false);
	indicator.parameters:addBoolean("Monthly", "Monthly Line", "", false);
	indicator.parameters:addBoolean("Quarter", "Quarterly Line", "", false);
	indicator.parameters:addBoolean("Year", "Yearly Line", "", true);
	
	
	
	  
    indicator.parameters:addGroup("1. Line Style");
    indicator.parameters:addColor("clr1", "Color", "", core.rgb(0, 127, 0));
    indicator.parameters:addInteger("width1", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Style", "", core.LINE_DOT);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);
	 indicator.parameters:addGroup("2. Line Style");
    indicator.parameters:addColor("clr2", "Color", "", core.rgb(0, 127, 0));
    indicator.parameters:addInteger("width2", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Style", "", core.LINE_DOT);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);
	 indicator.parameters:addGroup("3. Line Style");
    indicator.parameters:addColor("clr3", "Color", "", core.rgb(0, 127, 0));
    indicator.parameters:addInteger("width3", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Style", "", core.LINE_DOT);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);
	
	
	indicator.parameters:addGroup("Daily Line Style");
    indicator.parameters:addColor("clrD", "Color", "", core.rgb(0, 127, 0));
    indicator.parameters:addInteger("widthD", "Width", "", 5, 1, 5);
    indicator.parameters:addInteger("styleD", "Style", "", core.LINE_DOT);
    indicator.parameters:setFlag("styleD", core.FLAG_LEVEL_STYLE);
	
	
	
	indicator.parameters:addGroup("Weekly Line Style");
    indicator.parameters:addColor("clrW", "Color", "", core.rgb(0, 127, 0));
    indicator.parameters:addInteger("widthW", "Width", "", 5, 1, 5);
    indicator.parameters:addInteger("styleW", "Style", "", core.LINE_DOT);
    indicator.parameters:setFlag("styleW", core.FLAG_LEVEL_STYLE);
	
	
	indicator.parameters:addGroup("Monthly Line Style");
    indicator.parameters:addColor("clrM", "Color", "", core.rgb(0, 127, 0));
    indicator.parameters:addInteger("widthM", "Width", "", 5, 1, 5);
    indicator.parameters:addInteger("styleM", "Style", "", core.LINE_DOT);
    indicator.parameters:setFlag("styleM", core.FLAG_LEVEL_STYLE);
	
	
	indicator.parameters:addGroup("Quarterly Line Style");
    indicator.parameters:addColor("clrQ", "Color", "", core.rgb(0, 127, 0));
    indicator.parameters:addInteger("widthQ", "Width", "", 5, 1, 5);
    indicator.parameters:addInteger("styleQ", "Style", "", core.LINE_DOT);
    indicator.parameters:setFlag("styleQ", core.FLAG_LEVEL_STYLE);
	
	
	indicator.parameters:addGroup("Yearly Line Style");
    indicator.parameters:addColor("clrY", "Color", "", core.rgb(0, 127, 0));
    indicator.parameters:addInteger("widthY", "Width", "", 5, 1, 5);
    indicator.parameters:addInteger("styleY", "Style", "", core.LINE_DOT);
    indicator.parameters:setFlag("styleY", core.FLAG_LEVEL_STYLE);
	
	
	
end
local Day,styleD, widthD,clrD;
local Year,styleY, widthY,clrY;
local Quarter,styleQ, widthQ,clrQ;
local source;
local dummy, host;
local day1,day2,day3;
local hour1, hour2, hour3, clr, width, style;
--local canwork, error;
local minute1, minute2, minute3;
local DSize, WSize, MSize;
local Monthly,styleM,styleW;
local Weekly; 
local widthM, widthM,clrM;
local widthW, widthW,clrW;
local Size,HSize;
local dayoffset;
local weekoffset;

function Prepare(onlyname)

    Day = instance.parameters.Day;
	widthD = instance.parameters.widthD;	
	styleD = instance.parameters.styleD;
	clrD = instance.parameters.clrD;
	
	Year = instance.parameters.Year;
	widthY = instance.parameters.widthY;	
	styleY = instance.parameters.styleY;
	clrY = instance.parameters.clrY;
	
	Quarter = instance.parameters.Quarter;
	widthQ = instance.parameters.widthQ;	
	styleQ = instance.parameters.styleQ;
	clrQ = instance.parameters.clrQ;
	

     Monthly = instance.parameters.Monthly
    Weekly = instance.parameters.Weekly
    day1 = instance.parameters.day1;
	day2 = instance.parameters.day2;
	day3 = instance.parameters.day3;
	
    source = instance.source;
	
    clr1 = instance.parameters.clr1;
    width1 = instance.parameters.width1;
    style1 = instance.parameters.style1;
	
	styleW = instance.parameters.styleW;
	styleM = instance.parameters.styleM;
	
	widthW = instance.parameters.widthW;
	widthM = instance.parameters.widthM;
	
	clrW = instance.parameters.clrW;
	clrM = instance.parameters.clrM;
	
	minute1 = instance.parameters.minute1;
	minute2 = instance.parameters.minute2;
	minute3 = instance.parameters.minute3;
	
	clr2 = instance.parameters.clr2;
    width2 = instance.parameters.width2;
    style2 = instance.parameters.style2;
	
	clr3 = instance.parameters.clr3;
    width3 = instance.parameters.width3;
    style3 = instance.parameters.style3;
	
    hour1 = instance.parameters.hour1;
	hour2 = instance.parameters.hour2;
	hour3 = instance.parameters.hour3;
	
    host = core.host;
	
	dayoffset = core.host:execute("getTradingDayOffset");
   weekoffset = core.host:execute("getTradingWeekOffset");

   
	
	local s1, e1
	
	 s1, e1 = core.getcandle(source:barSize(),  0,  0, 0);
	 Size = e1-s1;
	
	 s1, e1 = core.getcandle("D1", 0, 0, 0);
	 DSize = e1-s1;
	 
	 s1, e1 = core.getcandle("W1", 0, 0, 0);
	 WSize = e1-s1;
	 
	 s1, e1 = core.getcandle("M1", 0, 0, 0);
	 MSize = e1-s1;
	 
	  s1, e1 = core.getcandle("H1", 0,0, 0);
	 HSize = e1-s1;	 

   

    local name;
    name = profile:id() .. "(" .. source:name() .. "(" .. Decode(day1) .. "," .. hour1 .. "," .. minute1 .. ")"
	                    .. ", (" .. Decode(day2) .. "," .. hour2 .. "," .. minute2 .. ")"
						.. ", (" .. Decode(day3) .. "," .. hour3 .. "," .. minute3 .. ")" ; 
    instance:name(name);

    if onlyname then
        return ;
    end


    dummy = instance:addStream("D", core.Line, name .. ".D", "D", clr1, 0);
end


function Decode(day)

if day == 0 then
return "No Line";
elseif day ==-1 then
return "Any";
elseif day == 2 then
return "Monday";
elseif day == 3 then
return "Tuesday";
elseif day == 4 then
return "Wednesday";
elseif day == 5 then
return "Thursday";
elseif day == 6 then
return "Friday";
else 
return "Not Supported";
end

end

local last_s = nil;
local id = 0;

function Update(period, mode)

    -- calculation restarted
    if period == 0 then
        host:execute("removeAll");
        id = 0;
    end

    local s = source:serial(period);

    if last_s ~= nil and s == last_s then
       return ;
    end

    last_s = s;

    local date = source:date(period) ;
	 local pdate = source:date(period-1) ;
 
	
	 
    local t = core.dateToTable(date);
	 local p = core.dateToTable(pdate);
	
    if t.min == minute1 and t.hour == hour1 and  (t.wday == day1  or day1 == -1 ) and day1 ~= 0 and  Size <= HSize then
        id = id + 1;
        host:execute("drawLine", id, date, 0, date, 100000, clr1, style1, width1, core.formatDate(host:execute("convertTime", core.TZ_EST, core.TZ_TS, date)));
		 if day1 == -1 then
		 host:execute("drawLine", 10 +id, date +DSize, 0, date +DSize, 100000, clr1, style1, width1, core.formatDate(host:execute("convertTime", core.TZ_EST, core.TZ_TS, date)));
		 else
		  host:execute("drawLine", 10 +id, date +DSize*7, 0, date +DSize*7, 100000, clr1, style1, width1, core.formatDate(host:execute("convertTime", core.TZ_EST, core.TZ_TS, date +DSize*7)));
         end
	end
	
	 if t.min == minute2 and t.hour == hour2 and  (t.wday == day2  or day2 == -1 ) and day2 ~= 0 and  Size <= HSize then
        id = id + 1;
        host:execute("drawLine", id, date, 0, date, 100000, clr2, style2, width2, core.formatDate(host:execute("convertTime", core.TZ_EST, core.TZ_TS, date)));
		if day2 == -1 then
		host:execute("drawLine", 10+id, date +DSize, 0, date +DSize, 100000, clr2, style2, width2, core.formatDate(host:execute("convertTime", core.TZ_EST, core.TZ_TS, date)));
		 else
		  host:execute("drawLine", 10 +id, date +DSize*7, 0, date +DSize*7, 100000, clr1, style1, width1, core.formatDate(host:execute("convertTime", core.TZ_EST, core.TZ_TS, date +DSize*7)));
		end
    end
	
	if t.min == minute3 and t.hour == hour3  and  (t.wday == day3  or day3 == -1 ) and day3 ~= 0 and  Size <= HSize then
        id = id + 1;
        host:execute("drawLine", id, date, 0, date, 100000, clr3, style3, width3, core.formatDate(host:execute("convertTime", core.TZ_EST, core.TZ_TS, date)));
		if day3 == -1 then
		host:execute("drawLine", 10+ id, date +DSize , 0, date +DSize, 100000, clr3, style3, width3, core.formatDate(host:execute("convertTime", core.TZ_EST, core.TZ_TS, date)));
		 else
		  host:execute("drawLine", 10 +id, date +DSize*7, 0, date +DSize*7, 100000, clr1, style1, width1, core.formatDate(host:execute("convertTime", core.TZ_EST, core.TZ_TS, date +DSize*7)));
		end
    end
	
	
	if t.month ~=  p.month and Monthly and Size < MSize then
        id = id + 1;
        host:execute("drawLine", id, date, 0, date, 100000, clrM, styleM, widthM );
	end	
	
	if t.wday  ~=  p.wday and Day and t.wday > p.wday and Size < DSize then
        id = id + 1;
        host:execute("drawLine", id, date, 0, date, 100000, clrW, styleW, widthW );
	end	
	if source:barSize() == "M1" then
	    if  Year and t.month == 12 and  p.month== 11 then
			id = id + 1;
			host:execute("drawLine", id, date, 0, date, 100000, clrY, styleY, widthY );
		end	
	else	
		if  Year and t.month == 1 and  p.month== 12 then
			id = id + 1;
			host:execute("drawLine", id, date, 0, date, 100000, clrY, styleY, widthY );
		end	
	end
	
	if source:barSize() == "M1" then
	       if ( t.month ==  3 and p.month ==  2 and Quarter) 
			or (  t.month ==  6 and p.month ==  5 and Quarter) 
			or ( t.month ==  9 and p.month ==  8 and Quarter) 
			or ( t.month ==  12 and p.month ==  11 and Quarter) 
			then
				id = id + 1;
				host:execute("drawLine", id, date, 0, date, 100000, clrQ, styleQ, widthQ);
			end	
	else
			
			if ( t.month ==  4 and p.month ==  3 and Quarter) 
			or (  t.month ==  7 and p.month ==  6 and Quarter) 
			or ( t.month ==  10 and p.month ==  9 and Quarter) 
			or ( t.month ==  1 and p.month ==  12 and Quarter) 
			then
				id = id + 1;
				host:execute("drawLine", id, date, 0, date, 100000, clrQ, styleQ, widthQ);
			end	
	end
	
	if Weekly and t.wday ==  2 and  p.wday == 1
	then
	    id = id + 1;
        host:execute("drawLine", id, date, 0, date, 100000, clrQ, styleQ, widthQ);
	
	end
	 
	-- host:execute ("drawLabel", source:serial (period), source:date(period), source.high[period], tostring( t.month) )
 
		
end



