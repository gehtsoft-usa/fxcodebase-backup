-- Id: 21381
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=66114


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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("High Low moving average band");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator); 

     indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Number of Periods", "", 20, 1, 10000);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");

  
	
    indicator.parameters:addGroup("Band Style");
    indicator.parameters:addColor("Up", "Up Line Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Down", "Down Line Color","", core.rgb(0, 0, 255));
	 
    indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
	
	
	indicator.parameters:addGroup("Line Style");
		indicator.parameters:addColor("UpUp", "Up Up Trend Color","", core.rgb(0,255, 0));
	indicator.parameters:addColor("DownUp", "Down Up Trend Line Color","", core.rgb(0, 100, 0));
	
	
	indicator.parameters:addColor("UpDown", "Up Down Trend Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("DownDown", "Down Down Trend Line Color","", core.rgb(255, 0, 0));
	
    indicator.parameters:addInteger("line_width", "Line Width", "", 5, 1, 5);
    indicator.parameters:addInteger("line_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("line_style", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Period;
 

local first;
local source = nil;
local Method; 

-- Streams block
local TL = nil;
local BL = nil;

local tl,bl; 


local UpUp, DownUp,UpDown,DownDown;
 
-- Routine
function Prepare(nameOnly)   
 
    Period = instance.parameters.Period;
	Method= instance.parameters.Method;
 
    source = instance.source;	
		
	first =source:first(period)+Period ;
	 
	


    local name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	UpUp= instance.parameters.UpUp;
	DownUp= instance.parameters.DownUp;
	UpDown= instance.parameters.UpDown;
	DownDown= instance.parameters.DownDown;
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	tl = core.indicators:create(Method, source.high, Period);
	bl = core.indicators:create(Method, source.low, Period);
	
	
    TL = instance:addStream("TL", core.Line, name .. ".TL", "TL", instance.parameters.Up, first)
    TL:setWidth(instance.parameters.width);
    TL:setStyle(instance.parameters.style);
    BL = instance:addStream("BL", core.Line, name .. ".BL", "BL", instance.parameters.Down, first)
    BL:setWidth(instance.parameters.width);
    BL:setStyle(instance.parameters.style);
    
end

-- Indicator calculation routine
function Update(period, mode)

	 
	    tl:update(mode);
		bl:update(mode);
		
		if period < first then
		return;
		end
		
		
        TL[period] = tl.DATA[period];
        BL[period] = bl.DATA[period];
		
  local Color;
  
  if (TL[period]>TL[period-1]) then
  
		   if (BL[period]>BL[period-1]) then
		   Color=UpUp;			
		   else
		   Color=DownUp;	
		   end
 
  else
  
		   if (BL[period]>BL[period-1]) then
		  Color=UpDown;			
		   else
		   Color=DownDown;	
		   end
  end
  
  
  core.host:execute ("drawLine", source:serial(period), source:date(period), TL[period], source:date(period), BL[period], Color, instance.parameters.line_style, instance.parameters.line_width);
		
end





