-- Id: 10649
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60057

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("MA Cross Pivots");
    indicator:description("MA Pivots");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("ShortPeriod", "Short MA Period", "Short MA Period", 14);
	indicator.parameters:addString("ShortMethod", "Short MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("ShortMethod", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("ShortMethod", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("ShortMethod", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("ShortMethod", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("ShortMethod", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("ShortMethod", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("ShortMethod", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("ShortMethod", "WMA", "WMA" , "WMA");
	
    indicator.parameters:addInteger("LongPeriod", "Long MA Period", "Long MA Period", 28);
	
	indicator.parameters:addString("LongMethod", "Short MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("LongMethod", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("LongMethod", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("LongMethod", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("LongMethod", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("LongMethod", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("LongMethod", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("LongMethod", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("LongMethod", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addGroup("Pivot Calculation ");
	indicator.parameters:addString("Method", "Pivot Method", " " , "Number of Crosses Observed");
    indicator.parameters:addStringAlternative("Method", "Number of Crosses Observed", "Number of Crosses Observed" , "Number of Crosses Observed");
    indicator.parameters:addStringAlternative("Method", "On Chart Crosses", "On Chart Crosses" , "On Chart Crosses");
	
	
	indicator.parameters:addString("Side", "Cross Type", " " , "Both");
    indicator.parameters:addStringAlternative("Side", "Both", "" , "Both");
    indicator.parameters:addStringAlternative("Side", "CrossOver", "" , "CrossOver");
	indicator.parameters:addStringAlternative("Side", "CrossUnder", "" , "CrossUnder");
	
    indicator.parameters:addInteger("LookBackPeriod", "Number of Crosses Observed", "", 1, 0 , 1000);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addBoolean("Show", "Show MA`s", "", true);
    indicator.parameters:addColor("Short_color", "Color of Short", "Color of Short", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Long_color", "Color of Long", "Color of Long", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("Pivot Style");
	indicator.parameters:addBoolean("Pivot", "Show Pivot`s", "", true);
	  indicator.parameters:addColor("Up", "Cross Over Pivot Color", "", core.rgb(0, 255, 0));
	  indicator.parameters:addColor("Down", "Cross Under Pivot Color", "", core.rgb(255, 0, 0));
	  indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local ShortPeriod;
local LongPeriod;
local LookBackPeriod;
local LongMethod, ShortMethod;
local first;
local source = nil;
local short, long;
-- Streams block
local Short = nil;
local Long = nil;
local Show;
local Up, Down;
local Pivot;
local Side;
local Method;
-- Routine
function Prepare(nameOnly)
    Side= instance.parameters.Side;
    Show = instance.parameters.Show;
	Pivot = instance.parameters.Pivot;
    ShortPeriod = instance.parameters.ShortPeriod;
    LongPeriod = instance.parameters.LongPeriod;
    LookBackPeriod = instance.parameters.LookBackPeriod;
	LongMethod = instance.parameters.LongMethod;
	ShortMethod = instance.parameters.ShortMethod;
	Method = instance.parameters.Method;
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
    source = instance.source;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(ShortPeriod) .. ", " .. tostring(ShortMethod).. ", " .. tostring(LongPeriod) .. ", " .. tostring(LongMethod) .. ", " .. tostring(LookBackPeriod) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
    assert(core.indicators:findIndicator(ShortMethod) ~= nil, ShortMethod .. " indicator must be installed");
		short = core.indicators:create(ShortMethod, source,ShortPeriod );
    assert(core.indicators:findIndicator(LongMethod) ~= nil, LongMethod .. " indicator must be installed");
		long = core.indicators:create(LongMethod, source, LongPeriod);
		first = math.max(short.DATA:first(), long.DATA:first());
	    if Show then
        Short = instance:addStream("Short", core.Line, name .. ".Short", "Short", instance.parameters.Short_color, first);
        Long = instance:addStream("Long", core.Line, name .. ".Long", "Long", instance.parameters.Long_color, first);
		
		Short:setWidth(instance.parameters.width1);
        Short:setStyle(instance.parameters.style1);
		Long:setWidth(instance.parameters.width2);
        Long:setStyle(instance.parameters.style2);
		
		else
		Short= instance:addInternalStream(0, 0);
		Long= instance:addInternalStream(0, 0);
		end
		
    end
	
	
	if not Pivot then 
    instance:ownerDrawn(false);
    else
	 instance:ownerDrawn(true);
	end
	
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not  source:hasData(period) then
	return;
	end
	
	short:update(mode);
	long:update(mode);
        Short[period] = short.DATA[period];
        Long[period]  = long.DATA[period];
		
	
	

    
end

local init = false;

function Draw(stage, context)
    if stage~= 2 then
    return;
	end
	
        if not init then
            context:createPen (1,  instance.parameters.style,  instance.parameters.width, Up)
			context:createPen (2,  instance.parameters.style,  instance.parameters.width, Down)
            init = true;
        end


    local top=context:top ();
	local bottom=context:bottom ();
	local left=context:left ();
	local right=context:right ();
	local x1, x2, x3 ;
	
	local i, Color;
	local Count=0;
	local visible, y;
	local FIRST;
	
	
    if Method == "On Chart Crosses" then
	FIRST= math.max(source:first(), context:firstBar ());
	else
	FIRST=source:first()+1;
	end
	
    for i= source:size()-1, FIRST, -1 do	
	
		 
		 if core.crosses (short.DATA, long.DATA, i) then
		 
		--  x, y math2d.lineIntersection (l1x1, l1y1, l1x2, l1y2, l2x1, l2y1, l2x2, l2y2)
		 
		     x1, x2, x3 = context:positionOfBar (i);
			 visible, y = context:pointOfPrice (short.DATA[i])
		 
			 if core.crossesOver (short.DATA, long.DATA, i)  and Side ~= "CrossUnder" then
			 context:drawLine (1, x1, top, x1, bottom);
			 context:drawLine (1, left, y, right ,y )
			 end
			 
			 if core.crossesUnder (short.DATA, long.DATA, i)  and Side ~= "CrossOver" then
			 context:drawLine (2, x1, top, x1, bottom);
			 context:drawLine (2, left, y, right , y)
			 end
			 
			Count=Count+1;	 
			
		 end
		 
		  
		 
		 if Count>= LookBackPeriod  and   Method ~= "On Chart Crosses"  then
		 break;
		 end
	 end
 
end	 