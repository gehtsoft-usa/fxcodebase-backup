-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65833

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
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine

function Init()
    indicator:name("Trend Signal");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("RISK", "Risk", "", 3);
    indicator.parameters:addInteger("SSP", "SSP", "", 9);
 
	indicator.parameters:addBoolean("SignalMode" , "Signal Mode", "", false);	
 
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0)); 
    indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addInteger("Size", "Size", "", 9);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local RISK, SSP ; 
local K;
local Range;
local Trend;
local Up, Down,Size;
local first;
local source = nil;
 
local Oscillator;  
local Indicator={};
local up, down;
local Line;
local SignalMode, Signal;

-- Routine
 function Prepare(nameOnly)   
 
    RISK= instance.parameters.RISK;
	SSP= instance.parameters.SSP; 
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	Size= instance.parameters.Size;
	
	SignalMode= instance.parameters.SignalMode;
	
 
    local name = profile:id() .. "(" ..  instance.source:name() .. ", " ..  RISK .. ", " ..  SSP .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	if not SignalMode then
	up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, Up, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, Down, 0);
	end
	
	 Range = instance:addInternalStream(0, 0);
	 Trend = instance:addInternalStream(0, 0);
	 K=33-RISK;

   
    source = instance.source;     
    first= source:first()+SSP;
	
	

	
	if SignalMode then
	Signal = instance:addStream("Signal", core.Bar, name .. ".Signal", "Signal", instance.parameters.color, first);
	Line= instance:addInternalStream(0, 0);
	else
	Signal= instance:addInternalStream(0, 0);
	
	Line = instance:addStream("Line", core.Line, name .. ".Line", "Line", instance.parameters.color, first);
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
	
	end
	
end

-- Indicator calculation routine
function Update(period, mode)

    Range[period]= source.high[period]-source.low[period];
  
    if period < first then
	return;
	end
	if not SignalMode then
	 up:setNoData(period);
	 down:setNoData(period);
	 else
	Signal[period]=0;
	end
	
	local AvgRange=mathex.avg(Range, period-SSP+1, period);
	local SsMin, SsMax=mathex.minmax(source, period-SSP+1, period);
	
	local  smin = SsMin+(SsMax-SsMin)*K/100;
    local  smax = SsMax-(SsMax-SsMin)*K/100;	
	
	  if(source.close[period]<smin) then       
         Trend[period]=-1;
   
	  
      elseif(source.close[period]>smax) then        
         Trend[period]=1;
       else
	   
	   Trend[period]=Trend[period-1];
	   
	   end
		
	 
	  if( Trend[period]~=  Trend[period-1] and Trend[period]==1) then       
        Value=source.low[period]-Range[period]*0.5;
		if not SignalMode then
		up:set(period, Value, "\217", Value);
		else
		Signal[period]=1;
		end
      end

      if( Trend[period]~=  Trend[period-1] and Trend[period]==-1) then
         Value=source.high[period]+Range[period]*0.5;	
         if not SignalMode then		 
		 down:set(period , Value, "\218", Value);
		 else
		 Signal[period]=-1;
		 end
      end
	  
	  
	
	  period=period-1;
	  
	  if( Trend[period]~=  Trend[period-1]  ) then
	  
	  local  Last, Price1,Price2 = Get(period);
	  
	  
	  if Last~= nil then
	   core.drawLine(Line, core.range(Last, period), Price1, Last, Price2, period, instance.parameters.color, first);
	   end
  
      end	  
	  
	  
	 	  
end

function  Get(period)

  local Price1, Price2;
  local Last=nil;
  
  for i= period-1, first, -1 do
  
	  Last=i;
	  if Trend[i]~=  Trend[i-1] then  
	  break;
	  end
	  
	  
  
  end
  
  
  if Trend[Last] == 1 then
  Price1=source.low[Last];  
  else
   Price1=source.high[Last];  
  end
  
  
    
  if Trend[period] == 1 then
  Price2=source.low[period];  
  else
   Price2=source.high[period];  
  end
  
  
  return Last,  Price1, Price2;
  
end