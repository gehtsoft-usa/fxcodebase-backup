
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1838

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
    indicator:name("Inside/outside bar Indicator");
    indicator:description("Inside/outside bar Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    
   indicator.parameters:addColor("Up", "Up Trend Color", "", core.COLOR_UPCANDLE );
	indicator.parameters:addColor("Down", "Down Trend Color", "", core.COLOR_DOWNCANDLE );
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
end

local first;
local source = nil;
local Up, Down,Size;
local font;
function Prepare(nameOnly)   
    source = instance.source;
    Percent=instance.parameters.Percent;
    MaxPeriod=instance.parameters.MaxPeriod;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Size=instance.parameters.Size;
	font = core.host:execute("createFont", "Wingdings", Size, false, false);
end

function Update(period, mode)
 
   core.host:execute ("removeLabel", source:serial(period)); 

 if (period<first) then
  return;
  end
 
 
    
	
	if source.high[period]>source.high[period-1] and source.low[period]<source.low[period-1]  then
 
 core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, source.low[period], core.CR_CHART, core.H_Center, core.V_Bottom, font,Up, "\108");
end

if source.high[period]<source.high[period-1] and source.low[period]>source.low[period-1] then
 core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center, core.V_Top, font,Down, "\108");
 
end

if source.high[period]<source.high[period-1] and source.low[period]<source.low[period-1] then
 
    if source.close[period-1]>source.open[period-1] then
    core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, source.low[period], core.CR_CHART, core.H_Center, core.V_Bottom, font,Up, "\108");
	else  
	core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center, core.V_Top, font,Down, "\108");
	end
	
end

if source.high[period]>source.high[period-1] and source.low[period]>source.low[period-1] then
	 if source.close[period]>source.open[period] then
    core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, source.low[period], core.CR_CHART, core.H_Center, core.V_Bottom, font,Up, "\108");
	else  
	core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center, core.V_Top, font,Down, "\108");
	end
end

end

