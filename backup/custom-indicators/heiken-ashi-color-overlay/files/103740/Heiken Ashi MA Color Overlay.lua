-- Id: 15178
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62944


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
    indicator:name("Heiken Ashi Color Overlay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
		
  

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Heiken Ashi Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Heiken Ashi Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	
	
	indicator.parameters:addBoolean("Overlay", "Show Overlay", "Show Overlay", true);
	indicator.parameters:addBoolean("Confirmation", "Show Confirmation", "Show Confirmation", true);
	
	indicator.parameters:addGroup("Confirmation Calculation");
	indicator.parameters:addBoolean("Shift", "Use Shift", "Use Shift", true);
		
	indicator.parameters:addInteger("Period", "MA Period", "", 7);	
	indicator.parameters:addString("Method", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
   indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
end

local source;
local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;
local first;
local HA; 
local Up,Down,Neutral;
local Overlay;
local Confirmation;
local Size;
local MA;
local Method;
local Period;
local Shift;
function Prepare(nameOnly)
    
	source = instance.source;    
	
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
	Method=instance.parameters.Method;
	Period=instance.parameters.Period;
	Shift=instance.parameters.Shift
 
	Overlay=instance.parameters.Overlay;
	Confirmation=instance.parameters.Confirmation;
	Size=instance.parameters.Size;
	
	  local name =  profile:id()  ;
	  instance:name(name);
	if   (nameOnly) then
        return;
    end
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	MA = core.indicators:create(Method, source.close, Period);  
	HA = core.indicators:create("HA", source);
	first=math.max(HA.DATA:first(), MA.DATA:first())+1;
	
	if Confirmation then
	font = core.host:execute("createFont", "Wingdings", Size, false, false);
	end
	
	if Overlay then 
    open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
	end
	
end

function Update(period, mode)
   
     HA:update(mode); 
	 MA:update(mode); 
 
	 if period < first
	 then
	 return;
	 end
	 
	 
		
	if Confirmation then
	
	     if Shift then
	     p=period-1;
		 else
		 p=period;
		 end
		 
	     core.host:execute ("removeLabel", source:serial(period));  
		 
		 if  HA.close[period]>HA.open[period] 
		 and source.close[p]> MA.DATA[p] 
		 then
		 core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, source.low[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, Up, "\225");
		elseif  HA.close[period]<HA.open[period] 
		and  source.close[p]< MA.DATA[p] 
		then
		 core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center, core.V_Top, font, Down, "\226");	
		end
	 
	end 
    
	if not Overlay then
	return;
	end
	
    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];

	
	if  HA.close[period]>HA.open[period] then
	open:setColor(period,Up);
	elseif  HA.close[period]<HA.open[period] then
	open:setColor(period, Down);
	else
	open:setColor(period, Neutral);
	end
end
	

