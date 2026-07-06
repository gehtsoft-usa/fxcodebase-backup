
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59406

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
    indicator:name("Triple Extreme TMA line indicator");
    indicator:description("Extreme TMA line indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("TMA_Period", "TMA period", "", 56);
    indicator.parameters:addInteger("ATR_Period", "ATR period", "", 100);
    indicator.parameters:addDouble("ATR_Mult1", "1. ATR multiplier", "", 2);
	 indicator.parameters:addDouble("ATR_Mult2", "2. ATR multiplier", "", 4);
	  indicator.parameters:addDouble("ATR_Mult3", "3. ATR multiplier", "", 6);
    indicator.parameters:addDouble("TrendThreshold", "TrendThreshold", "", 0.5);
    indicator.parameters:addBoolean("ShowTMA", "Show TMA", "", true);
    indicator.parameters:addBoolean("Redraw", "Redraw", "", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("TMA_NEclr", "TMA neutral Color", "TMA neutral Color", core.rgb(128, 128, 128));
    indicator.parameters:addColor("TMA_UPclr", "TMA UP Color", "TMA UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("TMA_DNclr", "TMA DN Color", "TMA DN Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("TMAwidth", "TMA width", "TMA width", 2, 1, 5);
    indicator.parameters:addInteger("TMAstyle", "TMA style", "TMA style", core.LINE_SOLID);
    indicator.parameters:setFlag("TMAstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Bandclr1", "1. Band Color", "Band Color", core.rgb(128, 128, 0));
	indicator.parameters:addColor("Bandclr2", "2. Band Color", "Band Color", core.rgb(128, 128, 0));
	indicator.parameters:addColor("Bandclr3", "3. Band Color", "Band Color", core.rgb(128, 128, 0));
    indicator.parameters:addInteger("Bandwidth", "Band width", "Band width", 1, 1, 5);
    indicator.parameters:addInteger("Bandstyle", "Band style", "Band style", core.LINE_DASH);
    indicator.parameters:setFlag("Bandstyle", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local TMA_Period;
local ATR_Period;
local ATR_Mult1, ATR_Mult2, ATR_Mult3;
local TrendThreshold;
local ShowTMA;
local Redraw;
local TMA=nil;
local ATR;
local Upper1=nil;
local Lower1=nil;
local Upper2=nil;
local Lower2=nil;
local Upper3=nil;
local Lower3=nil;

function Prepare(nameOnly)
    source = instance.source;
    TMA_Period=instance.parameters.TMA_Period;
    ATR_Period=instance.parameters.ATR_Period;
    ATR_Mult1=instance.parameters.ATR_Mult1;
	ATR_Mult2=instance.parameters.ATR_Mult2;
	ATR_Mult3=instance.parameters.ATR_Mult3;
    TrendThreshold=instance.parameters.TrendThreshold;
    ShowTMA=instance.parameters.ShowTMA;
    Redraw=instance.parameters.Redraw;
   
    ATR=core.indicators:create("ATR", source, ATR_Period);
	first = math.max(source:first()+TMA_Period+1,ATR.DATA:first()) ;	
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.TMA_Period .. ", " .. instance.parameters.ATR_Period .. ", " .. instance.parameters.ATR_Mult1 .. ", " .. instance.parameters.ATR_Mult2 .. ", " .. instance.parameters.ATR_Mult3 .. ", " .. instance.parameters.TrendThreshold .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    if ShowTMA then
     TMA = instance:addStream("TMA", core.Line, name .. ".TMA", "TMA", instance.parameters.TMA_NEclr, first);
    else
     TMA = instance:addInternalStream(first, 0);
    end 
   
    TMA:setWidth(instance.parameters.TMAwidth);
    TMA:setStyle(instance.parameters.TMAstyle);
	
	Upper1 = instance:addStream("Upper1", core.Line, name .. "1. Upper", "1. Upper", instance.parameters.Bandclr1, first);
    Lower1 = instance:addStream("Lower1", core.Line, name .. "1. Lower", "1. Lower", instance.parameters.Bandclr1, first);
    Upper1:setWidth(instance.parameters.Bandwidth);
    Upper1:setStyle(instance.parameters.Bandstyle);
    Lower1:setWidth(instance.parameters.Bandwidth);
    Lower1:setStyle(instance.parameters.Bandstyle);
	
	Upper2 = instance:addStream("Upper2", core.Line, name .. "2. Upper", "2. Upper", instance.parameters.Bandclr2, first);
    Lower2 = instance:addStream("Lower2", core.Line, name .. "2. Lower", "2. Lower", instance.parameters.Bandclr2, first);
    Upper2:setWidth(instance.parameters.Bandwidth);
    Upper2:setStyle(instance.parameters.Bandstyle);
    Lower2:setWidth(instance.parameters.Bandwidth);
    Lower2:setStyle(instance.parameters.Bandstyle);
	
	Upper3 = instance:addStream("Upper3", core.Line, name .. "3. Upper", "3. Upper", instance.parameters.Bandclr3, first);
    Lower3 = instance:addStream("Lower3", core.Line, name .. "3. Lower", "3. Lower", instance.parameters.Bandclr3, first);
    Upper3:setWidth(instance.parameters.Bandwidth);
    Upper3:setStyle(instance.parameters.Bandstyle);
    Lower3:setWidth(instance.parameters.Bandwidth);
    Lower3:setStyle(instance.parameters.Bandstyle);
end

function Update(period, mode)


    ATR:update(mode);
	
   if (period<first) then
   return;
   end
   
   
    local i;
    local ii=TMA_Period;
    local LastPeriod;
    if period==source:size()-1 then
     LastPeriod=true;
    else
     LastPeriod=false;
    end
    while ii>0 do
    if not(LastPeriod) then
     ii=0;
    else
     ii=ii-1; 
    end
    local Sum=0;
    local SumW=(TMA_Period+2)*(TMA_Period+1)/2;
    for i=0,TMA_Period,1 do
     Sum=Sum+(TMA_Period-i+1)*source.close[period-i];
     if Redraw then
      if i<=source:size()-1-period and i>0 then
       Sum=Sum+(TMA_Period-i+1)*source.close[period+i];
       SumW=SumW+(TMA_Period-i+1);
      end
     end 
    end
    TMA[period]=Sum/SumW;
    local Slope=(TMA[period]-TMA[period-1])/(0.1*ATR.DATA[period]);
    if Slope>TrendThreshold then
     TMA:setColor(period,instance.parameters.TMA_UPclr);
    elseif Slope<-TrendThreshold then
     TMA:setColor(period,instance.parameters.TMA_DNclr);
    else
     TMA:setColor(period,instance.parameters.TMA_NEclr);
    end
    local range1=ATR.DATA[period]*ATR_Mult1;
	local range2=ATR.DATA[period]*ATR_Mult2;
	local range3=ATR.DATA[period]*ATR_Mult3;
    Upper1[period]=TMA[period]+range1;
    Lower1[period]=TMA[period]-range1;
	
	Upper2[period]=TMA[period]+range2;
    Lower2[period]=TMA[period]-range2;
	
	Upper3[period]=TMA[period]+range3;
    Lower3[period]=TMA[period]-range3;
	
    period=period-1;
   end 
  
end

