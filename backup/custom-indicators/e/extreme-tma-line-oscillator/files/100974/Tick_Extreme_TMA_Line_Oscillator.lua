-- Id: 14316

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62321

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
    indicator:name("Extreme TMA line indicator");
    indicator:description("Extreme TMA line indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("TMA_Period", "TMA period", "", 56);
    indicator.parameters:addInteger("ATR_Period", "ATR period", "", 100);
    indicator.parameters:addDouble("ATR_Mult", "ATR multiplier", "", 2);
    indicator.parameters:addDouble("TrendThreshold", "TrendThreshold", "", 0.5);
    indicator.parameters:addBoolean("Redraw", "Redraw", "", true);
	
	indicator.parameters:addString("Method", "Calculation Method", "Method" , "Absolute");
    indicator.parameters:addStringAlternative("Method", "Absolute", "Absolute" , "Absolute");
    indicator.parameters:addStringAlternative("Method", "Relative", "Relative" , "Relative");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("TMA_NEclr", "TMA neutral Color", "TMA neutral Color", core.rgb(128, 128, 128));
    indicator.parameters:addColor("TMA_UPclr", "TMA UP Color", "TMA UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("TMA_DNclr", "TMA DN Color", "TMA DN Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("TMAwidth", "TMA width", "TMA width", 2, 1, 5);
    indicator.parameters:addInteger("TMAstyle", "TMA style", "TMA style", core.LINE_SOLID);
    indicator.parameters:setFlag("TMAstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Bandclr", "Band Color", "Band Color", core.rgb(128, 128, 0));
    indicator.parameters:addInteger("Bandwidth", "Band width", "Band width", 1, 1, 5);
    indicator.parameters:addInteger("Bandstyle", "Band style", "Band style", core.LINE_DASH);
    indicator.parameters:setFlag("Bandstyle", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local TMA_Period;
local ATR_Period;
local ATR_Mult;
local TrendThreshold;
local Redraw;
local TMA=nil;
local ATR;
local Upper=nil;
local Lower=nil;
local Method;
local Oscillator;

function Prepare(nameOnly)
    source = instance.source;
	Method=instance.parameters.Method;
    TMA_Period=instance.parameters.TMA_Period;
    ATR_Period=instance.parameters.ATR_Period;
    ATR_Mult=instance.parameters.ATR_Mult;
    TrendThreshold=instance.parameters.TrendThreshold;
    Redraw=instance.parameters.Redraw;
    first = source:first()+2*TMA_Period;
	
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.TMA_Period .. ", " .. instance.parameters.ATR_Period .. ", " .. instance.parameters.ATR_Mult .. ", " .. instance.parameters.TrendThreshold .. ")";
    instance:name(name);   
	
	if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator("TATR") ~= nil, "Please, download and install TATR.LUA indicator");
    ATR=core.indicators:create("TATR", source, ATR_Period);
	
	Oscillator = instance:addStream("Oscillator", core.Bar, name .. ".Oscillator", "Oscillator", instance.parameters.TMA_NEclr, first);  
    TMA = instance:addInternalStream(0, 0);	
	
    Upper = instance:addStream("Upper", core.Line, name .. ".Upper", "Upper", instance.parameters.Bandclr, first);
    Lower = instance:addStream("Lower", core.Line, name .. ".Lower", "Lower", instance.parameters.Bandclr, first);
    TMA:setWidth(instance.parameters.TMAwidth);
    TMA:setStyle(instance.parameters.TMAstyle);
    Upper:setWidth(instance.parameters.Bandwidth);
    Upper:setStyle(instance.parameters.Bandstyle);
    Lower:setWidth(instance.parameters.Bandwidth);
    Lower:setStyle(instance.parameters.Bandstyle);
	
	Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
	Upper:setPrecision(math.max(2, instance.source:getPrecision()));
	Lower:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if (period <first) then
   return;
   end
   
    ATR:update(mode);
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
     Sum=Sum+(TMA_Period-i+1)*source[period-i];
     if Redraw then
      if i<=source:size()-1-period and i>0 then
       Sum=Sum+(TMA_Period-i+1)*source[period+i];
       SumW=SumW+(TMA_Period-i+1);
      end
     end 
    end
    TMA[period]=Sum/SumW;
    local Slope=(TMA[period]-TMA[period-1])/(0.1*ATR.DATA[period]);
    if Slope>TrendThreshold then
     Oscillator:setColor(period,instance.parameters.TMA_UPclr);
    elseif Slope<-TrendThreshold then
     Oscillator:setColor(period,instance.parameters.TMA_DNclr);
    else
     Oscillator:setColor(period,instance.parameters.TMA_NEclr);
    end
    local range=ATR.DATA[period]*ATR_Mult;
  
     if Method == "Absolute" then
	Oscillator[period]=source[period]-TMA[period];
	Upper[period]=range;
    Lower[period]=-range;
	else
	Oscillator[period]=(source[period]-TMA[period]) / (range/100);
	Upper[period]=100
    Lower[period]=-100;
	end
	
    period=period-1;
	
  
    period=period-1;
   end 
 
end

