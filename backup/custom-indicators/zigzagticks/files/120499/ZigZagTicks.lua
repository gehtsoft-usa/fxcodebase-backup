-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66489

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

function Init()
    indicator:name("ZigZag Ticks");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("1. MA Calculation"); 
    indicator.parameters:addDouble("NumberOfTicks", "NumberOfTicks", "", 200);
 
	 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local NumberOfTicks; 
local first;
local source = nil;
local Point; 
local ZigZag;  
local LastLow, LastHigh, Temp; 
local CurrentTrend, flat;
local LastPeriod;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
  
    NumberOfTicks = instance.parameters.NumberOfTicks;
			
    source = instance.source;  
	first=source:first();
	
	Point=source:pipSize();
	
	 if NumberOfTicks < 2 then
	 error( "Number of Ticks must be greater than 1, Default used!");
	 NumberOfTicks=200;
     end
	 
	 LastLow = instance:addInternalStream(0, 0);
	 LastHigh = instance:addInternalStream(0, 0);
	 Temp = instance:addInternalStream(0, 0);
	 
	 CurrentTrend= instance:addInternalStream(0, 0);
	 
   
 
	ZigZag = instance:addStream("ZigZag" , core.Line, " ZigZag"," ZigZag",instance.parameters.color, first);
	ZigZag:setWidth(instance.parameters.width);
    ZigZag:setStyle(instance.parameters.style);
    
	
	
end

-- Indicator calculation routine
function Update(period)

  
    if period <= first then
	CurrentTrend[period] =1;
	return;
	end
	
	
	CurrentTrend[period]=CurrentTrend[period-1];
	
 
 
	
	if (CurrentTrend[period]  > 0) then
 
		if (source.high[period] >= LastHigh[period-1])  then
		 
		LastHigh[period] = source.high[period];
		Temp[period] = source.high[period]; 
		elseif (source.low[period] <= (LastHigh[period-1] -Point*NumberOfTicks))   then
		
		LastLow[period] = source.low[period];
		LastHigh[period] = source.low[period];
		Temp[period] = source.low[period];
		CurrentTrend[period]  = -1; 
        else LastHigh[period] = LastHigh[period-1];
		Temp[period] = LastHigh[period-1]; 
		end
 
else 
 
		if (source.low[period] <= LastLow[period-1])   then 
		LastLow[period] = source.low[period];
		Temp[period] = source.low[period];
	 
		elseif (source.high[period] >= (LastLow[period-1] + Point*NumberOfTicks))  then
		 
		LastHigh[period] = source.high[period];
		LastLow[period] = source.high[period];
		Temp[period] = source.high[period];
		CurrentTrend[period] = 1;
		 
	 
		else LastLow[period] = LastLow[period-1]; 
		Temp[period] = LastLow[period];
		 
		end
end
		
	  	
 
	  
	   
	   x1,x2=FindLast(period);
	   if x1== nil or  x2== nil then
	   return;
	   end
	   
	   LastPeriod=x2;
	   
	   if CurrentTrend[x1] == -1 then
	   core.drawLine(ZigZag, core.range(x1, x2), LastLow[x1], x1, LastHigh[x2], x2, instance.parameters.color);
	   else
	   core.drawLine(ZigZag, core.range(x1, x2), LastHigh[x1], x1, LastLow[x2], x2, instance.parameters.color);
	   end
	 
	 
	 
	 if period == source:size()-1 then
	 
	 
	   x1= LastPeriod;
	   x2= source:size()-1;
	   
	   if CurrentTrend[x1] == -1 then
	   core.drawLine(ZigZag, core.range(x1, x2), LastLow[x1], x1, LastHigh[x2], x2, instance.parameters.color);
	   else
	   core.drawLine(ZigZag, core.range(x1, x2), LastHigh[x1], x1, LastLow[x2], x2, instance.parameters.color);
	   end
	   
	 end
				  
end

function FindLast(period)

  local Return={};
  local Count =0;
  
  for i = period, first, -1 do
  
		  if (CurrentTrend[i]~= CurrentTrend[i-1])  then
		  Count=Count+1;
		  Return[Count]=i-1;
		  
			  if Count== 2 then
			  break;
			  end
		  
		  end
  end
  
  
  return Return[2],Return[1];
  
