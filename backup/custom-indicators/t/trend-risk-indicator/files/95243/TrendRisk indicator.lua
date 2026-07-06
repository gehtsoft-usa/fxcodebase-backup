-- Id: 12253
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61007

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
    indicator:name("Trend Risk Indicator");
    indicator:description("Trend Risk Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	 indicator.parameters:addGroup("Trend Risk Indicator Calculation");
	 indicator.parameters:addInteger("Period", "Periods for Switch", "", 3);

    indicator.parameters:addGroup("T3 Trend Bands Calculation");
    indicator.parameters:addInteger("BandBars", "Count of bars for band", "", 28);
    indicator.parameters:addDouble("Deviation", "Deviation", "", 3.5);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128));
	
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
local Bottom=nil;
 
local Color;
local open=nil;
local close=nil;
local high=nil;
local low=nil;
local Up, Down,Neutral;
local Period;
function Prepare(nameOnly)
    Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
	Period=instance.parameters.Period;
    source = instance.source;
    BandBars=instance.parameters.BandBars;
    Deviation=instance.parameters.Deviation;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name()  .. ", " .. Period .. ", " .. instance.parameters.BandBars .. ", " .. instance.parameters.Deviation .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
    SmoothPrice = instance:addInternalStream(first, 0);
    SmoothRange = instance:addInternalStream(first, 0);
    Top = instance:addStream("TOP", core.Line, name .. ".Top", "Top",  Up,  first);
	Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style);
    
    Bottom = instance:addStream("BOTTOM", core.Line, name .. ".Bottom", "Bottom",  Down, first);
	Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style);
	
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("ZONE", "", open, high, low, close);
	
	
	Color = instance:addInternalStream(0, 0);

end

function Update(period, mode)

    high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];	
	
	
	
    if period==first then
    SmoothPrice[period]=source.close[period];
    SmoothRange[period]=source.high[period]-source.low[period];
    elseif period>first then
    SmoothPrice[period]=(SmoothPrice[period-1]*(BandBars-1)+source.close[period])/BandBars;
    SmoothRange[period]=(SmoothRange[period-1]*(BandBars-1)+source.high[period]-source.low[period])/BandBars;
  
    Top[period]=SmoothPrice[period]+SmoothRange[period]*Deviation;
    Bottom[period]=SmoothPrice[period]-SmoothRange[period]*Deviation;
    end
	
	
	if period < Period then
	open:setColor(period, Neutral);			
	return;
	end
	
	
	 Color[period] = Color[period-1];
      Check(period);
	  
	
	            if Color[period] == 1 then 
				open:setColor(period, Up);
				elseif Color[period] == -1  then
				open:setColor(period, Down);	
				else 
				open:setColor(period, Neutral);				 
				end
				
	
 
	
  end

  
function Check(period)

   
    local i;
	local T=1;
	local D=1;
	local N=1;
	
	for i= period, period-Period+1, -1 do
	
	    if source.close[i]< Top[i] then
		T=0;
		end
		
		if source.close[i]> Bottom[i] then
		D=0;
		end
		
		if source.close[i]<  Bottom[i] or  source.close[i]> Top[i] then
		N=0;
		end
	
	    if T== 0 and D== 0 and N== 0 then
		return;
		end
	
	end
	
    
    if T== 1 then 
    Color[period]= 1;
	elseif D== 1 then 
	Color[period]=-1;
	elseif N== 1 then 
	Color[period] =0; 
     end
end

