-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66134

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
    indicator:name("Daily open line indicator");
    indicator:description("Daily open line indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addDouble("Delta", "Delta", "", 50);
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Time", "Time Zone", "", 4);
    indicator.parameters:addIntegerAlternative("Time", "EST", "", 1);
    indicator.parameters:addIntegerAlternative("Time", "Coordinated Universal Time", "", 2);
    indicator.parameters:addIntegerAlternative("Time", "The user's local time zone", "", 3);
    indicator.parameters:addIntegerAlternative("Time","The display time zone", "", 4);
    indicator.parameters:addIntegerAlternative("Time", "Server time zone", "", 5);
    indicator.parameters:addIntegerAlternative("Time", "Financial time ", "", 6); 
	
	indicator.parameters:addInteger("OpenHour", "Open hour", "", 0, 0, 23);
	
	
	indicator.parameters:addGroup("Label Style");
	indicator.parameters:addBoolean("ShowLabel", "Show Label", "", true);
	indicator.parameters:addColor("Label", "Color", "Color", core.COLOR_LABEL );
	indicator.parameters:addInteger("Size", "Size", "Size", 10 );
	
    indicator.parameters:addGroup("Open Line Style");
	

	
	indicator.parameters:addColor("color1", "Color", "Color", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	
	
	 indicator.parameters:addGroup("Top Line Style");
	 indicator.parameters:addColor("color2", "Color", "Color", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color3", "Color", "Color", core.rgb(255, 0, 0));
	 indicator.parameters:addGroup("Bottom Line Style");
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
 
end

local first;
local source = nil; 
local Open, Top,Bottom;
local Delta;
local OpenHour, Time;
local Last;
local dayoffset;
local weekoffset;
local SourceData, loading;
local font;
local Label,Size;
local id;
local ShowLabel;
 function ReleaseInstance()
       core.host:execute("deleteFont", font);

end	   
function Prepare(nameOnly)
   
    source = instance.source;
    Delta=instance.parameters.Delta;
	ShowLabel=instance.parameters.ShowLabel;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Delta .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;		
    end
	
	Size= instance.parameters.Size;
	font = core.host:execute("createFont", "Arial", Size, true, false);
  
	SourceData = core.host:execute("getSyncHistory", source:instrument(), "H1", source:isBid(), first, 100, 101);
	loading=true;
	
	  dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	
	
	OpenHour= instance.parameters.OpenHour;
	Time= instance.parameters.Time;
	Label= instance.parameters.Label;
	
	
    Open = instance:addStream("Open", core.Line, name .. ".Open", "Open", instance.parameters.color1, first);
    Open:setWidth(instance.parameters.width1);
    Open:setStyle(instance.parameters.style1);
	
	Top = instance:addStream("Top", core.Line, name .. ".Top", "Top", instance.parameters.color2, first);
    Top:setWidth(instance.parameters.width2);
    Top:setStyle(instance.parameters.style2);
	
	
	Bottom = instance:addStream("Bottom", core.Line, name .. ".Bottom", "Bottom", instance.parameters.color3, first);
    Bottom:setWidth(instance.parameters.width3);
    Bottom:setStyle(instance.parameters.style3);
	
	id=0;
end

function Update(period, mode)

   local p =  Initialization(period) 
	
   if  period<first
   or loading 
   or not p
   then
   return;
   end
   
   if period==first then 
   id=0;
   end

  
    local tickday,ticktimenum,ticktime; 
	ticktimenum = core.host:execute("convertTime", 1, Time, source:date(period));   -- EST->Display
    ticktime = core.dateToTable(ticktimenum);
    tickday = ticktime.day;
   
  local tickhour=core.dateToTable(source:date(period)).hour;
  local tickday=core.dateToTable(source:date(period)).day;
  
 
  if tickday~= Last 
  and  OpenHour<= tickhour 
  then
  Last=tickday;
  Open[period]=SourceData.open[p];
  Top[period]=Open[period]+Delta*source:pipSize();
  Bottom[period]=Open[period]-Delta*source:pipSize();
  
  
  if ShowLabel then
   id= id+1;
  core.host:execute("drawLabel1", id, source:date(period), core.CR_CHART, Open[period], core.CR_CHART , core.H_Right, core.V_Bottom,   font, Label,  Open[period]);
  
  id= id+1;
  core.host:execute("drawLabel1", id, source:date(period), core.CR_CHART, Top[period], core.CR_CHART , core.H_Right, core.V_Bottom,   font, Label, Top[period]);
  
  id= id+1;
  core.host:execute("drawLabel1", id, source:date(period), core.CR_CHART, Bottom[period], core.CR_CHART , core.H_Right, core.V_Bottom,   font, Label, Bottom[period]);
  end
  
  else
  Open[period]=Open[period-1];
  Top[period]=Top[period-1];
  Bottom[period]=Bottom[period-1];
  end
   
  

   

  if Open[period]~= Open[period-1] then
  Open:setBreak  (period,true);
  Top:setBreak  (period,true);
  Bottom:setBreak  (period,true);
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
    Candle = core.getcandle("H1", source:date(period), dayoffset, weekoffset);

  
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
