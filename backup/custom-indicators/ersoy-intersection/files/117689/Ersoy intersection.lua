-- Id: 20537
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65718

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

-- Indicator profile initialization routine

function Init()
    indicator:name("Ersoy intersection");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	
 
	
	 indicator.parameters:addGroup("Calculation");
	 
	indicator.parameters:addInteger("Period1", "1.MA Period", "Period" , 1);
	
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("Period2", "2.MA Period", "Period" , 21);
 
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	
    indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
 
	
	indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
	
	 indicator.parameters:addInteger("transp", "Transparency","", 80, 0, 100);
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255,0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0,0));
	indicator.parameters:addColor("Label", "Label Color", "", core.COLOR_LABEL );
	 indicator.parameters:addInteger("Size", "Font Size","", 10);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Period1,Period2,Method1,Method2; 
local MA1,MA2;
local first;
local source = nil;
local Line1,Line2;
local Top,Bottom,Label;
local Up,Down;
local Size;
local font;
-- Routine
 function Prepare(nameOnly)  


    
	 Up= instance.parameters.Up;
	 Down= instance.parameters.Down;
	 Period1= instance.parameters.Period1;
	 Period2= instance.parameters.Period2;
	 Method1= instance.parameters.Method1;
	 Method2= instance.parameters.Method2;
	 Label= instance.parameters.Label;
	 Size= instance.parameters.Size;
 
    local name = profile:id() .. "(" ..  instance.source:name()    .. ", " ..  Period1 .. ", " ..  Method1 .. ", " ..  Period2 .. ", " ..  Method2.. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 
	
   font = core.host:execute("createFont", "Wingdings", Size, false, false);
			
    source = instance.source;
	
	 Top= instance:addInternalStream(0, 0);
	 Bottom = instance:addInternalStream(0, 0);
	 
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
	MA1= core.indicators:create(Method1,source,Period1);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
	MA2= core.indicators:create(Method2,source,Period2);
	first = math.max(MA1.DATA:first() ,MA2.DATA:first());
    
   
 
	 
    Line1 = instance:addStream("Line1" , core.Line, " 1. Line"," 1. Line",instance.parameters.color1, first);
    Line1:setPrecision(math.max(2, instance.source:getPrecision()));
	Line1:setWidth(instance.parameters.width1);
    Line1:setStyle(instance.parameters.style1);
	Line2 = instance:addStream("Line2" , core.Line, " 2. Line"," 2. Line",instance.parameters.color2, first);
    Line2:setPrecision(math.max(2, instance.source:getPrecision()));
	Line2:setWidth(instance.parameters.width2);
    Line2:setStyle(instance.parameters.style2);
	
	instance:createChannelGroup("Channel", "Channel", Top, Bottom, Up, 100 - instance.parameters.transp);

	
end

-- Indicator calculation routine
function Update(period, mode)

  
 
   MA1:update(mode);
   MA2:update(mode);
   if period < first then
   return;
   end
 
    Line1[period]= MA1.DATA[period];
    Line2[period]= MA2.DATA[period];
	
	Top[period]= MA1.DATA[period];
    Bottom[period]= MA2.DATA[period];
	
	  if Line1[period]>Line2[period] then
	  Top:setColor(period, Up);
	  else
	  Top:setColor(period, Down);
	  end		  
	  
	  if Line1[period]> Line2[period]
	  and  Line1[period-1]<= Line2[period-1]
	  then
	  core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, Line2[period], core.CR_CHART, core.H_Center, core.V_Top, font, Label, "\88");							 
	  elseif Line1[period]< Line2[period]
	  and  Line1[period-1]>= Line2[period-1]
	  then
	  core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, Line2[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, Label, "\88");
	  end
	  
	  
end
function ReleaseInstance()
       core.host:execute("deleteFont", font);
end
