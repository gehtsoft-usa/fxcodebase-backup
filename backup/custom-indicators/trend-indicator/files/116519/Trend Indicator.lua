
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65461&p=116519#p116519

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
    indicator:name("Trend Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
 
 

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("SlowLength", "Slow Length","", 7);	
	indicator.parameters:addInteger("SlowPipDisplace", "Slow Pip Displace","", 0);
	
	 indicator.parameters:addInteger("FastLength", "Fast Length","", 3);	
	indicator.parameters:addInteger("FastPipDisplace", "Slow Pip Displace","", 0);
	
	indicator.parameters:addBoolean("ShowCandles", "Show Candles", "", true);
	indicator.parameters:addBoolean("ShowCross", "Show Cross", "", true);
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "1. Line Color","", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width1","Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addColor("color2", "2. Line Color","", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width2","Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addGroup("Candle Style");
	indicator.parameters:addColor("Down", "Up Trend Color","Up Trend Color", core.rgb(0,255,0));
	indicator.parameters:addColor("Up", "Down Trend Color","Down Trend Color", core.rgb(255,0,0));
	indicator.parameters:addColor("Neutral", "Neutral Trend Color","Neutral Trend Color", core.rgb(128,128,128));
	indicator.parameters:addInteger("Size", "Font Size","",10);
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
 

local first;
local source = nil;
local  SlowLength, SlowPipDisplace,FastLength,FastPipDisplace;
local ShowCandles;

-- Streams block
local Line1, Line2 = nil;
local Trend;

local open=nil;
local close=nil;
local high=nil;
local low=nil;
local Up, Down;--, Neutral;
local Cross,ShowCross;

local Size, cross_up, cross_down;
-- Routine
function Prepare(nameOnly) 
     
   
    SlowLength= instance.parameters.SlowLength;
	SlowPipDisplace= instance.parameters.SlowPipDisplace;
	FastLength= instance.parameters.FastLength;
	FastPipDisplace= instance.parameters.FastPipDisplace;
	ShowCandles= instance.parameters.ShowCandles;
	Size= instance.parameters.Size;
	ShowCross= instance.parameters.ShowCross;
	
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	Neutral = instance.parameters.Neutral; 
	
    source = instance.source;
    first = source:first()+math.max(SlowLength, FastLength);

    local name = profile:id() .. "(" .. source:name() .. ", " .. SlowLength .. ", " .. FastLength.. ")";
    instance:name(name); 
	
	if   (nameOnly) then
        return;
    end
	
	Trend = instance:addInternalStream(0, 0);
	Cross= instance:addInternalStream(0, 0);
	
	
    Line1 = instance:addStream("Line1", core.Line, name, "Line1", instance.parameters.color1, first);
    Line1:setWidth(instance.parameters.width1);
    Line1:setStyle(instance.parameters.style1);
	
	
	Line2 = instance:addStream("Line2", core.Line, name, "Line2", instance.parameters.color2, first);
    Line2:setWidth(instance.parameters.width2);
    Line2:setStyle(instance.parameters.style2);
	
	if ShowCandles then
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("ZONE", "", open, high, low, close);
	end
	
	if ShowCross then
	cross_up = instance:createTextOutput ("Cross_Up", "Cross Up", "Wingdings",  Size, core.H_Center, core.V_Center, Down, 0);
	cross_down = instance:createTextOutput ("Cross_Down", "Cross DOwn", "Wingdings",  Size, core.H_Center, core.V_Center, Up, 0);
    end
end
 
function Update(period)
    if period < first then
	return;
	end
	
	if ShowCandles then
	high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];
	end
	
	 local  pipMultiplier = source:pipSize()*math.pow(10,source:getPrecision()%2);
	 
	 local L1, H1= mathex.minmax(source, period -SlowLength +1 ,period); 
	 local L2, H2= mathex.minmax(source, period -FastLength +1 ,period); 
 
         local High1 = H1+ SlowPipDisplace*pipMultiplier;
         local Low1  = L1 - SlowPipDisplace*pipMultiplier;
         local High2 = H2 + FastPipDisplace*pipMultiplier;
         local Low2  = L2 - FastPipDisplace*pipMultiplier;
		 
            if   source.close[period]>Line1[period-1]  then
            Line1[period] = Low1;
            else 
			Line1[period] = High1; 
            end            
            if   source.close[period]>Line2[period-1]  then
            Line2[period] = Low2;
            else  
			Line2[period] = High2;   
	        end
			
			Cross[period]=Cross[period-1];
			Trend[period] =  0;
		
		       if (source.close[period]<Line1[period] and source.close[period]<Line2[period]) then
			   Trend[period] =  1;
			   end
               if (source.close[period]>Line1[period] and source.close[period]>Line2[period])  then
			   Trend[period] = -1; 
			   end
			   
			   
			   if ShowCandles then
               if (Trend[period]== 1) then 
			   open:setColor(period, Up);
               elseif (Trend[period]==-1)  then 
			   open:setColor(period, Down);
			   else 
			   open:setColor(period, Neutral);
			   end
			   end
			   
			   
			       Cross[period]= Cross[period-1];
				   
				   
				  if (Line1[period]>Line2[period] or Trend[period] ==  1)  then   Cross[period] =  1;  end
                 if (Line1[period]<Line2[period] or Trend[period] == -1)  then  Cross[period] = -1;  end
				  
				  
				
				if ShowCross and Cross[period] ~=Cross[period-1] then
						
						
						max=math.max(Line1[period], Line2[period]);
						min=math.min(Line1[period], Line2[period]);
						
						if Cross[period] == 1 then
						cross_down:set(period, max, "\108", max);		
                        cross_up:setNoData(period  );						
						elseif Cross[period] == -1 then
						cross_up:set(period, min, "\108", min); 
						cross_down:setNoData(period  );
						else
						cross_up:setNoData(period  );
						cross_down:setNoData(period  );
						end
				
				end
				
	 
end
 