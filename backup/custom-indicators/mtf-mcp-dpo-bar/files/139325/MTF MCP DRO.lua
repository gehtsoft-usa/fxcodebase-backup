 -- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70687


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
    indicator:name("MTF MCP Detrended Range Oscillator (DPO)");
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
    indicator.parameters:addColor("color", "Color of Line", "", core.COLOR_UPCANDLE );
	
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	    indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("Level1", "1. Level","", 70);
	indicator.parameters:addDouble("Level2", "2. Level","", 30);
    indicator.parameters:addDouble("Level3", "3. Level","", 50);
	
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);		
 
end

local first;
local source = nil;
local MA;
local N;

local  Line=nil;
local Method;
 

local TF; 
local dayoffset;
local weekoffset;
local SourceData;
local loading = false;   
 
local  Instrument; 

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
	
	
	
	
    MA = core.indicators:create(Method, SourceData.close, N); 
    first = MA.DATA:first();
     
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first);
	
	Line:setPrecision(math.max(2, instance.source:getPrecision()));	
	
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
	
    Line:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    Line:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    Line:addLevel(instance.parameters.Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
 
end

function Update(period, mode)

    MA:update(mode); 
	
	
	 local p =  Initialization(period) 
     
	    if not p then
		return;
		end
	
    if (p <N) then
	return;
	end
 
	  
	
    local min,max=0,0;
    local Array ={};
	
	for i=1, N, 1 do
	Array[i]=  (SourceData.open[p-i+1] - MA.DATA[p-i+1]) ;
    end
	
	
	
	
	for i=1, N, 1 do
		if i== 1 then 
		min = Array[i];
		end
		
		if  Array[i]> max then
		max=Array[i];
		end
		
		if  Array[i]< min then
		min=Array[i];
		end
	end
	
	Line[period]= (Array[1]-min)/((max-min)/100)
    
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

