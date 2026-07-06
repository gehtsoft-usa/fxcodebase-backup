-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=62969


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
	
	indicator.parameters:addGroup("CCI Calculation");
	indicator.parameters:addInteger("Period", "Period", "Period", 14);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Heiken Ashi Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Heiken Ashi Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	
 
	
 
	
end

local source;
local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;
local first;
local HA; 
local Up,Down,Neutral; 
local Period; 
local CCI;
function Prepare(nameOnly)
    
	source = instance.source;    
	
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
	Period=instance.parameters.Period;
 
	
	  local name =  profile:id()  ;
	  instance:name(name);
	  
	if   (nameOnly) then
        return;
    end
	
	CCI = core.indicators:create("CCI", source, Period);  
	HA = core.indicators:create("HA", source);
	first=math.max(HA.DATA:first(), CCI.DATA:first())+1;
	
	 
	
	 
    open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
 
	
end

function Update(period, mode)
   
     HA:update(mode); 
	 CCI:update(mode); 
 
	 if period < first
	 then
	 return;
	 end
	  
    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];

	
	if  HA.close[period]>HA.open[period]
	and CCI.DATA[period]> 0 
	then
	open:setColor(period,Up);
	elseif  HA.close[period]<HA.open[period] 
	and CCI.DATA[period]< 0
    then	
	open:setColor(period, Down);
	else
	open:setColor(period, Neutral);
	end
end
	

