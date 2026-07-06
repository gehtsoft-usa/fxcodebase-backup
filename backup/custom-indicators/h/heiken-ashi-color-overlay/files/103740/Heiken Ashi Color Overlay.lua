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
function Prepare(nameOnly)
    
	source = instance.source;    
	
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
	Overlay=instance.parameters.Overlay;
	Confirmation=instance.parameters.Confirmation;
	Size=instance.parameters.Size;
	
	  local name =  profile:id()  ;
	  instance:name(name);
	  
	if   (nameOnly) then
        return;
    end
	  
	HA = core.indicators:create("HA", source);
	first=HA.DATA:first();
	
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
 
	 if period < HA.DATA:first() then
	 return;
	 end
	 
	 
		
	if Confirmation then
	
	     core.host:execute ("removeLabel", source:serial(period));  
		 
		 if  HA.close[period]>HA.open[period] 
		 and source.close[period]> source.open[period] 
		 then
		 core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, source.low[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, Up, "\225");
		elseif  HA.close[period]<HA.open[period] 
		and  source.close[period]<source.open[period] 
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
	

