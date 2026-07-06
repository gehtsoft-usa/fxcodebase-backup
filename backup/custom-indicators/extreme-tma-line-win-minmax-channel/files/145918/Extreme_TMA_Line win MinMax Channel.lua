-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/posting.php?mode=post&f=17

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--Your donations will allow the service to continue onward.
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+
 
function Init()
    indicator:name("Extreme TMA line indicator");
    indicator:description("Extreme TMA line indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
    indicator.parameters:addGroup("Selector");
    indicator.parameters:addBoolean("ShowTMA", "Show TMA", "", true);	
    indicator.parameters:addBoolean("ShowChannel", "Show ShowChannel", "", true);		
    indicator.parameters:addBoolean("ShowMinMax", "Show MinMax", "", true);	 

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("TMA_Period", "TMA period", "", 56);
    indicator.parameters:addInteger("MinMax_Period", "Min/Max TMA period", "", 100);	
	
    indicator.parameters:addInteger("ATR_Period", "ATR period", "", 100);
    indicator.parameters:addDouble("ATR_Mult", "ATR multiplier", "", 2);
    indicator.parameters:addDouble("TrendThreshold", "TrendThreshold", "", 0.5);

    indicator.parameters:addBoolean("Redraw", "Redraw", "", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("TMA_NEclr", "TMA neutral Color", "TMA neutral Color", core.rgb(128, 128, 128));
    indicator.parameters:addColor("TMA_UPclr", "TMA UP Color", "TMA UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("TMA_DNclr", "TMA DN Color", "TMA DN Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("TMAwidth", "TMA width", "TMA width", 2, 1, 5);
    indicator.parameters:addInteger("TMAstyle", "TMA style", "TMA style", core.LINE_SOLID);
    indicator.parameters:setFlag("TMAstyle", core.FLAG_LINE_STYLE);
	
	
    indicator.parameters:addGroup("Channel Style");	
    indicator.parameters:addColor("Bandclr", "Band Color", "Band Color", core.rgb(128, 128, 0));
    indicator.parameters:addInteger("Bandwidth", "Band width", "Band width", 1, 1, 5);
    indicator.parameters:addInteger("Bandstyle", "Band style", "Band style", core.LINE_DASH);
    indicator.parameters:setFlag("Bandstyle", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addGroup("Min/Max Channel Style");	
    indicator.parameters:addColor("MinMaxclr", "Band Color", "Band Color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("MinMaxBandwidth", "Band width", "Band width", 1, 1, 5);
    indicator.parameters:addInteger("MinMaxBandstyle", "Band style", "Band style", core.LINE_DASH);
    indicator.parameters:setFlag("MinMaxBandstyle", core.FLAG_LINE_STYLE);
	
end

local first;
local source = nil;
local TMA_Period;
local ATR_Period;
local ATR_Mult;
local TrendThreshold;
local ShowTMA;
local Redraw;
local TMA=nil;
local ATR;
local Upper=nil;
local Lower=nil;
local ShowMinMax,ShowChannel;
local MinMax_Period;
function Prepare(nameOnly)
    source = instance.source;
    TMA_Period=instance.parameters.TMA_Period;
    ATR_Period=instance.parameters.ATR_Period;
    ATR_Mult=instance.parameters.ATR_Mult;
    TrendThreshold=instance.parameters.TrendThreshold;
    ShowTMA=instance.parameters.ShowTMA;
    Redraw=instance.parameters.Redraw;
	ShowMinMax=instance.parameters.ShowMinMax;
	ShowChannel=instance.parameters.ShowChannel;
	MinMax_Period=instance.parameters.MinMax_Period;
   
    ATR=core.indicators:create("ATR", source, ATR_Period);
	first = math.max(source:first()+TMA_Period+1,ATR.DATA:first()) ;	
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.TMA_Period .. ", " .. instance.parameters.ATR_Period .. ", " .. instance.parameters.ATR_Mult .. ", " .. instance.parameters.TrendThreshold .. ")";
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
	
	
	if ShowMinMax then
	Max = instance:addStream("MAX", core.Line, name .. ".Max", "Max", instance.parameters.MinMaxclr, first);
    Min = instance:addStream("MIN", core.Line, name .. ".Min", "Min", instance.parameters.MinMaxclr, first);	
    Max:setWidth(instance.parameters.MinMaxBandwidth);
    Max:setStyle(instance.parameters.MinMaxBandstyle);
    Min:setWidth(instance.parameters.MinMaxBandwidth);
    Min:setStyle(instance.parameters.MinMaxBandstyle);	
	else
	Max = instance:addInternalStream(0, 0);
	Min = instance:addInternalStream(0, 0);		
	end
	
	
	if ShowChannel then  
	Upper = instance:addStream("Upper", core.Line, name .. ".Upper", "Upper", instance.parameters.Bandclr, first);
    Lower = instance:addStream("Lower", core.Line, name .. ".Lower", "Lower", instance.parameters.Bandclr, first);	
    Upper:setWidth(instance.parameters.Bandwidth);
    Upper:setStyle(instance.parameters.Bandstyle);
    Lower:setWidth(instance.parameters.Bandwidth);
    Lower:setStyle(instance.parameters.Bandstyle);
	else
	Upper = instance:addInternalStream(0, 0);
	Lower = instance:addInternalStream(0, 0);	
    end	
	
end

function Update(period, mode)


    ATR:update(mode);
	
   if (period<=first) then
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
    local range=ATR.DATA[period]*ATR_Mult;
    Upper[period]=TMA[period]+range;
    Lower[period]=TMA[period]-range;
    period=period-1;
   end 
   

   
	
	if period <= first + MinMax_Period then
	return;
	end
	
	
	min,max=mathex.minmax(TMA, period-MinMax_Period+1, period);
	Min[period]=min;
	Max[period]=max;	
  
end

