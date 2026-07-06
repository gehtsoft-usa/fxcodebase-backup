-- Id: 12676
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2068


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
    indicator:name("TrendLord with Higher Time Frame Confirmation");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Price1", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "WEIGHTED", "", "weighted");	
	
    indicator.parameters:addInteger("Period", "Period", "Period", 50);
    indicator.parameters:addString("Method1", "MA Method", "Method" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	 indicator.parameters:addGroup("Confirmation Filter  Calculation");
	  indicator.parameters:addBoolean("UseFilter", "Use MA Filter", "", true);
	 TF={"Chart","m1", "m5", "m15", "m30", "H1" , "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"};
	  indicator.parameters:addString("BS", "Filter MA Time Frame", "", "D1");
	for i= 1, 14, 1 do
	indicator.parameters:addStringAlternative("BS", TF[i], TF[i] , TF[i]);
    end  
 	
	  
     indicator.parameters:addString("Price2", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price2", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price2", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price2", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price2","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price2", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price2", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price2", "WEIGHTED", "", "weighted");	
	
	indicator.parameters:addInteger("FilterPeriod", "Period", "Period", 50);
	indicator.parameters:addString("Method2", "MA Method", "Method" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	 

    indicator.parameters:addGroup("Style");
	indicator.parameters:addString("Type", "Line/Bar", "", "BAR");
    indicator.parameters:addStringAlternative("Type", "Bar", "", "BAR");
    indicator.parameters:addStringAlternative("Type", "Line", "", "LINE");		
    indicator.parameters:addColor("clrUP", "Up color", "Up color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrDN", "Down color", "Down color", core.rgb(255, 0, 0));
	indicator.parameters:addColor("clrNE", "Neutral color", "Neutral color", core.rgb(0, 0, 255));
	
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
end

local first;
local source = nil;
local Period;
local MA1, MA2;
local TrendLord=nil;
local FilterPeriod;
local Type;
local UseFilter;
local SourceData;
local loading;
local host;
local offset;
local weekoffset;
local Method1, Method2;
local Filter1, Filter2;
local Price1, Price2;
function Prepare(nameOnly)
    Type=instance.parameters.Type;
	UseFilter=instance.parameters.UseFilter;
	FilterPeriod=instance.parameters.FilterPeriod;
	Method1=instance.parameters.Method1;
	Method2=instance.parameters.Method2;
	Price1=instance.parameters.Price1;
	Price2=instance.parameters.Price2;
    source = instance.source;
    Period=instance.parameters.Period;
    BS = instance.parameters.BS;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period.. ", " .. instance.parameters.Method1 .. ", " .. instance.parameters.FilterPeriod .. ", " .. instance.parameters.Method2 .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	
	s, e = core.getcandle(source:barSize(), 0, 0, 0);
    s1, e1 = core.getcandle(BS, 0, 0, 0);
    assert ((e - s) <= (e1 - s1), "The chosen Filter time frame must be equal to or bigger than the chart time frame!");
	
	
	host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");

    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
    MA1 = core.indicators:create(Method1, source[Price1], Period);
    MA2 = core.indicators:create(Method1, MA1.DATA, math.sqrt(Period));
	first = math.max(MA1.DATA:first() , MA2.DATA:first() );
   
   if UseFilter then
   SourceData = core.host:execute("getSyncHistory", source:instrument(), BS, source:isBid(), first, 100, 101);
   loading=true;   
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
   Filter1 = core.indicators:create(Method2, SourceData[Price2], FilterPeriod);
   Filter2 = core.indicators:create(Method2, Filter1.DATA,  math.sqrt(FilterPeriod));
   end
   
    if Type == "BAR" then
    TrendLord = instance:addStream("TrendLord", core.Bar, name .. ".TrendLord", "TrendLord", instance.parameters.clrUP, first);   
    TrendLord:setPrecision(math.max(2, instance.source:getPrecision()));
    TrendLord:setPrecision(math.max(2, instance.source:getPrecision()));
	else
	TrendLord = instance:addStream("TrendLord", core.Line, name .. ".TrendLord", "TrendLord", instance.parameters.clrUP, first);  
	TrendLord:setWidth(instance.parameters.width);
    TrendLord:setStyle(instance.parameters.style);
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
    Candle = core.getcandle(BS, source:date(period), offset, weekoffset);

  
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


function Update(period, mode)
    MA1:update(mode);
    MA2:update(mode);

    if period < first then
	return;
	end
	
	
	if UseFilter then
	
	    Filter1:update(mode);
		Filter2:update(mode);
		
        local p =  Initialization(period) 
     
	    if not p then
		return;
		end
         if   Filter2.DATA[p] >   Filter2.DATA[p-1]  then
		 Flag= 1;
		 elseif   Filter2.DATA[p] <   Filter2.DATA[p-1]  then
		 Flag= -1;
		 else
		 Flag=0;
		 end
    end 
		
        TrendLord[period] = MA2.DATA[period];
		 
        if MA2.DATA[period] > MA2.DATA[period-1] 
		and ( Flag == 1  or not UseFilter )
		then
        TrendLord:setColor(period, instance.parameters.clrUP);
        elseif MA2.DATA[period] < MA2.DATA[period-1] 
		and ( Flag == -1  or not UseFilter )
		then       
        TrendLord:setColor(period, instance.parameters.clrDN);
		else
		TrendLord:setColor(period, instance.parameters.clrNE);
        end
      
end