end 

--[[

#property description "Price ZigZag indicator based on a Tick size"
#property description "input value. Aid for waves counting 2018 V1.3"
#property description "ATTENTION!"
#property description "Last section only drawn after current reversal"
#property strict
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Goldenrod
#property indicator_width1 2
#property indicator_style1 STYLE_SOLID
extern int NumberOfTicks = 200; // Reversal Number of Ticks
int CurrentTrend, flat;
//--------buffers
double LastLow [];
double LastHigh [];
double ZZTemp [];
double ZigZagFinal[];
//+------------------------------------------------------------------+
//| SveHLZigZagTicks indicator initialization function |
//+------------------------------------------------------------------+
int OnInit(void)
{
IndicatorBuffers(4);
SetIndexBuffer (0,ZigZagFinal);
SetIndexStyle (0,DRAW_SECTION);
SetIndexBuffer (1,ZZTemp);
SetIndexStyle (1,DRAW_NONE);
SetIndexBuffer (2,LastHigh);
SetIndexStyle (2,DRAW_NONE);
SetIndexBuffer (3,LastLow);
SetIndexStyle (3,DRAW_NONE);
//---- name for data Window and indicator subwindow label
string StrNumberOfTicks = IntegerToString(NumberOfTicks);
IndicatorShortName("SveHLZigZagTicks ("+StrNumberOfTicks+")");
// Check validity of the inputs
if(NumberOfTicks < 2)
{
Alert("Number of Ticks must be > 1, Default used!");
NumberOfTicks = 200;
}
CurrentTrend = 1; // just start assuming trend is up
//---- Init done
return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| SveHLZigZagTicks indicator iteration function |
//+------------------------------------------------------------------+
int OnCalculate (const int rates_total,
const int prev_calculated,
const datetime& time[],
const double& open[],
const double& high[],
const double& low[],
const double& close[],
const long& tick_volume[],
const long& volume[],
const int& spread[])
{
//--- last counted bar will be recounted
int limit = rates_total - prev_calculated; // differenc already calculated
if (limit < 0) return(-1); // No bars return error.
if (prev_calculated>=0) limit--; // -1 start addressing from 0
// ----------
flat = 1;
for(int i=limit-2; i>=0 && !_StopFlag; i--)
{
if (CurrentTrend > 0) // trend is up, look for new swing high
{
if (high[i] >= LastHigh[i+1])
{ // found a higher high
LastHigh[i] = high[i];
ZZTemp[i] = high[i];
}
else if (low[i] <= (LastHigh[i+1] - Point*NumberOfTicks)) //
found a swing low
{
LastLow[i] = low[i];
LastHigh[i] = low[i];
ZZTemp[i] = low[i];
CurrentTrend = -1;
}
else LastHigh[i] = LastHigh[i+1]; ZZTemp[i] = LastHigh[i];
}
else // dir < 0, trend is down, look for new swing high
{
if (low[i] <= LastLow[i+1]) // found a lower low
{
LastLow[i] = low[i];
ZZTemp[i] = low[i];
}
else if (high[i] >= (LastLow[i+1] + Point*NumberOfTicks)) //
found a swing high
{
LastHigh[i] = high[i];
LastLow[i] = high[i];
ZZTemp[i] = high[i];
CurrentTrend = 1;
}
else LastLow[i] = LastLow[i+1]; ZZTemp[i] = LastLow[i];
}
ZigZagFinal[i] = EMPTY_VALUE;
if (ZZTemp[i+flat] < ZZTemp[i+flat+1] && ZZTemp[i] > ZZTemp[i+1])
ZigZagFinal[i+flat] = low[i+flat];
else if (ZZTemp[i+flat] > ZZTemp[i+flat+1] && ZZTemp[i] < ZZTemp[i+1])
ZigZagFinal[i+flat] = high[i+flat];
if (ZZTemp[i] == ZZTemp[i+1]) flat = flat+1;
else flat = 1;
}
//----
return(rates_total);
}
//+-------------------------------------END OF PROGRAM---------------------------+
]]