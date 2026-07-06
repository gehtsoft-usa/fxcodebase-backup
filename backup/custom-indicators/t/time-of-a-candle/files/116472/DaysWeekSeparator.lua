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
    indicator:name("Day of week separator");
    indicator:description("Day of week separator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("BeginTime", "Begin time of the day", "", "00:00");

    indicator.parameters:addGroup("Style"); 
    indicator.parameters:addColor("Color", "Line Color", "Line Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("Width", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("Style", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("Style", core.FLAG_LINE_STYLE);	
end

local first;
local source = nil;
local BeginT;

local Color;
local Width;
local Style;

function Prepare(nameOnly)  
    source = instance.source;
	Color=instance.parameters.Color;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
    
    local BeginTime=instance.parameters.BeginTime;
    Color = instance.parameters.Color;
    Width = instance.parameters.Width;
    Style = instance.parameters.Style;

    local Pos=string.find(BeginTime,":");
    local BeginH=tonumber(string.sub(BeginTime,1,Pos-1));
    local BeginM=tonumber(string.sub(BeginTime,Pos+1));
    BeginT=60*BeginH+BeginM;
	
	instance:setLabelColor(Color);
    instance:ownerDrawn(true);
end

function DayNumber(period)

    local D = source:date(period);
    local T = core.dateToTable(D);
    local wday = T.wday;
    local CandleTime = 60*T.hour + T.min;
    if CandleTime < BeginT then
        wday = wday-1;
        if wday < 1 then
            wday = 7;
        end
    end
    return wday;
end

function Update(period, mode)
end

function Draw(stage, context)

    if stage ~= 2 then
        return ;
    end
		
    local First, Last;	
    First = math.max(context:firstBar(), first);
    Last = math.min(context:lastBar(),source:size());
    local Max = mathex.max(source, First, Last)*2;
	
    local period;
    for period = First, Last, 1 do
       if (period > first) then
            local DN = DayNumber(period);
            local DN2 = DayNumber(period-1);
            if DN2 ~= DN then
                core.host:execute("drawLine", period, source:date(period), 0, source:date(period), Max, Color, Style, Width);   
            end
        end 
    end
end