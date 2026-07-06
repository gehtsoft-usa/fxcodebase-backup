--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

function Init()
    indicator:name("T3TrendBands indicator");
    indicator:description("T3TrendBands indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("BandBars", "Count of bars for band", "", 28);
    indicator.parameters:addDouble("Deviation", "Deviation", "", 3.5);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP", "Up Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DN", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("NE", "Neutral Color", "", core.rgb(128, 128, 128));
	
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local BandBars;
local Deviation;
local SmoothPrice;
local SmoothRange;
local Top=nil;
local Middle=nil;
local Bottom=nil;
local UP, DN,NE;

function Prepare()
    UP=instance.parameters.UP;
	DN=instance.parameters.DN;
	NE=instance.parameters.NE;
    source = instance.source;
    BandBars=instance.parameters.BandBars;
    Deviation=instance.parameters.Deviation;
    first = source:first()+1;
    SmoothPrice = instance:addInternalStream(first, 0);
    SmoothRange = instance:addInternalStream(first, 0);
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.BandBars .. ", " .. instance.parameters.Deviation .. ")";
    instance:name(name);
    Top = instance:addStream("TOP", core.Line, name .. ".Top", "Top",  NE,  first);
	Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style);
    Middle = instance:addStream("MID", core.Line, name .. ".Middle", "Middle",  NE, first);
	Middle:setWidth(instance.parameters.width);
    Middle:setStyle(instance.parameters.style);
    Bottom = instance:addStream("BOTTOM", core.Line, name .. ".Bottom", "Bottom",  NE, first);
	Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style);

end

function Update(period, mode)
   if period==first then
    SmoothPrice[period]=source.close[period];
    SmoothRange[period]=source.high[period]-source.low[period];
   elseif period>first then
    SmoothPrice[period]=(SmoothPrice[period-1]*(BandBars-1)+source.close[period])/BandBars;
    SmoothRange[period]=(SmoothRange[period-1]*(BandBars-1)+source.high[period]-source.low[period])/BandBars;
  
     Top[period]=SmoothPrice[period]+SmoothRange[period]*Deviation;
     Middle[period]=SmoothPrice[period];
     Bottom[period]=SmoothPrice[period]-SmoothRange[period]*Deviation;
	 
	 if Top[period] > Top[period-1] then
	 Top:setColor(period, UP);
	 elseif Top[period] < Top[period-1] then
	 Top:setColor(period, UP);
	 else 
	 Top:setColor(period, NE);
	 end
	 
	 if Middle[period] > Middle[period-1] then
	 Middle:setColor(period, UP);
	 elseif Middle[period] < Middle[period-1] then
	 Middle:setColor(period, UP);
	 else 
	 Middle:setColor(period, NE);
	 end
	 
	 if  Bottom[period] >  Bottom[period-1] then
	  Bottom:setColor(period, UP);
	 elseif  Bottom[period] <  Bottom[period-1] then
	  Bottom:setColor(period, UP);
	 else 
	  Bottom:setColor(period, NE);
	 end
   
    end
  end


