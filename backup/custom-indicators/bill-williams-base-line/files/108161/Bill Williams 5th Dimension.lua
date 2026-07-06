
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63877

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


-- initializes the indicator
function Init()
    indicator:name("Bill Williams 5th Dimension");
    indicator:description("")
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Zone Calculation");
    indicator.parameters:addInteger("FM", "AC/AO fast moving average", "", 5);
    indicator.parameters:addInteger("SM", "AC/AO slow moving average", "", 35);
    indicator.parameters:addInteger("AM", "A/C moving average", "", 5);	
	
	
	 indicator.parameters:addGroup("Jaw Calculation");
    indicator.parameters:addInteger("JawN","Alligator Jaw smoothing periods", "", 13, 1, 300);
    indicator.parameters:addInteger("JawS", "Alligator Jaw shift periods", "", 8, 0, 300);
	indicator.parameters:addString("MTH", "Smoothing method","", "SMMA");
    indicator.parameters:addStringAlternative("MTH", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MTH", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MTH", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MTH", "REGRESSION", "", "REGRESSION");
    indicator.parameters:addStringAlternative("MTH", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("MTH", "VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative("MTH", "VIDYA92", "", "VIDYA92");
    indicator.parameters:addStringAlternative("MTH", "WMA", "", "WMA");

	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Buy", "Color of Buy ", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Sell", "Color of Sell ", "", core.rgb(255, 0, 0));	
	indicator.parameters:addColor("Label", "Color of Label ", "", core.COLOR_LABEL );
	
	indicator.parameters:addColor("Up", "Up Trend Color","Up Trend Color", core.rgb(0,255,0));
	indicator.parameters:addColor("Down", "Down Trend Color","Down Trend Color", core.rgb(255,0,0));
	indicator.parameters:addColor("Neutral", "Neutral Trend Color","Neutral Trend Color", core.rgb(128,128,128));
	
	indicator.parameters:addInteger("Size", "Font Size","", 15);
	
	indicator.parameters:addGroup("Line");
	indicator.parameters:addColor("color", "Line Color","", core.rgb(0,0,255));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("Jaw Line Style");

    indicator.parameters:addColor("JawC", "Line Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("JawW", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("JawSt", "Line style","", core.LINE_SOLID);
    indicator.parameters:setFlag("JawSt", core.FLAG_LEVEL_STYLE);
	
    

end


local Buy, Sell,Label;
local JawN, JawS, jaw, MTH;
-- indicator source
local source;
local first;
local font;
local Size;
local open, high, low, close;
local FM, SM, AM;
local Up, Down,Neutral;
local color, style, width;
local Jaw;
-- process parameters and prepare for calculations
function Prepare(nameOnly) 
    
	MTH=instance.parameters.MTH;
	JawN=instance.parameters.JawN;
	JawS=instance.parameters.JawS;
	
 
	assert(core.indicators:findIndicator(MTH) ~= nil, "Please, download and install "..  MTH .. " indicator");
    source  = instance.source;
	Size= instance.parameters.Size;
	font = core.host:execute("createFont", "Courier", Size, true, false);
	Buy=instance.parameters.Buy;
    Sell=instance.parameters.Sell;
	Label=instance.parameters.Label;
	
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	Neutral = instance.parameters.Neutral;

   color = instance.parameters.color;
   style = instance.parameters.style;
   width = instance.parameters.width;
	
	FM = instance.parameters.FM;
    SM = instance.parameters.SM;
    AM = instance.parameters.AM;
	
    first=source:first();    

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	
	AC = core.indicators:create("AC", source, FM, SM, AM);
    AO = core.indicators:create("AO", source, FM, SM);
    zonefirst = math.max( AC.DATA:first(), AO.DATA:first());	
	
	jaw = core.indicators:create(MTH,   source.median, JawN);

    Jaw = instance:addStream("Jaw", core.Line, name .. ".Jaw", "Jaw", instance.parameters.JawC, jaw.DATA:first(), JawS);
    Jaw:setWidth(instance.parameters.JawW);
    Jaw:setStyle(instance.parameters.JawSt);

	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), zonefirst)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), zonefirst)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), zonefirst)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), zonefirst)
    instance:createCandleGroup("ZONE", "", open, high, low, close);
end

function ReleaseInstance()
       core.host:execute("deleteFont", font);
end
	   
-- Indicator calculation routine
function Update(period, mode)
   
    AC:update(mode);
    AO:update(mode);
	jaw:update(mode);
	
	
	 if (period + JawS >= 0 and period >= jaw.DATA:first()) then
        Jaw[period + JawS] = jaw.DATA[period];
    end
	
   if period > zonefirst then	
	high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];

               if  AO.DATA[period] > AO.DATA[period - 1]  and AC.DATA[period] > AC.DATA[period - 1] then 
				open:setColor(period, Up);
				elseif AO.DATA[period] < AO.DATA[period - 1]  and  AC.DATA[period] < AC.DATA[period - 1] then
				open:setColor(period, Down);	
				else
				open:setColor(period, Neutral);
				end	
   end

   if period < source:size()-1 then
   return;
   end
  
   local Index1, Index2=Find(period);
   
   if Index1== nil 
   or Index2 == nil 
   then
   return;
   end
   
   core.host:execute ("drawLine", 1, source:date(Index1-1-3), source.high[Index1-1]+source:pipSize(), source:date(Index1-1), source.high[Index1-1]+source:pipSize(), color, style, width,source.high[Index1-1]+source:pipSize());
   core.host:execute ("drawLine", 2, source:date(Index2-1-3), source.low[Index2-1]-source:pipSize(), source:date(Index2-1), source.low[Index2-1]-source:pipSize(), color, style, width,source.low[Index2-1]-source:pipSize());
   
   local id1=10;
   local id2=20;
   
   
   local Count1=0;
   local Count2=0;
   
   for p1= Index1, math.max(Index1-4, first), -1 do
    id1 = id1 + 1;
	if p1==Index1 then 
    core.host:execute("drawLabel1", id1, source:date(p1), core.CR_CHART,  source.high[p1], core.CR_CHART, core.H_Center, core.V_Top,  font, Buy, "B");
	else
	Count1=Count1+1;
	core.host:execute("drawLabel1", id1,  source:date(p1), core.CR_CHART,  source.high[p1], core.CR_CHART, core.H_Center, core.V_Top,  font, Label, win32.formatNumber(Count1, false, 0));
	end
   end
   

   for p2= Index2, math.max(Index2-4, first), -1 do
      id2 = id2 + 1;
	 if p2==Index2 then  
     core.host:execute("drawLabel1", id2 ,  source:date(p2), core.CR_CHART, source.low[p2], core.CR_CHART, core.H_Center, core.V_Bottom, font, Sell, "S"); 
	 else
	 Count2=Count2+1;
	 core.host:execute("drawLabel1", id2 ,  source:date(p2), core.CR_CHART, source.low[p2], core.CR_CHART, core.H_Center, core.V_Bottom, font, Label, win32.formatNumber(Count2, false, 0)); 
	 end
   end
   

   
end


function Find (period)

local High=nil;
local Low=nil;

 for period=period, first, -1 do 
     
	 if High == nil and  source.high[period]< source.high[period-1]  then
	 High= period;
	 end
	 
	 if Low == nil and  source.low[period]> source.low[period-1]  then
	 Low= period;
	 end
  
	 if High~= nil and Low ~= nil then
	 break;
	 end 
 end
 
    return High, Low;
 
end
