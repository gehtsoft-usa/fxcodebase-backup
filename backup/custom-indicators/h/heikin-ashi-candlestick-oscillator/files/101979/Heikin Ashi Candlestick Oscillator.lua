-- Id: 14709
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62585

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
    indicator:name("Heikin Ashi Candlestick Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("Period1", "Up TEMA Average Period", "", 34, 2, 1000);
	indicator.parameters:addInteger("Period2", "Down TEMA Average Period", "", 34, 2, 1000);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color", "Line Color", "", core.rgb(0, 255, 255));
 
end

 
local source;
local first;
local haOpen,haC;
local Period1, Period2;
local Color;
local Oscillator;
local TMA1,TMA2;
local TMA3,TMA4;
local keepall1;
local keeping1; 
local keepall2;
local keeping2; 
local dtr,utr;
local TMA11, TMA12, TMA13, TMA14;
function Prepare(onlyName)
    source = instance.source;
    first = source:first()+1;  
    local name;
    Period1 = instance.parameters.Period1;
    Period2 = instance.parameters.Period2;
	Color = instance.parameters.Color;
    name = profile:id() .. "(" .. source:name() .. "," .. Period1 .. "," .. Period2 .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end
	
	haOpen = instance:addInternalStream(first, 0);
    haC = instance:addInternalStream(first, 0);
	
	keepall1 = instance:addInternalStream(first, 0);
	keeping1= instance:addInternalStream(first, 0);
	
	keepall2 = instance:addInternalStream(first, 0);
	keeping2= instance:addInternalStream(first, 0);
	
	utr= instance:addInternalStream(first, 0);
	dtr= instance:addInternalStream(first, 0);
    
    TMA1 = core.indicators:create("TMA", haC, Period1); 
	TMA2 = core.indicators:create("TMA", TMA1.DATA, Period1); 
	
	TMA3 = core.indicators:create("TMA", source.median, Period1); 
	TMA4 = core.indicators:create("TMA", TMA3.DATA, Period1); 
	
	
	TMA11 = core.indicators:create("TMA", haC, Period2); 
	TMA12 = core.indicators:create("TMA", TMA11.DATA, Period2); 
	
	TMA13 = core.indicators:create("TMA", source.median, Period2); 
	TMA14 = core.indicators:create("TMA", TMA13.DATA, Period2); 
	
	
    Oscillator = instance:addStream("Oscillator", core.Line, name, "Oscillator", Color, TMA14.DATA:first());
    Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
     
 
 
     
    
    
end

function Update(period, mode)
     
 
    if period <= first then
	return;
	end
 
	haOpen[period]=((source.open[period-1]+source.high[period-1]+source.low[period-1]+source.close[period-1])/4 + haOpen[period-1])/2;
    haC[period]=((source.open[period]+source.high[period]+source.low[period]+source.close[period])/4+haOpen[period]+math.max(source.high[period],haOpen[period])+math.min(source.low[period],haOpen[period]))/4;
   
   TMA1:update(mode);
   TMA2:update(mode);
   
   
   
   if period < TMA2.DATA:first() then
   return;
   end
   
   local Diff= TMA1.DATA[period] - TMA2.DATA[period];
   local ZlHa= TMA1.DATA[period] + Diff;
   
   
   
   TMA3:update(mode);
   TMA4:update(mode);
   
    if period < TMA4.DATA:first() then
   return;
   end
 
   local Diff= TMA3.DATA[period] - TMA4.DATA[period];
   local ZlCl= TMA3.DATA[period] + Diff;
   local ZlDif=ZlCl-ZlHa;

  local keep1;
  if haC[period]>=haOpen[period] 
  or haC[period-1]>=haOpen[period-1] 
  then
  keep1=true;
  else
  keep1=false;
  end

  local keep2;
  if ZlDif>=0 then
  keep2=true;
  else
  keep2=false;
  end
 
  
  if (keep1 or keep2)then
  keeping1[period]= 1;
  else
  keeping1[period]= 0;
  end
  
   
  if keeping1[period] == 1 or   keeping1[period-1] == 1 and source.close[period]>=source.open[period] or source.close[period]>=source.close[period-1] then
  keepall1[period]=1;
  else
  keepall1[period]=0;
  end
  
  local keep3;
  if math.abs(source.close[period]-source.open[period])<(source.high[period]-source.low[period])*0.35 and source.high[period]>= source.low[period-1] then
  keep3=true;
  else
  keep3=false;
  end
    
 
  if keepall1[period] == 1  or keepall1[period-1] == 1 and keep3 then
  utr[period]=1;
  else
  utr[period]=0;
  end
  
  
  TMA11:update(mode);
  TMA12:update(mode);
  
  if period < TMA12.DATA:first() then
  return;
  end
  
  
  local Diff= TMA11.DATA[period] - TMA12.DATA[period];
   local ZlHa= TMA11.DATA[period] + Diff;
   
   
   
   TMA13:update(mode);
   TMA14:update(mode);
   
    if period < TMA14.DATA:first() then
   return;
   end
 
   local Diff= TMA13.DATA[period] - TMA14.DATA[period];
   local ZlCl= TMA13.DATA[period] + Diff;
   local ZlDif=ZlCl-ZlHa;
  
  
  local keep1;
  if haC[period]<haOpen[period] 
  or haC[period-1]<haOpen[period-1] 
  then
  keep1=true;
  else
  keep1=false;
  end
  
  local keep2;
  if ZlDif< 0 then
  keep2=true;
  else
  keep2=false;
  end
  
 
  
    local keep3;
  if math.abs(source.close[period]-source.open[period])<(source.high[period]-source.low[period])*0.35 and source.low[period]<= source.high[period-1] then
  keep3=true;
  else
  keep3=false;
  end
  
  if keep1 or keep2 then
  keeping2[period]=1;
  else
  keeping2[period]=0;
  end
  
   
  
  if keeping2[period]== 1  or keeping2[period-1]== 1 and source.close[period]<source.open[period] or source.close[period]< source.close[period-1] then
  keepall2[period]=1;
  else
   keepall2[period]=0;
  end

  
  if keepall2[period]== 1 or keepall2[period-1]==1 and keep3 then
  dtr[period]=1;
  else
  dtr[period]=0;
  end  
    
  
  local upw;
  if dtr[period]==0 and dtr[period-1]==1 and utr[period]==1 then
  upw= 1;
  else
  upw= 0;
  end
  
  local dnw;
  if utr[period]==0 and utr[period-1]== 1 and dtr[period]==1 then
  dnw=1;
  else
  dnw=0;
  end
  
  if upw== 1  then 
  Oscillator[period]=1;
  elseif dnw== 1 then
  Oscillator[period]=0;
  else
  Oscillator[period]=Oscillator[period-1];
  end
  
end


 